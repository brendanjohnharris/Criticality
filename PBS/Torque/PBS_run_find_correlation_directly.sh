#!/bin/bash
# Set name of job
#PBS -N xxNamexx
#PBS -o matlab_output.txt
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l mem=16GB
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=10:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
hostname
matlab -nodisplay -singleCompThread -r "home_dir = pwd; cd('~/hctsa'), startup, cd('~/Criticality'), add_all_subfolders, cd(home_dir), find_correlation_directly(xxDirectionsxx, 'inp_ops.txt', 'input_file.mat', 0, 'xxNamexx.mat', 'xxCorrelationTypexx', xxCPRangexx, xxSubEtarangexx); exit"
exit
