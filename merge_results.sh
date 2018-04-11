#!/bin/bash
./rmrebuttal 3 'date_from;date_to;release;n_top_contributing_coms;top_contributions_perc' '1;2;3;5;10;15;20;25;30;50;100;200;500' results/merged_contributions_data.csv
./rmrebuttal 1 'release;n_top_contributing_coms' '1;2;3;5;10;15;20;25;30;50;100;200;500' results/merged_contributing_companies.csv
./rmrebuttal 1 'release;top_contributions_perc' '1;2;3;5;10;15;20;25;30;50;100;200;500' results/merged_percent_contributions.csv
