% Remember home directory
myStartingDir = pwd;

% Load paths for the HCTSA package:
cd('~/hctsa/')
startup

% Move Matlab back to the working PBS directory
cd(myStartingDir);

% ------------------------------------------------------------------------------
%% SET RANGE OF TS_IDs TO COMPUTE:
% ------------------------------------------------------------------------------
tsid_min = xxTSIDMINxx; % Calculate from this ts_id...
tsid_max = xxTSIDMAXxx; % To this ts_id

% ------------------------------------------------------------------------------
%% Default parameters for computation:
% ------------------------------------------------------------------------------
nSeriesPerGo = 20;
useParralel = false;
opRange = [];
customFile = 'HCTSA_subset.mat';

%-------------------------------------------------------------------------------
% Make the required subset from the master HCTSA file:
%-------------------------------------------------------------------------------
TS_subset('../HCTSA.mat',tsid_min:tsid_max,[],true,customFile);

% ------------------------------------------------------------------------------
%% Start calculating:
% ------------------------------------------------------------------------------

% Provide a quick message:
fprintf(1,'About to calculate time series (ts_ids %u--%u), %u at a time\n', ...
                tsid_min,tsid_max,nSeriesPerGo);

% Calculate nSeriesPerGo time series at a time (so results are regularly saved)
currentId = tsid_min;
while currentId <= tsid_max
    tsRange = (currentId:currentId + nSeriesPerGo);
    tsRange(2) = min([tsRange(2),tsid_max]);
    TS_compute(useParralel,tsRange,opRange,'bad',customFile, 0);
    currentId = currentId + nSeriesPerGo + 1;
end

fprintf(1,'Finished calculating ts_ids %u--%u!\n',tsid_min,tsid_max);
