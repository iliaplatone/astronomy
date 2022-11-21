#!/bin/bash

echo "set datafile separator ','
set xlabel 'channel'
set ylabel 'counts'
plot '$1' w points
" |gnuplot -persist
