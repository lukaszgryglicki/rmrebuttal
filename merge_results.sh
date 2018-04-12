#!/bin/bash
if [ -z "$RRE" ]
then
  rname="all"
else
  if [ -z "$RNAME" ]
  then
    echo "$0: if specifying rows by regexp using RRE, you need to specify name prefix too, by using RNAME"
    exit 1
  fi
  rname=$RNAME
fi
if [ -z "$PROJS" ]
then
  PROJS="kubernetes"
fi
for proj in $PROJS
do
  db=$proj
  if [ "$proj" = "kubernetes" ]
  then
    db="gha"
  elif [ "$proj" = "all" ]
  then
    db="allprj"
  fi
  pref="results/${proj}_${rname}"
  echo "Project: $proj, DB: $db, prefix: $pref"
  PG_DB=$db ./rmrebuttal 3 'date_from;date_to;release;n_top_contributing_coms;top_contributions_perc' '1;2;3;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_merged_contributions_data.csv" || exit 1
  PG_DB=$db ./rmrebuttal 1 'release;n_top_contributing_coms' '1;2;3;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_merged_contributing_companies.csv" || exit 1
  PG_DB=$db ./rmrebuttal 1 'release;top_contributions_perc' '1;2;3;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_merged_percent_contributions.csv" || exit 1
done
echo 'OK'
