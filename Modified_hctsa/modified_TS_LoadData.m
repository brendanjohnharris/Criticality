function [TS_DataMat,TimeSeries,Operations,whatDataFile] = TS_LoadData(whatDataFile,getClustered)
% TS_LoadData   Load HCTSA data from file.
%
% Reorders a data matrix and TimeSeries and Operation structures according to the
% permutation information in the given data file (ts_clust or op_clust), or
% provided explicitly by the user.
%
% Note that extra elements can be loaded subsequently using the TS_GetFromData
% function.
%
%---INPUTS:
% whatDataFile: the name of the HCTSA data file to load in. Use 'norm' (default)
%               to load in HCTSA_N.mat
% getClustered: whether to reorder the structures according to a clustering
%
%---OUTPUTS:
% The key hctsa data objects obtained from the data source:
%       *) TS_DataMat (matrix)
%       *) TimeSeries (structure array)
%       *) Operations (structure array)
% whatDataFile, a string providing the file name of the data file used to load
%               the data

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

%-------------------------------------------------------------------------------
% Check inputs, set defaults
%-------------------------------------------------------------------------------
if nargin < 1 || isempty(whatDataFile)
    whatDataFile = 'norm';
end
if nargin < 2 || isempty(getClustered)
    getClustered = false;
end

%-------------------------------------------------------------------------------
% In some cases, you provide a structure with the pre-loaded data already in it
% e.g., as a whatDataFile = load('HCTSA.mat');
% In this case, no further loading is required -- just a restructuring
%-------------------------------------------------------------------------------
if isstruct(whatDataFile)
    if isfield(whatDataFile,'TS_DataMat')
        TS_DataMat = whatDataFile.TS_DataMat;
    else
        TS_DataMat = [];
    end
    if isfield(whatDataFile,'TimeSeries')
        TimeSeries = whatDataFile.TimeSeries;
    else
        TimeSeries = table();
    end
    if isfield(whatDataFile,'Operations')
        Operations = whatDataFile.Operations;
    else
        Operations = table();
    end

    % Check if used legacy structure array format for metadata:
    [TimeSeries,Operations] = CheckStructureToTable(TimeSeries,Operations);

    % Cluster the data if necessary/possible:
    if getClustered
        [TS_DataMat,TimeSeries,Operations] = clusterMe(TS_DataMat,TimeSeries,Operations);
    end

    % Name the datafile going out of the function as an input structure:
    whatDataFile = '--INPUT_STRUCTURE--'; % revive this, so this output is always a string

    return
end

%-------------------------------------------------------------------------------
% Use intuitive settings for HCTSA package defaults -- setting 'raw', 'norm', or 'cl'
switch whatDataFile
case {'raw','loc'} % the raw, un-normalized data:
    whatDataFile = 'HCTSA.mat';
    getClustered = false;
case 'norm' % the normalized data:
    whatDataFile = 'HCTSA_N.mat';
    getClustered = false;
case 'cl' % the clustered data:
    whatDataFile = 'HCTSA_N.mat';
    getClustered = true;
end

%-------------------------------------------------------------------------------
% Check the file is a .mat file:
if ~strcmp(whatDataFile(end-3:end),'.mat')
    error('Specify a .mat filename');
end

% Load data from the file:
if ~exist(whatDataFile,'file')
    error('%s not found',whatDataFile);
end
fprintf(1,'Loading data from %s...',whatDataFile);
load(whatDataFile,'TS_DataMat','Operations','TimeSeries');
fprintf(1,' Done.\n');

% Check whether an old version of hctsa using structure arrays
[TimeSeries,Operations] = CheckStructureToTable(TimeSeries,Operations);

if getClustered
    [TS_DataMat,TimeSeries,Operations] = clusterMe(TS_DataMat,TimeSeries,Operations);
end

%-------------------------------------------------------------------------------
function [TimeSeries,Operations] = CheckStructureToTable(TimeSeries,Operations)
    % Check whether an old version of hctsa using structure arrays
    if isstruct(TimeSeries) || isstruct(Operations)
        warning(['Metadata stored in old structure-array format; run ',...
                'TS_ConvertToTable on your hctsa data file to update?'])
    end
    if isstruct(TimeSeries)
        TimeSeries = struct2table(TimeSeries);
    end
    if isstruct(Operations)
        Operations = struct2table(Operations);
    end
end
%-------------------------------------------------------------------------------
function [TS_DataMat,TimeSeries,Operations] = clusterMe(TS_DataMat,TimeSeries,Operations)
    % Change order according to stored clustering (if none has been run, by default
    % returns the same ordering as the original dataset)
    ts_clust = TS_GetFromData(whatDataFile,'ts_clust');
    op_clust = TS_GetFromData(whatDataFile,'op_clust');
    if isempty(ts_clust) && isempty(op_clust)
        warning('No clustering info found in the data source -- returning unclustered data');
    else
        if ~isempty(ts_clust)
            TimeSeries = TimeSeries(ts_clust.ord,:);
            TS_DataMat = TS_DataMat(ts_clust.ord,:);
        end
        if ~isempty(op_clust)
            Operations = Operations(op_clust.ord,:);
            TS_DataMat = TS_DataMat(:,op_clust.ord);
        end
    end
end

end
