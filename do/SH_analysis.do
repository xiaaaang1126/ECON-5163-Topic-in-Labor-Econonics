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


* Prepare the dataset
do "$do/SH_clean.do"


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



********************************************
***        Post-Double Selection         ***
********************************************

pdslasso university divorce c.($cf_2001)