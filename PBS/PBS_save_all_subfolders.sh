#!/bin/bash
# Set name of job
#PBS -N save_data
#PBS -o save_data_output
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l mem=180GB
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=100:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
hostname
matlab -nodisplay -singleCompThread -r "home_dir = pwd; cd('~/hctsa'), startup, cd('~/Criticality'), add_all_subfolders, cd(home_dir), save_data('./time_series_data.mat', '', 'time_series_generator', 'HCTSA.mat', 'inputs_out.mat', 0, 0, 1); exit"
exit
