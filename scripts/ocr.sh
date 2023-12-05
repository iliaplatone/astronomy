#!/bin/bash


rm -rf images texts
mkdir -p images texts

for file in $(ls ../spectra/); do pdf=../spectra/$file; image=images/$(echo $file | sed -e 's/\.pdf//g'); text=texts/$(echo $file | sed -e 's/pdf/txt/g'); pdftoppm -f 0 -l 0 -png $pdf $image; for png in $image*; do tesseract --psm 3 -l eng $png - >> $text; done; done
