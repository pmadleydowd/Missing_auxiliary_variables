********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		19 May 2022
* Description:	Create the environment for simulation of missing auxiliary data 
********************************************************************************
clear 

global Projectdir "YOURPATHNAME"

global Dodir 		"$Projectdir\dofiles"
global Logdir 		"$Projectdir\logfiles"
global Datadir 		"$Projectdir\datafiles"
global Graphdir 	"$Projectdir\graphfiles"

global Sim1 "1_MCAR_auxiliary"
global Sim2 "2_MAR_auxiliary"
global Sim3 "3_MNAR_auxiliary"
global Sim4 "4_MNARv2_auxiliary"

cd "$Projectdir"
