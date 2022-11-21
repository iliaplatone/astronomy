#!/bin/bash

step=$1
plots=$2
qfactor=$3
lowpass=$4
trigger=$5
catalogs=$6

if (( $# < 6 )); then
echo "Usage: $0 step plots qfactor lowpass trigger catalogs" >&2
exit
fi

rm -rf csv/* tmp/*
mkdir -p tmp csv
for file in $(ls ../spectra/); do
 pdf=../spectra/$file
 dir=$(basename $file | cut -d '.' -f 1)
 element=$(echo "$dir" | sed -e 's/^\([^0-9]*\).*/\1/')
 N=$(echo "$dir" | sed -e 's/^[^0-9]*\(.*\)/\1/')
 code=$(grep --ignore-case "^$element;" elements.txt | cut -d ';' -f 1)
 name=$(grep --ignore-case "^$element;" elements.txt | cut -d ';' -f 2)

 echo $code$N $name$N

 mkdir -p tmp/$dir/
 gs -o tmp/$dir/tmp.pdf -sDEVICE=pdfwrite -dFILTERTEXT $pdf 2>/dev/null 1>/dev/null
 pdftoppm -r 300 -l $(($(pdfgrep -n 'Decay' ../spectra/ac227.pdf | cut -d ':' -f 1)-1)) -png tmp/$dir/tmp.pdf tmp/$dir/ 2>/dev/null 1>/dev/null
 pushd tmp/$dir/ 2>/dev/null 1>/dev/null
 rm -fr $catalogs/$dir.txt ../../csv/$dir.csv
 for file in *.png; do
  convert $file -fill white -fuzz 10% -opaque black -negate -define morphology:compose=darken -morphology Thinning Rectangle:'1x30+0+0<' -blur 2 -threshold 0 -negate image$file
  ../../coords.py image$file ../../signal.png $step $plots $qfactor $lowpass $trigger "$code$N" "$name$N" $catalogs/$dir.txt ../../csv/$dir
  sleep 2
 done
 popd 2>/dev/null 1>/dev/null
done
ls $catalogs/ > $catalogs/index.txt
