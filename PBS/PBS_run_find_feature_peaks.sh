#!/bin/bash
# Set name of job
#PBS -N find_feature_peaks
#PBS -o matlab_output.txt
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=2:ppn=16
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=02:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
hostname
export TZ='Australia/Sydney'
matlab -nodisplay -r "parpool(32), delete(gcp), exit"
exit
