#!/bin/bash
if [ -z "${PG_PASS}" ]
then
  echo "You need to set PG_PASS environment variable to run this script"
  exit 1
fi
if [ -z "$ONLY" ]
then
  all_n=`cat ./ns.txt`
else
  all_n=$ONLY
fi
for n in $all_n
do
  ./get_data.sh $n || exit 1
done
echo 'OK'
