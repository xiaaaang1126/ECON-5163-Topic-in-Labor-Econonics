********************************************
***   Core Pupulation Sample Cleaning    ***
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


********************************************
***          CP & NCP 2005 Data          ***
********************************************

* Import CP & NCP dataset (2005) and merge with parents' data
use "$rawData\NP\NP_withCP_2005_A_student.dta", clear
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2005_G_parent.dta", keepusing(w3p103) nogenerate
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2007_G_parent.dta", keepusing(w4p103) nogenerate

* Main Variable: `sp', `sp_comply' and `ap_severe'
recode w3p103 w4p103 (97/99 = .)
gen sp        = (w3p103 != 1 | w4p103 != 1) if !missing(w3p103, w4p103)  // one-time single parent
gen sp_comply = (w3p103 != 1 & w4p103 != 1) if !missing(w3p103, w4p103)  // all-time single parent
gen sp_severe = (w3p103 == 1 & w4p103 != 1) if !missing(w3p103, w4p103)  // suddenly single parent

* Student's Background Information (Other control variables in CP 2007)
rename w3s480 female       // gender
rename w3priv hs_private   // private/public univeristy
rename w3urban3 hs_urban   // urban/rural area
rename w3pgrm hs_type      // school system type

replace female = female - 1
recode hs_urban (1/2 = 0)
replace hs_urban = 1 if hs_urban == 3
gen general_high = hs_type == 2  if hs_type != .        // 普通高中
gen hs_scarea_north = w3scarea == 1 if w3scarea != .
gen hs_scarea_middle = w3scarea == 2 if w3scarea != .
gen hs_scarea_south = w3scarea == 3 if w3scarea != .
gen hs_scarea_east = w3scarea == 4 if w3scarea != .
gen hs_capital = (w3admarea == 11 | w3admarea == 12 | w3admarea == 25) if w3admarea != .
gen hs_science =  (w3clspgm == 21|w3clspgm == 23) if general_high == 1

label define map_general_high 0 "高職五專" 1 "普通高中"
label define map_science 0 "社會組" 1 "自然組"

label values hs_private map_private
label values hs_urban map_urban
label values hs_scarea_north map_scarea_north
label values hs_scarea_middle map_scarea_middle
label values hs_scarea_south map_scarea_south
label values hs_scarea_east map_scarea_east
label values hs_capital map_capital
label values hs_science map_science
label values general_high map_general_high

* Keep Only Useful Variables
keep stud_id cp sp sp_severe sp_comply female                        ///
     general_high hs_private hs_urban hs_capital hs_science          ///
     hs_scarea_north hs_scarea_middle hs_scarea_south hs_scarea_east

* Save Original Data
save "$workData\NPCP_sp.dta", replace



********************************************
***    Merge with future working data    ***
********************************************
***      CP: 2009, 2013                  ***
***      NP: 2013                        ***
********************************************

* Import data
use "$rawData\CP\CP_2009.dta", clear

* Outcome Variable (1): Bachelor Degree
merge 1:1 stud_id using "$rawData\CP\CP_2013.dta", keepusing(cp13v29) nogenerate
merge 1:1 stud_id using "$rawData\NP\NP_2013.dta", keepusing(np13v29) nogenerate
recode cp09v06 (7/98 = .)
gen university_CP_2009 = (cp09v06 == 6) if !missing(cp09v06)
recode cp13v29 (9/98 = .)
gen university_CP_2013 = (cp13v29 == 6 | cp13v29 == 7 | cp13v29 == 8) if !missing(cp13v29)
recode np13v29 (9/98 = .)
gen university_NP_2013 = (np13v29 == 6 | np13v29 == 7 | np13v29 == 8) if !missing(np13v29)
egen university = rowmax(university_CP_2009 university_CP_2013 university_NP_2013)

* Outcome Variable (2): Master Degree
gen master_CP_2013 = (cp13v29 == 7 | cp13v29 == 8) if !missing(cp13v29)
gen master_NP_2013 = (np13v29 == 7 | np13v29 == 8) if !missing(np13v29)
egen master = rowmax(master_CP_2013 master_NP_2013)

* Outcome Variable (3): Public University    
merge 1:1 stud_id using "$rawData\CP\CP_2013.dta", keepusing(cp13v32v33_u) nogenerate
merge 1:1 stud_id using "$rawData\NP\NP_2013.dta", keepusing(np13v32v33_u) nogenerate
recode cp09v08_u cp13v32v33_u np13v32v33_u (11/99 = .)
gen public_CP_2009 = (cp09v08_u == 1) if !missing(cp09v08_u)
gen public_CP_2013 = (cp13v32v33_u == 1) if !missing(cp13v32v33_u)
gen public_NP_2013 = (np13v32v33_u == 1) if !missing(np13v32v33_u)
egen public = rowmax(public_CP_2009 public_CP_2013 public_NP_2013)

* Outcome Variable (4): Working Year at 2013
merge 1:1 stud_id using "$rawData\CP\CP_2013.dta", keepusing(cp13v53 cp13v50 cp13v54) nogenerate
merge 1:1 stud_id using "$rawData\NP\NP_2013.dta", keepusing(np13v50 np13v53 np13v54) nogenerate
recode cp13v54 cp13v50 (12/99 = .)  // CP: (1) when to start first job; (2) when to start job (now)
recode np13v54 np13v50 (13/99 = .)  // NP: (1) when to start first job; (2) when to start job (now)
gen work_year_CP_2013 = 12 - cp13v54
replace work_year_CP_2013 = 12 - cp13v50 if (cp13v53 == 1|cp13v53 == 96|cp13v53 == 97|cp13v53 == 98) 
gen work_year_NP_2013 = 13 - np13v54
replace work_year_NP_2013 = 13 - np13v50 if (np13v53 == 1 | np13v53 == 96 | np13v53 == 97 | np13v53 == 98 |np13v53 == 99)
egen work_year = rowmax(work_year_CP_2013 work_year_NP_2013)

* Keep Only Useful Variable
keep stud_id university master public work_year 
save "$workData\NPCP_outcome2009_outcome2013.dta", replace



********************************************
***   Merge sp with future working data  *** 
********************************************

use "$workData\NPCP_sp.dta", clear 
merge 1:1 stud_id using "$workData\NPCP_outcome2009_outcome2013.dta", nogenerate
save "$workData\NPCP_sp_outcome2009_outcome2013.dta", replace


