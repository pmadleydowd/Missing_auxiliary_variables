#!/bin/bash   
# Working directory, create folder for job sumissions
export WORKDIR=/user/home/pm0233/Simulations/Auxiliary_missing/MAR_outcome/4_MNARv2_auxiliary
#Change into working directory 
cd $WORKDIR

# sim loop
declare -i i=1
declare -i ei=4
while [ $i -le $ei ] ; do
	cd $WORKDIR
	cp template.script logfiles/MI.submission."$i".script
	cd $WORKDIR/logfiles
	echo "stata do sim_aux_call.do "$i" " >> MI.submission."$i".script
	cd $WORKDIR/logfiles
	sbatch MI.submission."$i".script
	sleep 4
	i=$i+1
done