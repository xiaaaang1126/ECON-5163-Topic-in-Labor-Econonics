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


* Preparation
clear all
capture log close
set more off, perm
log using "$log\Homework1", text replace


* part 1: Read Data
cd $rawdata
use "SH\SH_2001_A_student.dta", clear


* part 2: Examine Data
sum w1cls_pn, detail       // number of students per classroom
tab w1s208                 // Divorse Time
inspect w1s208
duplicates report
duplicates report stud_id  // use student id to verify uniqueness


* part 3: Create Sample For Analysis: Part 1 & Part 2
gen divorse = 1 if (2 <= w1s208) & (w1s208 <= 5) & (w1s208 != .)
replace divorse = 0 if (1 == w1s208 | w1s208 >= 6) & (w1s208 != .)
egen divorseRate = mean(divorse)
label define mapping_divorse 1"divorsed" 0"not divorsed"
labe value divorse mapping_divorse
recode w1s208 (97/99 = .)
merge 1:1 stud_id using "SH\SH_2009.dta"


* part 4: Visualize Data
histogram w1s208, discrete percent width(0.5) xtitle(education period) ytitle(percent) xlabel(1 2 3 4 5, valuelabel)
save "$pic\histogram.png", replace
recode sh09v33 (9/99 = .)
gen undergraduate = 1 if (sh09v33>=5) & (sh09v33 != .)
replace undergraduate = 0 if (sh09v33<5) & (sh09v33 != .)
twoway (lfit undergraduate divorse)
save "$pic\twoway.png", replace


* part 5: Prelimilary Analysis
qui reg undergraduate divorse, r

rename _merge merge_2009
merge 1:1 stud_id using "SH/SH_2001_G_parent.dta"
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
gen fa_undergraduate = 1 if (w1faedu>=3) & (w1faedu<=5) & (w1faedu != .)
replace fa_undergraduate = 0 if (w1faedu<3 | w1faedu>5) & (w1faedu != .)
gen ma_undergraduate = 1 if (w1moedu>=3) & (w1moedu<=5) & (w1moedu != .)
replace ma_undergraduate = 0 if (w1moedu<3 | w1moedu>5) & (w1moedu != .)
qui reg undergraduate divorse fa_undergraduate ma_undergraduate, r

log close