cap log close
log using "$Logdir\plot_results_MNAR_aux.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		12 May 2022
* Description:	Visualisation of output
********************************************************************************
* Contents 
********************************************************************************
* 1 - Bias plots
* 3 - FMI plots

********************************************************************************
* 1 - Bias plots 
******************************************************************************** 
foreach outmis in MAR_outcome Proxy_outcome {
	forvalues val = 1(1)3 {
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1 - Y MAR given complete X and Z"
			if `val' == 1 {
				local gtext1 = "A"
			}
			if `val' == 2 {
				local gtext1 = "B"
			}
			if `val' == 3 {
				local gtext1 = "C"
			} 		
		}
		if "`outmis'" == "Proxy_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 2 - Y MNAR"
			if `val' == 1 {
				local gtext1 = "D"
			}
			if `val' == 2 {
				local gtext1 = "E"
			}
			if `val' == 3 {
				local gtext1 = "F"
			} 					
		}		
		
		if `val' == 1 {
			local dir = "`outmis'/1_MCAR_auxiliary"
			local gtext0 = ""			
			local gtext2 = " MCAR auxiliary data"
		}
		if `val' == 2 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 = "`outmis_text'"						
			local gtext2 = " MAR auxiliary data"
		}
		if `val' == 3 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""						
			local gtext2 = " MNAR auxiliary data"		
		} 
		
		
		
		if "`outmis'" == "MAR_outcome" {
			local outs = "MAR"
		}
		if "`outmis'" == "Proxy_outcome" {
			local outs = "prox"
		}
		
		disp "`dir'"
		disp "`gtext'"
		
		use "$Datadir/`dir'/Prepared_data/simsum_out_1", clear
		append using "$Datadir/`dir'/Prepared_data/simsum_out_2"
		append using "$Datadir/`dir'/Prepared_data/simsum_out_3"
		append using "$Datadir/`dir'/Prepared_data/simsum_out_4"

		gen abs_bias = abs(bias)
		gen lci_bias = abs_bias - invnormal(0.975)*bias_mcse
		gen uci_bias = abs_bias + invnormal(0.975)*bias_mcse
		
		gen relbias 	= 100*abs_bias/abs(cca_bias)
		gen relbias_lci = 100*lci_bias/abs(cca_bias)
		gen relbias_uci = 100*uci_bias/abs(cca_bias)

		sort auxid misaux varname	
		local ccaline = "yline(100, lp(dash) lc(black))"
	
		local ytextpos0 = 150
		local ytextpos1 = 125
		local ytextpos2 = 125

		disp "test1"

		twoway 	(line relbias misaux    				if imp == 1 & auxid == 1, col(red))   ///
				(rcap relbias_lci relbias_uci misaux 	if imp == 1 & auxid == 1, col(red))   ///
				(line relbias misaux    				if imp == 1 & auxid == 2, col(blue))  ///
				(rcap relbias_lci relbias_uci misaux	if imp == 1 & auxid == 2, col(blue))  ///
				(line relbias misaux    				if imp == 1 & auxid == 3, col(green)) ///
				(rcap relbias_lci relbias_uci misaux	if imp == 1 & auxid == 3, col(green)) ///
				(line relbias misaux    				if imp == 1 & auxid == 4, col(orange)) ///
				(rcap relbias_lci relbias_uci misaux	if imp == 1 & auxid == 4, col(orange)) ///		
				, ///
				`ccaline' ///
				ytitle("% Relative bias" "(MC 95% CI)", size(small)) ///
				ylab(0(25)100, labsize(small)) ///
				yscale(range(-5 105)) ///
				xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
				xlab(,labsize(small)) ///
				legend(order(1  "Correlation of Z and Y = 0.1" ///
							 3  "Correlation of Z and Y = 0.3" ///
							 5  "Correlation of Z and Y = 0.5" ///
							 7  "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos0' -190 "`gtext0'", place(e) size(medium))  ///							
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10   "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(bias`val'_`outs', replace)

	}			
}	



local outmis = "Efficiency_imputation" 
forvalues val = 1(1)3 {
	if `val' == 1 {
		local dir = "`outmis'/1_MCAR_auxiliary"
		local gtext0 = ""
		local gtext1 = "G"
		local gtext2 = " MCAR auxiliary data"
	}
	if `val' == 2 {
		local dir = "`outmis'/2_MAR_auxiliary"
		local gtext0 = "Outcome Missingness Mechanism 3 - Y MAR given complete X"
		local gtext1 = "H"
		local gtext2 = " MAR auxiliary data"
	}
	if `val' == 3 {
		local dir = "`outmis'/3_MNAR_auxiliary"
		local gtext0 = ""
		local gtext1 = "I"
		local gtext2 = " MNAR auxiliary data"		
	}
	
	
	disp "`dir'"
	disp "`gtext'"
	
	use "$Datadir/`dir'/Prepared_data/simsum_out_1", clear
	append using "$Datadir/`dir'/Prepared_data/simsum_out_2"
	append using "$Datadir/`dir'/Prepared_data/simsum_out_3"
	append using "$Datadir/`dir'/Prepared_data/simsum_out_4"

	gen abs_bias = abs(bias)
	gen lci_bias = abs_bias - invnormal(0.975)*bias_mcse
	gen uci_bias = abs_bias + invnormal(0.975)*bias_mcse

	sort auxid misaux varname	
	
	local cca1 = abs_bias[11]
	local cca2 = abs_bias[23]
	local cca3 = abs_bias[35]
	local cca4 = abs_bias[47]
			
	local ccaline = "yline(`cca1', lp(dash) lc(red))"
	local ccaline = "`ccaline' " + "yline(`cca2', lp(dash) lc(blue))" 
	local ccaline = "`ccaline' " + "yline(`cca3', lp(dash) lc(green))" 
	local ccaline = "`ccaline' " + "yline(`cca4', lp(dash) lc(orange))" 
	
	local ytextpos0 = .15
	local ytextpos1 = .125
	local ytextpos2 = .125

	disp "test1"

	twoway 	(line abs_bias misaux    				if imp == 1 & auxid == 1, col(red))   ///
			(rcap lci_bias uci_bias misaux 	if imp == 1 & auxid == 1, col(red))   ///
			(line abs_bias misaux    				if imp == 1 & auxid == 2, col(blue))  ///
			(rcap lci_bias uci_bias misaux	if imp == 1 & auxid == 2, col(blue))  ///
			(line abs_bias misaux    				if imp == 1 & auxid == 3, col(green)) ///
			(rcap lci_bias uci_bias misaux	if imp == 1 & auxid == 3, col(green)) ///
			(line abs_bias misaux    				if imp == 1 & auxid == 4, col(orange)) ///
			(rcap lci_bias uci_bias misaux	if imp == 1 & auxid == 4, col(orange)) ///		
			, ///
			`ccaline' ///
			ytitle("Absolute bias" "(MC 95% CI)", size(small)) ///
			ylab(0(0.025)0.1, labsize(small)) ///
			yscale(range(-0.001 0.105)) ///	
			xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
			xlab(,labsize(small)) ///
			legend(order(1  "Correlation of Z and Y = 0.1" ///
						 3  "Correlation of Z and Y = 0.3" ///
						 5  "Correlation of Z and Y = 0.5" ///
						 7  "Correlation of Z and Y = 0.7") ///
					position(6) ring(0) size(2) cols(2)) ///
			text(`ytextpos0' -190 "`gtext0'", place(e) size(medium))  ///												
			text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
			text(`ytextpos2' 10   "`gtext2'", place(e) size(small))  ///						 
			graphregion(color(white)) ///
			name(bias`val'_eff, replace)
}		


grc1leg bias1_MAR  bias2_MAR  bias3_MAR  ///
		bias1_prox bias2_prox bias3_prox ///
		bias1_eff  bias2_eff  bias3_eff ///
		, rows(3) graphregion(color(white)) name("bias_plot", replace) 
graph export "$Graphdir\bias_plot.png", name(bias_plot) replace width(2400) height(1600)
	

	
********************************************************************************
* 2 - FMI plots
********************************************************************************
******************************************************************************** 

local i = 0
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	forvalues val = 1(1)3 {
		
		local i = `i' + 1
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1 - Y MAR given complete X and Z"
			if `val' == 1 {
				local gtext1 = "A"
			}
			if `val' == 2 {
				local gtext1 = "B"
			}
			if `val' == 3 {
				local gtext1 = "C"
			} 		
		}
		if "`outmis'" == "Proxy_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 2 - Y MNAR"
			if `val' == 1 {
				local gtext1 = "D"
			}
			if `val' == 2 {
				local gtext1 = "E"
			}
			if `val' == 3 {
				local gtext1 = "F"
			} 					
		}
		if "`outmis'" == "Efficiency_imputation" {
			local outmis_text = "Outcome Missingness Mechanism 3 - Y MAR given complete X"
			if `val' == 1 {
				local gtext1 = "G"
			}
			if `val' == 2 {
				local gtext1 = "H"
			}
			if `val' == 3 {
				local gtext1 = "I"
			} 		
		}

		
		if `val' == 1 {
			local dir = "`outmis'/1_MCAR_auxiliary"
			local gtext0 = ""		
			local gtext2 = " MCAR auxiliary data"
		}
		if `val' == 2 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 = "`outmis_text'"							
			local gtext2 = " MAR auxiliary data"
		}
		if `val' == 3 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""						
			local gtext2 = " MNAR auxiliary data"		
		} 
		
		disp "`dir'"
		disp "`gtext0'"
		disp "`gtext1'"
		disp "`gtext2'"
		
		use "$Datadir/`dir'/Prepared_data/FMI_sumstats_auxid1", clear
		append using "$Datadir/`dir'/Prepared_data/FMI_sumstats_auxid2"
		append using "$Datadir/`dir'/Prepared_data/FMI_sumstats_auxid3"
		append using "$Datadir/`dir'/Prepared_data/FMI_sumstats_auxid4"
		

		gen lci = mean - invnormal(0.975)*se
		gen uci = mean + invnormal(0.975)*se


		sort auxid auximp misaux
		
		gen obs = _n
		summarize obs if auximp == 0 & round(auxcorr,0.1) == round(0.1,0.1)
		local fmi1 = mean[r(mean)]
		summarize obs if auximp == 0 & round(auxcorr,0.1) == round(0.3,0.1)
		local fmi2 = mean[r(mean)]
		summarize obs if auximp == 0 & round(auxcorr,0.1) == round(0.5,0.1)
		local fmi3 = mean[r(mean)]
		summarize obs if auximp == 0 & round(auxcorr,0.1) == round(0.7,0.1)
		local fmi4 = mean[r(mean)]	
		
		disp "`fmi1'" "  " "`fmi2'" "  " "`fmi3'" "  " "`fmi4'"
				
		local ytextpos0 = 1.05
		local ytextpos1 = 0.90
		local ytextpos2 = 0.90

		
		twoway 	(line mean misaux    if auximp == 1 & auxid == 1, col(red))   ///
				(rcap lci uci misaux if auximp == 1 & auxid == 1, col(red))   ///
				(line mean misaux    if auximp == 1 & auxid == 2, col(blue))  ///
				(rcap lci uci misaux if auximp == 1 & auxid == 2, col(blue))  ///
				(line mean misaux    if auximp == 1 & auxid == 3, col(green)) ///
				(rcap lci uci misaux if auximp == 1 & auxid == 3, col(green)) ///
				(line mean misaux    if auximp == 1 & auxid == 4, col(orange)) ///				
				(rcap lci uci misaux if auximp == 1 & auxid == 4, col(orange)) ///
				, ///
				yline(`fmi1', lp(dash) lc(red)) ///
				yline(`fmi2', lp(dash) lc(blue)) ///
				yline(`fmi3', lp(dash) lc(green)) ///
				yline(`fmi4', lp(dash) lc(orange)) ///				
				ytitle("Mean FMI" "(MC 95% CI)", size(small)) ///
				ylab(,labsize(small)) ///
				xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
				xlab(,labsize(small)) ///
				legend(order(1 "Correlation of Z and Y = 0.1" ///
							 3 "Correlation of Z and Y = 0.3" ///
							 5 "Correlation of Z and Y = 0.5" ///
							 7 "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos0' -190 "`gtext0'", place(e) size(medium))  ///												
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10  "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(FMI_mean`i', replace)
	}							
}

grc1leg FMI_mean1 FMI_mean2 FMI_mean3 /// 
		FMI_mean4 FMI_mean5 FMI_mean6 ///
		FMI_mean7 FMI_mean8 FMI_mean9 ///
		, ycommon graphregion(color(white)) name("FMI_plot", replace) 
graph export "$Graphdir\FMI_plot.png", name(FMI_plot) replace width(2400) height(1600)



********************************************************************************
log close


