#!/bin/bash

#################################################
#only needed for qsub'd runs
#set time 
#!/bin/bash

#SBATCH --job-name=auxsim3
#SBATCH --partition=compute
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=4-00:00
#SBATCH --mem=0

#################################################

#Define working directory 
export WORK_DIR=/user/home/pm0233/Simulations/Auxiliary_missing/MAR_outcome/4_MNARv2_auxiliary
#Change into working directory 
cd $WORK_DIR

#store the date
now=$(date +"%Y%m%d")

#################################################


module load apps/stata/17
stata do "sim_aux_call3.do"

	



