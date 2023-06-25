*********************************************
***  Junior High School Sample Analyzing  ***
*********************************************

* Directory
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


********************************************
***          Merge the Dataset           ***
********************************************

* do "$do/CP_clean.do"
use "$workData\NPCP_sp_outcome2009_outcome2013.dta", clear
merge 1:1 stud_id using "$workData\CP_parent2001.dta", nogenerate
merge 1:1 stud_id using "$workData\NP_parent2005.dta", replace update

* Merge data with 2005 teacher data (CP & NP)
foreach i in "c" "d" "e" "m"{
    merge 1:1 stud_id using "$workData\NPCP_teacher_`i'_2005.dta", nogenerate
}

merge 1:1 stud_id using "$workData\NPCP_teacher_dc_2005.dta", nogenerate



********************************************
***    Define Varlist and Fix Sample     ***
********************************************

* define control variables
vl create stud_info = (female general_high hs_private hs_urban hs_capital hs_science      ///
                       hs_scarea_north hs_scarea_middle hs_scarea_south)

foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2005 = (w3t101_`i' w3t110_`i' w3t117_`i' w3t203_`i' w3t204_`i' w3t206_`i' w3t209_`i' w3t210_`i'   ///
                             w3t211_`i' w3t212_`i' w3t314_`i' w3t316_`i' w3t317_`i' w3t323_`i' w3t324_`i')
}

vl create tc_dc_2005 = (w3dtc02 w3dtc03 w3dtc04 w3dtc05 w3dtc06 w3dtc07 w3dtc08)


* Keep the non-missing sample to fix sample size and save for graphing
save "$workData\CP_pds.dta", replace
keep if !missing(paedu, female, general_high, hs_private, hs_urban, hs_capital, hs_science, hs_scarea_north, hs_scarea_middle, hs_scarea_south, w3t101_c, w3t110_c, w3t117_c, w3t203_c, w3t204_c, w3t206_c, w3t209_c, w3t210_c, w3t211_c, w3t212_c, w3t314_c, w3t316_c, w3t317_c, w3t323_c, w3t324_c, w3t101_d, w3t110_d, w3t117_d, w3t203_d, w3t204_d, w3t206_d, w3t209_d, w3t210_d, w3t211_d, w3t212_d, w3t314_d, w3t316_d, w3t317_d, w3t323_d, w3t324_d, w3t101_e, w3t110_e, w3t117_e, w3t203_e, w3t204_e, w3t206_e, w3t209_e, w3t210_e, w3t211_e, w3t212_e, w3t314_e, w3t316_e, w3t317_e, w3t323_e, w3t324_e, w3t101_m, w3t110_m, w3t117_m, w3t203_m, w3t204_m, w3t206_m, w3t209_m, w3t210_m, w3t211_m, w3t212_m, w3t314_m, w3t316_m, w3t317_m, w3t323_m, w3t324_m, w3dtc02, w3dtc03, w3dtc04, w3dtc05, w3dtc06, w3dtc07, w3dtc08)
save "$workData\CP_pds_drop.dta", replace


********************************************
***           Baseline Model             ***
********************************************

* Outcome Variable (1): University degree
qui reg university sp, r             
est sto university_1
qui reg university sp_severe, r      
est sto university_2
qui reg university sp_comply, r
est sto university_3

* Outcome Variable (2): Master degree
qui reg master sp, r             
est sto master_1
qui reg master sp_severe, r      
est sto master_2
qui reg master sp_comply, r
est sto master_3

* Outcome Variable (3): Public University
qui reg public sp, r                 
est sto public_1
qui reg public sp_severe, r          
est sto public_2
qui reg public sp_comply, r
est sto public_3

* Outcome Variable (4): Working Year at 2009
qui reg work_year sp, r
est sto work_year_1
qui reg work_year sp_severe, r
est sto work_year_2
qui reg work_year sp_comply, r
est sto work_year_3

* Present the Outcome
esttab university_1 university_2 university_3, p num star(* 0.10 ** 0.05 *** 0.01) 
esttab master_1 master_2 master_3, p num star(* 0.10 ** 0.05 *** 0.01)
esttab public_1 public_2 public_3, p num star(* 0.10 ** 0.05 *** 0.01)
esttab work_year_1 work_year_2 work_year_3, p num star(* 0.10 ** 0.05 *** 0.01)



********************************************
***           Adding Confounder          ***
********************************************

* Outcome Variable (1): University
qui reg university sp female hs_private hs_urban general_high paedu, r               // t = -3.20 √
est sto university_4
qui reg university sp_severe female hs_private hs_urban general_high paedu, r        // t = -0.87
est sto university_5
qui reg university sp_comply female hs_private hs_urban general_high paedu, r        // t = -0.87
est sto university_6

* Outcome Variable (2): Master
qui reg master sp female hs_private hs_urban general_high paedu, r
est sto master_4
qui reg master sp_severe female hs_private hs_urban general_high paedu, r
est sto master_5
qui reg master sp_comply female hs_private hs_urban general_high paedu, r   
est sto master_6

* Outcome Variable (3): Public University
qui reg public sp female hs_private hs_urban general_high paedu, r                   // t = 0.24 
est sto public_4
qui reg public sp_severe female hs_private hs_urban general_high paedu, r            // t = -0.05
est sto public_5
qui reg public sp_comply female hs_private hs_urban general_high paedu, r            // t = -0.05
est sto public_6

* Outcome Variable (4): Working Year at 2009
qui reg work_year sp female hs_private hs_urban general_high paedu, r           // t = 3.59 √
est sto work_year_4
qui reg work_year sp_severe female hs_private hs_urban general_high paedu, r           // t = 3.59 √
est sto work_year_5
qui reg work_year sp_comply female hs_private hs_urban general_high paedu, r           // t = 3.59 √
est sto work_year_6

* Outcome Table
esttab university_4 university_5 university_6, p num star(* 0.10 ** 0.05 *** 0.01)
esttab master_4 master_5 master_6, p num star(* 0.10 ** 0.05 *** 0.01)
esttab public_4 public_5 public_6, p num star(* 0.10 ** 0.05 *** 0.01)
esttab work_year_4 work_year_5 work_year_6, p num star(* 0.10 ** 0.05 *** 0.01)



********************************************
***        Post-Double Selection         ***
********************************************

* Outcome Variable (1): University
qui pdslasso university sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo university_7
qui pdslasso university sp_severe (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo university_8
qui pdslasso university sp_comply (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo university_9

* Outcome Variable (2): Master degree
qui pdslasso master sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo master_7
qui pdslasso master sp_severe (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo master_8
qui pdslasso master sp_comply (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo master_9

* Outcome Variable (3): Public University
qui pdslasso public sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo public_7
qui pdslasso public sp_severe (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo public_8
qui pdslasso public sp_comply (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo public_9

* Outcome Variable (4): work_year at 2009
qui pdslasso work_year sp (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo work_year_7
qui pdslasso work_year sp_severe (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo work_year_8
qui pdslasso work_year sp_comply (paedu $stud_info $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo work_year_9

* Outcome Table
esttab university_7 university_8 university_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab master_7 master_8 master_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab public_7 public_8 public_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab work_year_7 work_year_8 work_year_9, p num star(* 0.10 ** 0.05 *** 0.01)


/*
* save the results as tex
esttab PDS_university PDS_university_s using "$do\table_tex\CPNP_table.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex replace
esttab PDS_public PDS_public_s using "$do\table_tex\CPNP_table.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex append
esttab PDS_wageLevel_2013 PDS_wageLevel_2013_s PDS_wageLevel_2019 PDS_wageLevel_2019_s using "$do\table_tex\CPNP_table.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex append
esttab PDS_workyear_2013 PDS_workyear_2013_s PDS_workyear_2019 PDS_workyear_2019_s using "$do\table_tex\CPNP_table.tex", p num star(* 0.10 ** 0.05 *** 0.01) tex append
*/


