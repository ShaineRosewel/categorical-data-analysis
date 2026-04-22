/*******************************************************************************
*
* This file replicates all the figures in the paper  "Working From Home 
* Around the World" (Cevat Giray Aksoy, Jose Maria Barrero, Nicholas Bloom, 
* Steven J. Davis, Mathias Dolls, and Pablo Zarate).
*
*******************************************************************************/

version 15.1
clear all
macro drop _all

set matsize 2000
set varabbrev off, permanent 
set more off, permanently  

	/* Defining paths and globals */
* Paths:
gl PATH "C:\Users\Pablo\Dropbox\EBRD - ifo Survey 2021\BPEA Replication file"

gl output_data "${PATH}\Data"
gl figures "${PATH}\Figures"


* Globals for labels
		global countries_continent `" "Brazil" "Canada" "USA" "Austria" "France" "Germany" "Greece" "Hungary" "Italy" "Netherlands" "Poland" "Serbia" "Spain" "Sweden" "Turkey" "UK" "Ukraine" "China" "India" "Japan" "Korea" "Malaysia" "Russia" "Singapore" "Taiwan" "Egypt"	"Australia" "'

		global countries_continent_HE `" "Brazil" "Canada {bf:(HE)}" "USA" "Austria {bf:(HE)}" "France" "Germany" "Greece {bf:(HE)}" "Hungary" "Italy {bf:(HE)}" "Netherlands {bf:(HE)}" "Poland" "Serbia {bf:(HE)}" "Spain {bf:(HE)}" "Sweden" "Turkey {bf:(HE)}" "UK" "Ukraine {bf:(HE)}" "China {bf:(HE)}" "India {bf:(HE)}" "Japan" "Korea {bf:(HE)}" "Malaysia {bf:(HE)}" "Russia {bf:(HE)}" "Singapore {bf:(HE)}" "Taiwan {bf:(HE)}" "Egypt {bf:(HE)}"	"Australia {bf:(HE)}" "'

		
		gl coefplot_rows_continents  `" c1 = "{bf: Average}"  "'
		local jj = 1
		foreach cntry of global countries_continent_HE {
			local jj = `jj' + 1
			gl coefplot_rows_continents `"  ${coefplot_rows_continents} c`jj' = "`cntry'"  "'
		}
		
		gl coefplot_rows_continentsnotag  `" c1 = "{bf: Average}"  "'
		local jj = 1
		foreach cntry of global countries_continent {
			local jj = `jj' + 1
			gl coefplot_rows_continentsnotag `"  ${coefplot_rows_continentsnotag} c`jj' = "`cntry'"  "'
		}


			
		global countries_continent_w2 `" "Brazil" "Canada {bf:(HE)}" "USA" "Austria {bf:(HE)}" "France" "Germany" "Greece {bf:(HE)}" "Hungary" "Italy {bf:(HE)}" "Netherlands {bf:(HE)}" "Poland" "Spain {bf:(HE)}" "Sweden" "Turkey {bf:(HE)}" "UK" "Ukraine {bf:(HE)}" "China {bf:(HE)}" "India {bf:(HE)}" "Japan" "Korea {bf:(HE)}" "Malaysia {bf:(HE)}" "Russia {bf:(HE)}" "Singapore {bf:(HE)}" "Taiwan {bf:(HE)}"	"Australia {bf:(HE)}" "'	
		
		gl coefplot_rows_continents_w2  `" c1 = "{bf:Average}"  "'
		gl table_rows_cont_w2  `" "Brazil"  "'
		local jj = 1
		foreach cntry of global countries_continent_w2 {
			local jj = `jj' + 1
			gl coefplot_rows_continents_w2 `"  ${coefplot_rows_continents_w2} c`jj' = "`cntry'"  "'
		}	
		
		
/*******************************************************************************
	Figures 1, 2, 3 and 4, 
	Figures A2, A5, A6, A7 and A8

	* Note: We use a loop to produce all these figures. The loop consists of:
		1) Estimating the linear regression and adding back the raw mean in the USA.
		2) Storing the elements in a matrix.
		3) Dividing the matrix by continent and plotting them by continent.
		4) Combining the plots into a single one.
	
*******************************************************************************/
use "${output_data}/G-SWA.dta", clear

* We define globals useful here:
gl outcomesvariables n_work_home daysemployer_work_home value_WFH_rawpercent25 commuting_time daysemployee_work_home WFH_expectations1 WFHperceptions
global controls gender agegroups education industry_job


* First, we estimate the coefficients:

	foreach var of global outcomesvariables {
* Regression:
sum `var' if original_country == "USA"
local y_ref = r(mean)
xi: reghdfe `var' b3.originalcountry, abs(${controls} wave) cl(country)

* We store the coefficients in a matrix called S1_"variable":
matrix S1_`var' = J(3,27,.)
matrix S1_`var'[1,1.27] = r(table)[1,1..27]
matrix S1_`var'[2,1.27] = r(table)[5,1..27]
matrix S1_`var'[3,1.27] = r(table)[6,1..27]

* Then, we add the benchmark of the raw mean value of the variable in the USA to each element in the matrix:
foreach num of numlist 1/3{
	foreach numm of numlist 1/27 {
		matrix S1_`var'[`num',`numm'] = S1_`var'[`num',`numm'] + `y_ref' 
	}
}

}

* For Appendix Figures A.7 and A.8
gen deaths_100 = 100000*deaths_pc

bys country: egen nn = count(age)
replace nn = 1/nn
foreach var of varlist LSI deaths_100 {
	matrix S1_`var' = J(1,27,.)
	foreach numm of numlist 1/27 {
		qui: sum `var' [aw=nn] if originalcountry == `numm' 
		matrix S1_`var'[1,`numm'] = r(mean)
	}
}

* Then, we plot them:
gl outc LSI deaths_100 $outcomesvariables
foreach var of global outc {
preserve
matrix results = J(2,28,.)
qui: sum `var'
local nn : di %6.0fc r(N)

gen regr = S1_`var'[1,_n] in 1/27
sum regr 
gl meanval = r(mean)
matrix results[1,1] = $meanval
matrix results[1,2.28] = S1_`var'[1,1..27]
matlist results
matlist S1_`var'
 

 * X-axis title:
if "`var'" == "n_work_home" local ytitles `" "Number of days working from home this week"  "'
if "`var'" == "daysemployer_work_home" local ytitles `" "Number of planned full workdays at home"  "'
if "`var'" == "daysemployee_work_home" local ytitles `" "Number of desired full workdays at home"  "'
if "`var'" == "WFHperceptions" local ytitles `" "Percentage change in work from home perceptions"  "'
if "`var'" == "WFH_expectations1" local ytitles `" "WFH productivity during COVID relative to expectations, percent"  "'
if "`var'" == "value_WFH_rawpercent25" local ytitles `" ""  "'
if "`var'" == "commuting_time" local ytitles `" "Time spent commuting to work, in minutes"  "'
if "`var'" == "LSI" local ytitles `" "Cumulative Lockdown Stringency"  "'
if "`var'" == "deaths_100" local ytitles `" "Cumulative COVID-19 deaths per 100.000 habitants"  "'

* X-axis numeric labels:
if "`var'" == "n_work_home" local ylabels `"0(1)3"'
if "`var'" == "daysemployer_work_home" local ylabels `"0(0.5)2"'
if "`var'" == "daysemployee_work_home" local ylabels `"0(1)3"'
if "`var'" == "WFHperceptions" local ylabels `"10(10)60"'
if "`var'" == "WFH_expectations1" local ylabels `"0(2)12"'
if "`var'" == "value_WFH_rawpercent25" local ylabels `"0(5)10 15"'
if "`var'" == "commuting_time" local ylabels `"20(10)100"'
if "`var'" == "views_distance" local ylabels `"60(5)95"'
if "`var'" == "LSI" local ylabels `"5(5)25"'
if "`var'" == "deaths_100" local ylabels `"0(100)400"'

* Number of the graph
if "`var'" == "n_work_home" local numm 1
if "`var'" == "daysemployer_work_home" local numm 2
if "`var'" == "value_WFH_rawpercent25" local numm 3
if "`var'" == "commuting_time" local numm 4

if "`var'" == "daysemployee_work_home" local numm `"A2"' 
if "`var'" == "WFH_expectations1" local numm `"A5"'
if "`var'" == "WFHperceptions" local numm `"A6"'
if "`var'" == "LSI" local numm `"A7"'
if "`var'" == "deaths_100" local numm `"A8"' 



local decval 2
if inlist("`var'","n_work_home","daysemployer_work_home","daysemployee_work_home","value_WFH_rawpercent25","WFH_expectations1","LSI") local decval 1
 
if inlist("`var'","commuting_time","WFHperceptions","views_distance") local decval 0
if inlist("`var'","deaths_100") local decval 0

local mlabel `"  string(@b, "%5.`decval'f") "'

local nummm 
if inlist("`var'","LSI","deaths_100") local nummm "notag"

matrix ress1 = results[1,1]
matrix ress2 = results[1,2..4]
matrix ress3 = results[1,5..18]
matrix ress4 = results[1,19..26]
matrix ress5 = results[1,27..28]

coefplot (matrix(ress1), recast(bar) bcolor(black) ) ///
		 (matrix(ress2), recast(bar) bcolor(maroon)) ///
		 (matrix(ress3), recast(bar) bcolor(navy)) ///
		 (matrix(ress4), recast(bar) bcolor(dkgreen)) ///
		 (matrix(ress5), recast(bar) bcolor(sienna)) ///
		 (matrix(results), mlabel(`mlabel') mlabposition(3) mlabsize(small) mlabcolor(black) mcolor(navy) msize(vtiny) msymbol(d) aux(2)),  ///
		coeflabels(${coefplot_rows_continents`nummm'}) legend(off) groups(c2 c4 = "{bf: Americas}" c5 c18 = "{bf: Europe}" c19 c26 = "{bf: Asia}" c27 c28 = "{bf: Rest}") xlabel(`ylabels')  offset(0)  xtitle(`ytitles', size(small)) ylabel(, labsize(small)) graphregion(color(white)) legend(off) grid(none) fintensity(inten90)
   	gr export "${figures}/Figure `numm'.png", replace

	
restore
}

/*******************************************************************************
	Figure 5: Women More Highly Value the Option to WFH in Most Countries
*******************************************************************************/
use "${output_data}/G-SWA.dta", clear
global controls gender agegroups education industry_job

gen countriesordered = ""
local j = 1
foreach cntry of global countries_continent {
    replace countriesordered = "`cntry'" if _n == `j'
	local j = `j' + 1
}

** Raw perk value of the option to WFH, by gender:
	foreach val of numlist 1/2 {
	    local var value_WFH_rawpercent25
* Regression:
sum `var' if original_country == "USA" & gender == `val'
local y_ref = r(mean)
xi: reghdfe `var' b3.originalcountry if gender == `val', abs(${controls} wave) cl(country)

matrix S1_`val'_rawperk = J(3,27,.)
matrix S1_`val'_rawperk[1,1.27] = r(table)[1,1..27]
matrix S1_`val'_rawperk[2,1.27] = r(table)[5,1..27]
matrix S1_`val'_rawperk[3,1.27] = r(table)[6,1..27]

di `y_ref'
foreach num of numlist 1/3{
	foreach numm of numlist 1/27 {
		matrix S1_`val'_rawperk[`num',`numm'] = S1_`val'_rawperk[`num',`numm'] + `y_ref' 
	}
}

}

gen rawperk_male = S1_2_rawperk[1,_n] in 1/27
gen rawperk_female = S1_1_rawperk[1,_n] in 1/27

gen clock = 3
replace clock = 9 if inlist(countriesordered,"India","Sweden","Greece","Germany","Korea","Ukraine","Canada")
replace clock = 10 if inlist(countriesordered,"Hungary")
replace clock = 2 if inlist(countriesordered,"Japan")
replace clock = 4 if inlist(countriesordered,"UK")
replace clock = 12 if inlist(countriesordered,"China")

twoway (scatter rawperk_female rawperk_male, xtitle("Men") ytitle("Women") msymbol(d) mlabsize(vsmall) mlabel(countriesordered) mlabvpos(clock)) (line rawperk_male rawperk_male), legend(order(2 "45° line") pos(10) ring(0)) graphregion(color(white))

gr export "${figures}/Figure 5.png", replace



/*******************************************************************************

	Figure 6: How the Amenity Value of WFH Differs by Sex and Family Circumstances,
			  Conditional Means by Country
			  *******************************************************************************/

use "${output_data}/G-SWA.dta", clear
global controls gender agegroups education industry_job


* I define groups for comparison:
gen 	groups = 1 	if gender == 2 & with_kids == 1	& married == 1 /*Male w/children*/
replace groups = 2 	if gender == 2 & with_kids == 0 & married == 1 /*Male w/o children*/
replace groups = 3	if gender == 1 & with_kids == 1	& married == 1 /*Female w/children*/
replace groups = 4 	if gender == 1 & with_kids == 0 & married == 1 /*Female w/o children*/
replace groups = 5	if gender == 2 & with_kids == 0 & married == 0 /* Male single without children*/
replace groups = 6	if gender == 1 & with_kids == 0 & married == 0 /* Female single without children*/

* We remove countries with less than 50 observations in the subgroup
bys groups original_country: gen obsN = _N
gen tomiss = obsN<=50
bys original_country: egen miss12 = max(tomiss) if inlist(groups,1,2)
replace groups = . if miss12 == 1
bys original_country: egen miss34 = max(tomiss) if inlist(groups,3,4)
replace groups = . if miss34 == 1
bys original_country: egen miss56 = max(tomiss) if inlist(groups,5,6)
replace groups = . if miss56 == 1


gen countriesordered = ""
local j = 1
foreach cntry of global countries_continent {
    replace countriesordered = "`cntry'" if _n == `j'
	local j = `j' + 1
}

** We estimate the linear regression and add back the raw mean in the USA, 
** for each group (groupval)

foreach groupval of numlist 1/6 {
	    local var value_WFH_rawpercent25
* Regression:
sum `var' if original_country == "USA" & groups == `groupval'
local y_ref = r(mean)
xi: reghdfe `var' b3.originalcountry if groups == `groupval', abs(${controls} wave) cl(country)
matrix RESULT = r(table)

gen rawval_g`groupval' = .
matrix TAB = J(1,27,.)

levelsof originalcountry if groups == `groupval', local(countryvalues)
local j = 1
foreach num of local countryvalues {
matrix TAB[1,`j'] = RESULT[1,`j'] + `y_ref'
replace rawval_g`groupval' = TAB[1,`j']  if _n == `num'
local j = `j' + 1
}


}


***** Panel A: Married men, comparison between with and without children
gen lineval = 0 if _n == 1
replace lineval = 15 if _n == 2

gen clock = 3
replace clock = 9 if inlist(countriesordered,"Ukraine","Greece","Sweden","Hungary","Germany")
replace clock = 6 if inlist(countriesordered,"Netherlands")
replace clock = 12 if inlist(countriesordered,"Poland")

twoway (scatter rawval_g1 rawval_g2, xtitle("Married men without children", size(large)) ytitle("Married men with children", size(large)) msymbol(d) mlabsize(small) mlabel(countriesordered) mlabvpos(clock)) (line lineval lineval), legend(order(2 "45° line") pos(10) ring(0) region(lstyle(none))) graphregion(color(white))
gr export "${figures}/Figure 6A.png", replace



***** Panel A: Married women, comparison between with and without children
drop clock
gen clock = 3
replace clock = 9 if inlist(countriesordered,"Netherlands","Australia","Spain","Sweden")
replace clock = 12 if inlist(countriesordered,"USA")


twoway (scatter rawval_g3 rawval_g4, xtitle("Married women without children", size(large)) ytitle("Married women with children", size(large)) msymbol(d) mlabsize(small) mlabel(countriesordered) mlabvpos(clock)) (line lineval lineval), legend(order(2 "45° line") pos(10) ring(0) region(lstyle(none))) graphregion(color(white))
gr export "${figures}/Figure 6B.png", replace


***** Panel C: Unpartnered/single persons, comparison between men and women
drop clock
gen clock = 3
replace clock = 9 if inlist(countriesordered,"Austria","UK","Netherlands","China")

twoway (scatter rawval_g6 rawval_g5, xtitle("Single men", size(large)) ytitle("Single women", size(large)) msymbol(d) mlabsize(small) mlabel(countriesordered) mlabvpos(clock)) (line lineval lineval), legend(order(2 "45° line") pos(10) ring(0) region(lstyle(none))) graphregion(color(white))
gr export "${figures}/Figure 6C.png", replace



/*******************************************************************************
	Figure 7: The Distribution of WFH Productivity Relative to Expectations
*******************************************************************************/
gen all = 1
foreach var of varlist home_work_expectations_workers {
	local length = 50
	if "`var'" == "views_distancing" local length = 40
	splitvallabels `var', length(`length')


catplot all `var', percent var2opts(relabel(`r(relabel)')) ///
blabel(bar, format(%10.1f) pos(inside) color(white)) ylabel(,grid glcolor(gs12)) ///
graphregion(color(white)) ytitle(Percent of respondents) plotregion(lcolor(black)) asyvars ///
legend(off) 

gr export "${figures}/Figure 7.png",replace
}

/*******************************************************************************
	Figure 8: Planned levels of WFH after the pandemic increase with 
			  WFH productivity surprises during the pandemic 
*******************************************************************************/

preserve
** Employer plans vs productivity.
collapse (mean) daysemployer_work_home, by(WFH_expectations1)

twoway (scatter daysemployer_work_home WFH_expectations1, color(red) msymbol(d)) ///
	(lfit daysemployer_work_home WFH_expectations1, color(red)), legend(off) xtitle("Relative to expectations, WFH Productivity during COVID (%)") ytitle("Number of planned full workdays at home") graphregion(color(white)) plotregion(lcolor(black)) xlabel(-25(5)25) ylabel(0(0.5)2) 
	
gr export "${figures}/Figure 8.png",replace
restore




/*******************************************************************************
	Figure A.1: Histogram of the Willigness to Pay for the Option to 
				Work from Home 2-3 Days per Week
*******************************************************************************/

eststo clear
reghdfe value_WFH_rawpercent25 b3.originalcountry, abs(${controls} wave) cl(original_country) resid
predict res, res
predict val

sum value_WFH_rawpercent25, d
replace res = res + r(mean)

twoway (hist value_WFH_rawpercent25) (kdensity res), graphregion(color(white)) xtitle("Amenity value of the option to WFH 2-3 days", size(medlarge)) legend(order(1 "Amenity value of WFH option" 2 "Recentered residuals") ring(0) pos(10) row(2) region(lstyle(none)))
graph export "${figures}/FigureA.1.png", replace


sum val /*SD: 2.281*/
sum res /*SD: 10.512*/
sum value_WFH_rawpercent25 /*SD: 10.969*/



/*******************************************************************************
	Figure A.3: Many Workers Will Quit or Seek a New Job If Required to Return to the Employer's Worksite 5+ Days Per Week
*******************************************************************************/

gen notreturnoffice1 = 100*(return_office == 2) if !missing(return_office) & n_work_home>0 & !missing(n_work_home)
gen notreturnoffice2 = 100*(return_office == 3) if !missing(return_office) & n_work_home>0 & !missing(n_work_home)

** Share of employee that would quit or start looking for another job:
* For outcomes in wave 2 only:
foreach var of varlist notreturnoffice1 notreturnoffice2 {
sum `var' if original_country == "USA"
local y_ref = r(mean)
xi: reghdfe `var' b3.originalcountry, abs(${controls}) cl(country)

matrix S1_`var' = J(3,25,.)
matrix S1_`var'[1,1.25] = r(table)[1,1..25]
matrix S1_`var'[2,1.25] = r(table)[5,1..25]
matrix S1_`var'[3,1.25] = r(table)[6,1..25]

di `y_ref'
foreach num of numlist 1/3{
	foreach numm of numlist 1/25 {
		matrix S1_`var'[`num',`numm'] = S1_`var'[`num',`numm'] + `y_ref' 
	}
}
}

matrix S_notreturnoffice2 = S1_notreturnoffice2[1,1..25]
matrix S_notreturnoffice1 = S1_notreturnoffice1[1,1..25] + S_notreturnoffice2




* Separated in two bars:
foreach var of newlist notreturnoffice {


foreach num of numlist 1/2 {
preserve
matrix results`num' = J(1,26,.)

gen regr = S_`var'`num'[1,_n] in 1/25
sum regr 
gl meanval`num' = r(mean)
matrix results`num'[1,1] = ${meanval`num'}
matrix results`num'[1,2.26] = S_`var'`num'[1,1..25]
matlist results`num'
matlist S_`var'`num'

restore
}

local ytitles `" "Share of employees that would quit or start looking for a WFH job" "'
local ylabels `"0(10)40 45"'

matrix ress1_1 = results1[1,1]
matrix ress2_1 = results1[1,2..4]
matrix ress3_1 = results1[1,5..17]
matrix ress4_1 = results1[1,18..25]
matrix ress5_1 = results1[1,26]

matrix ress1_2 = results2[1,1]
matrix ress2_2 = results2[1,2..4]
matrix ress3_2 = results2[1,5..17]
matrix ress4_2 = results2[1,18..25]
matrix ress5_2 = results2[1,26]


mat colnames ress5_1 = c26
mat colnames ress5_2 = c26

coefplot (matrix(ress1_1), recast(bar) bcolor(black) ) ///
		 (matrix(ress2_1), recast(bar) bcolor(maroon)) ///
		 (matrix(ress3_1), recast(bar) bcolor(navy)) ///
		 (matrix(ress4_1), recast(bar) bcolor(dkgreen)) ///
		 (matrix(ress5_1), recast(bar) bcolor(sienna)) ///
		 (matrix(ress1_2), recast(bar) bcolor(black*0.6) ) ///
		 (matrix(ress2_2), recast(bar) bcolor(maroon*0.6)) ///
		 (matrix(ress3_2), recast(bar) bcolor(navy*0.6)) ///
		 (matrix(ress4_2), recast(bar) bcolor(dkgreen*0.6)) ///
		 (matrix(ress5_2), recast(bar) bcolor(sienna*0.6)) ///
		 (matrix(results1[1,]), mlabel(string(@b, "%5.0f")) mlabposition(3) mlabsize(small) mlabcolor(black) mcolor(navy) msize(vtiny) msymbol(d) ),  ///
		coeflabels(${coefplot_rows_continents_w2}) groups(c2 c4 = "{bf: Americas}" c5 c17 = "{bf: Europe}" c18 c25 = "{bf: Asia}" c26 c26 = "{bf: Rest}") xlabel(`ylabels')  offset(0)  xtitle(`ytitles', size(small)) ylabel(, labsize(small)) graphregion(color(white)) legend(order(2 "Look for a" "WFH job" 12 "Quit") size(small) symxsiz(small) pos(1) ring(0)) grid(none) fintensity(inten90)
}

   	gr export "${figures}/Figure A3.png",replace

	


/*******************************************************************************
	Figure A.4: Planned WFH Levels Rise with the WFH Productivity Surprise in All Countries
*******************************************************************************/


encode original_country, g(countries_val)

local j = 1
foreach num of numlist 9 18 27 {
	preserve
	
keep if countries_val>`num'-9 & countries_val<=`num'

** Employer plans and employee desires vs productivity.
collapse (mean) daysemployer_work_home if ever_WFH == 100, by(WFH_expectations1 original_country)

twoway (scatter daysemployer_work_home WFH_expectations1, color(red) msymbol(d)) ///
	(lfit daysemployer_work_home WFH_expectations1, color(red)), legend(off) xtitle("Relative to expectations, WFH Productivity during COVID (%)") ytitle("Number of planned full workdays at home") by(original_country, graphregion(color(white)) note("") legend(off)) plotregion(lcolor(black)) xlabel(-25 -15 -5 0 5 15 25) ylabel(0(1)3) 
	
gr export "${figures}/Figure A4_`j'.png",replace
local j = `j'+1
restore
}



