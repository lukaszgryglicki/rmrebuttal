#!/bin/bash
./get_data.sh results1.csv 1 || exit 1
./get_data.sh results2.csv 2 || exit 1
./get_data.sh results5.csv 5 || exit 1
./get_data.sh results10.csv 10 || exit 1
./get_data.sh results15.csv 15 || exit 1
./get_data.sh results20.csv 20 || exit 1
./get_data.sh results25.csv 25 || exit 1
./get_data.sh results30.csv 30 || exit 1
./get_data.sh results50.csv 50 || exit 1
./get_data.sh results100.csv 100 || exit 1
./get_data.sh results200.csv 200 || exit 1
echo 'OK'
