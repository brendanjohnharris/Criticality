# Feature Evaluation- Main Analysis

A record of the commands used to generate a filled `hctsa.mat` file from the result of `testTimeseries.mat`. Follow quoted steps and code blocks to reproduce the calculations exactly (for a general description see `./README.md`) where `./` is the directory of this repository and `~/` is the home directory of the cluster. Start an ssh connection to the cluster, then:

```
module load Matlab2017b
module load pbspro
```

> Transfer the `/results/` folder produced by `testTimeseries.m` to the cluster (e.g. with FileZilla) at `~/testTimeseries/results/`

> [Clone _hctsa_](https://hctsa-users.gitbook.io/hctsa-manual/) version 0.98 into `~/hctsa_v098` and [compile mex/TISEAN files](https://hctsa-users.gitbook.io/hctsa-manual/setup/compiling_binaries) (c.f. `./docs/USydPhysicsHPC.md`).

> Modify the `TS_compute.m` and `SQL_add.m` files of _hctsa_ as described in `./README.md`

> Transfer `./PBS/PBSpro/PBS_array_TS_compute.sh` to `~/testTimeseries/results/PBS_array_TS_compute.sh` (if the parameters in `testTimeseries.m` were modified, this will need to be updated to match) and navigate to `~/testTimeseries/results/`.

```
dos2unix -n PBS_array_TS_compute.sh PBS_array_TS_compute.sh
```
(In case the file has windows-style line endings, particularly important for PBSpro)

```
qsub PBS_array_TS_compute.sh
```

> The jobs should then be submitted; wait until complete

> Transfer `~/testTimeseries/results/` to `./test/<system>/results/`

```
hctsaAllSubfolders(0, [], [], [], 0, 'HCTSA.mat')
```
(To catch any features the cluster may have missed)
