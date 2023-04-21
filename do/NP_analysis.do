********************************************
* New Population in High School Analysis
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


* Clean NP 2005 data
* only keep sample we can identify divorce or not
cd "$rawData"
use "NP\NP_2005_A_student.dta", clear
merge 1:1 stud_id using "NP\NP_withCP_2005_G_parent.dta"
drop if _merge == 1 | _merge == 2

* generate covariates: divorce, faedu and moedu
recode w3p103 (5/99 = .)
gen divorce_2005 = (w3p103 == 2) | (w3p103 == 3) if w3p103 != .
gen father = (w3p101 <= 3) & (w3p102 == 1)
gen mother = (w3p101 <= 3) & (w3p102 == 2)
recode w3p104 (97/99 = .)
gen faedu = w3p104 if father == 1
gen moedu = w3p104 if mother == 1
label value faedu w3p104
label value moedu w3p104

* keep only a few variable for later analysis
keep stud_id divorce_2005 faedu moedu
save "$workData\NP_divorce.dta", replace


* Clean 2007 data
use "NP\NP_2007_A_student.dta", clear

