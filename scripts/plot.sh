#!/bin/bash

catalog=$1
tmp_csv=$TMPDIR/$$.csv

cat $catalog | while read line; do
 echo "$(echo $line | cut -s ' ' -f 2),$(echo $line | cut -s ' ' -f 1)" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x 2
set logscale y 2
plot '$1' w lines
" |gnuplot -persist
