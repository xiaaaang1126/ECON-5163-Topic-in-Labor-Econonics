********************************************
***  Senior High School Sample Cleaning  ***
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
***         SH 2001 & 2003 Data          ***
********************************************

* Import Dataset (2001 & 2003)
cd "$rawData"
use "SH\SH_2001_A_student.dta", clear
merge 1:1 stud_id using "SH\SH_2003_A_student.dta", keepusing(w2s224) nogenerate

* Main Variable: `divorce' and `severe_divorce'
recode w1s208 w2s224 (97/99 = .)
recode w2s224 (2 = 0)
gen divorce_2001 = (w1s208 > 1) if w1s208 != .
gen divorce_2003 = (w2s224 == 1) if w2s224 != .
gen divorce = divorce_2001 == 1 & divorce_2003 == 1 if (w1s208 != . & w2s224 != .)
gen severe_divorce = divorce_2001 == 0 & divorce_2003 == 1 if (w1s208 != . & w2s224 != .)

* (Potential) Confouder: `cf_2001'
recode w1s2023 w1s2024 w1s210 w1s211 w1s212 w1s213 w1s219 w1s220 w1s221 w1s222 w1s223 w1s224 w1s225 w1s226 w1s227 w1s2281 w1s2282 w1s2283 w1s2284 w1s2285 w1s2286 w1s229 w1s230 w1s231 w1s232 w1s233 w1s2341 w1s2342 w1s2343 w1s2344 w1s2345 w1s2346 w1s235 w1s236 w1s237 w1s238 w1s241 w1s242 w1s253 w1s254 w1s255 w1s256 (90/99 = .)  // (2) Parent 
recode w1s508 w1s509 w1s510 w1s511 w1s512 w1s513 w1s514 w1s515 w1s516 w1s517 w1s518 w1s519 w1s520 w1s521 w1s522 w1s523  w1s535 w1s536 w1s537 w1s538 w1s539 w1s540 w1s541 w1s542 w1s543 w1s544 w1s545 w1s546 w1s547 w1s548 w1s549 w1s550 w1s551 w1s552 w1s553b w1s553c w1s554b w1s554c w1s555 w1s556 w1s557 w1s558 w1s559 w1s560 (90/99 = .) // (5) personal characteristic
global cf_2001 (w1s2023 w1s2024 w1s210 w1s211 w1s212 w1s213 w1s219 w1s220 w1s221 w1s222 w1s223 w1s224 w1s225 w1s226 w1s227 w1s2281 w1s2282 w1s2283 w1s2284 w1s2285 w1s2286 w1s229 w1s230 w1s231 w1s232 w1s233 w1s2341 w1s2342 w1s2343 w1s2344 w1s2345 w1s2346 w1s235 w1s236 w1s237 w1s238 w1s241 w1s242 w1s253 w1s254 w1s255 w1s256 w1s508 w1s509 w1s510 w1s511 w1s512 w1s513 w1s514 w1s515 w1s516 w1s517 w1s518 w1s519 w1s520 w1s521 w1s522 w1s523  w1s535 w1s536 w1s537 w1s538 w1s539 w1s540 w1s541 w1s542 w1s543 w1s544 w1s545 w1s546 w1s547 w1s548 w1s549 w1s550 w1s551 w1s552 w1s553b w1s553c w1s554b w1s554c w1s555 w1s556 w1s557 w1s558 w1s559 w1s560)

* Output
keep stud_id divorce severe_divorce $cf_2001
save "$workData\SH_divorce.dta", replace


********************************************
***         SH 2009 & 2015 Data          ***
********************************************

* Import Dataset (2009 & 2003)
use "SH\SH_2009.dta", clear 
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v28 sh15v29 sh15v30) nogenerate

* Outcome Variable (1): university degree
recode sh09v33 sh09v36 sh15v28 sh15v29 sh15v30 (9/99 = .)
gen university_2009 = (sh09v33 == 5) | (sh09v33 == 6) | (sh09v33 == 7) | (sh09v33 == 8) if sh09v33 != .
gen university_2015 = (sh15v30 == 5) | (sh15v30 == 6) | (sh15v30 == 7) | (sh15v30 == 8) if sh15v30 != .
replace university_2015 = 1 if (sh15v28 == 1 & university_2009 == 1)
replace university_2015 = 1 if (sh15v28 == 1 & sh15v30 >= 5 & sh15v30 <= 8)
gen university = university_2009 == 1 | university_2015 == 1 if university_2009 != . | university_2015 != .

* Outcome Variable (2): Public University
recode sh09v37v38_u (5 = .) (11/99 = .)
gen public = (sh09v37v38_u == 1) | (sh09v37v38_u == 2) | (sh09v37v38_u == 3) | (sh09v37v38_u <= 4) if sh09v37v38_u != .
gen severe_public = (sh09v37v38_u == 1) | (sh09v37v38_u == 2) if sh09v37v38_u != .

* Outcome Variable (3): Wage Level at 2009
recode sh09v53 (96/99 = .)
gen wage_level_2009 = sh09v53 - 1

* Outcome Variable (4): Wage Level at 2009
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v57) nogenerate
recode sh15v57 (93/99 = .)
gen wage_level_2015 = sh15v57 - 1

* Outcome Variable (5): Working Year at 2009
recode sh09v51 sh09v55 (12/99 = .)
gen work_year_2009 = 12 - sh09v51
replace work_year_2009 = 12 - sh09v55 if sh09v54 == 2

* Outcome Variable (6): Working Year at 2015
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v56 sh15v59 sh15v60) nogenerate
recode sh15v56 sh15v60 (90/999 = .)
gen work_year_2015 = 19 - sh15v56
replace work_year_2015 = 19 - sh15v60 if sh15v59 == 2

* Output
keep stud_id university public severe_public wage_level_2009 wage_level_2015 work_year_2009 work_year_2015
save "$workData\SH_outcome2009_outcome2015.dta", replace


********************************************
***                Merge                 ***
********************************************

use "$workData\SH_divorce.dta", clear
merge 1:1 stud_id using "$workData\SH_outcome2009_outcome2015.dta", nogenerate
save "$workData\SH_divorce_outcome2009_outcome2015.dta", replace


********************************************
***         SH 2001 Parent Data          ***
********************************************

use "$rawData\SH\SH_2001_G_parent.dta", clear
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
rename w1faedu faedu
rename w1moedu moedu
keep stud_id faedu moedu
save "$workData\SH_parent2001.dta", replace