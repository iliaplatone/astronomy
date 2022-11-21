#!/bin/bash

rm -f $catalog_path/*.txt
mkdir -p tmp/csv
for element in $(cat elements.txt | cut -d ' ' -f 1); do
 tmpfile=tmp/csv/$element.csv
 element_name=$(grep -w $element elements.txt | cut -d ' ' -f 2)
 echo getting data for $element_name ...
 [ -e $tmpfile ] || wget "https://physics.nist.gov/cgi-bin/ASD/lines1.pl?spectra=${element}&limits_type=0&low_w=&upp_w=&unit=1&de=0&I_scale_type=1&format=2&line_out=0&diag_out=1&remove_js=on&en_unit=0&output=0&bibrefs=1&page_size=15&show_obs_wl=1&show_calc_wl=1&unc_out=1&order_out=0&max_low_enrg=&show_av=3&max_upp_enrg=&tsb_value=0&min_str=&A_out=0&A8=1&f_out=on&S_out=on&intens_out=on&max_str=&allowed_out=1&forbid_out=1&min_accur=&min_intens=&conf_out=on&term_out=on&enrg_out=on&J_out=on&g_out=on&submit=Retrieve+Data" -O - 2>/dev/null > $tmpfile
 if [ -e $tmpfile ]; then
  if grep -e "Error" $tmpfile >/dev/null; then
   rm -f $tmpfile;
  fi
 fi
done
