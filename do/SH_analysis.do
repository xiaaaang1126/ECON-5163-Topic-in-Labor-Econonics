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
use "$workData\SH_divorce_outcome2009_outcome2015.dta", clear


********************************************
***           Baseline Model             ***
********************************************

* Outcome Variable (1): University
reg university divorce, r               // t = -3.81 √
reg university severe_divorce, r        // t = 0.532

* Outcome Variable (2): Public University
reg public divorce, r                   // t = -0.84 
reg public severe_divorce, r            // t = 0.07
reg severe_public divorce, r            // t = -1.13
reg severe_public severe_divorce, r     // t = 0.18

* Outcome Variable (3): Wage Level at 2009
reg wage_level_2009 divorce, r          // t = 0.97
reg wage_level_2009 severe_divorce, r   // t = 0.41

* Outcome Variable (4): Wage Level at 2015
reg wage_level_2015 divorce, r          // t = 0.30
reg wage_level_2015 severe_divorce, r   // t = 1.90 √

* Outcome Variable (5): Working Year at 2009
reg work_year_2009 divorce, r           // t = 3.13 √

* Outcome Variable (6): Working Year at 2015
reg work_year_2015 divorce, r           // t = 1.40



********************************************
***           Adding Confounder          ***
********************************************

* Import Data
merge 1:1 stud_id using "$workData\SH_parent2001.dta", nogenerate

* Outcome Variable (1): University
reg university divorce i.faedu i.moedu, r               // t = -3.20 √
reg university severe_divorce i.faedu i.moedu, r        // t = -0.87

* Outcome Variable (2): Public University
reg public divorce i.faedu i.moedu, r                   // t = 0.24 
reg public severe_divorce i.faedu i.moedu, r            // t = -0.05
reg severe_public divorce i.faedu i.moedu, r            // t = -0.16
reg severe_public severe_divorce i.faedu i.moedu, r     // t = 0.27

* Outcome Variable (3): Wage Level at 2009
reg wage_level_2009 divorce i.faedu i.moedu, r          // t = 1.35
reg wage_level_2009 severe_divorce i.faedu i.moedu, r   // t = 0.04

* Outcome Variable (4): Wage Level at 2015
reg wage_level_2015 divorce i.faedu i.moedu, r          // t = 0.92
reg wage_level_2015 severe_divorce i.faedu i.moedu, r   // t = 1.81 √

* Outcome Variable (5): Working Year at 2009
reg work_year_2009 divorce i.faedu i.moedu, r           // t = 3.59 √

* Outcome Variable (6): Working Year at 2015
reg work_year_2015 divorce i.faedu i.moedu, r           // t = 0.79


********************************************
***        Post-Double Selection         ***
********************************************
vl create cf_2001 = (w1s2023 w1s2024 w1s210 w1s211 w1s212 w1s213 w1s219 w1s220 w1s221 w1s222 w1s223 w1s224 w1s225 w1s226 w1s227 w1s2281 w1s2282 w1s2283 w1s2284 w1s2285 w1s2286 w1s229 w1s230 w1s231 w1s232 w1s233 w1s2341 w1s2342 w1s2343 w1s2344 w1s2345 w1s2346 w1s235 w1s236 w1s237 w1s238 w1s241 w1s242 w1s253 w1s254 w1s255 w1s256 w1s508 w1s509 w1s510 w1s511 w1s512 w1s513 w1s514 w1s515 w1s516 w1s517 w1s518 w1s519 w1s520 w1s521 w1s522 w1s523 w1s535 w1s536 w1s537 w1s538 w1s539 w1s540 w1s541 w1s542 w1s543 w1s544 w1s545 w1s546 w1s547 w1s548 w1s549 w1s550 w1s551 w1s552 w1s553b w1s553c w1s554b w1s554c w1s555 w1s556 w1s557 w1s558 w1s559 w1s560)
pdslasso university divorce $cf_2001, rob
reg university $cf_2001