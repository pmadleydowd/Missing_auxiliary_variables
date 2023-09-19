capture log using "$Logdir\3_descriptive_statistics.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date:			06 April 2023	   
* Description: 	Descriptive statistics for empirical example
********************************************************************************
* Contents
********************************************************************************
* 1 - Load data and create environment 
* 2 - Table S1 Descriptive statistics of cohort characteristics
* 3 - Table S2 Descriptive statistics of missing data according to missing confounder status 
* 4 - Table S5 ORs for missing data in the outcome and auxiliary variables

********************************************************************************
* 1 - Load data and create environment 
********************************************************************************
ssc install table1_mc
use "$Datadir\Alsp_derived.dta", clear

********************************************************************************
* 2 - Table S1 Descriptive statistics of cohort characteristics
********************************************************************************
preserve
keep if inclusion == 1
table1_mc, 	by(mat_smok_bin18wk) ///
			vars(IQ_age15 	contn 	%5.1f \ ///
				 IQ_age8  	contn 	%5.1f \ ///
				 KS4	  	contn 	%5.1f \ ///
 				 matage   	contn 	%5.1f \ ///
				 parity_cat cat 	%5.1f \ ///
				 matEdDrv  	cat 	%5.1f \ ///
				 sex      	cat 	%5.1f \ ///
				 ) ///
		    nospace onecol missing total(before) ///
			saving("$Datadir\TableS1_Cohort_descriptives.xlsx", replace)
restore

********************************************************************************
* 3 - Table S2 Descriptive statistics of missing data according to missing confounder status 
********************************************************************************
preserve
keep if in_core  == 1 & kz011b   == 1 

table1_mc, 	by(mis_confany) ///
			vars(mis_out 	cat 	%5.1f \ ///
				 mis_auxIQ  cat 	%5.1f \ ///
				 mis_auxKS4	cat 	%5.1f \ ///
				 mis_exp  	cat 	%5.1f \ ///
 				 mis_matage cat 	%5.1f \ ///
				 mis_parity cat 	%5.1f \ ///
				 mis_mated 	cat 	%5.1f \ ///
				 ) ///
		    nospace onecol missing total(before) ///
			saving("$Datadir\TableS2_missing_confounder.xlsx", replace)
restore	


********************************************************************************
* 4 - Table S5 ORs for missing data in the outcome and auxiliary variables
********************************************************************************
capture postutil close 
tempname memhold 
postfile `memhold' str10 misvar str10 var lev str20 OR95CI using "$Datadir\TableS5_missingORs.dta", replace

foreach misind in mis_out mis_auxIQ mis_auxKS4 {
	foreach var in IQ_age15 IQ_age8 KS4 mat_smok_bin18wk matage parity_cat matEdDrv sex { 
		if ("`misind'" == "mis_out"    & "`var'" == "IQ_age15") | ///
		   ("`misind'" == "mis_auxIQ"  & "`var'" == "IQ_age8")  | ///
		   ("`misind'" == "mis_auxKS4" & "`var'" == "KS4") {
			
			post `memhold' ("`misind'") ("`var'") (1) ("-")			
			continue 
		}
		
		if "`var'" != "parity_cat" {
			logistic `misind' `var'
			post `memhold' ("`misind'") ("`var'") (1) ///
				(strofreal(r(table)[1,1], "%5.2f") + " (" + strofreal(r(table)[5,1], "%5.2f") + "-" + strofreal(r(table)[6,1], "%5.2f") + ")")			
		}
		if "`var'" == "parity_cat" {
			logistic `misind' i.`var'
			post `memhold' ("`misind'") ("`var'") (1) ///
				(strofreal(r(table)[1,2], "%5.2f") + " (" + strofreal(r(table)[5,2], "%5.2f") + "-" + strofreal(r(table)[6,2], "%5.2f") + ")")	
			post `memhold' ("`misind'") ("`var'") (2) ///
				(strofreal(r(table)[1,3], "%5.2f") + " (" + strofreal(r(table)[5,3], "%5.2f") + "-" + strofreal(r(table)[6,3], "%5.2f") + ")")					
		}
		
	}
}

postclose `memhold'


use "$Datadir\TableS5_missingORs.dta", clear		
gen _seq = 1 if misvar == "mis_out"
replace _seq = 2 if misvar == "mis_auxIQ"
replace _seq = 3 if _seq == .	

drop misvar
reshape wide OR95CI, i(var lev) j(_seq)	
rename OR95CI1 OR95CI_IQage15
rename OR95CI2 OR95CI_IQage8
rename OR95CI3 OR95CI_KS4

export excel using "$Datadir\TableS5_missingORs.xlsx", replace firstrow(var)
********************************************************************************
capture log close