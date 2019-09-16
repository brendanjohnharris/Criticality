#!/bin/bash
# Set name of job
#PBS -N combineBatchFiles
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
matlab -nodisplay -singleCompThread -r "cd('~/hctsa'); startup; cd('~/xxFolderNamexx'); combineBatchFiles; exit"
exit
