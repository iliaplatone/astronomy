#!/bin/bash
pushd ineel;
 rm *.png.png ../ineel_tmp/*.txt
 for file in *.png
  do
  bsname=$( echo $file | cut -d '-' -f 1 )
  element=$(echo ${bsname^} | sed -e 's/[0-9]m//g' | tr -d [0-9])
  nuclide=$(echo ${bsname^} | tr -d '[a-z:A-Z]')
  convert $file +dither -posterize 2 $file.png
  convert $file.png -fill white -fuzz 10% -opaque black -fill white -fuzz 10% -opaque yellow -blur 0x1 $file.png
  tesseract $file.png $bsname -l eng -c tessedit_char_whitelist=0123456789.\  --psm 6
  sed -i 's/ 0\([0-9]\)/ 0.\1/g' $bsname.txt
  sed -i 's/\([0-9]+*\)\.\([0-9]+\)\./\1.\2/g' $bsname.txt
  tail -n+2 $bsname.txt | while read line
   do
   echo $(bc -l <<<"sqrt(sqrt($(echo $line | cut -d ' ' -f 4))+$(echo $line | cut -d ' ' -f 5 | head -c-2)^2)" | sed 's/^\./0./')\ \ $(bc -l <<<"1000000/$(echo $line | cut -d ' ' -f 1)") $(grep -e "^$element " ../../../elements.txt | cut -d ' ' -f 1)$nuclide $(grep -e "^$element " ../../../elements.txt | cut -d ' ' -f 2)$nuclide | sed -e '/^\ /d'  | sed -e '/\ \ \ /d' >> ../ineel_tmp/$bsname.txt
  done
 done
popd
