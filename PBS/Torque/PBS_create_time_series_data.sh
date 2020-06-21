#!/bin/bash
# Set name of job
#PBS -N time_series_data
#PBS -o matlab_output
#PBS -j oe
# Specify a queue:
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l mem=4GB
# Set your minimum acceptable walltime, format: day-hours:minutes:seconds
#PBS -l walltime=100:00:00
# Email user if job ends or aborts
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
#PBS -t 1-100
# -t for torque, -J for PBSpro

# your commands/programs start here, for example:
cd "$PBS_O_WORKDIR"
cd time_series_data-$PBS_ARRAYID
hostname
matlab -nodisplay -singleCompThread -r "home_dir = pwd; cd('~/hctsa'), startup, cd('~/Criticality'), add_all_subfolders, cd(home_dir), TS_init('timeseries.mat', 'INP_mops.txt', 'INP_ops.txt', 0); TS_compute(0, [], [], [], [], 1); exit"
exit
