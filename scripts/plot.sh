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
 x_val=$(echo $line | cut -d ';'  -f 3);
 y_val=$(echo $line | cut -d ';'  -f 1);
 echo $line
 echo $(echo "$x_val+1" | bc -l)",0" >> $tmp_csv
 printf "$x_val," >> $tmp_csv
 echo "l($y_val)/l($logscale_y)" | bc -l >> $tmp_csv
 echo $(echo "$x_val-1" | bc -l)",0" >> $tmp_csv
done

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x $logscale_x
plot '$tmp_csv' w lines
" |gnuplot -persist
rm $tmp_csv
