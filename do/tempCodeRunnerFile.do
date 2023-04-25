foreach i in "c" "e" "m"{
* Import data set
use "$rawData\SH\SH_2001_C_`i't.dta", clear

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
        w1t308 w1t309 w1t311 w1t315 w1t316 w1t318 w1t319 w1t320 w1t325 w1t326)        ///
        (w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
        w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i' ///
        w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i')

* keep useful variables
keep w1t105_`i' w1t106_`i' w1t109_`i' w1t112_`i' w1t113_`i' w1t114_`i' w1t115_`i' w1t116_`i'     ///
     w1t201_`i' w1t202_`i' w1t308_`i' w1t309_`i' w1t311_`i' w1t315_`i' w1t316_`i' w1t318_`i' ///
     w1t319_`i' w1t320_`i' w1t325_`i' w1t326_`i'

* save dataset
save "$workData\SH_teacher_`i'_2001.dta", replace

}
