/*******************************************************************************
*
* This file replicates all the tables in the paper  "Working From Home 
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

* Define path:
gl PATH "C:\Users\Pablo\Dropbox\EBRD - ifo Survey 2021\BPEA Replication file"

gl output_data "${PATH}\Data"
gl figures "${PATH}\Figures"
gl tables "${PATH}\Tables"

/*******************************************************************************

	Table 1: The Structure of Preferences over WFH

*******************************************************************************/

use "${output_data}/G-SWA.dta", clear

* The Structure of Preferences over WFH.
eststo clear
eststo: reghdfe value_WFH_rawpercent25 tertiary graduate married male with_kids male_with_kids if !missing(commute_time_hs), abs(wave agegroups) cl(original_country)
eststo: reghdfe value_WFH_rawpercent25 tertiary graduate married male with_kids male_with_kids commute_time_hs, abs(wave agegroups) cl(original_country)
eststo: reghdfe value_WFH_rawpercent25 tertiary graduate married male with_kids male_with_kids commute_time_hs, abs(wave agegroups original_country) cl(original_country)
eststo: reghdfe value_WFH_rawpercent25 tertiary graduate married with_kids commute_time_hs if male == 1, abs(wave agegroups original_country) cl(original_country)
eststo: reghdfe value_WFH_rawpercent25 tertiary graduate married with_kids commute_time_hs if male == 0, abs(wave agegroups original_country) cl(original_country)

esttab using "${tables}/Table1.rtf", nocons nocons label se nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3) b(3)

* Standard error: 
sum value_WFH_rawpercent25 if !missing(married) & !missing(male_with_kids) & !missing(commute_time_hs)
bys male: sum value_WFH_rawpercent25 if !missing(married) & !missing(male_with_kids) & !missing(commute_time_hs)

		
/*******************************************************************************

	Table 2, 3, A.5, A.6 and A.7:

*******************************************************************************/
gl outcomesvariables n_work_home daysemployee_work_home daysemployer_work_home value_WFH_rawpercent25
global controls gender agegroups education industry_job

use "${output_data}/G-SWA.dta", clear

* For the Stringency and COVID-19 deaths, we take the subnational values in the countries where it is available and the national values in the rest of the countries.
replace reg_deaths_pc = deaths_pc if missing(reg_deaths_pc)
ren subn_LSI reg_LSI
replace reg_LSI = LSI if missing(reg_LSI)

* We standardize the variables for interpretation.
egen deathsregpc_std = std(reg_deaths_pc)
egen LSIreg_std = std(reg_LSI)
egen deathspc_std = std(deaths_pc)
egen LSI_std = std(LSI)
egen oxf_LSI_std = std(oxf_LSI)

egen mask_std = std(mask)
gen log_gdp = log(gdppc2019)

* We label the variables:
label var deathspc_std "Cum. COVID-19 deaths per capita (std.)"
label var LSI_std "Cum. Lockdown Stringency (std.)"
label var oxf_LSI_std "Cum. Oxford Stringency (std.)"
label var deathsregpc_std "Cum. subnational COVID-19 deaths per capita (std.)"
label var LSIreg_std "Cum. subnational Lockdown Stringency (std.)"
label var mask_std "Cum. Mask Mandate Orders (std.)"


********************************************************************************
***** Table 2: Current and planned levels of WFH rise with the cumulative 
*****		   stringency of government-mandated lockdowns

eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' LSI_std deathspc_std log_gdp, abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/Table2.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(deathspc_std LSI_std) order(LSI_std deathspc_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)



********************************************************************************
***** Table 3: Lockdown Effects Are Stronger for the More Educated
	* Panel A:
eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' LSI_std deathspc_std log_gdp if inlist(education,3,4), abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/Table3A.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(deathspc_std LSI_std) order(LSI_std deathspc_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)

	* Panel B:
eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' LSI_std deathspc_std log_gdp if inlist(education,4), abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/Table3B.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(deathspc_std LSI_std) order(LSI_std deathspc_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)




********************************************************************************
***** Appendix Table A.5: Current and planned levels of WFH rise with the cumulative
***** 					  stringency of government-mandated lockdowns, adding controls 
*****					  for cumulative mask mandates

eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' LSI_std deathspc_std mask_std log_gdp, abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/TableA5.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(deathspc_std LSI_std mask_std) order(LSI_std deathspc_std mask_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)



********************************************************************************
***** Appendix Table A.6: Current and planned levels of WFH rise with the cumulative
*****					  stringency of government-mandated lockdowns, using subnational
*****					  variation where available.

eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' LSIreg_std deathsregpc_std log_gdp, abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/TableA6.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(LSIreg_std deathsregpc_std) order(LSIreg_std deathsregpc_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)



********************************************************************************
***** Appendix Table A.7: Current and planned levels of WFH rise with cumulative
*****					  lockdown stringency, using the Oxford stringency index

eststo clear
foreach var of global outcomesvariables {
qui: eststo: xi: reghdfe `var' oxf_LSI_std deathspc_std log_gdp, abs(industry_job education gender agegroups wave) cl(original_country)
}

esttab using "${tables}/TableA7.rtf", nocons float mtitle("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") keep(oxf_LSI_std deathspc_std) order(oxf_LSI_std deathspc_std) label se(3) b(3) nonumber eqlabels(" " " ") star(* 0.10 ** 0.05 *** 0.01) replace r2(3)






/*******************************************************************************
			Appendix Tables A.1, A.2, A.3 and A.4:
*******************************************************************************/
gl outcomesvariables n_work_home daysemployer_work_home daysemployee_work_home WFH_expectations1 commuting_time value_WFH_rawpercent25 WFHperceptions 

use "${output_data}/G-SWA.dta", clear

********************************************************************************
***** Appendix Table A.1: G-SWA Country-Level Survey Waves: Timing and Observation Counts

bys wave: tab original_country 
	* Note: Because only the final data is available, we only report the number of
	* observations after removing speeders and after removing those who failed 
	* the attention check question.

	
	
********************************************************************************
***** Appendix Table A.2: Country-Level Summary Statistics, Raw Sample Means after Drops

preserve 
collapse age $outcomesvariables, by(original_country)
foreach var of varlist age commuting_time WFHperceptions {
replace `var' = round(`var',1)
}
foreach var of varlist n_work_home daysemployer_work_home daysemployee_work_home WFH_expectations1 value_WFH_rawpercent25 {
replace `var' = round(`var',0.1)
}

restore


********************************************************************************
***** Appendix Table A.3: Country-Level Summary Statistics, Percentages
gl outcomessummary fem sec tert grad with_kids1 commute_20 commute_60

gen fem = (gender==1)*100
gen sec = (education==2)*100
gen tert = (education==3)*100
gen grad = (education==4)*100

gen with_kids1 = 100*with_kids
gen commute_20 = (commuting_time<=20)*100
gen commute_60 = (commuting_time>=60)*100


tabstat $outcomessummary , stat(mean) by(original_country) format(%9.0f) save



********************************************************************************
***** Appendix Table A.4: Comparisons of G-SWA Data with Gallup World Poll Data

	** G-SWA statistics for comparison with Gallup World Poll Data
gen tertmore = tert+grad
tabstat fem age sec tertmore, stat(mean) by(original_country) format(%9.2f) save

	* Note: We employ the licensed Gallup World Poll data as a benchmark for these outcomes.
	* We restrict the analysis to respondents aged 20-59 (wp1220>=20 and wp1220<=59), 
	* with Secondary or Tertiary education (wp3117 equal to 2 or 3) and working 
	* full-time (emp_2010 equal to 1 or 2). Using observations from 2017 and 2018 only, 
	* we compute the weighted average of the characteristics at the country-level.
















