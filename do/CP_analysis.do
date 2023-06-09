********************************************
* Junior High School Sample Analysis
********************************************


* Directory (Xiang Jyun Jhang)
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


* Prepare the dataset
//do "$do/CP_clean.do"
use "$workData\CP_divorce_Outcome2009_2019.dta", clear


********************************************
* Regression (2009)
********************************************
// CP: analysis - university on severe_divorce/divorce
qui reg university divorce, r
est sto university_1
qui reg university severe_divorce, r
est sto university_2

qui reg public divorce, r
est sto public_1
qui reg public severe_divorce, r
est sto public_2

qui reg wage_level_2013 divorce, r
est sto wage_level_2013_1
qui reg wage_level_2013 severe_divorce, r
est sto wage_level_2013_2
qui reg wage_level_2019 divorce, r
est sto wage_level_2019_1
qui reg wage_level_2019 severe_divorce, r
est sto wage_level_2019_2


qui reg work_year_2013 divorce, r
est sto work_year_2013_1
qui reg work_year_2013 severe_divorce, r
est sto work_year_2013_2
qui reg work_year_2019 divorce, r
est sto work_year_2019_1
qui reg work_year_2019 severe_divorce, r
est sto work_year_2019_2

********************************************
***           Adding Confounder          ***
********************************************

* Import data
merge 1:1 stud_id using "$workData\CP_parent2001.dta", nogenerate
merge 1:1 stud_id using "$workData\NP_parent2005.dta", replace update

* Outcome Variable (1): University
qui reg university divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto university_3
qui reg university female hs_private hs_urban general_high i.faedu i.moedu, r
est sto university_4

* Outcome Variable (2): Public University
qui reg public divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto public_3
qui reg public severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto public_4

* Outcome Variable (3): Wage Level at 2013
qui reg wage_level_2013 divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2013_3
qui reg wage_level_2013 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2013_4

* Outcome Variable (4): Wage Level at 2013
qui reg wage_level_2013 divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2013_3
qui reg wage_level_2013 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2013_4

* Outcome Variable (5): Wage Level at 2019
qui reg wage_level_2019 divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2019_3
qui reg wage_level_2019 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto wage_level_2019_4

* Outcome Variable (6): Working Year at 2013
qui reg work_year_2013 divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto work_year_2013_3
qui reg work_year_2013 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto work_year_2013_4

* Outcome Variable (7): Working Year at 2019
qui reg work_year_2019 divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto work_year_2019_3
qui reg work_year_2019 severe_divorce female hs_private hs_urban general_high i.faedu i.moedu, r
est sto work_year_2019_4

esttab university_1 university_2 university_3 university_4, p num
esttab public_1 public_2 public_3 public_4, p num
esttab wage_level_2013_1 wage_level_2013_2 wage_level_2013_3 wage_level_2013_4, p num
esttab wage_level_2019_1 wage_level_2019_2 wage_level_2019_3 wage_level_2019_4, p num
esttab work_year_2013_1 work_year_2013_2 work_year_2013_3 work_year_2013_4, p num
esttab work_year_2019_1 work_year_2019_2 work_year_2019_3 work_year_2019_4, p num



********************************************
***         Merge data for PDS           ***
********************************************

* Merge data with 2001 teacher data (only CP)
foreach i in "c" "d" "e" "m"{
    merge 1:1 stud_id using "$workData\CP_teacher_`i'_2001.dta", nogenerate
}

merge 1:1 stud_id using "$workData\CP_teacher_dc_2001.dta", nogenerate

* Merge data with 2005 teacher data (CP & NP)
foreach i in "c" "d" "e" "m"{
    merge 1:1 stud_id using "$workData\NPCP_teacher_`i'_2005.dta", nogenerate
}

merge 1:1 stud_id using "$workData\NPCP_teacher_dc_2005.dta", nogenerate

save "$workData\CP_pds.dta", replace

* define control variables
vl create cf_p_2001 = (w1p308 w1p309 w1p310 w1p311 w1p312 w1p313 ///
                       w1p401 w1p501 w1p502 w1p503 expect_degree w1p511)
vl create stud_info = (female general_high hs_private hs_urban hs_capital hs_science      ///
                       hs_scarea_north hs_scarea_middle hs_scarea_south hs_scarea_east)

foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2001 = (w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
                             w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i'     ///
                             w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')
}

vl create tc_dc_2001 = (w1dtc01 w1dtc02 w1dtc03 w1dtc04 w1dtc05 w1dtc06 w1dtc07 w1dtc08)

foreach i in "c" "d" "e" "m"{
    vl create tc_`i'_2005 = (w3t101_`i' w3t110_`i' w3t117_`i' w3t203_`i' w3t204_`i' w3t206_`i' w3t209_`i' w3t210_`i'   ///
                             w3t211_`i' w3t212_`i' w3t314_`i' w3t316_`i' w3t317_`i' w3t323_`i' w3t324_`i')
}

vl create tc_dc_2005 = (w3dtc02 w3dtc03 w3dtc04 w3dtc05 w3dtc06 w3dtc07 w3dtc08)


********************************************
***     Post Double Selection for CP     ***
********************************************

* pdslasso for university
pdslasso university divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_university
pdslasso university severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_university_s

* pdslasso for public
pdslasso public divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_public
pdslasso public severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_public_s

* pdslasso for wage_level_2013
pdslasso wage_level_2013 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_wageLevel_2013
pdslasso wage_level_2013 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_wageLevel_2013_s

* pdslasso for work_year_2013
pdslasso work_year_2013 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_workyear_2013
pdslasso work_year_2013 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_workyear_2013_s

* pdslasso for wage_level_2019
pdslasso wage_level_2019 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_wageLevel_2019 
pdslasso wage_level_2019 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001 $tc_dc_2001) if cp == 1, rob loption(prestd)
eststo PDS_wageLevel_2019_s

* pdslasso for work_year_2019
pdslasso work_year_2019 divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001) if cp == 1, rob loption(prestd)
eststo PDS_workyear_2019
pdslasso work_year_2019 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2001 $tc_c_2001 $tc_d_2001 $tc_e_2001 $tc_m_2001) if cp == 1, rob loption(prestd)
eststo PDS_workyear_2019_s

* save the results as tex
esttab university_1 university_2 university_3 university_4 using "$do\table_tex\CP_table.tex", p num tex replace
esttab public_1 public_2 public_3 public_4 using "$do\table_tex\CP_table.tex", p num rtf append
esttab wage_level_2013_1 wage_level_2013_2 wage_level_2013_3 wage_level_2013_4 using "$do\table_tex\CP_table.tex", p num tex append
esttab wage_level_2019_1 wage_level_2019_2 wage_level_2019_3 wage_level_2019_4 using "$do\table_tex\CP_table.tex", p num tex append
esttab work_year_2013_1 work_year_2013_2 work_year_2013_3 work_year_2013_4 using "$do\table_tex\CP_table.tex", p num tex append
esttab work_year_2019_1 work_year_2019_2 work_year_2019_3 work_year_2019_4 using "$do\table_tex\CP_table.tex", p num tex append
esttab PDS_university PDS_university_s using "$do\table_tex\CP_table.tex", p num tex append
esttab PDS_public PDS_public_s using "$do\table_tex\CP_table.tex", p num tex append
esttab PDS_wageLevel_2013 PDS_wageLevel_2013_s PDS_wageLevel_2019 PDS_wageLevel_2019_s using "$do\table_tex\CP_table.tex", p num tex append
esttab PDS_workyear_2013 PDS_workyear_2013_s PDS_workyear_2019 PDS_workyear_2019_s using "$do\table_tex\CP_table.tex", p num tex append


********************************************
***  Post Double Selection for CP & NP   ***
********************************************

* pdslasso for university
pdslasso university divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_university
pdslasso university severe_divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_university_s

* pdslasso for public
pdslasso public divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_public
pdslasso public severe_divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_public_s

* pdslasso for wage_level_2013
pdslasso wage_level_2013 divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_wageLevel_2013
pdslasso wage_level_2013 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_wageLevel_2013_s

* pdslasso for work_year_2013
pdslasso work_year_2013 divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_workyear_2013
pdslasso work_year_2013 severe_divorce (i.faedu i.moedu $stud_info $cf_p_2005 $tc_c_2005 $tc_d_2005 $tc_e_2005 $tc_m_2005 $tc_dc_2005), rob loption(prestd)
eststo PDS_workyear_2013_s


* save the results as tex
esttab PDS_university PDS_university_s using "$do\table_tex\CPNP_table.tex", p num tex replace
esttab PDS_public PDS_public_s using "$do\table_tex\CPNP_table.tex", p num tex append
esttab PDS_wageLevel_2013 PDS_wageLevel_2013_s PDS_wageLevel_2019 PDS_wageLevel_2019_s using "$do\table_tex\CPNP_table.tex", p num tex append
esttab PDS_workyear_2013 PDS_workyear_2013_s PDS_workyear_2019 PDS_workyear_2019_s using "$do\table_tex\CPNP_table.tex", p num tex append


