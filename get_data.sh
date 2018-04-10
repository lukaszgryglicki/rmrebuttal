#!/bin/sh
if [ -z "$1" ]
then
  echo "$0: please provide CSV output filename and N"
  exit 1
fi
if [ -z "$2" ]
then
  echo "$0: please provide N"
  exit 1
fi
GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="results/$1" ./runq ./query.sql {{exclude_bots}} "`cat ./exclude_bots.sql`" {{n}} "$2"
