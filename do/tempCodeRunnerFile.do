keep stud_id university public wage_level_2009 work_year_2009

// Merge with school time data
merge 1:1 stud_id using "$workData\CP_divorce.dta"
drop _merge
save "$workData\CP_divorce_Outcome2009.dta", replace
