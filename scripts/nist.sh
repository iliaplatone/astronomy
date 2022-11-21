#!/bin/bash

if (( $# < 2 )); then
 echo "usage: $0 catalog_path scale"
 exit 1
fi
catalog_path=$1
scale=$2
rm -f $catalog_path/*.txt
for tmpfile in $(ls tmp/csv/*.csv); do
 header=$(head -n 1 $tmpfile)
 nspectrum_index=0
 for i in $(seq 1 44); do
  [ "$(echo $header | cut -d ',' -f $i)" == "sp_num" ] && nspectrum_index=$i;
 done
 wavelength_index=0
 for i in $(seq 1 44); do
  [ "$(echo $header | cut -d ',' -f $i)" == "ritz_wl_vac(nm)" ] && wavelength_index=$i;
 done
 energy_index=0
 for i in $(seq 1 44); do
  [ "$(echo $header | cut -d ',' -f $i)" == "Ek(cm-1)" ] && energy_index=$i;
 done
 info_index=0
 for i in $(seq 1 44); do
  [ "$(echo $header | cut -d ',' -f $i)" == "conf_i" ] && info_index=$i;
 done
 element=$(grep -w $(basename ${tmpfile} | cut -d '.' -f 1) elements.txt | cut -d ' ' -f 1)
 element_name=$(grep -w ${element} elements.txt | cut -d ' ' -f 2)
 echo processing $element_name ...
 rm -f csv/$element.csv
 cat $tmpfile | sed -e '/ritz_wl_vac/d' | while read line; do
  (( $wavelength_index > 0 )) && wavelength=$(echo $line | cut -d ',' -f ${wavelength_index} | sed -e 's/[^0-9:\.]//g')
  (( $nspectrum_index > 0 )) && nspectrum=-$(./indian2roman.py $(echo $line | cut -d ',' -f ${nspectrum_index}))
  (( $energy_index > 0 )) && energy=$(echo $line | cut -d ',' -f ${energy_index} | sed -e 's/[^0-9:\.]//g')
  [ "$wavelength" != "" ] && [ "$energy" != "" ] && {
   wavelength=$(echo "scale=${scale};$wavelength*1000.0" | bc | awk "{printf \"%.${scale}f\n\", \$0}")
   energy=$(echo "scale=${scale};${energy}" | bc | awk "{printf \"%.${scale}f\n\", \$0}")
   zero=$(echo 0 | awk "{printf \"%.${scale}f\n\", \$0}")
   [ "$energy" != "$zero" ] && {
    energy=$(echo "scale=${scale};0${wavelength}*(10^10)/(${energy}^4)" | bc | awk "{printf \"%.${scale}f\n\", \$0}")
    (( $info_index > 0 )) && info=$(echo $line | cut -d ',' -f ${info_index} | sed -e 's/[^0-9:a-z:A-Z:\.]//g')
    echo "${wavelength},${energy}" >> csv/$element.csv
    echo "${energy} ${info} ${wavelength} ${element}${nspectrum} ${element_name}" >> $catalog_path/${element}.txt
   }
  }
 done
done
pushd $catalog_path
 ls *.txt > index.txt
popd
