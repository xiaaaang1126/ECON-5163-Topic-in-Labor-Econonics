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
***         CP 2001 Teacher Data         ***
********************************************
foreach i in "c" "d" "e" "m"{
    * Import data set
    use "$rawData\CP\CP_2001_D_`i't.dta", clear

    * Teaching situation
    recode w1t501 (97/99 = .)    // 老師性別
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

    replace w1t501 = w1t501 - 1
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

    label define map_female 0 "男" 1 "女"
    label define map_percentage 0 "幾乎沒有" 1 "少部分如此" 2 "至少一半如此" 3 "大部分如此"
    label define map_frequency 0 "從未" 1 "偶爾" 2 "有時" 3 "經常"
    label value (w1t308 w1t309 w1t310 w1t311 w1t315 w1t316) map_percentage
    label value (w1t318 w1t319 w1t320) map_frequency
    label value w1t501 map_female

    label variable w1t310 "w1:學生不尊重老師?"        // 邏輯剛好相反
    label variable w1t311 "w1:學生不認真學習?"
    label variable w1t315 "w1:老師教學不認真?"
    label variable w1t316 "w1:老師不相互比較學生成績?"

    * 標記為dt檔案變數
    rename (w1t501 w1t105 w1t106 w1t109 w1t112 w1t113 w1t114 w1t115 w1t116 w1t201 w1t202         ///
            w1t308 w1t309 w1t310 w1t311 w1t315 w1t316 w1t318 w1t319 w1t320 w1t325 w1t326)        ///
           (w1t501_`i' w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i'     ///
            w1t116_`i' w1t201_`i' w1t202_`i' w1t308_`i' w1t310_`i' w1t309_`i' w1t311_`i' w1t315_`i'     ///
            w1t316_`i' w1t318_`i' w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')

    * keep useful variables
    keep stud_id                                                                                        ///
            w1t501_`i' w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i'     ///
            w1t116_`i' w1t201_`i' w1t202_`i' w1t308_`i' w1t310_`i' w1t309_`i' w1t311_`i' w1t315_`i'     ///
            w1t316_`i' w1t318_`i' w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i'

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
***    CP 2001 Teacher_d Data (class)    ***
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


********************************************
***      CP & NP 2005 Teacher Data       ***
********************************************
foreach i in "c" "d" "e" "m"{
    * Import data set
    use "$rawData\NP\NP_withCP_2005_B_`i't.dta", clear

    * Teaching degrees
    recode w3t101 (97/99 = .)    // 老師性別
    recode w3t110 (97/99 = .)    // 最高學歷
    recode w3t117 (97/99 = .)    // 擔任教職幾年

    replace w3t101 = w3t101 - 1
    replace w3t110 = w3t110 - 2
    replace w3t117 = w3t117 - 1

    label define map_female 0 "男" 1 "女"
    label define map_degree 0 "學士" 1 "碩士" 2 "博士"
    label define map_w3t117 0 "一年以下" 1 "1-3年" 2 "3-6年" 3 "6-9年" 4 "9-20年" 5 "20年以上"

    label value w3t101 map_female
    label value w3t110 map_degree
    label value w3t117 map_w3t117

    * Teaching situation
    recode w3t203 (97/99 = .)    // 每周課堂數
    recode w3t204 (97/99 = .)    // 周末上課
    recode w3t206 (97/99 = .)    // 幾天在校
    recode w3t209 (97/99 = .)    // 家長聯絡時間
    recode w3t210 (97/99 = .)    // 課後輔導時間
    recode w3t211 (97/99 = .)    // 改作業時間
    recode w3t212 (97/99 = .)    // 準備教材時間

    replace w3t203 = w3t203 - 1
    replace w3t204 = -w3t204 + 4

    label define map_frequency 0 "從未" 1 "偶爾" 2 "有時" 3 "經常"
    label value w3t204 map_frequency

    * Students' situation
    recode w3t314 (97/99 = .)    // 問題學生
    recode w3t316 (97/99 = .)    // 程度不好
    recode w3t317 (97/99 = .)    // 程度差異
    recode w3t323 (97/99 = .)    // 家長困擾
    recode w3t324 (97/99 = .)    // 政策變化

    replace w3t314 = w3t314 - 1
    replace w3t316 = w3t316 - 1
    replace w3t317 = w3t317 - 1
    replace w3t323 = w3t323 - 1
    replace w3t324 = w3t324 - 1

    label value (w3t314 w3t316 w3t317 w3t323 w3t324) map_frequency

    * 標記為dt檔案變數
    rename (w3t101 w3t110 w3t117 w3t203 w3t204 w3t206 w3t209 w3t210    ///
            w3t211 w3t212 w3t314 w3t316 w3t317 w3t323 w3t324)          ///
           (w3t101_`i' w3t110_`i' w3t117_`i' w3t203_`i' w3t204_`i' w3t206_`i' w3t209_`i' w3t210_`i'   ///
            w3t211_`i' w3t212_`i' w3t314_`i' w3t316_`i' w3t317_`i' w3t323_`i' w3t324_`i')

    * keep useful variables
    keep stud_id w3t101_`i' w3t110_`i' w3t117_`i' w3t203_`i' w3t204_`i' w3t206_`i' w3t209_`i' ///
         w3t210_`i' w3t211_`i' w3t212_`i' w3t314_`i' w3t316_`i' w3t317_`i' w3t323_`i' w3t324_`i'

    * save dataset
    save "$workData\NPCP_teacher_`i'_2005.dta", replace

}

********************************************
***  CP & NP 2005 Teacher_d Data (class) ***
********************************************

* Import dataset
use "$rawData\NP\NP_withCP_2005_B_dtc.dta", clear

* Teachers' feeling
forvalues i = 1/8{
    recode w3dtc0`i' (97/99 = .)
}
recode w3dtc03 (6 = .)     // 學生程度好
recode w3dtc05 (5 = 0)     // 親師會次數

* Change values
replace w3dtc02 = w3dtc02 - 1         // 學生好帶
replace w3dtc03 = - (w3dtc03) + 3     // 學生程度好
replace w3dtc04 = w3dtc04 - 1         // 老師見家長數
replace w3dtc06 = - (w3dtc06) + 4     // 老師家長熟識
replace w3dtc07 = - (w3dtc07) + 4     // 家長協助班務
replace w3dtc08 = - (w3dtc08) + 4     // 家長升學壓力

* label variables
label define map_w3dtc02 0 "很難帶" 1 "比較難帶" 2 "還算好帶" 4 "很好帶"
label value w3dtc02 map_w3dtc02
label define map_w3dtc03 -2 "特別差" -1 "比較差" 0 "差不多" 1 "比較好" 2 "特別好"
label value w3dtc03 map_w3dtc03
label define map_w3dtc04 0 "0" 1 "1-5位" 2 "6-10位" 3 "11-15位" 4 "16-20位" 5 "21位以上"
label value w3dtc04 map_w3dtc04
label define map_w3dtc05 0 "0" 1 "1" 2 "2" 3 "3" 4 "4次以上"
label value w3dtc05 map_w3dtc05
label define map_w3dtc06 0 "幾乎不熟" 1 "熟識少數幾位" 2 "熟識不少位" 3 "大部分都熟"
label value w3dtc06 w3dtc06
label define map_w3dtc07 0 "幾乎不願意" 1 "少部分願意" 2 "大部分願意" 3 "都很願意"
label value w3dtc07 map_w3dtc07
label define map_w3dtc08 0 "完全沒壓力" 1 "壓力不大" 2 "壓力大" 3 "壓力非常大"
label value w3dtc08 map_w3dtc08

* keep data
keep stud_id w3dtc02 w3dtc03 w3dtc04 w3dtc05 w3dtc06 w3dtc07 w3dtc08

* save data
save "$workData\NPCP_teacher_dc_2005.dta", replace
