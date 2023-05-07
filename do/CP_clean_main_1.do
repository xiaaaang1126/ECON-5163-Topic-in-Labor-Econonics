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
***          CP & NCP 2005 Data          ***
********************************************

* Import CP & NCP 2005 student data 
use "$rawData\NP\NP_withCP_2005_A_student.dta", clear

* Merge parents' data
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2005_G_parent.dta", keepusing(w3p103) nogenerate
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2007_G_parent.dta", keepusing(w4p103) nogenerate

* Main Variable: `divorce' and `severe_divorce'
gen divorce = (w3p103 == 2 | w3p103 == 3 | w4p103 == 2 | w4p103 == 3)
gen severe_divorce = (w3p103 == 1) & (w4p103 == 2 | w4p103 == 3)

* Other control variables in CP 2007
rename w3s480 female       // 女性
rename w3pgrm hs_type      // 學程類別
rename w3priv hs_private   // 公私立
rename w3urban3 hs_urban   // 都市地區

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

* keep only useful variables
keep stud_id cp divorce severe_divorce female                        ///
     general_high hs_private hs_urban hs_capital hs_science          ///
     hs_scarea_north hs_scarea_middle hs_scarea_south hs_scarea_east

* save data
save "$workData\CP_divorce.dta", replace

********************************************
* Merge with 2009 future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import data
use "$rawData\CP\CP_2009.dta", clear 

* Outcome Variable (1): university degree
recode cp09v06 (7/98 = .)
gen university = (cp09v06 == 5) | (cp09v06 == 6) if cp09v06 != .

* Outcome Variable (2): Public University
recode cp09v08_u (11/99 = .)
gen public = (cp09v08_u == 1) if cp09v08_u != .
gen all_public = (cp09v08_u == 1) | (cp09v08_u == 2) | (cp09v08_u == 3) | (cp09v08_u == 4) if cp09v08_u != .

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce.dta", nogenerate
save "$workData\CP_divorce_Outcome2009.dta", replace


********************************************
* Merge with 2013 CP future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import 2013 data
use "$rawData\CP\CP_2013.dta", clear 

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009.dta", keepusing(university) nogenerate

* Update Outcome Variable (1): university degree
recode cp13v29 (9/98 = .)
gen university_1 = (cp13v29 == 6 | cp13v29 == 7 | cp13v29 == 8) if cp13v29 !=.
replace university = 1 if (university == 0 & university_1 == 1)
drop university_1

* Outcome Variable (3): Wage Level at 2013
recode cp13v52 (96/99 = .)
gen wage_level_2013 = cp13v52 - 1

* Outcome Variable (4): Working Year at 2013
recode cp13v54 (12/99 = .) // when to start first job
recode cp13v50 (12/99 = .) // when to start job(now)
gen work_year_2013 = 12 - cp13v54
count if work_year_2013 != . // 712

replace work_year_2013 = 12 - cp13v50 if (cp13v53 == 1|cp13v53 == 96|cp13v53 == 97|cp13v53 == 98) 
count if work_year_2013 != . // 2,138

* keep only useful variables
keep stud_id wage_level_2013 work_year_2013 university

* Save data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009.dta", nogenerate replace update
save "$workData\CP_divorce_Outcome2009_2013.dta", replace



********************************************
* Merge with 2013 NCP future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import 2013 data
use "$rawData\NCP\NCP_2011_2013.dta", clear 

* Outcome Variable (1): university degree
recode ncp11v29 (11/98 = .)
gen university = (ncp11v29 == 7) | (ncp11v29 == 8) | (ncp11v29 == 9) | (ncp11v29 == 10) if ncp11v29 != .

* Outcome Variable (2): Public University
recode ncp11v32_u (11/99 = .)
gen public = (ncp11v32_u == 1) if ncp11v32_u != .
gen all_public = (ncp11v32_u == 1) | (ncp11v32_u == 2) | (ncp11v32_u == 3) | (ncp11v32_u == 4) | (ncp11v32_u == 5) if ncp11v32_u != .

* Outcome Variable (5): Wage Level at 2013
recode ncp11v47 (96/99 = .)
gen wage_level_2013 = ncp11v47 - 1

* Outcome Variable (6): Working Year at 2013
recode ncp11v49 (7/99 = .) // when to start first job
recode ncp11v45 (7/99 = .) // when to start job(now)
gen work_year_2013 = 13 - ncp11v49
count if work_year_2013 !=. // 91

replace work_year_2013 = 13 - ncp11v45 if (ncp11v48 == 1 | ncp11v48 == 96 | ncp11v48 == 97 | ncp11v48 == 98 |ncp11v48 == 99)
count if work_year_2013 !=. // 91

* keep only useful variables
keep stud_id university public wage_level_2013 work_year_2013 all_public

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta", nogenerate
save "$workData\CP_divorce_Outcome2009_2013.dta", replace


********************************************
* Merge with 2019 CP future working data: 
* Find Y = wage_level.  
********************************************
use "$rawData\CP\CP_2019.dta", clear 

* Outcome Variable (7): Wage Level at 2019
recode cp19v66 (22/99 = .)
gen wage_level_2019 = cp19v66 - 1

* keep only useful variables
keep stud_id wage_level_2019

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta", nogenerate
save "$workData\CP_divorce_Outcome2009_2019.dta", replace


