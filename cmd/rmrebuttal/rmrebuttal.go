package main

import (
	"fmt"
	"os"
	"strings"
	"time"
)

// Get cols from results/resultI.csv files I={n1, n2, ..., nN} and save to ofn.
func mergeCSVs(cols, ns, ofn string) (err error) {
	colsMap := make(map[string]struct{})
	ary := strings.Split(cols, ";")
	for _, col := range ary {
		colsMap[col] = struct{}{}
	}
	fmt.Printf("%+v\n", colsMap)
	return
}

func main() {
	dtStart := time.Now()
	if len(os.Args) < 4 {
		fmt.Printf("%s: required 'col1;col2;..;colN' 'n1;n2,..,nN' output.csv\n", os.Args[0])
		return
	}
	err := mergeCSVs(os.Args[1], os.Args[2], os.Args[3])
	if err != nil {
		fmt.Printf("Error: %s\n", err)
	}
	dtEnd := time.Now()
	fmt.Printf("Time: %v\n", dtEnd.Sub(dtStart))
}
