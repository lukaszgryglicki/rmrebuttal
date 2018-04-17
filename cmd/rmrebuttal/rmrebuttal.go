package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
	"regexp"
	"strconv"
	"strings"
	"time"
)

// Get cols from results/prefix_top_I.csv files I={n1, n2, ..., nN} and save to ofn.
// Prefix is the project name, like kubernetes, prometheus ... it is taken from PG_DB env variable
func mergeCSVs(stat, cols, ns, rowRegexp, ofn string) error {
	// Static columns, they are not dependent on N
	// Static columns are from the left.
	nStatic, err := strconv.Atoi(stat)
	if err != nil {
		return err
	}

	// Debug/verbose mode
	debug := os.Getenv("DEBUG") != ""

	// Get filename prefix
	prefix := os.Getenv("PG_DB")
	if prefix == "" || prefix == "gha" {
		prefix = "kubernetes"
	}

	// Row regexp handle
	ary := strings.Split(rowRegexp, ";;;")
	lAry := len(ary)
	if lAry > 2 || (lAry == 1 && rowRegexp != "") {
		return fmt.Errorf("'%s' should be einter empty or in 'colname;;;regexp' format", rowRegexp)
	}
	var (
		reColumn  *string
		colRegexp *regexp.Regexp
	)
	if lAry == 2 {
		if ary[0] != "" && ary[1] != "" {
			colRegexp = regexp.MustCompile(ary[1])
			reColumn = &ary[0]
		}
	}

	// column names set
	colsMap := make(map[string]struct{})
	// Column number - to be able to detect if this is a static column
	colNum := make(map[string]int)
	colsAry := strings.Split(cols, ";")
	for i, col := range colsAry {
		if col == "" {
			return fmt.Errorf("empty column definition in '%s'", cols)
		}
		colsMap[col] = struct{}{}
		colNum[col] = i
	}
	lColsAry := len(colsAry)

	// No dynamic columns
	if nStatic >= lColsAry {
		return fmt.Errorf("no dynamic columns, all columns: %d, static columns: %d", lColsAry, nStatic)
	}

	// n values set
	nMap := make(map[int]struct{})
	nAry := strings.Split(ns, ";")
	for _, col := range nAry {
		iCol, err := strconv.Atoi(col)
		if err != nil {
			return err
		}
		nMap[iCol] = struct{}{}
	}

	// Column name mappings, column types and formats
	// "colName1,newName1,type1,fmt1;,,,;colNameN,newNameN,typeN,fmtN"
	// colNameI - required, column name to apply mapping
	// newnameI - new name for column, optional, it can contain '%s' which will be replaced with N if column is dynamic
	// typeI - type of column (to apply format): can be n (numeric), d (datetime), optional
	// fmtI - format of column (if type given), can be Sprintf format for n, or date format for d, optional
	// fmtI for "n" (numeric) column can be for example "%.1f%%".
	// fmtI for "d" (datetime) column can be for example: "2012-11-01T22:08:41+00:00".
	// I = {1,2,...N}
	// Example: COLFMT="release,Release,,;date_from,Date,d,2012-11-01;top_commits_perc,Percent of top %s committers commits,n,%.1f%%"
	colNameMap := make(map[string]string)
	colFmtMap := make(map[string]func(string) string)
	colFmt := os.Getenv("COLFMT")
	if colFmt != "" {
		colFmtAry := strings.Split(colFmt, ";")
		for i, data := range colFmtAry {
			if data == "" {
				return fmt.Errorf("empty column format definition: '%s'", colFmt)
			}
			ary := strings.Split(data, ",")
			lAry := len(ary)
			if lAry != 4 {
				return fmt.Errorf("#%d column format must contain 4 values: '%s', all: '%s'", i, data, colFmt)
			}
			col := ary[0]
			if col == "" {
				return fmt.Errorf("#%d column format must contain column name: '%s', all: '%s'", i, data, colFmt)
			}
			applied := false
			if ary[1] != "" && ary[1] != col {
				colNameMap[col] = ary[1]
				applied = true
			}
			if ary[2] != "" && ary[3] != "" {
				typ := ary[2]
				form := ary[3]
				switch typ {
				case "n":
					colFmtMap[col] = func(in string) string {
						if in == "" {
							return ""
						}
						fl, err := strconv.ParseFloat(in, 64)
						if err != nil {
							fmt.Printf("Cannot parse number '%s'\n", in)
							return ""
						}
						if debug {
							fmt.Printf("n_func: form=%s in=%s, fl=%f, out=%s\n", form, in, fl, fmt.Sprintf(form, fl))
						}
						return fmt.Sprintf(form, fl)
					}
					applied = true
				case "d":
					colFmtMap[col] = func(in string) string {
						//tm, e := time.Parse("2006-01-02T15:04:05Z", in)
						tm, err := time.Parse(time.RFC3339, in)
						if err != nil {
							fmt.Printf("Cannot parse datetime '%s'\n", in)
							return ""
						}
						if debug {
							fmt.Printf("d_func: form=%s in=%s, tm=%v, out=%s\n", form, in, tm, tm.Format(form))
						}
						return tm.Format(form)
					}
					applied = true
				default:
					return fmt.Errorf("#%d column contains unknown type specification (allowed: n, d): '%s', all: '%s'", i, data, colFmt)
				}
			}
			if !applied {
				return fmt.Errorf("#%d column contains no usable transformation(s): '%s', all: '%s'", i, data, colFmt)
			}
		}
	}

	// main output: column name --> values
	// each column name ins "columnI J" I-th column and J-th N
	// First nStatic columns doesn not have N added.
	values := make(map[string][]string)
	nN := 0
	for n := range nMap {
		// Read Top N file (current n)
		ifn := fmt.Sprintf("results/%s_top_%d.csv", prefix, n)
		iFile, err := os.Open(ifn)
		if err != nil {
			return err
		}
		defer func() { _ = iFile.Close() }()
		reader := csv.NewReader(iFile)
		rows := 0
		// Will keep column name -> data index map
		colIndex := make(map[string]int)
		for {
			record, err := reader.Read()
			// No more rows
			if err == io.EOF {
				break
			} else if err != nil {
				return err
			}
			rows++
			// Get column -> data index map (from the header row)
			if rows == 1 {
				for i, col := range record {
					_, ok := colsMap[col]
					if ok {
						colIndex[col] = i
					}
				}
				// Check if all columns found
				for col := range colsMap {
					_, ok := colIndex[col]
					if !ok {
						return fmt.Errorf("column '%s' not found in data files", col)
					}
				}
				continue
			}
			// Handle filtering rows by row[reColumn] matching colRegexp
			if reColumn != nil && colRegexp != nil {
				cNum, ok := colNum[*reColumn]
				if !ok {
					return fmt.Errorf("regexp filtering column '%s' not found", *reColumn)
				}
				if cNum >= nStatic {
					return fmt.Errorf(
						"regexp filtering column '%s' is not static (there are %d static cols, this column is #%d)",
						*reColumn,
						nStatic,
						cNum+1,
					)
				}
				index, ok := colIndex[*reColumn]
				if !ok {
					return fmt.Errorf("regexp filtering column '%s' not found by index", *reColumn)
				}
				value := record[index]
				if !colRegexp.MatchString(value) {
					if debug {
						fmt.Printf("Skipping %s=%s, not matching %s\n", *reColumn, value, colRegexp.String())
					}
					continue
				}
			}
			for col, i := range colIndex {
				// Column is "ColName I J" I-th column and J-th N
				// First nStatic columns doesn not have N added.
				colName := col
				cNum := colNum[col]
				if cNum >= nStatic {
					colName = fmt.Sprintf("%s %d", col, n)
				} else {
					// Static column should only be inserted once
					if nN > 0 {
						continue
					}
				}
				_, ok := values[colName]
				if !ok {
					values[colName] = []string{}
				}
				values[colName] = append(values[colName], record[i])
			}
		}
		nN++
	}
	// Write output CSV
	oFile, err := os.Create(ofn)
	if err != nil {
		return err
	}
	defer func() { _ = oFile.Close() }()
	writer := csv.NewWriter(oFile)
	defer writer.Flush()

	// Create header row
	hdr := []string{}
	hdrNoMap := []string{}
	hdrNoN := []string{}
	for _, col := range colsAry {
		name, ok := colNameMap[col]
		// Handle static columns
		cNum := colNum[col]
		if cNum >= nStatic {
			for _, n := range nAry {
				if ok {
					hdr = append(hdr, fmt.Sprintf(name, n))
				} else {
					hdr = append(hdr, fmt.Sprintf("%s %s", col, n))
				}
				hdrNoMap = append(hdrNoMap, fmt.Sprintf("%s %s", col, n))
				hdrNoN = append(hdrNoN, col)
			}
		} else {
			if ok {
				hdr = append(hdr, name)
			} else {
				hdr = append(hdr, col)
			}
			hdrNoMap = append(hdrNoMap, col)
			hdrNoN = append(hdrNoN, col)
		}
	}
	// Write header
	err = writer.Write(hdr)
	if err != nil {
		return err
	}
	// Get length of data and write data
	dataLen := len(values[hdrNoMap[0]])
	for i := 0; i < dataLen; i++ {
		data := []string{}
		for j, col := range hdrNoMap {
			fmtFunc, ok := colFmtMap[hdrNoN[j]]
			if ok {
				data = append(data, fmtFunc(values[col][i]))
			} else {
				data = append(data, values[col][i])
			}
		}
		err = writer.Write(data)
		if err != nil {
			return err
		}
	}
	return nil
}

func main() {
	dtStart := time.Now()
	if len(os.Args) < 6 {
		fmt.Printf("%s: required nStaticCols 'col1;col2;..;colN' 'n1;n2;..;nN' 'colname;;;regexp' output.csv\n", os.Args[0])
		fmt.Printf(
			"Example: %s 3 'date_from;date_to;release;n_top_contributing_coms;top_contributions_perc;"+
				"n_top_committing_coms;top_commits_perc' '10;30;100' 'release;;;(?im)cncf'\n",
			os.Args[0],
		)
		fmt.Printf("%s: use empty colname or empty regexp to skip selecting rows\n", os.Args[0])
		os.Exit(1)
		return
	}
	err := mergeCSVs(os.Args[1], os.Args[2], os.Args[3], os.Args[4], os.Args[5])
	if err != nil {
		fmt.Printf("Error: %s\n", err)
	}
	dtEnd := time.Now()
	fmt.Printf("Time: %v\n", dtEnd.Sub(dtStart))
}
