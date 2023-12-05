#!/bin/bash

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
set logscale x 2
set logscale y 2
plot '$1' w lines
" |gnuplot -persist
