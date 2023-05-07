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
do "$do/CP_clean.do"
use "$workData\SH_divorce_outcome2009_outcome2015.dta", clear
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

qui reg wage_level_2009 divorce, r
est sto wage_level_2009_1
qui reg wage_level_2009 severe_divorce, r
est sto wage_level_2009_2
qui reg wage_level_2013 divorce, r
est sto wage_level_2013_1
qui reg wage_level_2013 severe_divorce, r
est sto wage_level_2013_2
qui reg wage_level_2019 divorce, r
est sto wage_level_2019_1
qui reg wage_level_2019 severe_divorce, r
est sto wage_level_2019_2


qui reg work_year_2009 divorce, r
est sto work_year_2009_1
qui reg work_year_2013 divorce, r
est sto work_year_2013_1

// SH: parent
use "$rawData\CP\CP_2001_G_parent.dta", clear
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
rename w1faedu faedu
rename w1moedu moedu
keep stud_id faedu moedu


// SH: analysis - adding counfounder
cd "$workData"
merge 1:1 stud_id using "CP_divorce_Outcome2009_2019.dta"

qui reg university divorce i.faedu i.moedu, r
est sto university_3
qui reg university severe_divorce i.faedu i.moedu, r
est sto university_4


qui reg public divorce i.faedu i.moedu, r
est sto public_3
qui reg public severe_divorce i.faedu i.moedu, r
est sto public_4


qui reg wage_level_2009 divorce i.faedu i.moedu work_year_2009, r
est sto wage_level_2009_3
qui reg wage_level_2009 severe_divorce i.faedu i.moedu work_year_2009, r
est sto wage_level_2009_4
qui reg wage_level_2013 divorce i.faedu i.moedu work_year_2013, r
est sto wage_level_2013_3
qui reg wage_level_2013 severe_divorce i.faedu i.moedu work_year_2013, r
est sto wage_level_2013_4
qui reg wage_level_2019 divorce i.faedu i.moedu, r
est sto wage_level_2019_3
qui reg wage_level_2019 severe_divorce i.faedu i.moedu, r
est sto wage_level_2019_4

qui reg work_year_2009 divorce i.faedu i.moedu, r
est sto work_year_2009_2
qui reg work_year_2009 severe_divorce i.faedu i.moedu , r
est sto work_year_2009_3

qui reg work_year_2013 divorce i.faedu i.moedu, r
est sto work_year_2013_2
qui reg work_year_2013 severe_divorce i.faedu i.moedu, r
est sto work_year_2013_3

est tab university_1 university_2 university_3 university_4, p
est tab public_1 public_2 public_3 public_4, p
est tab wage_level_2009_1 wage_level_2009_2 wage_level_2009_3 wage_level_2009_4, p
est tab wage_level_2013_1 wage_level_2013_2 wage_level_2013_3 wage_level_2013_4, p
est tab wage_level_2019_1 wage_level_2019_2 wage_level_2019_3 wage_level_2019_4, p
est tab work_year_2009_1 work_year_2009_2 work_year_2009_3, p
est tab work_year_2013_1 work_year_2013_2 work_year_2013_3, p

