cap log close 
log using "$Logdir/Combine_results/log_collate_results.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		12 May 2022
* Description:	Collate results from all simulations 
********************************************************************************
* Contents 
********************************************************************************
* 1 - Put datasets in wide format 
* 2 - Append datasets 
* 3 - Run simsum 



********************************************************************************
* 1 - Put datasets in wide format 
********************************************************************************
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues sim = 1(1)1000	{
			forvalues auxid = 1(1)4 {
				disp "outmis = `outmis', auxmis = `auxmis', sim = `sim', auxid = `auxid'"
				use "$Datadir/`outmis'/`auxmis'/simout_sim`sim'_auxid`auxid'.dta", clear
				gen seq = _n

				drop full cca imp aux misprop

				reshape wide beta se fmi prop_yzmiss, i(sim auxid auxcorr) j(seq)

				rename *10 *_imp_auxmiss60p
				rename *11 *_imp_auxmiss70p
				rename *12 *_imp_auxmiss80p
				rename *13 *_imp_auxmiss90p
				rename *1  *_fulldata
				rename *2  *_cca 
				rename *3  *_imp_noaux
				rename *4  *_imp_auxnomiss
				rename *5  *_imp_auxmiss10p
				rename *6  *_imp_auxmiss20p
				rename *7  *_imp_auxmiss30p
				rename *8  *_imp_auxmiss40p
				rename *9  *_imp_auxmiss50p
				

				save "$Datadir/`outmis'/`auxmis'/Prepared_data/_temp/sim`sim'_auxid_`auxid'.dta", replace
			
			}
		}
	}
}

********************************************************************************
* 2 - Append datasets 
********************************************************************************
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues auxid = 1(1)4 {
			use "$Datadir/`outmis'/`auxmis'/Prepared_data/_temp/sim1_auxid_`auxid'.dta", clear
			forvalues sim = 2(1)1000	{
				append using "$Datadir/`outmis'/`auxmis'/Prepared_data/_temp/sim`sim'_auxid_`auxid'.dta"
			}
			rename se_* beta_*_se // used for simsum command
			save "$Datadir/`outmis'/`auxmis'/Prepared_data/simall_auxid_`auxid'.dta", replace
			
			forvalues sim = 1(1)1000	{
				capture erase "$Datadir/`outmis'/`auxmis'/Prepared_data/_temp/sim`sim'_auxid_`auxid'.dta"
			}
		}
	}
}		
		
********************************************************************************
* 3 - Run simsum to obtain estimates of bias  
********************************************************************************

foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues auxid = 1(1)4 {
	
			use "$Datadir/`outmis'/`auxmis'/Prepared_data/simall_auxid_`auxid'.dta", clear

			simsum beta_cca beta_imp_noaux beta_imp_auxnomiss ///
				   beta_imp_auxmiss10p beta_imp_auxmiss20p beta_imp_auxmiss30p beta_imp_auxmiss40p ///
				   beta_imp_auxmiss50p beta_imp_auxmiss60p beta_imp_auxmiss70p beta_imp_auxmiss80p ///
				   beta_imp_auxmiss90p ///
						,  bias empse modelse relerror cover mcse sesuffix(_se) true(beta_fulldata) clear
						
						
			xpose , clear varname 
			rename v1 bias 
			rename v2 emp_se
			rename v3 modelse
			rename v4 relerror
			rename v5 cover
			rename _varname varname
			drop if varname=="perfmeasnum" | varname=="perfmeascode"
			gen mcse=1 if strpos(varname,"mcse") != 0 
			replace mcse=0 if missing(mcse) 
			gen bias_mcse=bias if mcse==1
			gen emp_se_mcse=emp_se if mcse==1
			gen modelse_mcse=modelse if mcse==1
			gen relerror_mcse=relerror if mcse==1
			gen cover_mcse=cover if mcse==1
			replace varname=substr(varname,1,strpos(varname,"_mcse")-1) if mcse==1 

			save "$Datadir/`outmis'/`auxmis'/Prepared_data/_temp/simsum_out_`auxid'.dta", replace

			drop if mcse==1 
			drop bias_mcse emp_se_mcse modelse_mcse relerror_mcse cover_mcse mcse
			save "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\simsum_out_beta_`auxid'.dta", replace
			use "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\simsum_out_`auxid'.dta", clear
			drop if mcse==0
			drop bias emp_se modelse relerror mcse
			save "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\simsum_out_mcse_`auxid'.dta", replace
			
			
			use "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\simsum_out_beta_`auxid'.dta", clear
			merge 1:1 varname using "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\simsum_out_mcse_`auxid'.dta", nogen
			order varname 
			
			gen imp = 1 if varname != "beta_cca"
			replace imp = 0 if varname == "beta_cca"
			
			gen str_numpos = strpos(varname,"0")
			gen misaux = substr(varname,str_numpos-1,2) if str_numpos > 0 
			destring misaux , replace
			replace misaux = 0 if varname == "beta_imp_auxnomiss"
			
			gen aux = 1 if!inlist(varname, "beta_cca", "beta_imp_noaux")
			gen auxid = `auxid'
			gen auxcorr = `auxid'*0.2 - 0.1
			
			sort auxid misaux varname
			gen cca_bias = bias[11]

			save "$Datadir/`outmis'/`auxmis'/Prepared_data\simsum_out_`auxid'.dta", replace
		}
	}
}	

********************************************************************************
* 4 - Calculate summary statistics for FMI 
********************************************************************************
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues auxid = 1(1)4 {
			use "$Datadir/`outmis'/`auxmis'/Prepared_data\simall_auxid_`auxid'.dta", clear

			capture postutil clear
			tempname memhold 
			postfile `memhold' auxid auxcorr auximp misaux mean se median LQ UQ /// 
					 using "$Datadir/`outmis'/`auxmis'/Prepared_data\FMI_sumstats_auxid`auxid'.dta", replace


					 
			summ fmi_imp_noaux, det
			post `memhold' (`auxid') (`auxid'*0.2 - 0.1) (0) (0) (r(mean)) (r(sd)/sqrt(r(N))) (r(p50)) (r(p25)) (r(p75))	

			summ fmi_imp_auxnomiss, det
			post `memhold' (`auxid') (`auxid'*0.2 - 0.1) (1) (0) (r(mean)) (r(sd)/sqrt(r(N))) (r(p50)) (r(p25)) (r(p75))	


			forvalues misval = 10(10)90 {
				summ fmi_imp_auxmiss`misval'p, det
				post `memhold' (`auxid') (`auxid'*0.2 - 0.1) (1) (`misval') (r(mean)) (r(sd)/sqrt(r(N))) (r(p50)) (r(p25)) (r(p75))	
			}

			postclose `memhold '

		}
	}
}

********************************************************************************
* 5 - Calculate summary statistics for amount missing Y and Z 
********************************************************************************
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues auxid = 1(1)4 {
			use "$Datadir/`outmis'/`auxmis'/Prepared_data\simall_auxid_`auxid'.dta", clear

			capture postutil clear
			tempname memhold 
			postfile `memhold' auxid auxcorr aux imp misaux mean se median LQ UQ /// 
					 using "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\prop_yzmiss_sumstats_auxid`auxid'.dta", replace


			summ prop_yzmiss_imp_auxnomiss, det
			post `memhold' (`auxid') (`auxid'*0.2 - 0.1) (1) (1) (0) (r(mean)) (r(sd)/sqrt(r(N))) (r(p50)) (r(p25)) (r(p75))	


			forvalues misval = 10(10)90 {
				summ prop_yzmiss_imp_auxmiss`misval'p, det
				post `memhold' (`auxid') (`auxid'*0.2 - 0.1) (1) (1) (`misval') (r(mean)) (r(sd)/sqrt(r(N))) (r(p50)) (r(p25)) (r(p75))	
			}

			postclose `memhold '

		}
	}
}


* merge on bias information 
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
		forvalues auxid = 1(1)4 {

			use "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\prop_yzmiss_sumstats_auxid`auxid'.dta", clear
			merge 1:1 misaux aux imp using "$Datadir/`outmis'/`auxmis'/Prepared_data\simsum_out_`auxid'.dta", keep(3) 
			save "$Datadir/`outmis'/`auxmis'/Prepared_data\prop_yzmiss_sumstats_auxid`auxid'.dta", replace
			capture erase "$Datadir/`outmis'/`auxmis'/Prepared_data\_temp\prop_yzmiss_sumstats_auxid`auxid'.dta"

		}
	}
}

********************************************************************************
log close