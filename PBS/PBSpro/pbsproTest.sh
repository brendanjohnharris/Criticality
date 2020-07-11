#!/bin/tcsh
#PBS -N test
#PBS -o output.txt
#PBS -j oe
#PBS -l select=1:ncpus=1:mem=2GB
#PBS -l walltime=00:10:00
#PBS -m ea
#PBS -M bhar9988@uni.sydney.edu.au
#PBS -V
module load Matlab2017b
cd "$PBS_O_WORKDIR"
touch "$PBS_JOBID"_log.txt
echo "Exiting..."
echo "Exiting..." >& "$PBS_JOBID"_log.txt
exit

