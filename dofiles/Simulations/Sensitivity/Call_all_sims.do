********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		14 Feb 2023
* Description:		Call all simulation programs for the sensitivity analyses 
********************************************************************************


foreach sens in More_missing_outcome Stronger_ZY_than_XY {
	foreach outmis in Efficiency_imputation MAR_outcome Proxy_outcome {
		forvalues auxid = 4(1)4 {
			disp "sens = `sens', outmis = `outmis', auxid = `auxid'"
			if "`outmis'" == "Efficiency_imputation" {
				do "$Dodir/Simulations/Sensitivity/`sens'/`outmis'/3_MNAR_auxiliary/sim_aux_call.do" "`auxid'" "3_MNAR_auxiliary" "`outmis'" "`sens'"
			}
			if "`outmis'" != "Efficiency_imputation" {
				do "$Dodir/Simulations/Sensitivity/`sens'/`outmis'/2_MAR_auxiliary/sim_aux_call.do" "`auxid'" "2_MAR_auxiliary" "`outmis'" "`sens'"
			}
		}
	}
}