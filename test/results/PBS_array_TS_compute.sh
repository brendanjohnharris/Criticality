#!/bin/csh
#PBS -N timeseries
#PBS -o PBS_stdout
#PBS -j oe
#PBS -l select=1:ncpus=1:mem=4GB
#PBS -l walltime=50:00:00
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
#PBS -J 58-100
cd "$PBS_O_WORKDIR"
cd "time_series_data-$PBS_ARRAY_INDEX"
module load Matlab2017b
touch "TS_log-$PBS_ARRAY_INDEX.txt"
matlab -nodisplay -r "home_dir = pwd; cd('~/hctsa_v098'), startup, cd(home_dir), TS_compute(0, [], [], [], [], 0); exit" >& "TS_log-$PBS_ARRAY_INDEX.txt"
exit
