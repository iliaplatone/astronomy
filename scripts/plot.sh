#!/bin/bash

catalog=$1
tmp_csv=/tmp/cat.csv

cat $catalog | while read line; do
 echo "$(echo $line | cut -d ' ' -f 2),$(echo $line | cut -d ' ' -f 1)" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x 2
set logscale y 2
plot '$tmp_csv' w lines
" |gnuplot -persist
#rm $tmp_csv
