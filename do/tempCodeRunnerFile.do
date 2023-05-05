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
***         CP 2001 & 2007 Data          ***
********************************************

* Main Variable: `divorce'
use "$rawData\CP\CP_2001_B_student.dta", clear
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
keep stud_id divorce_2001 female js_private js_urban js_capital ///
     js_scarea_north js_scarea_middle js_scarea_south js_scarea_east

* Merge with CP 2007 data, identify divorce in Senior high 
merge 1:1 stud_id using "$rawData\NP\NP_withCP_2007_A_student.dta", nogenerate
