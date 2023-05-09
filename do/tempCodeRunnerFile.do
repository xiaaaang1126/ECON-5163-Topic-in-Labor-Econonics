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
