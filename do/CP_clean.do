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


********************************************
***         CP 2001 Parent Data          ***
********************************************

* Import data
use "$rawData\CP\CP_2001_H_parent.dta", clear

* Father & mother Education
recode w1faedu (6/99 = .)
recode w1moedu (6/99 = .)
rename w1faedu faedu
rename w1moedu moedu

* Parents conflict
recode w1p308 (97/99 = .)    // 功課衝突
recode w1p309 (97/99 = .)    // 交友衝突
recode w1p310 (97/99 = .)    // 功課聯絡
recode w1p311 (97/99 = .)    // 心理健康
recode w1p312 (97/99 = .)    // 品行問題
recode w1p313 (97/99 = .)    // 同儕家長

label define map_frequency 0 "從未" 1 "偶爾" 2 "有時" 3 "經常"
forvalues i = 8/9{
    replace w1p30`i' = w1p30`i' - 1
    label value w1p30`i' map_frequency
}
forvalues i = 10/12{
    replace w1p3`i' = w1p3`i' - 1
    label value w1p3`i' map_frequency
}

replace w1p313 = w1p313 - 1
label define map_w1p313 0 "都不認識" 1 "認識少部分" 2 "認識一半左右" 3 "大多認識"
label value w1p313 map_w1p313

* Parents expectation
recode w1p401 (97/99 = .)    // 功課聯絡
recode w1p501 (97/99 = .)    // 安排戶籍
recode w1p502 (97/99 = .)    // 安排班級
recode w1p503 (97/99 = .)    // 安排出國
recode w1p510a (97/99 = .)   // 期待學歷
recode w1p511 (97/99 = .)    // 期待出國

label define map_yesno 0 "從來沒有過" 1 "曾經有過"

recode w1p401 (1 = 0) (3 = 0)
recode w1p401 (2 = 1) 
recode w1p501 (1 = 0)
recode w1p501 (2 = 1)
recode w1p502 (1 = 0)
recode w1p502 (2 = 1)
recode w1p503 (1 = 0)
recode w1p503 (2 = 1)
label value (w1p401 w1p501 w1p502 w1p503) map_yesno

rename w1p510a expect_degree
recode expect_degree (6 = 0)
count if expect_degree ==. // 68
label define map_degree 0 "沒想過/不知道" 1 "高中同等學歷" 2 "大學同等學歷" 3 "研究所學歷" 
label value expect_degree map_degree

recode w1p511 (2 = 0) (3 = -1)
label define map_w1p511 -1 "從未期待" 0 "看他自己的能力" 1 "非常期待"
label value w1p511 map_w1p511

* keep only useful variables
keep stud_id faedu moedu w1p308 w1p309 w1p310 w1p311 w1p312 w1p313   ///
     w1p401 w1p501 w1p502 w1p503 expect_degree w1p511

* save data
save "$workData\CP_parent2001.dta", replace


/* ********************************************
PDS control variable in 2001
faedu moedu
w1p308 w1p309 w1p310 w1p311 w1p312 w1p313
w1p401 w1p501 w1p502 w1p503 expect_degree w1p511
********************************************* */



********************************************
***         SH 2001 Teacher Data         ***
********************************************
foreach i in "c" "d" "e" "m"{
    * Import data set
    use "$rawData\CP\CP_2001_D_`i't.dta", clear

    * Teaching situation
    recode w1t105 (97/99 = .)    // 每周課堂數
    recode w1t106 (97/99 = .)    // 周末上課
    recode w1t109 (97/99 = .)    // 幾天在校
    recode w1t112 (97/99 = .)    // 改作業時間
    recode w1t113 (97/99 = .)    // 準備教材時間
    recode w1t114 (97/99 = .)    // 個別輔導時間
    recode w1t115 (97/99 = .)    // 家長聯絡時間
    recode w1t116 (97/99 = .)    // 課後輔導時間


    * Teaching degrees
    recode w1t201 (97/99 = .)    // 最高學歷
    recode w1t202 (97/99 = .)    // 學歷國內外
    recode w1t202 (3 = 2)        // 學歷國內外

    replace w1t201 = w1t201 - 1
    replace w1t202 = w1t202 - 1

    * Students' situation
    recode w1t308 (97/99 = .)    // 問題學生
    recode w1t309 (97/99 = .)    // 缺席曠課
    recode w1t310 (97/99 = .)    // 不尊重老師
    recode w1t311 (97/99 = .)    // 不認真學習
    recode w1t315 (97/99 = .)    // 不教學認真
    recode w1t316 (97/99 = .)    // 不比較學生成績
    recode w1t318 (97/99 = .)    // 行為問題
    recode w1t319 (97/99 = .)    // 程度不好
    recode w1t320 (97/99 = .)    // 程度差異
    recode w1t325 (97/99 = .)    // 家長困擾
    recode w1t326 (97/99 = .)    // 政策變化

    replace w1t308 = w1t308 - 1
    replace w1t309 = w1t309 - 1
    replace w1t310 = w1t310 - 1
    replace w1t311 = w1t311 - 1
    replace w1t315 = w1t315 - 1
    replace w1t316 = w1t316 - 1
    replace w1t318 = w1t318 - 1
    replace w1t319 = w1t319 - 1
    replace w1t320 = w1t320 - 1
    replace w1t325 = w1t325 - 1
    replace w1t326 = w1t326 - 1

    label define map_percentage 0 "幾乎沒有" 1 "少部分如此" 2 "至少一半如此" 3 "大部分如此"
    label define map_frequency 0 "從未" 1 "偶爾" 2 "有時" 3 "經常"
    label value (w1t308 w1t309 w1t310 w1t311 w1t315 w1t316) map_percentage
    label value (w1t318 w1t319 w1t320) map_frequency

    label variable w1t310 "w1:學生不尊重老師?"        // 邏輯剛好相反
    label variable w1t311 "w1:學生不認真學習?"
    label variable w1t315 "w1:老師教學不認真?"
    label variable w1t316 "w1:老師不相互比較學生成績?"

    * 標記為dt檔案變數
    rename (w1t105 w1t106 w1t109 w1t112 w1t113 w1t114 w1t115 w1t116 w1t201 w1t202        ///
            w1t308 w1t309 w1t310 w1t311 w1t315 w1t316 w1t318 w1t319 w1t320 w1t325 w1t326)        ///
           (w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
            w1t201_`i' w1t202_`i' w1t308_`i' w1t310_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i'     ///
            w1t318_`i' w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')

    * keep useful variables
    keep stud_id                                                                                     ///
         w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
         w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i'     ///
         w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i'

    * save dataset
    save "$workData\CP_teacher_`i'_2001.dta", replace

}

/* ********************************************
PDS control variable in 2001
general_high science hs_private urban
w1t105_d w1t106_d w1t109_d w1t112_d w1t113_d w1t114_d w1t115_d w1t116_d    
w1t201_d w1t202_d w1t308_d w1t309_d w1t311_d w1t315_d w1t316_d w1t318_d
w1t319_d w1t320_d w1t325_d w1t326_d
********************************************* */

********************************************
***    SH 2001 Teacher_d Data (class)    ***
********************************************

* Import dataset
use "$rawData\CP\CP_2001_D_dtc.dta", clear

* Teachers' feeling
forvalues i = 1/8{
    recode w1dtc0`i' (97/99 = .)
}
recode w1dtc08 (5 = .)

* Change values
replace w1dtc01 = w1dtc01 - 1         // 學生好帶
replace w1dtc02 = - (w1dtc02) + 3     // 學生程度好
replace w1dtc03 = w1dtc03 - 1         // 老師見家長數
replace w1dtc04 = w1dtc04 - 1         // 親師會次數
replace w1dtc05 = - (w1dtc05) + 4     // 老師家長熟識
replace w1dtc06 = - (w1dtc06) + 4     // 家長協助班務
replace w1dtc07 = - (w1dtc07) + 4     // 家長升學壓力
replace w1dtc08 = - (w1dtc08) + 4      // 家長之間熟識

* label variables
label define map_w1dtc01 0 "很難帶" 1 "比較難帶" 2 "還算好帶" 4 "很好帶"
label value w1dtc01 map_w1dtc01
label define map_w1dtc02 -2 "特別差" -1 "比較差" 0 "差不多" 1 "比較好" 2 "特別好"
label value w1dtc02 map_w1dtc02
label define map_w1dtc03 0 "0" 1 "1-5位" 2 "6-10位" 3 "11-15位" 4 "16-20位" 5 "21位以上"
label value w1dtc03 map_w1dtc03
label define map_w1dtc04 0 "0" 1 "1" 2 "2" 3 "3" 4 "4次以上"
label value w1dtc04 map_w1dtc04
label define map_w1dtc05 0 "幾乎不熟" 1 "熟識少數幾位" 2 "熟識不少位" 3 "大部分都熟"
label value w1dtc05 map_w1dtc05
label define map_w1dtc06 0 "幾乎不願意" 1 "少部分願意" 2 "大部分願意" 3 "都很願意"
label value w1dtc06 map_w1dtc06
label define map_w1dtc07 0 "完全沒壓力" 1 "壓力不大" 2 "壓力大" 3 "壓力非常大"
label value w1dtc07 map_w1dtc07
label define map_w1dtc08 0 "幾乎不熟" 1 "少部分熟識" 2 "熟識不少位" 3 "大部分都熟識"
label value w1dtc08 map_w1dtc08

* keep data
keep stud_id w1dtc01 w1dtc02 w1dtc03 w1dtc04 w1dtc05 w1dtc06 w1dtc07 w1dtc08

* save data
save "$workData\CP_teacher_dc_2001.dta", replace

