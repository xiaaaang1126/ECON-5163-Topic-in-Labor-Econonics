* Directory
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
***         CP 2001 & 2007 Data          ***
********************************************

* Main Variable: `divorce'
use "$rawData\CP\CP_2001_B_student.dta", clear
gen cp = 1
recode w1s208 (97/99 = .)
gen divorce_2001 = (w1s208 > 1) //specify the divorce status in 2001

* Student's other information
rename w1s502 female       // 女性
rename w1priv js_private   // 公私立
rename w1urban3 js_urban   // 都市地區
rename w1scarea js_scarea  // 北中南東

recode female (97/99 = .)
replace female = female - 1
recode js_urban (1/2 = 0)
replace js_urban = 1 if js_urban == 3
gen js_scarea_north = js_scarea == 1
gen js_scarea_middle = js_scarea == 2
gen js_scarea_south = js_scarea == 3
gen js_scarea_east = js_scarea == 4
gen js_capital = (w1admarea == 11 | w1admarea == 12 | w1admarea == 25)

label define map_female 0 "男性" 1 "女性"
label define map_private 0 "公立" 1 "私立"
label define map_urban 0 "非都市" 1 "都市"
label define map_scarea_north 0 "非北部" 1 "北部"
label define map_scarea_middle 0 "非中部" 1 "中部"
label define map_scarea_south 0 "非南部" 1 "南部"
label define map_scarea_east 0 "非東部" 1 "東部"
label define map_capital 0 "非直轄市" 1 "直轄市"

label values female map_female
label values js_private map_private
label values js_urban map_urban
label values js_scarea_north map_scarea_north
label values js_scarea_middle map_scarea_middle
label values js_scarea_south map_scarea_south
label values js_scarea_east map_scarea_east
label values js_capital map_capital

* keep only useful variables
keep stud_id cp divorce_2001 female js_private js_urban js_capital ///
     js_scarea_north js_scarea_middle js_scarea_south js_scarea_east

* Merge with CP 2007 data, identify divorce in Senior high 
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2007_A_student.dta" // total obs. = 35,366
count if _merge == 1              // 15,892 obs. 只有國中資訊，沒有高中資訊
count if w4s2065 == 1             // 525 obs.
gen divorce_2007 = (w4s2065 == 1) if  w4s2065 != . //specify the divorce status in hs period


* Main Variable: `divorce' and `severe_divorce'
// 檢查divorce相關變數分布
recode w4s2062 w4s2063 w4s2064 w4s2065  (97/99 = .)
count if w4s2062 != . & w4s2063 != . & w4s2064 != . & w4s2065 != .
gen count_divorce = w4s2062 + w4s2063 + w4s2064 + w4s2065


// define severe_divorce: divorce in twelve grade
gen severe_divorce = (divorce_2001 == 0 & divorce_2007 == 1) if (divorce_2001 != . & divorce_2007 != .)
replace severe_divorce = 1 if (w4s2062 == 0 & w4s2063 == 0 & w4s2064 == 0 & w4s2065 == 1)
// define divorce: once divorce in the past
gen divorce = (divorce_2001 == 1 | w4s2062 == 1 | w4s2063 == 1 | w4s2064 == 1 | w4s2065 == 1)  ///
              if (w4s2062 != . & w4s2063 != . & w4s2064 != . & w4s2065 != .)
replace divorce = 1 if divorce_2001 == 1       



* Other control variables in CP 2007
rename w4pgrm hs_type      // 學程類別
rename w4priv hs_private   // 公私立
rename w4urban3 hs_urban   // 都市地區

recode hs_urban (1/2 = 0)
replace hs_urban = 1 if hs_urban == 3

gen general_high = hs_type == 2  if hs_type != .        // 普通高中
gen hs_scarea_north = w4scarea == 1 if w4scarea != .
gen hs_scarea_middle = w4scarea == 2 if w4scarea != .
gen hs_scarea_south = w4scarea == 3 if w4scarea != .
gen hs_scarea_east = w4scarea == 4 if w4scarea != .
gen hs_capital = (w4admarea == 11 | w4admarea == 12 | w4admarea == 25) if w4admarea != .
gen hs_science =  (w4clspgm == 21|w4clspgm == 23) if general_high == 1

label define map_general_high 0 "高職五專" 1 "普通高中"
label define map_science 0 "社會組" 1 "自然組"

label values hs_private map_private
label values hs_urban map_urban
label values hs_scarea_north map_scarea_north
label values hs_scarea_middle map_scarea_middle
label values hs_scarea_south map_scarea_south
label values hs_scarea_east map_scarea_east
label values hs_capital map_capital
label values hs_science map_science
label values general_high map_general_high

* keep only useful variables
keep stud_id cp divorce severe_divorce female js_private js_urban js_capital  ///
     js_scarea_north js_scarea_middle js_scarea_south js_scarea_east   ///
     general_high hs_private hs_urban hs_capital hs_science            ///
     hs_scarea_north hs_scarea_middle hs_scarea_south hs_scarea_east

* save data
save "$workData\CP_divorce.dta", replace

/* **********************************************
. tab divorce

    divorce |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     30,356       85.83       85.83
          1 |      5,010       14.17      100.00
------------+-----------------------------------
      Total |     35,366      100.00

. tab severe_divorce

severe_divo |
        rce |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     34,967       98.87       98.87
          1 |        399        1.13      100.00
------------+-----------------------------------
      Total |     35,366      100.00

********************************************** */



********************************************
* Merge with 2009 future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import data
use "$rawData\CP\CP_2009.dta", clear 

* Outcome Variable (1): university degree
recode cp09v06 (7/98 = .)
gen university = (cp09v06 == 5) | (cp09v06 == 6) if cp09v06 != .

* Outcome Variable (2): Public University
recode cp09v08_u (11/99 = .)
gen public = (cp09v08_u == 1) if cp09v08_u != .
gen all_public = (cp09v08_u == 1) | (cp09v08_u == 2) | (cp09v08_u == 3) | (cp09v08_u == 4) if cp09v08_u != .

* Outcome Variable (3): Wage Level at 2009
recode cp09v23 (96/99 = .)
gen wage_level_2009 = cp09v23 - 1

* Outcome Variable (4): Working Year at 2009
recode cp09v25 (7/99 = .) // when to start first job
recode cp09v21 (7/99 = .) // when to start job(now)
gen work_year_2009 = 7 - cp09v25
count if work_year_2009 !=. // 91

replace work_year_2009 = 7 - cp09v21 if (cp09v21 == 1|cp09v21 == 96|cp09v21 == 97|cp09v21 == 98)
count if work_year_2009 !=. // 91

/* 如果現在這份不是第一份工作，但她並沒有第一份工作是什麼時候開始的資料，那要用現在這份工作是什麼時候開始的資料作為工作年份嗎？
目前先納入  */

keep stud_id university public wage_level_2009 work_year_2009 all_public

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce.dta", nogenerate
save "$workData\CP_divorce_Outcome2009.dta", replace



********************************************
* Merge with 2013 CP future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import 2013 data
use "$rawData\CP\CP_2013.dta", clear 

* Outcome Variable (5): Wage Level at 2013
recode cp13v52 (96/99 = .)
gen wage_level_2013 = cp13v52 - 1

* Outcome Variable (6): Working Year at 2013
recode cp13v54 (12/99 = .) // when to start first job
recode cp13v50 (12/99 = .) // when to start job(now)
gen work_year_2013 = 12 - cp13v54
count if work_year_2013 != . // 712

replace work_year_2013 = 12 - cp13v50 if (cp13v53 == 1|cp13v53 == 96|cp13v53 == 97|cp13v53 == 98) 
count if work_year_2013 != . // 2,138

* keep only useful variables
keep stud_id wage_level_2013 work_year_2013

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta", nogenerate
save "$workData\CP_divorce_Outcome2009_2013.dta", replace



********************************************
* Merge with 2013 NCP future working data: 
* Find Y = university, public, wage_level.  
* And control variable: work_year
********************************************
* Import 2013 data
use "$rawData\NCP\NCP_2011_2013.dta", clear 

* Outcome Variable (1): university degree
recode ncp11v29 (11/98 = .)
gen university = (ncp11v29 == 7) | (ncp11v29 == 8) | (ncp11v29 == 9) | (ncp11v29 == 10) if ncp11v29 != .

* Outcome Variable (2): Public University
recode ncp11v32_u (11/99 = .)
gen public = (ncp11v32_u == 1) if ncp11v32_u != .
gen all_public = (ncp11v32_u == 1) | (ncp11v32_u == 2) | (ncp11v32_u == 3) | (ncp11v32_u == 4) | (ncp11v32_u == 5) if ncp11v32_u != .

* Outcome Variable (5): Wage Level at 2013
recode ncp11v47 (96/99 = .)
gen wage_level_2013 = ncp11v47 - 1

* Outcome Variable (6): Working Year at 2013
recode ncp11v49 (7/99 = .) // when to start first job
recode ncp11v45 (7/99 = .) // when to start job(now)
gen work_year_2013 = 13 - ncp11v49
count if work_year_2013 !=. // 91

replace work_year_2013 = 13 - ncp11v45 if (ncp11v48 == 1 | ncp11v48 == 96 | ncp11v48 == 97 | ncp11v48 == 98 |ncp11v48 == 99)
count if work_year_2013 !=. // 91

* keep only useful variables
keep stud_id university public wage_level_2013 work_year_2013 all_public

* Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta", nogenerate
save "$workData\CP_divorce_Outcome2009_2013.dta", replace


********************************************
* Merge with 2019 CP future working data: 
* Find Y = wage_level.  
********************************************
use "$rawData\CP\CP_2019.dta", clear 

* Outcome Variable (7): Wage Level at 2019
recode cp19v66 (22/99 = .)
gen wage_level_2019 = cp19v66 - 1

* keep only useful variables
keep stud_id wage_level_2019

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce_Outcome2009_2013.dta", nogenerate
save "$workData\CP_divorce_Outcome2009_2019.dta", replace


