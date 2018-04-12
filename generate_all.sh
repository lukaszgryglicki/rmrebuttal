#!/bin/bash
if [ -z "$PG_PASS" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if [ -z "$NS" ]
then
  all_n=`cat ./ns.txt`
else
  all_n=$NS
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
  echo "Project: $proj, DB: $db"
  for n in $all_n
  do
    echo "Top $n"
    PG_DB=$db ./get_data.sh $n || exit 1
  done
done
echo 'OK'
