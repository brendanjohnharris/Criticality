function savedata = light_TS_init(INP_ts,INP_mops,INP_ops,beVocal) % M
% LIGHT_TS_init A slightly modified version of TS_init, for use
% with large datasets that won't be written to a file. 
% Changes from hctsa 0.98:
%     - 'INP_ts' should be a structure containing fields corresponding 
%       to those required by a hctsa initialisation file
%     - An output argument, 'savedata', which contains fields corresponding 
%       to the variables in a traditional hctsa file
%     - SQL_add replaced by morph_to_hctsa
%     - 'outputFile' input argument removed
%     - Unnecessary lines commented out
% 
% Lines that have been modified are marked with an 'M'
%      
% :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
% TS_init       Takes in time series, master operation, and operation input
% files and produces a formatted HCTSA .mat file
%
% This function is used instead to run hctsa analysis without a linked mySQL database.
%
%---EXAMPLE USAGE:
% Initiate an HCTSA.mat file on a custom time-series dataset using default
% feature library, using a formatted input file, 'my_TS_INP_file.mat'
% >> TS_init('my_TS_INP_file.mat');
%
%---INPUTS:
% INP_ts: A time-series input file
% INP_mops: A master operations input file
% INP_ops: An operations input file
% beVocal: Whether to display details of the progress of the script to screen.
%           a 3-vector, specifying for 1. time series, 2. master operations,
%           and 3. operations.
% outputFile: Specify an output filename
%
%---OUTPUTS:
% Writes output into HCTSA.mat (or specified custom filename)

% ------------------------------------------------------------------------------
% Copyright (C) 2018, Ben D. Fulcher <ben.d.fulcher@gmail.com>,
% <http://www.benfulcher.com>
%
% If you use this code for your research, please cite the following two papers:
%
% (1) B.D. Fulcher and N.S. Jones, "hctsa: A Computational Framework for Automated
% Time-Series Phenotyping Using Massive Feature Extraction, Cell Systems 5: 527 (2017).
% DOI: 10.1016/j.cels.2017.10.001
%
% (2) B.D. Fulcher, M.A. Little, N.S. Jones, "Highly comparative time-series
% analysis: the empirical structure of time series and their methods",
% J. Roy. Soc. Interface 10(83) 20130048 (2013).
% DOI: 10.1098/rsif.2013.0048
%
% This work is licensed under the Creative Commons
% Attribution-NonCommercial-ShareAlike 4.0 International License. To view a copy of
% this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/ or send
% a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View,
% California, 94041, USA.
% ------------------------------------------------------------------------------

% ------------------------------------------------------------------------------
% Check Inputs:
% ------------------------------------------------------------------------------
if nargin < 1 || isempty(INP_ts)
    error('Please supply a formatted time-series structure.'); % M
end
if nargin < 2 || isempty(INP_mops)
    INP_mops = 'INP_mops.txt';
end
if nargin < 3 || isempty(INP_ops)
    INP_ops = 'INP_ops.txt';
end
if nargin < 4
    if nargin < 2
        beVocal = [true,false,false]; % by default helps you just for the time series input file you provided
    elseif nargin < 3
        beVocal = [true,true,false]; % by help you through the master operations too
    else
        beVocal = [true,true,true]; % Provided all custom input files--walks you through all of them
    end
end
if length(beVocal)==1
    beVocal = true(3,1)*beVocal;
end
%if nargin < 5 % M
%    outputFile = 'HCTSA.mat'; % M
%end % M

% ------------------------------------------------------------------------------
% First check if you're about to overwrite an existing file
% ------------------------------------------------------------------------------
%if exist(['./',outputFile],'file') % M
%    reply = input(sprintf(['Warning: %s already exists -- if you continue, this ' ... % M
%        'file will be overwritten.\n[press ''y'' to continue]'],outputFile),'s'); % M
%    if ~strcmp(reply,'y') % M
%        return % M
%    end % M
%end % M

%-------------------------------------------------------------------------------
% First check that all input files provided exist:
%-------------------------------------------------------------------------------
checkFiles = {INP_mops,INP_ops}; % M
for i = 1:2
    if ~exist(checkFiles{i},'file')
        error('Unknown file: ''%s''',checkFiles{i});
    end
end

% ------------------------------------------------------------------------------
% Get time series, operations, master operations into structure arrays
% ------------------------------------------------------------------------------
%TimeSeries = SQL_add('ts',INP_ts,false,beVocal(1)); % M
TimeSeries = morph_to_hctsa(INP_ts); % M
numTS = height(TimeSeries);
if numTS==0
    return; % The user did not approve of the set of inputs
end

MasterOperations = SQL_add('mops',INP_mops,false,beVocal(2));
numMops = height(MasterOperations);
if numMops==0
    return; % The user did not approve of the set of inputs
end

Operations = SQL_add('ops',INP_ops,false,beVocal(3));
numOps = height(Operations);
if numOps==0
    return; % The user did not approve of the set of inputs
end

%-------------------------------------------------------------------------------
% Link operations to their masters using label matching
% and update the structure arrays using the TS_LinkOperationsWithMasters function
%-------------------------------------------------------------------------------
[Operations,MasterOperations] = TS_LinkOperationsWithMasters(Operations,MasterOperations);
% MasterOperations may have been trimmed by TS_LinkOperationsWithMasters:
numMops = height(MasterOperations);

% ------------------------------------------------------------------------------
% Generate the TS_DataMat, TS_Quality, and TS_CalcTime matrices
% ------------------------------------------------------------------------------
% All NaNs -> NULL (haven't yet been calculated)
TS_DataMat = nan(numTS,numOps);
TS_Quality = nan(numTS,numOps);
TS_CalcTime = nan(numTS,numOps);

%-------------------------------------------------------------------------------
% Get git information to keep track of the version of code used at the time of TS_init
%-------------------------------------------------------------------------------
gitInfo = TS_AddGitInfo();

% ------------------------------------------------------------------------------
% Save to file
% ------------------------------------------------------------------------------
% Set a flag, fromDatabase, that tells you that you that this was generated by
% TS_init and shouldn't be written back to a database
fromDatabase = false;
%save(outputFile,'TimeSeries','Operations','MasterOperations',... % M
%            'TS_DataMat','TS_Quality','TS_CalcTime','fromDatabase','gitInfo'); % M
savedata = struct('TimeSeries', {TimeSeries}, 'Operations', {Operations}, 'MasterOperations', {MasterOperations},... % M
            'TS_DataMat', {TS_DataMat}, 'TS_Quality', {TS_Quality}, 'TS_CalcTime', {TS_CalcTime}, 'fromDatabase', {fromDatabase}, 'gitInfo', {gitInfo}); %M
fprintf(1,'Successfully initialized %u time series, %u master operations, and %u operations\n',... % M
                        numTS,numMops,numOps); % M

end
