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
	global do = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\do"
	global rawData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\rawData"
	global workData = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\workData"
	global log = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\log"
	global pic = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\pic"
}



* Clean CP 2001 data
cd "$rawData"
use "CP\CP_2001_A_student.dta", clear
drop if w1s208 == 97 | w1s208 == 99
gen divorce_2001 = (w1s208 > 1) //specify the divorce status in 2001
keep stud_id divorce_2001


* Merge with CP 2007 data, identify divorce in Senior high 
cd "$rawData"
merge 1:1 stud_id using "CP\CP_2007_A_student.dta", keepusing(w4s2065)
tab _merge
gen divorce_2007 = (w4s2065 == 1) //specify the divorce status in 2003
keep stud_id divorce_2001 divorce_2007


/* **********************************************
merge 1:1 stud_id using "CP\CP_2007_A_student.dta", keepusing(w4s2065)


                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |     15,654       78.99       78.99
         using only (2) |         30        0.15       79.14
            matched (3) |      4,133       20.86      100.00
------------------------+-----------------------------------
                  Total |     19,817      100.00


********************************************** */



* Compare the divorce status between 2001 & 2003

// define severe_divorce: divorce in twelve grade
gen severe_divorce = (divorce_2001 == 0 & divorce_2007 == 1) 
// define divorce: once divorce in the past
gen divorce = (divorce_2001 == 1) | (divorce_2007 == 1)
keep stud_id divorce severe_divorce

save "$workData\CP_divorce.dta", replace


********************************************
* Merge with 2009 future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
use "$rawData\CP\CP_2009.dta", clear 
recode cp09v06 (7/98 = .)
gen university = (cp09v06 == 5) | (cp09v06 == 6) if cp09v06 != .

recode cp09v08_u (11/99 = .)
gen public = (cp09v08_u == 1) | (cp09v08_u == 2) | (cp09v08_u == 3) | (cp09v08_u == 4) if cp09v08_u != .
gen sever_public = (cp09v08_u == 1) if cp09v08_u != .

recode sh09v53 (96/99 = .)
gen wage_level_2009 = sh09v53 - 1

recode sh09v55 (12/99 = .) // when to start first job
recode sh09v51 (12/99 = .) // when to start job(now)
gen work_year_2009 = 12 - sh09v55
count if work_year_2009 !=. // 2,055

replace work_year_2009 = 12 - sh09v51 if (sh09v54 == 1|sh09v54 == 96|sh09v54 == 97|sh09v54 == 98)
count if work_year_2009 !=. // 6,474

/* 如果現在這份不是第一份工作，但她並沒有第一份工作是什麼時候開始的資料，那要用現在這份工作是什麼時候開始的資料作為工作年份嗎？
目前先納入
*/

keep stud_id university public wage_level_2009 work_year_2009

// Merge with school time data
merge 1:1 stud_id using "$workData\SH_divorce.dta"
drop _merge
save "$workData\SH_divorce_Outcome2009.dta", replace

/* 
merge 1:1 stud_id using "$workData\SH_divorce.dta"
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        154        0.81        0.81
            matched (3) |     18,897       99.19      100.00
------------------------+-----------------------------------
                  Total |     19,051      100.00


*/


********************************************
* Merge with 2015 future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
use "SH\SH_2015.dta", clear 

recode sh15v57 (93/99 = .)
gen wage_level_2015 = sh15v57 - 1

recode sh15v60 (19/99 = .) // when to start first job
recode sh15v55 (19/99 = .) // when to start job(now)
gen work_year_2015 = 19 - sh15v60
count if work_year_2015!=. // 5,344

replace work_year_2015 = 19 - sh15v55 if (sh15v59 == 1|sh15v59 == 96|sh15v59 == 97|sh15v59 == 98) 
count if work_year_2015!=. // 7,920

keep stud_id wage_level_2015 work_year_2015

// Merge with school time data
merge 1:1 stud_id using "$workData\SH_divorce_Outcome2009.dta"
drop _merge
save "$workData\SH_divorce_Outcome2009_2015.dta", replace


/*
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        643        3.40        3.40
         using only (2) |      2,975       15.74       19.15
            matched (3) |     15,279       80.85      100.00
------------------------+-----------------------------------
                  Total |     18,897      100.00
*/




********************************************
* Regression (2009)
********************************************
use "$workData\SH_divorce_Outcome2009_2015.dta", clear

// SH: analysis - university on severe_divorce/divorce
reg university divorce, r
reg university severe_divorce, r

reg public divorce, r
reg public severe_divorce, r

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

reg wage_level_2009 divorce i.faedu i.moedu work_year_2009, r
* reg wage_level_2009 severe_divorce i.faedu i.moedu work_year_2009, r
reg wage_level_2015 divorce i.faedu i.moedu work_year_2015, r
reg wage_level_2015 severe_divorce i.faedu i.moedu work_year_2015, r


reg work_year_2009 divorce i.faedu i.moedu, r
* reg work_year_2009 severe_divorce i.faedu i.moedu , r
reg work_year_2015 divorce i.faedu i.moedu, r
* reg work_year_2015 severe_divorce i.faedu i.moedu, r



