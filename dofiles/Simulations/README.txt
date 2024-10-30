Paul Madley-Dowd - University of Bristol - 12 May 2022

The simulations were run on BluePebble (https://www.bristol.ac.uk/acrc/high-performance-computing/) as separate scripts for each design factor. 
Scripts to do this are found in the folder "Submission to HPC - BluePebble". 

Alternatively the masterfile - MASTER.do - can be used to run all design factors using a single script. Note that this will take a long time and any sensible individual will not do this. The Master file is provided to give an idea of how you could run the simulation study bit by bit.  

In each folder is a .do file titled "sim_aux_call.do". These are different within each folder and were titled the same name in order to be run as part of a loop where the folder names were changed but the script name was not. I would not advise doing this in any future projects and apologise for any confusion it causes. 

Some definitions that differ from the manuscript: 
- MAR_outcome - corresponds to missing outcome mechanism 1 - Missingness in Y caused by X and Z
- Proxy_outcome - corresponds to missing outcome mechanism 2 - Missingness in Y caused by Y
- Efficiency_imputation - corresponds to missing outcome mechanism 3 - Missingness in Y caused by X

- 1_MCAR_auxiliary - corresponds to missing auxiliary mechanism 1 - Missingness in Z not caused by any other variable
- 2_MAR_auxiliary - corresponds to missing auxiliary mechanism 3 - Missingness in Z caused by W  
- 3_MNAR_auxiliary - corresponds to missing auxiliary mechanism 2 - Missingness in Z caused by Z
- 4_MNARv2_auxiliary - corresponds to the sensitivity analysis of missing auxiliary mechanism 2 with W excluded from the imputation model
(note on history of the manuscript: mechanisms 2 and 3 were swapped round during the review process as we felt it led to a an easier narrative to follow)

- auxid takes values 1-4 which are transformed to the correlation values 0.1, 0.3, 0.5 and 0.7 between Z and Y. 

 There are an excessive number of folders in this simulation study. Find a better way to organise dofiles and datafiles. 
