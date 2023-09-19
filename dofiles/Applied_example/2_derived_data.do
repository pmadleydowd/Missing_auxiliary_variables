capture log using "$Logdir\2_derived_data.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date:			06 April 2023	   
* Description: 	Data derivations for empirical example
********************************************************************************
* Contents
********************************************************************************
* 1 - Load data and create environment 
* 2 - Derive exposure information
* 3 - Clean missing values in outcome and auxiliary variables
* 4 - Derive covariate/potential confounder variables
* 5 - Create missing data indicators
* 6 - Restrict to elliglible sample 
* 7 - Save dataset 					 

********************************************************************************
* 1 - Load data and create environment 
********************************************************************************
use "$Rawdatdir\20230328_b4170_madley_dowd.dta", clear


********************************************************************************
* 2 - Derive exposure information
********************************************************************************
* maternal smoking at 18 weeks (comparible to paternal smoking; taken from same time point)
replace b650 = . if b650 < 0  // replace missing questionnaire value with missing value (general) 
replace b659 = . if b659 < 0
replace b670 = . if b670 < 0
replace b671 = . if b671 < 0

gen mat_curr_smok = b650 == 1 & b659 != 1 if missing(b650) == 0 // defining current smoker as reporting having been a smoker and not reporting they have now stopped
gen mat_rep_smok = 1 if ( b670 > 0 & missing(b670) == 0 ) ///
						| ( b671 > 0 & missing(b671) == 0 ) 
replace mat_rep_smok = 0 if b670 == 0 & b671 == 0  ///
						| b670 == 0 & missing(b671) == 1 ///
						| missing(b670) == 1 & b671 == 0

gen mat_smok_bin18wk = mat_curr_smok == 1  | mat_rep_smok ==1 if missing(mat_curr_smok) + missing(mat_rep_smok) < 2	
label variable mat_smok_bin18wk "Any maternal smoking during pregnancy (Y/N) comparable with paternal report"
label define lb_smok 0 "Non-smoker at 18 weeks gestation" 1 "Current smoker at 18 weeks gestation"
label values mat_smok_bin18wk lb_smok



********************************************************************************
* 3 - Clean missing values in outcome and auxiliary variables
********************************************************************************
* IQ at age 15
gen IQ_age15 = fh6280 if fh6280 > 0
label variable IQ_age15 "Offspring IQ at age 15"

* IQ at age 8 
gen IQ_age8 = f8ws112 if f8ws112 > 0 
label variable IQ_age8 "Offspring IQ at age 8"

* KS4 score
gen KS4 = ks4_ptscnewe if ks4_ptscnewe >=0
label variable KS4 "Offspring KS4 score"


********************************************************************************
* 4 - Derive covariate/potential confounder variables
********************************************************************************
	* sex
rename kz021 	sex
replace sex=. 	if sex<0
replace sex=0 if sex==2  // female set as 0 (reference) 
label variable sex "Offspring assigned sex at birth"
label define lb_sex 0 "Female" 1 "Male"
label values sex lb_sex


	* parity 
rename b032		parity
		* as a categorical variable
egen parity_cat = cut(parity), at(-7,0,1,2,25) 
replace parity_cat=. if parity<0
label variable parity_cat "Parity Categories"
label define lb_parity 0 "0" 1 "1" 2 "2+"
label values parity_cat lb_parity

	* socioeconomic status variables 
rename c645a 	matEd
rename mz028b 	matage

		* maternal highest education
gen matEdDrv = 0 if matEd == 1 | matEd == 2| matEd ==3 // vocational/CSE/Olevel
replace matEdDrv = 1 if matEd == 4 | matEd == 5  // A level/Degree
replace matEdDrv=. 	  if matEd<0
label variable matEdDrv "Maternal highest education"
label define lb_mated 0 "O-level or lower" 1 "A-level/Degree or higher"
label values matEdDrv lb_mated

		* maternal age groups
replace matage=. 	  if matage<0
summ matage
gen matage_cntr = matage - r(mean)
gen matage_cntr_cubed = matage_cntr*matage_cntr*matage_cntr
label variable matage "Maternal age at birth"

********************************************************************************
* 5 - Create missing data indicators
********************************************************************************
gen mis_exp = missing(mat_smok_bin18wk)

gen mis_out = missing(IQ_age15)
gen mis_auxIQ = missing(IQ_age8)
gen mis_auxKS4 = missing(KS4)

egen mis_conf = rowmiss(parity_cat matEdDrv matage)
gen mis_confany = mis_conf > 0 
gen mis_parity = missing(parity_cat)
gen mis_mated = missing(matEdDrv)
gen mis_matage = missing(matage)

gen cca = 1 if mis_exp == 0 & mis_out == 0 & mis_conf == 0 

label define lb_missyn 0 "Observed" 1 "Missing"
label values mis_exp mis_out mis_auxIQ mis_auxKS4 mis_confany mis_parity mis_mated mis_matage lb_missyn  

********************************************************************************
* 6 - Restrict to elliglible sample 
********************************************************************************
replace kz011b = 2 if missing(kz011b)
replace in_core = 2 if missing(in_core)

gen inclusion = 0 
replace inclusion = 1 if in_core  == 1 & ///
					 kz011b   == 1 & ///
					 mis_exp  == 0 & ///
					 mis_conf == 0

********************************************************************************
* 7 - Save dataset 					 
********************************************************************************
save "$Datadir\Alsp_derived.dta", replace 


********************************************************************************					 
capture log close					 					 