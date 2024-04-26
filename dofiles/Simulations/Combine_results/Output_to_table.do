* Primary analyses 

* Bias and SE

clear 
gen aux_lab = ""
gen out_lab = ""
foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
	foreach aux in "1_MCAR" "3_MNAR" "2_MAR" {
		forvalues i = 1(1)4{
			append using "$Datadir\\`out'\\`aux'_auxiliary\Prepared_data\simsum_out_`i'.dta", gen(`out'_`aux'_`i')
			replace aux_lab = "`aux'" if `out'_`aux'_`i' == 1
			replace out_lab = "`out'" if `out'_`aux'_`i' == 1
			
		}	
	}
}

gen str_bias 	= strofreal(bias, "%5.3f") + " (" + strofreal(bias_mcse, "%5.4f") + ")"
gen str_modelse = strofreal(modelse, "%5.4f") + " (" + strofreal(modelse_mcse, "%6.5f") + ")"

keep if !inlist(varname, "beta_imp_noaux", "beta_cca") 
keep str* auxid *_lab mis


* FMI 

clear 
gen aux_lab = ""
gen out_lab = ""
foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
	foreach aux in "1_MCAR" "3_MNAR" "2_MAR" {
		forvalues i = 1(1)4{
			append using "$Datadir\\`out'\\`aux'_auxiliary\Prepared_data\FMI_sumstats_auxid`i'.dta", gen(`out'_`aux'_`i')
			replace aux_lab = "`aux'" if `out'_`aux'_`i' == 1
			replace out_lab = "`out'" if `out'_`aux'_`i' == 1
			
		}	
	}
}

gen str_FMI 	= strofreal(mean, "%5.3f") + " (" + strofreal(se, "%5.4f") + ")"

keep if auximp == 1
keep str* auxid *_lab mis


********************************************************************************
* Sensitivity analyses i and ii 

* Bias and SE 

clear 
gen aux_lab = ""
gen out_lab = ""
gen sens_lab = ""
foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
	foreach aux in "1_MCAR" "3_MNAR" "2_MAR" {
		foreach sens in "More_missing_outcome" "Stronger_ZY_than_XY" { 
			forvalues i = 1(1)4{
				local file = "$Datadir\Sensitivity\\`sens'\\`out'\\`aux'_auxiliary\Prepared_data\simsum_out_`i'.dta"
				
				if fileexists("`file'") == 1 {
					append using "`file'", gen(append)
					replace aux_lab = "`aux'" if append == 1
					replace out_lab = "`out'" if append == 1
					replace sens_lab = "`sens'" if  append == 1
					drop append
				}
			}
		}
	}
}

gen str_bias 	= strofreal(bias, "%5.3f") + " (" + strofreal(bias_mcse, "%5.4f") + ")"
gen str_modelse = strofreal(modelse, "%5.4f") + " (" + strofreal(modelse_mcse, "%6.5f") + ")"
keep str* auxid *_lab mis varname

browse if varname == "beta_cca"
browse if varname == "beta_imp_noaux"
browse if !inlist(varname, "beta_imp_noaux", "beta_cca") 


* FMI 

clear 
gen aux_lab = ""
gen out_lab = ""
gen sens_lab = ""
foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
	foreach aux in "1_MCAR" "3_MNAR" "2_MAR" {
		foreach sens in "More_missing_outcome" "Stronger_ZY_than_XY" { 
			forvalues i = 1(1)4{
				local file = "$Datadir\Sensitivity\\`sens'\\`out'\\`aux'_auxiliary\Prepared_data\FMI_sumstats_auxid`i'.dta"
				
				if fileexists("`file'") == 1 {
					append using "`file'", gen(append)
					replace aux_lab = "`aux'" if append == 1
					replace out_lab = "`out'" if append == 1
					replace sens_lab = "`sens'" if  append == 1
					drop append
				}
			}
		}
	}
}

gen str_FMI 	= strofreal(mean, "%5.3f") + " (" + strofreal(se, "%5.4f") + ")"

keep str* auxid *_lab mis auximp

browse if auximp == 0 
browse if auximp == 1 


********************************************************************************
* Sensitivity analyses excluding W

* Bias and SE 

clear 
gen aux_lab = ""
gen out_lab = ""
gen sens_lab = ""
foreach aux in "2_MAR" "4_MNARv2" {
	foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
		forvalues i = 1(1)4{
			local file = "$Datadir\\`out'\\`aux'_auxiliary\Prepared_data\simsum_out_`i'.dta"
			
			if fileexists("`file'") == 1 {
				append using "`file'", gen(append)
				replace aux_lab = "`aux'" if append == 1
				replace out_lab = "`out'" if append == 1
				replace sens_lab = "`sens'" if  append == 1
				drop append
			}
		}
	}
}

gen str_bias 	= strofreal(bias, "%5.3f") + " (" + strofreal(bias_mcse, "%5.4f") + ")"
gen str_modelse = strofreal(modelse, "%5.4f") + " (" + strofreal(modelse_mcse, "%6.5f") + ")"
keep str* auxid *_lab mis varname

browse if !inlist(varname, "beta_imp_noaux", "beta_cca") 


* FMI 

clear 
gen aux_lab = ""
gen out_lab = ""
gen sens_lab = ""
foreach aux in "2_MAR" "4_MNARv2" {
	foreach out in "MAR_outcome" "Proxy_outcome" "Efficiency_imputation" {
		forvalues i = 1(1)4{
			local file = "$Datadir\\`out'\\`aux'_auxiliary\Prepared_data\FMI_sumstats_auxid`i'.dta"
			
			if fileexists("`file'") == 1 {
				append using "`file'", gen(append)
				replace aux_lab = "`aux'" if append == 1
				replace out_lab = "`out'" if append == 1
				replace sens_lab = "`sens'" if  append == 1
				drop append
			}
		}
	}
}

gen str_FMI 	= strofreal(mean, "%5.3f") + " (" + strofreal(se, "%5.4f") + ")"

keep str* auxid *_lab mis auximp

browse if auximp == 1 



