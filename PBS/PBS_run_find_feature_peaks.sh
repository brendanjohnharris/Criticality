#!/bin/bash
# Set name of job
#PBS -N find_feature_peaks
#PBS -o matlab_output.txt
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=16
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=05:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
hostname
export TZ='Australia/Sydney'
matlab -nodisplay -r "home_dir = pwd; cd('~/hctsa'), startup, cd('~/Criticality'), add_all_subfolders, cd(home_dir), parpool(16), find_feature_peaks(1, 'Noise_shift_inp_ops.txt', 'parameter_file.mat', 1, 1000, [0, 20], 'results.mat'); delete(gcp), exit"
exit
