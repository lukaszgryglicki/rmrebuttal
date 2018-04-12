#!/bin/sh
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
GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="results/$pref_top_$1.csv" ./runq ./query.sql {{exclude_bots}} "`cat ./exclude_bots.sql`" {{n}} "$1" {{start_date}} `cat ./start_dates/$pref.txt` {{join_date}} `cat ./join_dates/$pref.txt` {{proj_rels}} "readfile:./partials/${pref}_rels.sql"
