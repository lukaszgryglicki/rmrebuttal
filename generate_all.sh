#!/bin/bash
./get_data.sh 1 || exit 1
./get_data.sh 2 || exit 1
./get_data.sh 3 || exit 1
./get_data.sh 5 || exit 1
./get_data.sh 10 || exit 1
./get_data.sh 15 || exit 1
./get_data.sh 20 || exit 1
./get_data.sh 25 || exit 1
./get_data.sh 30 || exit 1
./get_data.sh 50 || exit 1
./get_data.sh 100 || exit 1
./get_data.sh 200 || exit 1
./get_data.sh 500 || exit 1
echo 'OK'
