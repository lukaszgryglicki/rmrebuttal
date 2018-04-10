#!/bin/sh
GHA2DB_SKIPTIME=1 GHA2DB_SKIPLOG=1 GHA2DB_CSVOUT="./results.csv" ./runq ./query.sql {{exclude_bots}} "`cat ./exclude_bots.sql`"
