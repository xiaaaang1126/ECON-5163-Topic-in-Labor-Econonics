********************************************
***        Two Sample Comparison         ***
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


* Import SH & NPCP Dataset
use "$workData\SH_sp_outcome2009_outcome2015.dta", clear
destring(stud_id), replace
replace stud_id = stud_id + 100000
keep stud_id sp sp_comply sp_severe university master public work_year
tostring(stud_id), replace
merge 1:1 stud_id using "$workData\NPCP_sp_outcome2009_outcome2013", nogenerate


* Divide into two group and graph
destring(stud_id), replace
gen NPCP = (stud_id <= 100000)
graph bar (percent) university, over(sp, relabel(1 "non-sp" 2 "sp")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\university_sp.png", replace

graph bar (percent) public, over(sp, relabel(1 "non-sp" 2 "sp")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Public University Degree (%)")
graph export "$pic\public_sp.png", replace

graph bar (percent) master, over(sp, relabel(1 "non-sp" 2 "sp")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Master Degree (%)")
graph export "$pic\master_sp.png", replace


*