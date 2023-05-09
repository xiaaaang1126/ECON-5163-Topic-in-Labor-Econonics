recode sh09v33 sh09v36 sh15v28 sh15v29 sh15v30 (9/99 = .)
gen university_2009 = (sh09v33 == 5) | (sh09v33 == 6) | (sh09v33 == 7) | (sh09v33 == 8) if sh09v33 != .
gen university_2015 = (sh15v30 == 5) | (sh15v30 == 6) | (sh15v30 == 7) | (sh15v30 == 8) if sh15v30 != .
//replace university_2015 = 1 if (sh15v28 == 1 & university_2009 == 1)
//replace university_2015 = 1 if (sh15v28 == 1 & sh15v30 >= 5 & sh15v30 <= 8)
gen university = (university_2009 == 1 | university_2015 == 1) if university_2009 != . | university_2015 != .

