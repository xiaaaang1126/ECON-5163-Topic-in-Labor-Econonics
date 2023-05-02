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
	global rawdata = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\rawData"
	global workdata = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\workdata"
	global log = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\log"
	global pic = "C:\Users\jwutw\OneDrive\桌面\大四下資料\勞動經濟學\term_paper\pic"
}

// SH: 2001-2003 
cd "$rawData"
use "SH\SH_2001_A_student.dta", clear
drop if w1s208 == 97 | w1s208 == 99
gen divorce_2001 = (w1s208 > 1)
keep stud_id divorce_2001

merge 1:1 stud_id using "SH\SH_2003_A_student.dta", keepusing(w2s224)
drop if w2s224 == 97 | w2s224 == 99
gen divorce_2003 = (w2s224 == 1)
keep stud_id divorce_2001 divorce_2003

/* **********************************************
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        644        3.53        3.53
         using only (2) |        102        0.56        4.09
            matched (3) |     17,508       95.91      100.00
------------------------+-----------------------------------
                  Total |     18,254      100.00
********************************************** */

gen severe_divorce = (divorce_2001 == 0 & divorce_2003 == 1)
gen divorce = (divorce_2001 == 1) | (divorce_2003 == 1)
keep stud_id divorce severe_divorce
save "$workData\SH_divorce.dta", replace


// SH: university, public, wage_level.  And control variable: work_year
use "SH\SH_2009.dta", clear
recode sh09v33 (9/99 = .)
gen university = (sh09v33 == 5) | (sh09v33 == 6) | (sh09v33 == 7) | (sh09v33 == 8) if sh09v33 != .

recode sh09v37v38_u (5 = .) (10/99 = .)
gen public = (sh09v37v38_u == 1) | (sh09v37v38_u == 2) | (sh09v37v38_u == 3) | (sh09v37v38_u == 4) | (sh09v37v38_u == 4) if sh09v37v38_u != .

recode sh09v53 (96/99 = .)
gen wage_level = sh09v53 - 1

recode sh09v51 (12/99 = .)
gen work_year = 12 - sh09v51

keep stud_id university public wage_level work_year

// SH: merge
merge 1:1 stud_id using "$workData\SH_divorce.dta"
drop _merge

/*
                 _merge |      Freq.     Percent        Cum.
------------------------+-----------------------------------
        master only (1) |        643        3.40        3.40
         using only (2) |      2,975       15.74       19.15
            matched (3) |     15,279       80.85      100.00
------------------------+-----------------------------------
                  Total |     18,897      100.00
*/


// SH: analysis - university on severe_divorce/divorce
qui reg university divorce, r
qui reg university severe_divorce, r

qui reg public divorce, r
qui reg public severe_divorce, r

qui reg wage_level divorce, r
qui reg wage_level severe_divorce, r

save "$workData\SH_divorce_Outcome2009.dta", replace


// SH: parent
use "SH\SH_2001_G_parent.dta", clear
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
rename w1faedu faedu
rename w1moedu moedu
keep stud_id faedu moedu


// SH: analysis - adding counfounder
merge 1:1 stud_id using "$workData\SH_divorce_Outcome2009.dta"

qui reg university divorce i.faedu i.moedu, r
* qui reg university severe_divorce i.faedu i.moedu, r

* qui reg public divorce i.faedu i.moedu, r
* qui reg public severe_divorce i.faedu i.moedu, r

qui reg wage_level divorce i.faedu i.moedu work_year, r
* qui reg wage_level severe_divorce i.faedu i.moedu, r