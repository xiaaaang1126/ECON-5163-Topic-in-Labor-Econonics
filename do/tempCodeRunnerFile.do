* merge two pds data
use "$workData\SH_pds.dta", clear
gen SH = 1
destring(stud_id), replace
replace stud_id = stud_id + 100000
tostring(stud_id), replace
append using "$workData\CP_pds.dta"
replace SH = 0 if SH == .


***        Simple Regression       ***
* Outcome Variable (1): University
qui reg university sp if SH == 1, r         
est sto university_1_sh
qui reg university sp if SH == 0, r       
est sto university_1_cp

* Outcome Variable (2): Master
qui reg master sp if SH == 1, r
est sto master_1_sh
qui reg master sp if SH == 0, r
est sto master_1_cp

* Outcome Variable (3): Public University
qui reg public sp if SH == 1, r          
est sto public_1_sh
qui reg public sp if SH == 0, r              
est sto public_1_cp


***        Adding Control Variable       ***
* Outcome Variable (1): University
qui reg university sp female hs_private hs_urban general_high paedu if SH == 1, r         
est sto university_4_sh
qui reg university sp female hs_private hs_urban general_high paedu if SH == 0, r       
est sto university_4_cp

* Outcome Variable (2): Master
qui reg master sp female hs_private hs_urban general_high paedu if SH == 1, r
est sto master_4_sh
qui reg master sp female hs_private hs_urban general_high paedu if SH == 0, r
est sto master_4_cp

* Outcome Variable (3): Public University
qui reg public sp female hs_private hs_urban general_high paedu if SH == 1, r          
est sto public_4_sh
qui reg public sp female hs_private hs_urban general_high paedu if SH == 0, r              
est sto public_4_cp

***            PDS method                 ***
* define NPCP control variables
foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2005 = (w3t101_`i' w3t110_`i' w3t117_`i' w3t203_`i' w3t204_`i' w3t206_`i' w3t209_`i' w3t210_`i'   ///
                             w3t211_`i' w3t212_`i' w3t314_`i' w3t316_`i' w3t317_`i' w3t323_`i' w3t324_`i')
}

vl create tc_dc_2005 = (w3dtc02 w3dtc03 w3dtc04 w3dtc05 w3dtc06 w3dtc07 w3dtc08)

* Outcome Variable (1): University
qui pdslasso university sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if SH == 1, rob loption(prestd)
eststo university_7_sh
qui pdslasso university sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005) if SH == 0, rob loption(prestd)
eststo university_7_cp


* Outcome Variable (2): Master degree
qui pdslasso master sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if SH == 1, rob loption(prestd)
eststo master_7_sh
qui pdslasso master sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005) if SH == 0, rob loption(prestd)
eststo master_7_cp


* Outcome Variable (3): Public University
qui pdslasso public sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if SH == 1, rob loption(prestd)
eststo public_7_sh
qui pdslasso public sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005) if SH == 0, rob loption(prestd)
eststo public_7_cp