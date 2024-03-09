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
*do "$do/SH_clean.do"
use "$workData\SH_divorce_outcome2009_outcome2015.dta", clear


********************************************
***           Baseline Model             ***
********************************************

* Outcome Variable (1): University
qui reg university divorce, r               // t = -3.81 √
est sto university_1
qui reg university severe_divorce, r        // t = 0.532
est sto university_2
* Outcome Variable (2): Public University
qui reg public divorce, r                   // t = -0.84 
est sto public_1
qui reg public severe_divorce, r            // t = 0.07
est sto public_2

qui reg all_public divorce, r            // t = -1.13
qui reg all_public severe_divorce, r     // t = 0.18

* Outcome Variable (3): Wage Level at 2009
qui reg wage_level_2009 divorce, r          // t = 0.97
est sto wage_level_2009_1
qui reg wage_level_2009 severe_divorce, r   // t = 0.41
est sto wage_level_2009_2


* Outcome Variable (4): Wage Level at 2015
qui reg wage_level_2015 divorce, r          // t = 0.30
est sto wage_level_2015_1
qui reg wage_level_2015 severe_divorce, r   // t = 1.90 √
est sto wage_level_2015_2

* Outcome Variable (5): Working Year at 2009
qui reg work_year_2009 divorce, r           // t = 3.13 √
est sto work_year_2009_1

* Outcome Variable (6): Working Year at 2015
qui reg work_year_2015 divorce, r           // t = 1.40
est sto work_year_2015_1



********************************************
***           Adding Confounder          ***
********************************************

* Import Data
merge 1:1 stud_id using "$workData\SH_parent2001.dta", nogenerate