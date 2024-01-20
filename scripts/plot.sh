#!/bin/bash

(( $# < 1 )) && {
 echo "usage: $(basename $0) catalog [logscale_x [logscale_y]]"
 exit 11
}
catalog=$1
logscale_x=$2
logscale_y=$3
tmp_csv=/tmp/$$.csv

sed -e 's/ /;/g'  $catalog | while read line; do
 echo $line
 echo $(echo "$(echo $line | cut -d ';'  -f 3)+1" | bc -l)",0" >> $tmp_csv
 echo "$(echo 1/$(echo $line | cut -d ';'  -f 3) | bc -l),$(echo $line | cut -d ' ' -f 1)" >> $tmp_csv
 echo $(echo "$(echo $line | cut -d ';'  -f 3)-1" | bc -l)",0" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x $logscale_x
set logscale y $logscale_y
plot '$tmp_csv' w lines
" |gnuplot -persist
rm $tmp_csv
