********************************************
***  Senior High School Sample Cleaning  ***
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


********************************************
***         SH 2001 & 2003 Data          ***
********************************************

* Import Dataset (2001 & 2003)
cd "$rawData"
use "SH\SH_2001_A_student.dta", clear
merge 1:1 stud_id using "SH\SH_2001_G_parent.dta",  keepusing(w1p103) nogenerate
merge 1:1 stud_id using "SH\SH_2003_G_parent.dta",  keepusing(w2p103) nogenerate

* Main Variable: `divorce' and `severe_divorce'
recode w1p103 w2p103 (97/99 = .)
gen divorce = (w1p103 == 2 | w1p103 == 3 | w2p103 == 2 | w2p103 == 3) if (w1p103 !=. | w2p103 !=.)
gen severe_divorce = (w1p103 == 1) & (w2p103 == 2 | w2p103 == 3) if (w1p103 !=. | w2p103 !=.)
drop if divorce ==.

* Student's other information
rename w1s502 female       // 女性
rename w1priv hs_private   // 公私立
rename w1urban3 hs_urban   // 都市地區
rename w1scarea hs_scarea  // 北中南東
rename w1pgrm hs_type      // 學程類別

recode female (97/99 = .)
replace female = female - 1
recode hs_urban (1/2 = 0)
replace hs_urban = 1 if hs_urban == 3
gen hs_scarea_north = hs_scarea == 1
gen hs_scarea_middle = hs_scarea == 2
gen hs_scarea_south = hs_scarea == 3
gen hs_scarea_east = hs_scarea == 4
gen hs_capital = (w1admarea == 11 | w1admarea == 12 | w1admarea == 25)
gen general_high = hs_type == 2    // 普通高中
gen hs_science =  (w1clspgm == 21 | w1clspgm == 23) if general_high == 1

label define map_female 0 "男性" 1 "女性"
label define map_private 0 "公立" 1 "私立"
label define map_urban 0 "非都市" 1 "都市"
label define map_scarea_north 0 "非北部" 1 "北部"
label define map_scarea_middle 0 "非中部" 1 "中部"
label define map_scarea_south 0 "非南部" 1 "南部"
label define map_scarea_east 0 "非東部" 1 "東部"
label define map_capital 0 "非直轄市" 1 "直轄市"
label define map_general_high 0 "高職五專" 1 "普通高中"
label define map_science 0 "社會組" 1 "自然組"

label values female map_female
label values hs_private map_private
label values hs_urban map_urban
label values hs_scarea_north map_scarea_north
label values hs_scarea_middle map_scarea_middle
label values hs_scarea_south map_scarea_south
label values hs_scarea_east map_scarea_east
label values hs_capital map_capital
label values hs_science map_science

* keep only useful variables
keep stud_id divorce severe_divorce female hs_private hs_urban hs_capital general_high hs_science ///
     hs_scarea_north hs_scarea_middle hs_scarea_south hs_scarea_east

* Output as original data
save "$workData\SH_divorce.dta", replace


********************************************
***         SH 2009 & 2015 Data          ***
********************************************

* Import Dataset (2009 & 2015)
use "SH\SH_2009.dta", clear 
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v28 sh15v29 sh15v30 sh15v33v34_u) nogenerate

* Outcome Variable (1): university degree
recode sh09v33 sh09v36 sh15v28 sh15v29 sh15v30 (9/99 = .)
gen university_2009 = (sh09v33 == 5) | (sh09v33 == 6) | (sh09v33 == 7) | (sh09v33 == 8) if sh09v33 != .
gen university_2015 = (sh15v30 == 5) | (sh15v30 == 6) | (sh15v30 == 7) | (sh15v30 == 8) if sh15v30 != .
gen university = (university_2009 == 1 | university_2015 == 1) if university_2009 != . | university_2015 != .


* Outcome Variable (2): Public University
recode sh09v37v38_u sh15v33v34_u (11/99 = .)
gen public =  (sh09v37v38_u == 1 | sh15v33v34_u == 1)  if (sh09v37v38_u != . | sh15v33v34_u != .)
gen all_public = (sh09v37v38_u == 1 | sh09v37v38_u == 2 | sh09v37v38_u == 3 | sh09v37v38_u == 4) if (sh09v37v38_u != .)
replace all_public = 1 if (sh15v33v34_u == 1 | sh15v33v34_u == 2 | sh15v33v34_u == 3 | sh15v33v34_u == 4)

* Outcome Variable (3): Wage Level at 2009
recode sh09v53 (96/99 = .)
gen wage_level_2009 = sh09v53 - 1

* Outcome Variable (4): Wage Level at 2015
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v57) nogenerate
recode sh15v57 (93/99 = .)
gen wage_level_2015 = sh15v57 - 1

* Outcome Variable (5): Working Year at 2009
recode sh09v51 sh09v55 (12/99 = .)
gen work_year_2009 = 12 - sh09v51
replace work_year_2009 = 12 - sh09v55 if sh09v54 == 2

* Outcome Variable (6): Working Year at 2015
merge 1:1 stud_id using "SH\SH_2015.dta", keepusing(sh15v56 sh15v59 sh15v60) nogenerate
recode sh15v56 sh15v60 (90/999 = .)
gen work_year_2015 = 19 - sh15v56
replace work_year_2015 = 19 - sh15v60 if sh15v59 == 2

* Output
keep stud_id university public all_public wage_level_2009 wage_level_2015 work_year_2009 work_year_2015
save "$workData\SH_outcome2009_outcome2015.dta", replace


********************************************
***                Merge                 ***
********************************************

use "$workData\SH_divorce.dta", clear
merge 1:1 stud_id using "$workData\SH_outcome2009_outcome2015.dta", nogenerate
save "$workData\SH_divorce_outcome2009_outcome2015.dta", replace

