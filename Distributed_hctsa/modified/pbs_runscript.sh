#!/bin/bash
# Set name of job
#PBS -N CD_xxNameOfJobxx
#PBS -o matlab_output.txt
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=1
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=30:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
# Show the host on which the job ran
hostname
# Launch the Matlab job
matlab -nodisplay -singleCompThread -r "disp(pwd); HCTSA_Runscript; exit"
exit
