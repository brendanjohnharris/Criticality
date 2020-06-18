# _hctsa_ on PBS
Steps to perform _hctsa_ calculations on a single `HCTSA.mat` file of time series data with the University of Sydney School of Physics HPC cluster (Torque; perhaps PBSpro).

## Installing _hctsa_
- Clone the desired _hctsa_ version using git into `~/hctsa`
- Start an interactive job `qsub -I`
- `module load Matlab2017b`
- Use ‘matlab -nodisplay’ to open matlab
- Navigate to `~/hctsa/`, run `install` and [compile mex or tisean files](https://hctsa-users.gitbook.io/hctsa-manual/setup/compiling_binaries) if necessary
- Quit the interactive job

## Scripts
Shell, PBS and Matlab scripts are used to subset time series in a `HCTSA.mat` file, perform distributed _hctsa_ feature calculation and then recombine the subsets. Add the four files (`HCTSA_run.sh`, `HCTSA_Runscript.sh`, `PBS_combineBatchFiles.sh`, `pbs_runscript.sh`) found [here](./PBS/Distributed_hctsa/modified.md) (slightly modified from [distributed_hctsa](https://github.com/benfulcher/distributed_hctsa)) to the same directory on the cluster as `HCTSA.mat`
Enter `module load Matlab2017b` to the terminal before running any scripts.


## `distributed_hctsa` Parameters
- Set the wall time (time limit) in `PBS_runscript.sh` (e.g. using `vi PBS_runscript.sh`, then `i` to edit and `shift+zz` to save and close)
- Set the email in `PBS_runscript.sh`
- Set the `tsmin` (usually 1) and ‘tsmax’ (usually the number of time series in `HCTSA.mat`) to compute in `HCTSA_run.sh`
- Set `NumJobs`, the number of time series to calculate per job/core/process, in HCTSA_run.sh (This determines the approximate number of cores/processes/jobs it will use on the cluster)

## Initiating Jobs
- Set the permissions on `HCTSA_run.sh` using `chmod u+x HCTSA_run.sh`
- Run `HCTSA_run.sh` using `./HCTSA_run.sh` (This will distribute the timeseries and start all of the jobs)
- Wait.
- Check the progress of a job by navigating to one of the subset folders, using `tail matlab_output.txt` (or `tail -f matlab_output.txt` to update the text); often this will show errors that need to be fixed.
- Wait until all jobs are complete; their markers will disappear from `qload` (you can check how long jobs have been running for with `qstat`).


## Combining Timeseries
- Once calculations are complete, start an interactive job (`qsub -I`) and run matlab (`matlab -nodisplay`)
- Navigate to `~/hctsa/` and run `startup`
- Navigate to the folder containing the `hctsa.mat` file
- Run `combine_batch_files` and wait (don’t close the terminal tab containing the running job)
- When that is complete, the hctsa.mat file should be full and can be copied from the cluster.
