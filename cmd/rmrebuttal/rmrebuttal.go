package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"os"
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
				continue
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
	for _, col := range colsAry {
		// Handle static columns
		cNum := colNum[col]
		if cNum >= nStatic {
			for _, n := range nAry {
				hdr = append(hdr, fmt.Sprintf("%s %s", col, n))
			}
		} else {
			hdr = append(hdr, col)
		}
	}
	// Write header
	err = writer.Write(hdr)
	if err != nil {
		return err
	}
	// Get length of data and write data
	dataLen := len(values[hdr[0]])
	for i := 0; i < dataLen; i++ {
		data := []string{}
		for _, col := range hdr {
			data = append(data, values[col][i])
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
