********************************************
***        Two Sample Comparison         ***
********************************************

if "`c(username)'" == "Administrator" {  
    global do = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\do"
    global rawData = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\rawData"
    global workData = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\workData"
    global log = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\log"
    global pic = "C:\Users\Administrator\Desktop\LaborTopicTermPaper\pic"
}

if "`c(username)'" == "jwutw" {
	global do = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\do"
	global rawData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\rawData"
	global workData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\workData"
	global log = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\log"
	global pic = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\Git\LaborTopicTermPaper\pic"
}


* Import SH & NPCP Dataset
use "$workData\SH_pds.dta", clear
destring(stud_id), replace
replace stud_id = stud_id + 100000
keep stud_id sp sp_comply sp_severe university master public work_year
tostring(stud_id), replace
merge 1:1 stud_id using "$workData\CP_pds.dta", nogenerate


* Divide into two group and graph
destring(stud_id), replace
gen NPCP = (stud_id <= 100000)
graph bar (mean) university, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\university_sp.png", replace

graph bar (mean) public, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Public University Degree (%)")
graph export "$pic\public_sp.png", replace

graph bar (mean) master, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Master Degree (%)")
graph export "$pic\master_sp.png", replace

********************************************
* Regression Table comparison
********************************************

* merge two pds data
use "$workData\SH_pds_drop.dta", clear
gen SH = 1
destring(stud_id), replace
replace stud_id = stud_id + 100000
tostring(stud_id), replace
append using "$workData\CP_pds_drop.dta"
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

esttab university_1_sh university_4_sh university_7_sh university_1_cp university_4_cp university_7_cp using "$do\table_tex\comparison_univ.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex replace
esttab public_1_sh public_4_sh public_7_sh public_1_cp public_4_cp public_7_cp using "$do\table_tex\comparison_public.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex replace
esttab master_1_sh master_4_sh master_7_sh master_1_cp master_4_cp master_7_cp using "$do\table_tex\comparison_master.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex replace
