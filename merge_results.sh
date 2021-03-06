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
  PROJS="kubernetes prometheus containerd envoy grpc allprj opentracing fluentd linkerd coredns rkt cni jaeger notary tuf rook vitess nats opa spiffe spire cncf"
fi
if [ -z "$COLFMT" ]
then
  COLFMT="release,Release,,;date_from,Date from,d,1/2/2006;date_to,Date to,d,1/2/2006;n_top_contributing_coms,Distinct companies for top %s contributors,,;n_top_committing_coms,Distinct companies for top %s committers,,;top_commits_perc,Top %s developers commits as percent of all,n,%.1f%%;top_contributions_perc,Top %s contributors contributions as percent of all,n,%.1f%%;top_comp_contributions_perc,Top %s companies contributions as percent of all,n,%.1f%%;top_comp_commits_perc,Top %s companies commits as percent of all,n,%.1f%%;top_contributing_coms,Top %s contributing companies,,;top_committing_coms,Top %s committing companies,,"
fi
export COLFMT
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
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;n_top_contributing_coms' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_contributing_companies.csv" || exit 3
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;n_top_committing_coms' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_committing_companies.csv" || exit 4
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_contributions_perc' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_percent_contributions.csv" || exit 5
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_commits_perc' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_percent_commits.csv" || exit 6
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_comp_contributions_perc' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_comp_percent_contributions.csv" || exit 5
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_comp_commits_perc' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_comp_percent_commits.csv" || exit 6
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_contributing_coms' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_contributing_comp_names.csv" || exit 7
  PG_DB=$db ./rmrebuttal 3 'release;date_from;date_to;top_committing_coms' '1;2;3;4;5;10;15;20;25;30;50;100;200;500;1000' "$RRE" "${pref}_committing_comp_names.csv" || exit 7
done
echo 'OK'
