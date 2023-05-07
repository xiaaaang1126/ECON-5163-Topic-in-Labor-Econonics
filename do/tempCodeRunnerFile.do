// define severe_divorce: divorce in twelve grade
gen severe_divorce = (divorce_2001 == 0 & divorce_2007 == 1) if (divorce_2001 != . & divorce_2007 != .)
replace severe_divorce = 1 if (w4s2062 == 0 & w4s2063 == 0 & w4s2064 == 0 & w4s2065 == 1)
// define divorce: once divorce in the past
gen divorce = (divorce_2001 == 1 | w4s2062 == 1 | w4s2063 == 1 | w4s2064 == 1 | w4s2065 == 1)  ///
              if (w4s2062 != . & w4s2063 != . & w4s2064 != . & w4s2065 != .)
replace divorce = 1 if divorce_2001 == 1       

