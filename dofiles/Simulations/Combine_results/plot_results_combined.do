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
* 2 - FMI plots
* 3 - SE plots
* 4 - Patterns of missing data

********************************************************************************
* 1 - Bias plots 
******************************************************************************** 
foreach outmis in MAR_outcome Proxy_outcome {
	forvalues val = 1(1)3 {
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1: probability of missing Y independent of Y given complete X and Z"
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
			local outmis_text = "Outcome Missingness Mechanism 2: probability of missing Y dependent on Y"
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
			local gtext2 = " Auxiliary Missingness Mechanism 1"
		}
		if `val' == 2 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""						
			local gtext2 = " Auxiliary Missingness Mechanism 2"
		}
		if `val' == 3 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 = "`outmis_text'"						
			local gtext2 = " Auxiliary Missingness Mechanism 3"		
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
	
		local ytextpos0 = 155
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
				text(`ytextpos0' -310 "`gtext0'", place(e) size(medium))  ///							
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
		local gtext2 = " Auxiliary Missingness Mechanism 1"
	}
	if `val' == 2 {
		local dir = "`outmis'/3_MNAR_auxiliary"
		local gtext0 = ""
		local gtext1 = "H"
		local gtext2 = " Auxiliary Missingness Mechanism 2"
	}
	if `val' == 3 {
		local dir = "`outmis'/2_MAR_auxiliary"
		local gtext0 = "Outcome Missingness Mechanism 3: probability of missing Y independent of Y given complete X"
		local gtext1 = "I"
		local gtext2 = " Auxiliary Missingness Mechanism 3"		
	}
	
	
	disp "`dir'"
	disp "`gtext'"
	
	use "$Datadir/`dir'/Prepared_data/simsum_out_1", clear
	append using "$Datadir/`dir'/Prepared_data/simsum_out_2"
	append using "$Datadir/`dir'/Prepared_data/simsum_out_3"
	append using "$Datadir/`dir'/Prepared_data/simsum_out_4"

	gen abs_bias = abs(bias)
	gen lci_bias = abs(bias) - invnormal(0.975)*bias_mcse
	gen uci_bias = abs(bias) + invnormal(0.975)*bias_mcse

	gen relbias 	= 100*abs_bias/abs(cca_bias)
	gen relbias_lci = 100*lci_bias/abs(cca_bias)
	gen relbias_uci = 100*uci_bias/abs(cca_bias)

	
	sort auxid misaux varname	
	
	local ccaline = "yline(100, lp(dash) lc(black))"
	
	local ytextpos0 = 155*50
	local ytextpos1 = 125*50
	local ytextpos2 = 125*50

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
			ylab(0(1000)4000, labsize(small)) ///
			yscale(range(-250 5250)) ///
			xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
			xlab(,labsize(small)) ///
			legend(order(1  "Correlation of Z and Y = 0.1" ///
						 3  "Correlation of Z and Y = 0.3" ///
						 5  "Correlation of Z and Y = 0.5" ///
						 7  "Correlation of Z and Y = 0.7") ///
					position(6) ring(0) size(2) cols(2)) ///
			text(`ytextpos0' -320 "`gtext0'", place(e) size(medium))  ///												
			text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
			text(`ytextpos2' 10   "`gtext2'", place(e) size(small))  ///						 
			graphregion(color(white)) ///
			name(bias`val'_eff, replace)
}		


grc1leg bias1_MAR  bias2_MAR  bias3_MAR  ///
		bias1_prox bias2_prox bias3_prox ///
		bias1_eff  bias2_eff  bias3_eff ///
		, rows(3) graphregion(color(white)) name("bias_plot", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\bias_plot.png", name(bias_plot) replace width(2400) height(1600)
	

* create as individual plots
	* outcome mechanism 1
grc1leg bias1_MAR  bias2_MAR  bias3_MAR  ///
		, cols(3) graphregion(color(white) margin(0 0 0 20)) name("bias_plot1", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\bias_plot_om1.png", name(bias_plot1) replace width(2400) height(1600)	

	* outcome mechanism 2
grc1leg bias1_prox bias2_prox bias3_prox ///
		, cols(3) graphregion(color(white) margin(0 0 0 20)) name("bias_plot2", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\bias_plot_om2.png", name(bias_plot2) replace width(2400) height(1600)	

	* outcome mechanism 3
grc1leg bias1_eff  bias2_eff  bias3_eff ///
		, cols(3) graphregion(color(white) margin(0 0 0 20)) name("bias_plot3", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\bias_plot_om3.png", name(bias_plot3) replace width(2400) height(1600)		
	
********************************************************************************
* 2 - FMI plots
********************************************************************************

local i = 0
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	forvalues val = 1(1)3 {
		
		local i = `i' + 1
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1: probability of missing Y independent of Y given complete X and Z"
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
			local outmis_text = "Outcome Missingness Mechanism 2: probability of missing Y dependent on Y"
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
			local outmis_text = "Outcome Missingness Mechanism 3: probability of missing Y independent of Y given complete X"
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
			local gtext2 = " Auxiliary Missingness Mechanism 1"
		}
		if `val' == 2 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""							
			local gtext2 = " Auxiliary Missingness Mechanism 2"
		}
		if `val' == 3 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 = "`outmis_text'"								
			local gtext2 = " Auxiliary Missingness Mechanism 3"	
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
				
		local ytextpos0 = 1.13
		local ytextpos1 = 0.95
		local ytextpos2 = 0.95

		
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
				text(`ytextpos0' -310 "`gtext0'", place(e) size(medium))  ///												
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10  "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(FMI_mean`i', replace)
	}							
}

grc1leg FMI_mean1 FMI_mean2 FMI_mean3 /// 
		FMI_mean4 FMI_mean5 FMI_mean6 ///
		FMI_mean7 FMI_mean8 FMI_mean9 ///
		, ycommon graphregion(color(white)) name("FMI_plot", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\FMI_plot.png", name(FMI_plot) replace width(2400) height(1600)

* individual plots
	* outcome mechanism 1
grc1leg FMI_mean1 FMI_mean2 FMI_mean3 /// 
		, cols(3) ycommon graphregion(color(white) margin(0 0 0 35)) name("FMI_plot1", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\FMI_plot_om1.png", name(FMI_plot1) replace width(2400) height(1600)


	* outcome mechanism 2
grc1leg FMI_mean4 FMI_mean5 FMI_mean6 ///
		, cols(3) ycommon graphregion(color(white) margin(0 0 0 35)) name("FMI_plot2", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\FMI_plot_om2.png", name(FMI_plot2) replace width(2400) height(1600)


	* outcome mechanism 3
grc1leg FMI_mean7 FMI_mean8 FMI_mean9 ///
		, cols(3) ycommon graphregion(color(white) margin(0 0 0 35)) name("FMI_plot3", replace) ///
		note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
			 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
			 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\FMI_plot_om3.png", name(FMI_plot3) replace width(2400) height(1600)



********************************************************************************
* 3 - SE plots
********************************************************************************

local i = 0
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	forvalues val = 1(1)3 {
		
		local i = `i' + 1
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1: probability of missing Y independent of Y given complete X and Z"
			if `val' == 1 {
				local gtext1 = "A"
			}
			if `val' == 2 {
				local gtext1 = "B"
			}
			if `val' == 3 {
				local gtext1 = "C"
			}
			local ytextpos0 = .0463
			local ytextpos1 = .0425
			local ytextpos2 = .0425
			
		}
		if "`outmis'" == "Proxy_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 2: probability of missing Y dependent on Y"
			if `val' == 1 {
				local gtext1 = "D"
			}
			if `val' == 2 {
				local gtext1 = "E"
			}
			if `val' == 3 {
				local gtext1 = "F"
			} 
			local ytextpos0 = .0332
			local ytextpos1 = .031
			local ytextpos2 = .031
			
		}
		if "`outmis'" == "Efficiency_imputation" {
			local outmis_text = "Outcome Missingness Mechanism 3: probability of missing Y independent of Y given complete X"
			if `val' == 1 {
				local gtext1 = "G"
			}
			if `val' == 2 {
				local gtext1 = "H"
			}
			if `val' == 3 {
				local gtext1 = "I"
			}
			local ytextpos0 = .0725
			local ytextpos1 = .065
			local ytextpos2 = .065			
		}

		
		if `val' == 1 {
			local dir = "`outmis'/1_MCAR_auxiliary"
			local gtext0 = ""		
			local gtext2 = " Auxiliary Missingness Mechanism 1"
		}
		if `val' == 2 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""						
			local gtext2 = " Auxiliary Missingness Mechanism 2"
		}
		if `val' == 3 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 =  "`outmis_text'"							
			local gtext2 = "  Auxiliary Missingness Mechanism 3"		
		} 
		
		disp "`dir'"
		disp "`gtext0'"
		disp "`gtext1'"
		disp "`gtext2'"
		
		use "$Datadir/`dir'/Prepared_data/simsum_out_1", clear
		append using "$Datadir/`dir'/Prepared_data/simsum_out_2"
		append using "$Datadir/`dir'/Prepared_data/simsum_out_3"
		append using "$Datadir/`dir'/Prepared_data/simsum_out_4"
			
		gen lci_se = modelse - invnormal(0.975)*modelse_mcse
		gen uci_se = modelse + invnormal(0.975)*modelse_mcse

		sort auxid misaux varname	
		
		local cca1 = modelse[11]
		local cca2 = modelse[23]
		local cca3 = modelse[35]
		local cca4 = modelse[47]
				
		local ccaline = "yline(`cca1', lp(dash) lc(red))"
		local ccaline = "`ccaline' " + "yline(`cca2', lp(dash) lc(blue))" 
		local ccaline = "`ccaline' " + "yline(`cca3', lp(dash) lc(green))" 
		local ccaline = "`ccaline' " + "yline(`cca4', lp(dash) lc(orange))" 		
		
		gen obs = _n		

		twoway 	(line modelse misaux    		if imp == 1 & auxid == 1, col(red))   ///
				(rcap lci_se uci_se misaux 	if imp == 1 & auxid == 1, col(red))   ///
				(line modelse misaux    		if imp == 1 & auxid == 2, col(blue))  ///
				(rcap lci_se uci_se misaux 	if imp == 1 & auxid == 2, col(blue))  ///
				(line modelse misaux    		if imp == 1 & auxid == 3, col(green)) ///
				(rcap lci_se uci_se misaux 	if imp == 1 & auxid == 3, col(green)) ///
				(line modelse misaux    		if imp == 1 & auxid == 4, col(orange)) ///				
				(rcap lci_se uci_se misaux 	if imp == 1 & auxid == 4, col(orange)) ///
				, ///
				`ccaline' ///
				ytitle("Mean SE" "(MC 95% CI)", size(small)) ///
				ylab(,labsize(small)) ///
				xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
				xlab(,labsize(small)) ///
				legend(order(1 "Correlation of Z and Y = 0.1" ///
							 3 "Correlation of Z and Y = 0.3" ///
							 5 "Correlation of Z and Y = 0.5" ///
							 7 "Correlation of Z and Y = 0.7") ///
						position(6) ring(0) size(2) cols(2)) ///
				text(`ytextpos0' -310 "`gtext0'", place(e) size(medium))  ///												
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10  "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(SE`i', replace)
	}							
}

grc1leg SE1 SE2 SE3, cols(3) ycommon graphregion(color(white)) name("SE_plot1", replace) 
grc1leg SE4 SE5 SE6, cols(3) ycommon graphregion(color(white)) name("SE_plot2", replace) 
grc1leg SE7 SE8 SE9, cols(3) ycommon graphregion(color(white)) name("SE_plot3", replace) 

grc1leg	SE_plot1 SE_plot2 SE_plot3, ///
	rows(3) graphregion(color(white)) name("SE_plot", replace) ///
	note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
		 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
		 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\SE_plot.png", name(SE_plot) replace width(2400) height(1600)

* individual plots
	* outcome mechanism 1
grc1leg	SE_plot1, ///
	graphregion(color(white) margin(0 0 0 20)) name("SE_plotom1", replace) ///
	note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
		 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
		 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\SE_plot_om1.png", name(SE_plotom1) replace width(2400) height(1600)


	* outcome mechanism 2
grc1leg	SE_plot2, ///
	graphregion(color(white) margin(0 0 0 20)) name("SE_plotom2", replace) ///
	note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
		 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
		 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\SE_plot_om2.png", name(SE_plotom2) replace width(2400) height(1600)


	* outcome mechanism 3
grc1leg	SE_plot3, ///
	graphregion(color(white) margin(0 0 0 20)) name("SE_plotom3", replace) ///
	note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
		 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
		 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\SE_plot_om3.png", name(SE_plotom3) replace width(2400) height(1600)



********************************************************************************
* 4 - Patterns of missing data
********************************************************************************
local i = 0
foreach outmis in MAR_outcome Proxy_outcome Efficiency_imputation {
	forvalues val = 1(1)3 {
		
		local i = `i' + 1
		
		if "`outmis'" == "MAR_outcome" {
			local outmis_text = "Outcome Missingness Mechanism 1: probability of missing Y independent of Y given complete X and Z"
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
			local outmis_text = "Outcome Missingness Mechanism 2: probability of missing Y dependent on Y"
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
			local outmis_text = "Outcome Missingness Mechanism 3: probability of missing Y independent of Y given complete X"
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
			local gtext2 = " Auxiliary Missingness Mechanism 1"
		}
		if `val' == 2 {
			local dir = "`outmis'/3_MNAR_auxiliary"
			local gtext0 = ""						
			local gtext2 = " Auxiliary Missingness Mechanism 2"
		}
		if `val' == 3 {
			local dir = "`outmis'/2_MAR_auxiliary"
			local gtext0 =  "`outmis_text'"							
			local gtext2 = "  Auxiliary Missingness Mechanism 3"		
		} 
		
		disp "`dir'"
		disp "`gtext0'"
		disp "`gtext1'"
		disp "`gtext2'"
		
		
		use "$Datadir/`dir'/Prepared_data/prop_yzmiss_sumstats_auxid1", clear
		append using "$Datadir/`dir'/Prepared_data/prop_yzmiss_sumstats_auxid2"
		append using "$Datadir/`dir'/Prepared_data/prop_yzmiss_sumstats_auxid3"
		append using "$Datadir/`dir'/Prepared_data/prop_yzmiss_sumstats_auxid4"
		
		gen yandz = mean 
		gen yonly = 50 - mean
		gen zonly = misaux - mean
			
		gen lci_yandz = yandz - invnormal(0.975)*se
		gen uci_yandz = yandz + invnormal(0.975)*se
		gen lci_yonly = yonly - invnormal(0.975)*se
		gen uci_yonly = yonly + invnormal(0.975)*se
		gen lci_zonly = zonly - invnormal(0.975)*se
		gen uci_zonly = zonly + invnormal(0.975)*se

		sort auxid misaux varname	
		
		insobs 1 // empty row for legend
		
		local ytextpos0 = 75
		local ytextpos1 = 60
		local ytextpos2 = 60
		
		
		gen obs = _n		

		twoway 	///
				/// for legend 
				(line yandz misaux    				if auxid == ., col(red))   ///
				(line yandz misaux    				if auxid == ., col(blue))   ///
				(line yandz misaux    				if auxid == ., col(green))   ///	
				(line yandz misaux    				if auxid == ., col(orange))   ///								
				(line yandz misaux    				if auxid == ., col(black))   ///
				(line yonly misaux    				if auxid == ., col(black) lpattern(dash))   ///
				(line zonly misaux    				if auxid == ., col(black) lpattern(dot))   ///
				/// y and z
				(line yandz misaux    				if auxid == 1, col(red))   ///
				(line yandz misaux    				if auxid == 2, col(blue))  ///
				(line yandz misaux    				if auxid == 3, col(green)) ///
				(line yandz misaux    				if auxid == 4, col(orange)) ///				
				/// y only
				(line yonly misaux    				if auxid == 1, col(red) lpattern(dash))   ///
				(line yonly misaux    				if auxid == 2, col(blue) lpattern(dash))  ///
				(line yonly misaux    				if auxid == 3, col(green) lpattern(dash)) ///
				(line yonly misaux    				if auxid == 4, col(orange) lpattern(dash)) ///				
				/// z only
				(line zonly misaux    				if auxid == 1, col(red) lpattern(dot))   ///
				(line zonly misaux    				if auxid == 2, col(blue) lpattern(dot))  ///
				(line zonly misaux    				if auxid == 3, col(green) lpattern(dot)) ///
				(line zonly misaux    				if auxid == 4, col(orange) lpattern(dot)) ///				
				, ///
				`ccaline' ///
				ytitle("% with missing" "data pattern", size(small)) ///
				ylab(,labsize(small)) ///
				xtitle("Proportion of missing data" "in auxiliary variable, Z", size(small)) ///
				xlab(,labsize(small)) ///
				legend(order(1 "Correlation of Z and Y = 0.1" ///
							 2 "Correlation of Z and Y = 0.3" ///
							 3 "Correlation of Z and Y = 0.5" ///
							 4 "Correlation of Z and Y = 0.7" ///							 
							 5 "Y and Z missing" ///			
							 6 "Y only missing" ///	
							 7 "Z only missing" ///							 
							 ) ///
						position(6) ring(0) size(2) rows(2)) ///						
				text(`ytextpos0' -310 "`gtext0'", place(e) size(medium))  ///												
				text(`ytextpos1' 0   "`gtext1'", place(e) size(medium))  ///	
				text(`ytextpos2' 10  "`gtext2'", place(e) size(small))  ///						 
				graphregion(color(white)) ///
				name(pattern`i', replace)
	}							
}



grc1leg	pattern1 pattern2 pattern3 ///
	pattern4 pattern5 pattern6 ///
	pattern7 pattern8 pattern9 ///
	, ///
	rows(3) graphregion(color(white)) name("pattern_plot", replace) ///
	note("Auxiliary missingness mechanism 1: probability of missing Z not dependent on any other variables" ///
		 "Auxiliary missingness mechanism 2: probability of missing Z dependent on Y given incomplete Z  " ///
		 "Auxiliary missingness mechanism 3: probability of missing Z independent of Y  given complete W" , size(vsmall))
graph export "$Graphdir\pattern_plot.png", name(pattern_plot) replace width(2400) height(1600)



********************************************************************************
log close


