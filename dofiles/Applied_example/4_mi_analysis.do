capture log using "$Logdir\4_mi_analysis.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date:			06 April 2023	   
* Description: 	Empirical example MI analysis
********************************************************************************
* Contents
********************************************************************************
* 1 - Load data and create environment 
* 2 - Complete case analysis
* 3 - MI without auxiliaries
* 4 - IQ at age 8 as an auxiliary 
* 5 - KS4 score as an auxiliary
* 6 - IQ and KS4 score as auxiliaries
* 7 - KS4 cubed (including an interaction term with maternal highest education) as an auxiliary
* 8 - IQ and KS4 score cubed (including interaction term with maternal education) as auxiliaries


********************************************************************************
* 1 - Load data and create environment 
********************************************************************************
use "$Datadir\Alsp_derived.dta", clear
keep if inclusion == 1
global nimp = 1000
global burnin = 25

********************************************************************************
* 2 - Complete case analysis
********************************************************************************
regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 


********************************************************************************
* 3 - MI without auxiliaries
********************************************************************************
preserve

mi set flong
mi register imputed IQ_age15   
mi impute chained ///
	(regress) IQ_age15 = mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_noaux_$nimp.dta", replace	
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore 

********************************************************************************
* 4 - IQ at age 8 as an auxiliary 
********************************************************************************
preserve 

mi set flong
mi register imputed IQ_age15 IQ_age8  
mi impute chained ///
	(regress) IQ_age15 ///
	(regress) IQ_age8 ///	
	= mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_IQaux_$nimp.dta", replace		
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore 

********************************************************************************
* 5 - KS4 score as an auxiliary
********************************************************************************
preserve 

mi set flong
mi register imputed IQ_age15 KS4  
mi impute chained ///
	(regress) IQ_age15 ///
	(regress) KS4 ///	
	= mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_KS4aux_$nimp.dta", replace		
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore
********************************************************************************
* 6 - IQ and KS4 score as auxiliaries
********************************************************************************
preserve 

mi set flong
mi register imputed IQ_age15 IQ_age8 KS4  
mi impute chained ///
	(regress) IQ_age15 ///
	(regress) IQ_age8 ///	
	(regress) KS4 ///	
	= mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_IQKS4aux_$nimp.dta", replace		
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore

********************************************************************************
* 7 - KS4 cubed (including an interaction term with maternal highest education) as an auxiliary
********************************************************************************
preserve 

mi set flong
mi register imputed IQ_age15 KS4  
mi impute chained ///
	(regress, include((KS4^3) ((KS4^3)*matEdDrv)) omit(KS4))  IQ_age15 ///
	(regress, include((IQ_age15^(1/3)) ((IQ_age15^(1/3))*matEdDrv)) omit(IQ_age15)) KS4 ///
	= mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_KS4Intaux_$nimp.dta", replace		
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore


********************************************************************************
* 8 - IQ and KS4 score cubed (including interaction term with maternal education) as auxiliaries
********************************************************************************
preserve 

mi set flong
mi register imputed IQ_age15 IQ_age8 KS4  
mi impute chained ///
	(regress, include((KS4^3) ((KS4^3)*matEdDrv)) omit(KS4))  IQ_age15 ///
	(regress, include((KS4^3) ((KS4^3)*matEdDrv)) omit(KS4))  IQ_age8 ///	
	(regress, include((IQ_age15^(1/3)) ///
					  ((IQ_age15^(1/3))*matEdDrv) ///
					  (IQ_age8^(1/3)) ///
					  ((IQ_age8^(1/3))*matEdDrv)) ///
			  omit(IQ_age15 IQ_age8)) KS4 ///
	= mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed, ///
	add($nimp) burnin($burnin) rseed(478589)
save "$Datadir\Alsp_imputed_IQKS4Intaux_$nimp.dta", replace		
mi estimate: regress IQ_age15 mat_smok_bin18wk i.parity_cat i.matEdDrv matage_cntr matage_cntr_cubed 
matrix list e(fmi_mi) 

restore

********************************************************************************
capture log close