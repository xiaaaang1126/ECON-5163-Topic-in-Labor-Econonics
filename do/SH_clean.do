********************************************
* Senior High School Sample Analysis
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


* Clean SH 2001 data
cd "$rawData"
use "SH\SH_2001_A_student.dta", clear
drop if w1s208 == 97 | w1s208 == 99
gen divorce_2001 = (w1s208 > 1) //specify the divorce status in 2001
keep stud_id divorce_2001


* Merge with SH 2003 data
merge 1:1 stud_id using "SH\SH_2003_A_student.dta", keepusing(w2s224)
drop if w2s224 == 97 | w2s224 == 99
gen divorce_2003 = (w2s224 == 1) //specify the divorce status in 2003
keep stud_id divorce_2001 divorce_2003


* Define 'severe_divorce' (divorce in 12-th grade) and 'divorce' (once divorced)
gen severe_divorce = (divorce_2001 == 0 & divorce_2003 == 1) 
gen divorce = (divorce_2001 == 1) | (divorce_2003 == 1)
keep stud_id divorce severe_divorce

save "$workData\SH_divorce.dta", replace



* Merge with SH 2009 data: Generate outcome variable AND control variable
use "SH\SH_2009.dta", clear 
recode sh09v33 (9/99 = .)
gen university = (sh09v33 == 5) | (sh09v33 == 6) | (sh09v33 == 7) | (sh09v33 == 8) if sh09v33 != .

recode sh09v37v38_u (5 = .) (10/99 = .)
gen public = (sh09v37v38_u == 1) | (sh09v37v38_u == 2) | (sh09v37v38_u == 3) | (sh09v37v38_u == 4) | (sh09v37v38_u == 4) if sh09v37v38_u != .
gen severe_public = (sh09v37v38_u == 1) | (sh09v37v38_u == 2) if sh09v37v38_u != .

recode sh09v53 (96/99 = .)
gen wage_level_2009 = sh09v53 - 1

recode sh09v55 (12/99 = .)  // when to start first job
recode sh09v51 (12/99 = .)  // when to start job(now)
gen work_year_2009 = 12 - sh09v55  // sample size: 2,055
replace work_year_2009 = 12 - sh09v51 if (sh09v54 == 1 | sh09v54 == 96 | sh09v54 == 97 | sh09v54 == 98)  // sample size: 6,474

keep stud_id university public severe_public wage_level_2009 work_year_2009


* Merge with SH_divorce data
merge 1:1 stud_id using "$workData\SH_divorce.dta"
drop _merge
save "$workData\SH_divorce_Outcome2009.dta", replace



* Merge with SH 2009 data: Generate outcome variable AND control variable
use "SH\SH_2015.dta", clear 
recode sh15v57 (93/99 = .)
gen wage_level_2015 = sh15v57 - 1

recode sh15v60 (19/99 = .) // when to start first job
recode sh15v55 (19/99 = .) // when to start job(now)
gen work_year_2015 = 19 - sh15v60
count if work_year_2015 != . // 5,344

replace work_year_2015 = 19 - sh15v55 if (sh15v59 == 1|sh15v59 == 96|sh15v59 == 97|sh15v59 == 98) 
count if work_year_2015 != . // 7,920

keep stud_id wage_level_2015 work_year_2015


* Merge with SH_divorce_Outcome2009 data
merge 1:1 stud_id using "$workData\SH_divorce_Outcome2009.dta"
drop _merge
save "$workData\SH_divorce_Outcome2009_Outcome2015.dta", replace





********************************************
* Regression (2009)
********************************************
use "$workData\SH_divorce_Outcome2009_2015.dta", clear


// SH: analysis - university on severe_divorce/divorce
reg university divorce, r
reg university severe_divorce, r

reg public divorce, r
reg public severe_divorce, r
reg severe_public divorce, r
reg severe_public severe_divorce, r


reg wage_level_2009 divorce, r
reg wage_level_2009 severe_divorce, r
reg wage_level_2015 divorce, r
reg wage_level_2015 severe_divorce, r

reg work_year_2009 divorce, r
reg work_year_2015 divorce, r


// SH: parent
use "$rawData\SH\SH_2001_G_parent.dta", clear
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
rename w1faedu faedu
rename w1moedu moedu
keep stud_id faedu moedu


// SH: analysis - adding counfounder
cd "$workData"
merge 1:1 stud_id using "SH_divorce_Outcome2009_2015.dta"

reg university divorce i.faedu i.moedu, r
* reg university severe_divorce i.faedu i.moedu, r

* reg public divorce i.faedu i.moedu, r
* reg public severe_divorce i.faedu i.moedu, r
* reg severe_public divorce i.faedu i.moedu, r
* reg severe_public severe_divorce i.faedu i.moedu, r



reg wage_level_2009 divorce i.faedu i.moedu work_year_2009, r
* reg wage_level_2009 severe_divorce i.faedu i.moedu work_year_2009, r
reg wage_level_2015 divorce i.faedu i.moedu work_year_2015, r
reg wage_level_2015 severe_divorce i.faedu i.moedu work_year_2015, r


reg work_year_2009 divorce i.faedu i.moedu, r
* reg work_year_2009 severe_divorce i.faedu i.moedu , r
reg work_year_2015 divorce i.faedu i.moedu, r
* reg work_year_2015 severe_divorce i.faedu i.moedu, r




