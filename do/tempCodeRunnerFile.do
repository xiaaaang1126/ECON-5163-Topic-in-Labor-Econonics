use "$workData\SH_sp_outcome2009_outcome2015.dta", clear
destring(stud_id), replace
replace stud_id = stud_id + 100000
keep stud_id sp sp_comply sp_severe university master public work_year
tostring(stud_id), replace
merge 1:1 stud_id using "$workData\NPCP_sp_outcome2009_outcome2013", nogenerate


* Divide into two group and graph
destring(stud_id), replace
gen NPCP = (stud_id <= 100000)
graph bar (mean) university, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\university_sp.png", replace

graph bar (mean) public, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Public University Degree (%)")
graph export "$pic\public_sp.png", replace

graph bar (mean) master, over(sp, relabel(1 "non-SP" 2 "SP")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("Master Degree (%)")
graph export "$pic\master_sp.png", replace