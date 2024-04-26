cap log close
log using "$Logdir\plot_results_sensitivity.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		27 Oct 2022
* Description:	Visualisation of sensitivity results
********************************************************************************
* Contents 
********************************************************************************
* 1 - Bias plots
* 2 - FMI plots
* 3 - Excluding W from the imputation model 

********************************************************************************
* 1 - Bias plots 
******************************************************************************** 
local val = 0
foreach outmis in MAR_outcome Proxy_outcome {
	foreach sens in More_missing_outcome Stronger_ZY_than_XY {
		
		local val = `val' + 1
		local dir = "Sensitivity/`sens'/`outmis'/2_MAR_auxiliary"	
			
		if "`sens'" == "More_missing_outcome" & "`outmis'" ==  "MAR_outcome" {
			local gtext = "A - Missing outcome data = 75%"
			local gtext2 = "   Outcome Mechanism 1"
		}
		if "`sens'" == "More_missing_outcome" & "`outmis'" ==  "Proxy_outcome" {
			local gtext = "B - Missing outcome data = 75%"
			local gtext2 = "   Outcome Mechanism 2"
		}
		if "`sens'" == "Stronger_ZY_than_XY" & "`outmis'" ==  "MAR_outcome" {
			local gtext = "D - Correlation between X and Y = 0.2"
			local gtext2 = "   Outcome Mechanism 1"		
		}
		if "`sens'" == "Stronger_ZY_than_XY" & "`outmis'" ==  "Proxy_outcome" {
			local gtext = "E - Correlation between X and Y = 0.2"
			local gtext2 = "   Outcome Mechanism 2"	
		}
		
		disp "`dir'"
		disp "`gtext'"
		disp "`gtext2'"

		
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
	
		local ytextpos1 = 120
		local ytextpos2 = 110

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
				ytitle("% Relative bias (Monte Carlo 95% CI)", size(small)) ///
				ylab(0(20)100,labsize(small)) ///
				yscale(range(-5 105)) ///
				xtitle("Proportion of missing data in auxiliary variable, Z", size(small)) ///
				xlab(,labsize(small)) ///
				legend(order(1  "Correlation of Z and Y = 0.1" ///
							 3  "Correlation of Z and Y = 0.3" ///
							 5  "Correlation of Z and Y = 0.5" ///
							 7 "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos1' 0 "`gtext'", place(e) size(small))  ///	
				text(`ytextpos2' 0 "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(bias`val', replace)

	}			
}	
		
local outmis = "Efficiency_imputation" 
local val = 4
foreach sens in More_missing_outcome Stronger_ZY_than_XY {
	local val = `val' + 1
	local dir = "Sensitivity/`sens'/`outmis'/3_MNAR_auxiliary"	
		
	if "`sens'" == "More_missing_outcome" {
		local gtext = "C - Missing outcome data = 75%"
		local gtext2 = "   Outcome Mechanism 3"
		
	}
	if "`sens'" == "Stronger_ZY_than_XY" {
		local gtext = "F - Correlation between X and Y = 0.2"
		local gtext2 = "   Outcome Mechanism 3"	
	}

	local ytextpos1 = 120*140
	local ytextpos2 = 110*140

	
	disp "`dir'"
	disp "`gtext'"
	disp "`gtext2'"

	
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
			ytitle("% Relative bias (Monte Carlo 95% CI)", size(small)) ///
			ylab(0(2000)14000,labsize(small)) ///
			yscale(range(-700 14700)) ///		
			xtitle("Proportion of missing data in auxiliary variable, Z", size(small)) ///
			xlab(,labsize(small)) ///
			legend(order(1  "Correlation of Z and Y = 0.1" ///
						 3  "Correlation of Z and Y = 0.3" ///
						 5  "Correlation of Z and Y = 0.5" ///
						 7 "Correlation of Z and Y = 0.7") ///
					position(6) ring(0) size(2) cols(2)) ///
			text(`ytextpos1' 0 "`gtext'", place(e) size(small))  ///	
			text(`ytextpos2' 0 "`gtext2'", place(e) size(small))  ///						 
			graphregion(color(white)) ///
			name(bias`val', replace)

}	


grc1leg bias1 bias3 bias5 ///
		bias2 bias4 bias6, graphregion(color(white)) name("sensitivity_bias_plot", replace) 
graph export "$Graphdir\sensitivity_bias_plots.png", name(sensitivity_bias_plot) replace width(2400) height(1600)
	

	


********************************************************************************
* 2 - FMI plots
********************************************************************************
local val = 0
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	foreach sens in More_missing_outcome Stronger_ZY_than_XY  {
			
		local val = `val' + 1
		local dir = "Sensitivity/`sens'/`outmis'"	
				
		if "`sens'" == "More_missing_outcome" & "`outmis'" ==  "MAR_outcome" {
			local gtext = "A - Missing outcome data = 75%"
			local gtext2 = "   Outcome Mechanism 1"
		}
		if "`sens'" == "More_missing_outcome" & "`outmis'" ==  "Proxy_outcome" {
			local gtext = "B - Missing outcome data = 75%"
			local gtext2 = "   Outcome Mechanism 2"
		}
		if "`sens'" == "More_missing_outcome" & "`outmis'" ==  "Efficiency_imputation" {
			local gtext = "C - Missing outcome data = 75%"
			local gtext2 = "   Outcome Mechanism 3"			
		}		
		if "`sens'" == "Stronger_ZY_than_XY" & "`outmis'" ==  "MAR_outcome" {
			local gtext = "D - Correlation between X and Y = 0.2"
			local gtext2 = "   Outcome Mechanism 1"		
		}
		if "`sens'" == "Stronger_ZY_than_XY" & "`outmis'" ==  "Proxy_outcome" {
			local gtext = "E - Correlation between X and Y = 0.2"
			local gtext2 = "   Outcome Mechanism 2"	
		}
		if "`sens'" == "Stronger_ZY_than_XY" & "`outmis'" ==  "Efficiency_imputation" {
			local gtext = "F - Correlation between X and Y = 0.2"
			local gtext2 = "   Outcome Mechanism 3"	
		}
		
		if "`outmis'" != "Efficiency_imputation" {
			local dir2  = "2_MAR_auxiliary"
		}
		if "`outmis'" == "Efficiency_imputation" {
			local dir2  = "3_MNAR_auxiliary"
		}
		
		disp "`dir'"
		disp "`gtext'"
		disp "`gtext2'"

		
		use "$Datadir/`dir'/`dir2'/Prepared_data/FMI_sumstats_auxid1", clear
		append using "$Datadir/`dir'/`dir2'/Prepared_data/FMI_sumstats_auxid2"
		append using "$Datadir/`dir'/`dir2'/Prepared_data/FMI_sumstats_auxid3"
		append using "$Datadir/`dir'/`dir2'/Prepared_data/FMI_sumstats_auxid4"

		gen lci = mean - invnormal(0.975)*se
		gen uci = mean + invnormal(0.975)*se

		sort auxid auximp misaux
		local fmi1 = mean[1]
		local fmi2 = mean[12]
		local fmi3 = mean[23]
		local fmi4 = mean[34]
		
		local fmiline = "yline(`fmi1', lp(dash) lc(red))"
		local fmiline = "`fmiline' " + "yline(`fmi2', lp(dash) lc(blue))" 
		local fmiline = "`fmiline' " + "yline(`fmi3', lp(dash) lc(green))" 
		local fmiline = "`fmiline' " + "yline(`fmi4', lp(dash) lc(orange))" 			
			
		local ytextpos1 = 1.08
		local ytextpos2 = 1.03
			
		twoway 	(line mean misaux    if auximp == 1 & auxid == 1, col(red))   ///
				(rcap lci uci misaux if auximp == 1 & auxid == 1, col(red))   ///
				(line mean misaux    if auximp == 1 & auxid == 2, col(blue))  ///
				(rcap lci uci misaux if auximp == 1 & auxid == 2, col(blue))  ///
				(line mean misaux    if auximp == 1 & auxid == 3, col(green)) ///
				(rcap lci uci misaux if auximp == 1 & auxid == 3, col(green)) ///
				(line mean misaux    if auximp == 1 & auxid == 4, col(orange)) ///
				(rcap lci uci misaux if auximp == 1 & auxid == 4, col(orange)) ///
				, ///
				`fmiline' ///			
				ytitle("Mean FMI (Monte Carlo 95% CI)", size(small)) ///
				ylab(, labsize(small)) ///
				xtitle("Proportion of missing data in auxiliary variable, Z", size(small)) ///
				xlab(, labsize(small)) ///
				legend(order(1  "Correlation of Z and Y = 0.1" ///
							 3  "Correlation of Z and Y = 0.3" ///
							 5  "Correlation of Z and Y = 0.5" ///
							 7 "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos1' 0 "`gtext'", place(e) size(small))  ///	
				text(`ytextpos2' 0 "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(FMI_mean`val', replace)

	}			
}

grc1leg FMI_mean1 FMI_mean3 FMI_mean5 ///
		FMI_mean2 FMI_mean4 FMI_mean6, ycommon graphregion(color(white)) name("sensitivity_FMI_plot", replace) 
graph export "$Graphdir\sensitivity_FMI_plot.png", name(sensitivity_FMI_plot) replace width(2400) height(1600)



********************************************************************************
* 3 - Excluding W from the imputation model 
********************************************************************************
* Bias plot
************
foreach val in 4 2 {
	foreach outmis in MAR_outcome Proxy_outcome {
		
		if `val' == 4 {
			local dir = "`outmis'/4_MNARv2_auxiliary"			

			if "`outmis'" == "MAR_outcome" {
				local gtext0 = "Excluding W from imputation model"						
				local gtext1 = "A"
				local gtext2 = "  Outcome mechanism 1"						
			}
			if "`outmis'" == "Proxy_outcome" {
				local gtext0 = ""						
				local gtext1 = "B"
				local gtext2 = "  Outcome mechanism 2"						
			}
		}
		if `val' == 2 {
			local dir = "`outmis'/2_MAR_auxiliary"			
			
			if "`outmis'" == "MAR_outcome" {
				local gtext0 = "Including W in imputation model"						
				local gtext1 = "D"
				local gtext2 = "  Outcome mechanism 1"						
			}
			if "`outmis'" == "Proxy_outcome" {
				local gtext0 = ""						
				local gtext1 = "E"
				local gtext2 = "  Outcome mechanism 2"						
			}		
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
	
		local ytextpos0 = 125
		local ytextpos1 = 110
		local ytextpos2 = 110

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
				text(`ytextpos0' -45 "`gtext0'", place(e) size(medium))  ///							
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10   "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(bias`val'_`outs', replace)

	}			
}	



local outmis = "Efficiency_imputation" 
foreach val in 4 2 {
	if `val' == 4 {
		local dir = "`outmis'/4_MNARv2_auxiliary"
		local gtext0 = ""
		local gtext1 = "C"
		local gtext2 = "  Outcome mechanism 3"
	}
	if `val' == 2 {
		local dir = "`outmis'/2_MAR_auxiliary"
		local gtext0 = ""
		local gtext1 = "F"
		local gtext2 = "  Outcome mechanism 3"
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
	
	local ytextpos0 = .125
	local ytextpos1 = .110
	local ytextpos2 = .110

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
			text(`ytextpos0' -45 "`gtext0'", place(e) size(medium))  ///												
			text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
			text(`ytextpos2' 10   "`gtext2'", place(e) size(small))  ///						 
			graphregion(color(white)) ///
			name(bias`val'_eff, replace)
}		


grc1leg bias4_MAR  bias4_prox  bias4_eff  ///
		bias2_MAR  bias2_prox  bias2_eff ///
		, rows(2) graphregion(color(white)) name("bias_exclW_plot", replace) 
graph export "$Graphdir\bias_sens_exclW_plot.png", name(bias_exclW_plot) replace width(2400) height(1600)
	

			*****************************************
* FMI 	
************
local i = 0
foreach val in 4 2 {
	foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
		
		local i = `i' + 1
		
		if "`outmis'" == "MAR_outcome" {
			local gtext2 = "  Outcome mechanism 1"
		}
		if "`outmis'" == "Proxy_outcome" {
			local gtext2 = "  Outcome mechanism 2"
		}
		if "`outmis'" == "Efficiency_imputation" {
			local gtext2 = "  Outcome mechanism 3"
		}

		
		if `val' == 4 {
			local dir = "`outmis'/4_MNARv2_auxiliary"
			if "`outmis'" == "MAR_outcome" {
				local gtext0 = "Excluding W from imputation model"	
				local gtext1 = "A"
			}
			if "`outmis'" == "Proxy_outcome" {
				local gtext0 = "`outmis_text'"	
				local gtext1 = "B"
			}
			if "`outmis'" == "Efficiency_imputation" {
				local gtext0 = "`outmis_text'"	
				local gtext1 = "C"
			}
		}
		if `val' == 2 {
			local dir = "`outmis'/2_MAR_auxiliary"
			if "`outmis'" == "MAR_outcome" {
				local gtext0 = "Including W in imputation model"	
				local gtext1 = "D"
			}
			if "`outmis'" == "Proxy_outcome" {
				local gtext0 = ""	
				local gtext1 = "E"
			}
			if "`outmis'" == "Efficiency_imputation" {
				local gtext0 = ""	
				local gtext1 = "F"
			}	
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
				
		local ytextpos0 = 0.93
		local ytextpos1 = 0.86
		local ytextpos2 = 0.86

		
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
				legend(order(1  "Correlation of Z and Y = 0.1" ///
							 3  "Correlation of Z and Y = 0.3" ///
							 5  "Correlation of Z and Y = 0.5" ///
							 7 "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos0' -45 "`gtext0'", place(e) size(medium))  ///												
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10  "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(FMI_mean`i', replace)
	}							
}

grc1leg FMI_mean1 FMI_mean2 FMI_mean3 /// 
		FMI_mean4 FMI_mean5 FMI_mean6 ///
		, ycommon graphregion(color(white)) name("FMI_excW_plot", replace) 
graph export "$Graphdir\FMI_sens_excW_plot.png", name(FMI_excW_plot) replace width(2400) height(1600)



********************************************************************************
log close


