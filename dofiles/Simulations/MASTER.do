********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		12 May 2022
* Description:	Master file for simulation of missing auxiliary variables 
********************************************************************************
* Contents 
********************************************************************************
* 1 - Set up environment
* 2 - Run simulations 
*  2.1 - MAR outcome - outcome mechanism 1
*  2.2 - Proxy outcome - outcome mechanism 2
*  2.3 - Efficiency imputation - outcome mechanism 3
*  2.4 - Sensitivity analyses
* 3 - Collate results across simulations 
* 4 - Create figures of results 

********************************************************************************
* 1 - Set up environment
********************************************************************************
do "YOUR_PATH_NAME\dofiles\global_sim_MCAR_aux.do" // set all directories 
do "$Dodir\library.do" // loads all neccesary packages for the programs to work 

********************************************************************************
* 2 - Run simulations 
********************************************************************************
* NOTE FOR EACH SCRIPT IN THE SECTION 
* The program was submitted as four separate scripts (one script for each strength of association) to BluePebble, one of the University of Bristol's high performance computing systems using the files found in "$Dodir\Submission to HPC - BluePebble" - https://www.bristol.ac.uk/acrc/high-performance-computing/
* The dofiles below submit all iterations of each simulation as a single file

* 2.1 - MAR outcome - outcome mechanism 1
********************************************
do "$Dodir\Simulations\MAR_outcome\Call_all_sims.do" 	

* 2.2 - Proxy outcome - outcome mechanism 2
********************************************
do "$Dodir\Simulations\Proxy_outcome\Call_all_sims.do" 

* 2.3 - Efficiency imputation - outcome mechanism 3
******************************************************
do "$Dodir\Simulations\Proxy_outcome\Call_all_sims.do" 

* 2.4 - Sensitivity analyses 
*******************************
do "$Dodir\Simulations\Sensitivity\Call_all_sims.do" 

********************************************************************************
* 3 - Collate results across simulations
********************************************************************************
do "$Dodir\Combine_results\collate_results.do" // collates results across the .dta output created from each simulation
do "$Dodir\Combine_results\collate_sensitivity_results.do" // collates results across sensitvity simulations

********************************************************************************
* 4 - Create figures of results
********************************************************************************
do "$Dodir\Combine_results\plot_results_combined.do" // plots the results of the simulation study
do "$Dodir\Combine_results\plot_sensitivity_results_combined.do" // plots the results of the sensitivity analyses