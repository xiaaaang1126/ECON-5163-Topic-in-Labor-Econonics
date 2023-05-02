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


********************************************
***         CP 2001 & 2003 Data          ***
********************************************

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
gen severe_public = (cp09v08_u == 1) if cp09v08_u != .

recode cp09v23 (96/99 = .)
gen wage_level_2009 = cp09v23 - 1

recode cp09v25 (7/99 = .) // when to start first job
recode cp09v21 (7/99 = .) // when to start job(now)
gen work_year_2009 = 7 - cp09v25
count if work_year_2009 !=. // 91

replace work_year_2009 = 7 - cp09v21 if (cp09v21 == 1|cp09v21 == 96|cp09v21 == 97|cp09v21 == 98)
count if work_year_2009 !=. // 91

/* 如果現在這份不是第一份工作，但她並沒有第一份工作是什麼時候開始的資料，那要用現在這份工作是什麼時候開始的資料作為工作年份嗎？
目前先納入
*/

keep stud_id university public wage_level_2009 work_year_2009 severe_public

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce.dta"
drop _merge
save "$workData\CP_divorce_Outcome2009.dta", replace

/* 
 merge 1:1 stud_id using "$workData\CP_divorce.dta"

    Result                           # of obs.
    -----------------------------------------
    not matched                        15,558
        from master                         1  (_merge==1)
        from using                     15,557  (_merge==2)

    matched                             4,260  (_merge==3)
    -----------------------------------------

*/


********************************************
* Merge with 2013 future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
use "$rawData\CP\CP_2013.dta", clear 

recode cp13v52 (96/99 = .)
gen wage_level_2013 = cp13v52 - 1

recode cp13v54 (12/99 = .) // when to start first job
recode cp13v50 (12/99 = .) // when to start job(now)
gen work_year_2013 = 12 - cp13v54
count if work_year_2013 != . // 712

replace work_year_2013 = 12 - cp13v50 if (cp13v53 == 1|cp13v53 == 96|cp13v53 == 97|cp13v53 == 98) 
count if work_year_2013 != . // 2,138

keep stud_id wage_level_2013 work_year_2013

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009.dta"
drop _merge
save "$workData\CP_divorce_Outcome2009_2013.dta", replace


/*
 merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009.dta"

    Result                           # of obs.
    -----------------------------------------
    not matched                        15,557
        from master                         0  (_merge==1)
        from using                     15,557  (_merge==2)

    matched                             4,261  (_merge==3)
    -----------------------------------------

*/

********************************************
* Merge with 2019 future working data: 
* Find Y = wage_level.  
********************************************
use "$rawData\CP\CP_2019.dta", clear 

recode cp19v66 (22/99 = .)
gen wage_level_2019 = cp19v66 - 1

keep stud_id wage_level_2019

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta"
drop _merge
save "$workData\CP_divorce_Outcome2009_2019.dta", replace


/*
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta"

    Result                           # of obs.
    -----------------------------------------
    not matched                        15,557
        from master                         0  (_merge==1)
        from using                     15,557  (_merge==2)

    matched                             4,261  (_merge==3)
    -----------------------------------------


*/



