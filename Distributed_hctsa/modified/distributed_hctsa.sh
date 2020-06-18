#!/bin/bash
# Want to automate the execution of files in distributed_hctsa (the PBS versions)
# Should only need to edit:
#   - The number of jobs you want to start (-n, NumJobs)
#   - The email (-e, UserEmail)
#   - The memory to request for each job in PBS format (-m, MemPerJob)
#   - The time to request for each job in PBS format (-t, TimePerJob)
#   - The name of the hctsa file (-f, FileName)
#   - The number of timeseries in the dataset (-l, tsmax). Will be automatically calculated if not provided.
# -------------------------------------------------------------------------------
# |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
# -------------------------------------------------------------------------------
# This will be easy, but not neat. Make some variables containing neccessary scripts:
PeekHCTSA="#\!/bin/bash
#PBS -N PeekHCTSA
#PBS -o dhctsa_output.txt
#PBS -j oe
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l walltime=01:00:00
#PBS -m ea
#PBS -M xxUserEmailxx
#PBS -V
cd ""$PBS_O_WORKDIR""
hostname
matlab -nodisplay -singleCompThread -r 'disp(pwd); load(''../xxFileNamexx''); fid = fopen(''dhctsa_messenger.txt'',''w''); fprintf(fid, num2str(size(timeSeriesData, 1))); exit'
exit"
echo "23"
pbs_runscript="#\!/bin/bash
#PBS -N xxNameOfJobxx
#PBS -o dhctsa_output.txt
#PBS -j oe
#PBS -q physics
#PBS -l nodes=1:ppn=1
#PBS -l walltime=xxTimePerJobxx
#PBS -l mem=xxMemPerJobxx
#PBS -m ea
#PBS -M xxUserEmailxx
#PBS -V
cd ""$PBS_O_WORKDIR""
hostname
matlab -nodisplay -singleCompThread -r 'disp(pwd); HCTSA_Runscript; exit'
exit"
echo "43"
HCTSA_runscript="myStartingDir = pwd;
cd('~/hctsa/')
startup
cd(myStartingDir);
tsid_min = xxTSIDMINxx;
tsid_max = xxTSIDMAXxx;
nSeriesPerGo = 20;
useParralel = false;
opRange = [];
customFile = 'HCTSA_subset.mat';
TS_subset('../../xxFileNamexx.mat',tsid_min:tsid_max,[],true,customFile);
fprintf(1,'About to calculate time series (ts_ids %u--%u), %u at a time\n',tsid_min,tsid_max,nSeriesPerGo);
currentId = tsid_min;
while currentId <= tsid_max
    tsRange = (currentId:currentId + nSeriesPerGo);
    tsRange(2) = min([tsRange(2),tsid_max]);
    TS_compute(useParralel,tsRange,opRange,'bad',customFile, 0);
    currentId = currentId + nSeriesPerGo + 1;
end
fprintf(1,'Finished calculating ts_ids %u--%u\!\n',tsid_min,tsid_max);"
#-------------------------------------------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#-------------------------------------------------------------------------------

# Set the default arguments
NumJobs=10
UserEmail='bhar9988@uni.sydney.edu.au'
MemPerJob='2GB'
TimePerJob='01:00:00'
FileName='HCTSA.mat'
tsmax=0 # Will fill later, even if not supplied

echo "76"

# Get the supplied arguments
while getopts 'n:e:m:t:f:l:' opt
do
  case $opt in
    n) NumJobs=$OPTARG ;;
    e) UserEmail=$OPTARG ;;
    m) MemPerJob=$OPTARG ;;
    t) TimePerJob=$OPTARG ;;
    f) FileName=$OPTARG ;;
    l) tsmax=$OPTARG ;;
    \?) echo "Usage: distributed_hctsa [-n] [-e] [-m] [-t] [-f]";;
  esac
done

echo "92"

# Make a subdirectory to work in
mkdir dhctsa_workdir
cd dhctsa_workdir

# Will use a temporary file to contain the PBS scripts, and a temporary output file to pass information:
# Then peek at the hctsa file to see how many timeseries we have (only do this if not given)
if [ ${tsmax} -lt "1" ]
then
    echo "${PeekHCTSA}" | sed "s/xxUserEmailxx/${UserEmail}/g; s/xxFileNamexx/${FileName}/g" > PBS_tempscript.sh

    qsub ./PBS_tempscript.sh

    tsmax=$(tail -n 1 dhctsa_messenger.txt)
fi

echo "109"

echo "Running hctsa with:
                    NumJobs=${NumJobs}
                    UserEmail=${UserEmail}
                    MemPerJob=${MemPerJob}
                    TimePerJob=${TimePerJob}
                    FileName=${FileName}
                    tsmax=${tsmax}"

# Replace what need be replaced
pbs_runscript=$(echo "${pbs_runscript}" | sed "s/xxUserEmailxx/${UserEmail}/g; s/xxFileNamexx/${FileName}/g; s/xxTimePerJobxx/${TimePerJob}/g")
HCTSA_runscript=$(echo "${HCTSA_runscript}" | sed "s/xxFileNamexx/${FileName}/g")

echo "123"

# NumJobs requested might not fit the number of timeseries exactly, so:
NumPerJob=(${tsmax}/${NumJobs}) # Rounds down


# Then hand to HCTSA_run.sh script, which recalculates the number of jobs.
#-------------------------------------------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#-------------------------------------------------------------------------------
tsmin=1
NumJobs=$((($tsmax-$tsmin)/$NumPerJob+1))

# Start by writing the directory structure
# Stored in {DirNames[]} array
TheTS=$tsmin
for ((i=0; i<$NumJobs; i++)); do
    HereMin=$TheTS
    if [ $i -eq $(($NumJobs-1)) -a $(($NumJobs*$NumPerJob)) -gt $tsmax ]; then
        HereMax=$tsmax
    else
        HereMax=$(($TheTS+$NumPerJob-1))
    fi
    DirNames[i]="tsids_$HereMin-$HereMax" # Store the directory names
    JobNames[i]="tsids-$HereMin-$HereMax" # Make names for PBS jobs
    MinIDS[i]=$HereMin # Also store the minimum ts_id
    MaxIDS[i]=$HereMax # Also store the maximum ts_id
    mkdir ${DirNames[i]}
    TheTS=$(($TheTS+$NumPerJob))
done

# Next we want to go into each directory and create
# a PBS script with a suitable job name
# The file pbs_runscript.sh and HCTSA.mat must be in the base directory
for ((i=0; i<$NumJobs; i++)); do
    # Define the script location:
    ScriptLocation="${DirNames[i]}/pbs_runscript.sh"
    # echo $ScriptLocation
    # Use sed to replace the wildcard NameOfJob with the directory name
    echo "${pbs_runscript}" | sed "s/xxNameOfJobxx/${JobNames[i]}/g" > $ScriptLocation
    #sed "s/xxNameOfJobxx/${JobNames[i]}/g" pbs_runscript.sh > $ScriptLocation

    # Copy the HCTSA.mat file into the subdirectory
	# MatFileLocation="${DirNames[i]}/HCTSA.mat"
    # sed "s/xxNameOfJobxx/${JobNames[i]}/g" HCTSA.mat > $MatFileLocation
done

# Ok, so now we have all the PBS shell scripts for the jobs we want to
# run in their respective directories.
# Now we need to copy Matlab runscripts with the right range of ts_ids in them
# (into each directory)
for ((i=0; i<$NumJobs; i++)); do
    # Define the script location:
    RunScriptLocation="${DirNames[i]}/HCTSA_Runscript.m"
    echo "${HCTSA_runscript}" | sed -e "s/xxTSIDMINxx/${MinIDS[i]}/g" -e "s/xxTSIDMAXxx/${MaxIDS[i]}/g" > $RunScriptLocation
done

# Ok, so now we want to go through and actually submit all the PBS scripts as jobs
for ((i=0; i<$NumJobs; i++)); do
    cd ${DirNames[i]}
    JobNumber=$(qsub pbs_runscript.sh) # Take note of the job number
    echo "Job submitted for tsids between ${MinIDS[i]} and ${MaxIDS[i]} as $JobNumber"
    # Make a file for the job number
    echo ${JobNumber} > "${JobNumber%%.*}.txt"
    cd ../
done
#-------------------------------------------------------------------------------
#|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
#-------------------------------------------------------------------------------
echo "197"
