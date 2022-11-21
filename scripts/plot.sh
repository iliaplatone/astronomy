#!/bin/bash

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
plot '$1' with lines
" |gnuplot -persist
