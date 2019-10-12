#!/bin/bash
# Set name of job
#PBS -N SequentialPerformance
#PBS -o matlab_output
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l mem=4GB
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=10:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
#PBS -t 1-100

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
hostname
matlab -nodisplay -singleCompThread -r "home = pwd; cd('~/Criticality'), add_all_subfolders(), cd(home), Analysis2_LinearSVM($PBS_ARRAYID); exit"
exit

