********************************************************************************
* Author: 		Paul Madley-Dowd
* Date:			06 April 2023	   
* Description: 	Global file to set up directories for applied example
********************************************************************************
global Projectdir 	"YOUR_PATH_NAME"

global Dodir		"$Projectdir\dofiles"
global Rawdatdir	"RAWDATA_PATH" // location of Raw data on UKSeRP for linked educational data
global Datadir		"$Projectdir\datafiles"
global Graphdir		"$Projectdir\graphfiles"
global Logdir		"$Projectdir\logfiles"

cd "$Projectdir"
