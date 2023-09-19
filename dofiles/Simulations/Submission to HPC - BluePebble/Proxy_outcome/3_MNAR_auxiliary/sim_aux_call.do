********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		05 May 2022
* Description:	Call the simulation program 
********************************************************************************
args auxid 

global Projectdir "/user/home/pm0233/Simulations/Auxiliary_missing/Proxy_outcome/3_MNAR_auxiliary"
global Datadir 		"$Projectdir/datafiles"

disp "$Projectdir"
disp "$Datadir"

global simno = 1000 // number of simulations used
global impno = 100  // number of imputations used

set seed 548698274
forvalues sim = 1(1)$simno {
	local auxr = `auxid'*0.2 - 0.1
	
	disp "sim = `sim'; auxid = `auxid'; aux correlation = `auxr'"
	
	* Create data structure 
	matrix mu = (6,-3,2)
	matrix rownames mu = mean
	matrix colnames mu = Y X Z 
	matrix list mu
	  
	matrix Sigma = (1.0,0.6,`auxr' \ ///
					0.6,1,0 \ ///
					`auxr',0,1 )
	matrix rownames Sigma = Y X Z 
	matrix colnames Sigma = Y X Z  
	matrix list Sigma				

	* Simulate data
	clear
	set obs 1000
	drawnorm Y X Z  , means(mu) cov(Sigma)


	* Simulate missing data in Y 
	gen Y_m50 = Y if normal(Y-6) > 0.5


	* Simulate missing data in the auxiliaries 
	forvalues j = 0(1)9 {
		gen Z_`j' = Z if normal(Z-2) > `j'/10 
	}



	* run models 
	capture postutil clear
	tempname memhold 
	postfile `memhold' sim auxid auxcorr full cca imp aux misprop beta se fmi prop_yzmiss using "$Datadir/simout_sim`sim'_auxid`auxid'.dta", replace

	regress Y X
	matrix beta = e(b)
	matrix vari = e(V)
	post `memhold' (`sim') (`auxid') (`auxr') (1) (0) (0) (0) (0) (beta[1,1]) (sqrt(vari[1,1])) (0) (.)

	regress Y_m50 X
	matrix beta = e(b)
	matrix vari = e(V)
	post `memhold' (`sim') (`auxid') (`auxr') (0) (1) (0) (0) (0) (beta[1,1]) (sqrt(vari[1,1])) (0) (.)

		* no auxiliaries 
	preserve
		mi set flong 
		mi register imputed Y_m50  
		mi register regular X 

		mi impute chained (regress) Y_m50 = X, add($impno) dots
		mi estimate: regress Y_m50 X 
		
		matrix beta = e(b_mi)
		matrix vari = e(V_mi)
		matrix fmi  = e(fmi_mi)
		post `memhold' (`sim') (`auxid') (`auxr') (0) (0) (1) (0) (0) (beta[1,1]) (sqrt(vari[1,1])) (fmi[1,1]) (.)
	restore
		

	* Perform imputations
	forvalues j = 0(1)9 {
		preserve
		
		count if  Y_m50 == . & Z_`j' == .
		scalar prop_yzmiss = 100*r(N)/_N		
		
		mi set flong 
		mi register imputed Y_m50 Z_`j'  
		mi register regular X 

		mi impute chained (regress) Y_m50 ///
						  (regress) Z_`j' ///
						  = X, add($impno) dots
		mi estimate: regress Y_m50 X 
		
		matrix beta = e(b_mi)
		matrix vari = e(V_mi)
		matrix fmi  = e(fmi_mi)
		scalar mprop = `j'/10
		post `memhold' (`sim') (`auxid') (`auxr') (0) (0) (1) (1) (mprop) (beta[1,1]) (sqrt(vari[1,1])) (fmi[1,1]) (prop_yzmiss)
		
		restore 
	}

	postclose `memhold' 	
}	
	
		