graph bar (percent) university, over(sp, relabel(1 "nonsingle" 2 "single")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\university_sp.png", replace

graph bar (percent) public, over(sp, relabel(1 "nonsingle" 2 "single")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\public_sp.png", replace

graph bar (percent) master, over(sp, relabel(1 "nonsingle" 2 "single")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\master_sp.png", replace

graph bar (percent) work_year, over(sp, relabel(1 "nonsingle" 2 "single")) over(NPCP, relabel(1 "SH" 2 "NPCP")) blabel(bar, format(%4.2f)) yti("University Degree (%)")
graph export "$pic\workyear_sp.png", replace