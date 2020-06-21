#!/bin/csh
#PBS -N timeseries
#PBS -o PBS_stdout
#PBS -j oe
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l walltime=50:00:00
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
#PBS -J 1-100
cd "$PBS_O_WORKDIR"
cd "time_series_data-$PBS_ARRAY_INDEX"
module load Matlab2017b
touch "TS_log-$PBS_ARRAY_INDEX.txt"
matlab -nodisplay -r "home_dir = pwd; cd('~/hctsa_v098'), startup, cd(home_dir), try delete('./HCTSA.mat'); end, TS_init('timeseries.mat', [], [], 0); TS_compute(0, [], [], [], [], 0); exit" >& "TS_log-$PBS_ARRAY_INDEX.txt"
exit
