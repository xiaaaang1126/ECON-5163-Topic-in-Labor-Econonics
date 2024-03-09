## 1. Read Data

###### Global: Give a name to the paths

```python
global do = "D:\st1\do"
global rawData = "D:\st1\rawData"
global workData = "D:\st1\workData"
global pic = "D:\st1\pic"
global log = "D:\st1\log"
```

###### Global: Different users’ paths

```python
if "`c(username)'" == "ttyang" {
2 global do = "D:\st1\do"
3 global rawdata = "D:\st1\rawdata"
4 global workdata = "D:\st1\workdata"
5 }
6 if "`c(username)'" == "nest" {
7 global do = "C:\st2\do"
8 global rawdata = "C:\st2\rawdata"
9 global workdata = "C:\st2\workdata"
10 }
```

###### Use: Read Data in Stata Format (.dta)

```python
# absolute directory
use "D:\st1\rawdata\acs_2015.dta", clear
use "$rawdata\acs_2015.dta", clear

# relative directory
cd $rawdata
use "acs_2015.dta", clear

# use only some of the variables
use pernum sex age year using "$rawdata\acs_2015.dta", clear
```

###### Import Delimited: Import csv or txt Files to STATA

```python
# import different file type
import delimited using acs_2015.txt, clear
import delimited using acs_2015.csv, clear encoding("utf‐8")  # reading Chinese data

# rename specified variable name of imported columns: ID, and use first row as variable name
import delimited ID using acs_2015.csv,clear varnames(1)

# specify the range 
import delimited using acs_2015.csv, colrange(1:3) rowrange(3:8) clear
```

###### Export Data: Save to STATA format, csv or other files

```python
# Stata format (.dta)
save "$rawdata\acs_2015.dta", replace

# csv format
export delimited using acs_2015new.csv, replace

# Excel file
import excel datanum year serial using acs_2015new.xlsx, sheet("Data") clear
export excel using acs_2015new.xlsx, sheet("Data") replace
```

## 2. Examine Data

###### br/ed: See the contents of a data file

```python
browse
edit
describe using "$rawdata\cps_2014_16.dta"
```

###### List: Show entire data within the results window

```python
list serial year sex age
list serial year sex age in 55/60
list serial year sex age if age==37
```

###### Assert: Verifies whether a certain statement is true or false

```python
assert sex <3
assert sex >3
assert age >85
```

###### Codebook: Provides extra information on the variables

```python
codebook  // if not specified, show all variable
codebook age sex incwage
```

###### Summarize: Provides summary statistics

```python
sum  // if not specified, show all variable
sum incwage
sum incwage ,d
```

###### Tabulate: Produce a frequency table

```python
tab age
tab age sex

# we can know average wage by age (gender)
tab age , sum(incwage)
tab sex , sum(incwage)
```

###### Inspect: Show distribution of a variable

```python
# identifying outliers or unusual values
inspect age
inspect incwage
```

###### isid: Check uniquely identify

```
isid serial
```

###### Duplicate: Detecting repeated observations

```python
# Use option report to show the number of observation with the same “serial”
duplicates report serial

# Use option report to show the number of observation with the same characteristics (value of all variables)
duplicates report

# list one example for each group of duplicates
duplicates example serial age year in 1/100

# show all repeated observations
duplicates list serial age year in 1/100

# generate a variable to indicate how many duplicates for this observation
duplicates tag serial, gen(s_repeat)
tab s_repeat

# drop observation with the same “serial”
duplicates drop serial ,force
```

## 3. Create the Sample for Analysis: Part 1

###### Generate: Creating new variables

```python
gen age_sq = age^2
gen log_incwage = log(incwage)
gen month = 10                          # constant value of 10 
gen id = _n                             # id number of observation 
gen total = _N                          # total number of observations 
gen bigyear = year if incwage > 100000  # show the year if income > 100000

gen str6 source = "CPS"                 # string variable 
replace incwage = . if incwage==9999999 # replace 9999999 to missing
```

- Stata’s default data type is float, so if you want to create a variable in some other format (e.g. byte, string), you need tospecify
- Missing numeric observations, denoted by a dot, are interpreted by Stata as a very large positive number

###### eGenerate: Creating new variables based on summary measures

```python
# Use function total to sum the wage income for each year
egen year_inc = total(incwage), by(year)

# Use function mean to get average wage income for each state
egen state_inc = mean(incwage), by(statefip)

# generates numeric id variable for state and county
egen g_state_county = group(statefip county)  

# Use function count to count number of observations
egen count_id = count(id)

# Use function diff to generate a variable indicating if incwage and inctot are different
egen diff_v = diff(incwage inctot)

# Example:find the difference in sample i’s income and maximum of income within specific state
gen temp1 = incwage if year==2015
egen temp2 = max(temp1), by(statefip)
gen temp3 = incwage-temp2 if year==2015
egen diff = max(temp3), by(statefip)
drop temp*
```

###### Replace: Modifying existing variables

```python
gen ln_inctot = ln(inctot)
replace ln_inctot = 0 if ln_inctot==.  # note that apply on missing data will still be missing value

gen byte yr = year-1900
replace yr = yr-100 if yr >= 100 # 0,1,etc instead of 100 ,101 for 2000 onwards
```

###### Label: Put labels on datasets, variables or values

```python
label data "Data from CPS 2014 -2015"  # put label on whole dataset
label variable incwage "wage income"   # put label on single variable

# define mapping of label
label define gendercode 1 "Male" 2 "Female"
label values sex gendercode
```

###### Rename/Recode: Change the names/values of your variables

```python
# Rename
rename oldName newName

# Recode
recode [variable list] (oldValue = newValue)
recode incwage inctot (0 = .)  # missing value
recode incwage (0 / 50000 = 1) (50001 / 100000 = 2) (100000 / 7000000 = 3)  # interval to number
```

###### Tostring/Destring: Change variable to string/numeric variables

```python
# Numeric variables are in black/blue color and string variables are in red color
# use raplce or gen new variable to restore the newly generated variable
tostring year , replace
destring year , gen(year1)
```

###### Decode/Encode: Create a string variable from a numerical code/ Converting strings to numerical code

```python
# Decode: create a string variable which comes from the label attached to the numerical variable
decode statefip, gen(state_name)

# Encode: Converting strings to numerical code
encode state_name, gen(state_id)
```

###### Substring: Dividing string variables

```python
# Using substring and combine
tostring year, gen(yearcode)
gen yearcode1 = string(year)
gen stateyear = state_name + yearcode1

# Assigning different part
gen yr1 = substr(yearcode, 3, 2)  # '3' is for the position of first character, '2' is for the length
gen yr2 = substr(yearcode, -2, 2) # alternating method, but assigning different position
```

###### Create Dummy Variable

```python
# Method 1
gen largewage1 = (incwage_test>=30000)  

# Method 2
tab statefip, gen(state_d)  # generate state_d1, state_d2, ..., state_dn. We can use state_d* to present 

# Method 3
reg incwage i.sex#i.year   # only generate interaction term
reg incwage i.sex##i.year  # all dummies adn interaction term
```

