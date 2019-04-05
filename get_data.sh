#!/bin/sh
if [ -z "$PG_PASS" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if [ -z "$1" ]
then
  echo "$0: please provide N"
  exit 1
fi
if ( [ -z "$PG_DB" ] || [ "$PG_DB" = "gha" ] )
then
  pref="kubernetes"
else
  pref=$PG_DB
fi
GHA2DB_LOCAL=1 GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="results/${pref}_top_$1.csv" runq ./query.sql {{exclude_bots}} "`cat ./exclude_bots.sql`" {{n}} "$1" {{start_date}} `cat ./start_dates/${pref}.txt` {{join_date}} `cat ./join_dates/${pref}.txt` {{proj_rels}} "readfile:./partials/${pref}_rels.sql"
