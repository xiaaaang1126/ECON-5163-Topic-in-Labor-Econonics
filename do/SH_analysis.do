*********************************************
***  Senior High School Sample Analyzing  ***
*********************************************

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

*do "$do/SH_clean.do"

use "$workData\SH_sp_outcome2009_outcome2015.dta", clear                     // student's characteristic data  
merge 1:1 stud_id using "$workData\SH_parent2001.dta", nogenerate            // parent data
foreach i in "c" "d" "e" "m"{                                                 // each teacher data
    merge 1:1 stud_id using "$workData\SH_teacher_`i'_2001.dta", nogenerate
}
merge 1:1 stud_id using "$workData\SH_teacher_dc_2001.dta", nogenerate       // director teacher data



********************************************
***    Define Varlist and Fix Sample     ***
********************************************

* Define the valist for concise notation
vl create cf_p_2001 = (w1p308 w1p309 w1p310 w1p311 w1p312 w1p313  ///
                     w1p401 w1p501 w1p502 w1p503 expect_degree w1p511)
vl create stud_info = (paedu female general_high hs_private hs_urban hs_capital hs_science ///
                       hs_scarea_north hs_scarea_middle hs_scarea_south)

foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2001 = (w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
            w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i'      ///
            w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')
}
vl create tc_dc_2001 = (w1dtc01 w1dtc02 w1dtc03 w1dtc04 w1dtc05 w1dtc06 w1dtc07 w1dtc08)


* Keep the non-missing sample to fix sample size and save for graphing
save "$workData\SH_pds.dta", replace
keep if !missing(paedu, female, general_high, hs_private, hs_urban, hs_capital, hs_science, hs_scarea_north, hs_scarea_middle, hs_scarea_south, w1t105_c, w1t106_c, w1t109_c, w1t112_c, w1t113_c, w1t114_c, w1t115_c, w1t116_c, w1t201_c, w1t202_c, w1t308_c, w1t309_c, w1t311_c, w1t315_c, w1t316_c, w1t318_c, w1t319_c, w1t320_c, w1t325_c, w1t326_c, w1t105_d, w1t106_d, w1t109_d, w1t112_d, w1t113_d, w1t114_d, w1t115_d, w1t116_d, w1t201_d, w1t202_d, w1t308_d, w1t309_d, w1t311_d, w1t315_d, w1t316_d, w1t318_d, w1t319_d, w1t320_d, w1t325_d, w1t326_d, w1t105_e, w1t106_e, w1t109_e, w1t112_e, w1t113_e, w1t114_e, w1t115_e, w1t116_e, w1t201_e, w1t202_e, w1t308_e, w1t309_e, w1t311_e, w1t315_e, w1t316_e, w1t318_e, w1t319_e, w1t320_e, w1t325_e, w1t326_e, w1t105_m, w1t106_m, w1t109_m, w1t112_m, w1t113_m, w1t114_m, w1t115_m, w1t116_m, w1t201_m, w1t202_m, w1t308_m, w1t309_m, w1t311_m, w1t315_m, w1t316_m, w1t318_m, w1t319_m, w1t320_m, w1t325_m, w1t326_m, w1dtc01, w1dtc02, w1dtc03, w1dtc04, w1dtc05, w1dtc06, w1dtc07, w1dtc08)
save "$workData\SH_pds_drop.dta", replace

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
esttab university_1 university_2 university_3 
esttab master_1 master_2 master_3
esttab public_1 public_2 public_3
esttab work_year_1 work_year_2 work_year_3



********************************************
***        Adding Control Variable       ***
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
qui pdslasso university sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo university_7
qui pdslasso university sp_severe (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo university_8
qui pdslasso university sp_comply (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo university_9

* Outcome Variable (2): Master degree
qui pdslasso master sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo master_7
qui pdslasso master sp_severe (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo master_8
qui pdslasso master sp_comply (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo master_9

* Outcome Variable (3): Public University
qui pdslasso public sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo public_7
qui pdslasso public sp_severe (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo public_8
qui pdslasso public sp_comply (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo public_9

* Outcome Variable (4): work_year at 2009
qui pdslasso work_year sp (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo work_year_7
qui pdslasso work_year sp_severe (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo work_year_8
qui pdslasso work_year sp_comply (paedu $stud_info $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001), rob loption(prestd)
eststo work_year_9

* Outcome Table
esttab university_7 university_8 university_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab master_7 master_8 master_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab public_7 public_8 public_9, p num star(* 0.10 ** 0.05 *** 0.01)
esttab work_year_7 work_year_8 work_year_9, p num star(* 0.10 ** 0.05 *** 0.01)
