#!/bin/bash

catalog=$1
logscale=$2
tmp_csv=/tmp/$$.csv

sed -e 's/ /;/g'  $catalog | while read line; do
 echo $line
 echo $(echo "$(echo $line | cut -d ';'  -f 3)+1" | bc -l)",0" >> $tmp_csv
 echo "$(echo $line | cut -d ';'  -f 3),$(echo $line | cut -d ' ' -f 1)" >> $tmp_csv
 echo $(echo "$(echo $line | cut -d ';'  -f 3)-1" | bc -l)",0" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x $logscale
set logscale y 1
plot '$tmp_csv' w lines
" |gnuplot -persist
rm $tmp_csv
