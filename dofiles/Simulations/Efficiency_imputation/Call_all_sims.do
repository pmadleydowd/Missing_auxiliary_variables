********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		14 Feb 2023
* Description:	Call all simulation programs for the efficiency based imputation 
********************************************************************************


foreach auxmis in 1_MCAR_auxiliary 2_MAR_auxiliary 3_MNAR_auxiliary 4_MNARv2_auxiliary {
	forvalues auxid = 4(1)4 {
		disp "auxmis = `auxmis', auxid = `auxid'"
		do "$Dodir/Simulations/Efficiency_imputation/`auxmis'/sim_aux_call.do" "`auxid'" "`auxmis'"
		
	}
}
