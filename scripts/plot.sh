#!/bin/bash

catalog=$1
tmp_csv=/tmp/cat.csv

cat $catalog | tr -s ' ' ';' | while read line; do
 echo $line
 echo $(echo "$(echo $line | sed -e 's/ /;/g' | cut -d ';'  -f 3)+1" | bc -l)",0" >> $tmp_csv
 echo "$(echo $line | tr -s ' ' ';' | cut -d ';'  -f 3),$(echo $line | cut -d ' ' -f 1)" >> $tmp_csv
 echo $(echo "$(echo $line | tr -s ' ' ';' | cut -d ';'  -f 3)-1" | bc -l)",0" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x 1
set logscale y 1
plot '$tmp_csv' w lines
" |gnuplot -persist
#rm $tmp_csv
