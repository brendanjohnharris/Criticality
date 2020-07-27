function [featureMat1,featureMat2] = GroupTimeSeriesFeature(params,whatFeature)
% Overload humanStructureFunction for arbitrary features.
%-------------------------------------------------------------------------------
% Compute group-average time-series feature
%-------------------------------------------------------------------------------
if nargin < 2
    whatFeature = 'criticality';
end
%-------------------------------------------------------------------------------

% Load time-series data:
subfile = load(params.data.subjectInfoFile);
subjectIDs = subfile.subs100.subs;
numSubjects = length(subjectIDs);
% Test to get number of ROIs:
timeSeriesData = GiveMeTimeSeries(subjectIDs(1),params.data,false);
numROIs = size(timeSeriesData,2);

%-------------------------------------------------------------------------------
% Extract the feature from each time series:
if ~iscell(whatFeature)
    switch whatFeature
    case 'RLFP'
        % Compute RLFP feature in every ROI of every subject:
        featureMat1 = zeros(numROIs,numSubjects);
        for i = 1:numSubjects
            fprintf(1,'Subject %u/%u\n',i,numSubjects);
            featureMat1(:,i) = getFreqBand(subjectIDs(i),params,false);
        end
        % Compute mean (across subjects) in every ROI:
        % meanFeature = mean(featureMat,2);

    case 'fALFF'
        % Compute LFP feature in every ROI of every subject:
        featureMat1 = zeros(numROIs,numSubjects);
        for i = 1:numSubjects
            featureMat1(:,i) = getfALFF(subjectIDs(i),whichHemispheres,false,numBands,bandOfInterest);
        end

    case 'timescale'
        % Time-scale feature from hctsa function (CO_AutoCorrShape)
        timescaleMatDecay = zeros(numROIs,numSubjects);
        timescaleMatArea = zeros(numROIs,numSubjects);
        for i = 1:numSubjects
            fprintf(1,'Subject %u/%u\n',i,numSubjects);
            timeSeriesData = GiveMeTimeSeries(subjectIDs(i),params.data,false);
            numRegions = size(timeSeriesData,2);
            for j = 1:numRegions
                out = CO_AutoCorrShape(zscore(timeSeriesData(:,j)),'posDrown');
                if ~isstruct(out) & isnan(out)
                    timescaleMatDecay(j,i) = NaN;
                    timescaleMatArea(j,i) = NaN;
                else
                    timescaleMatDecay(j,i) = out.decayTimescale;
                    timescaleMatArea(j,i) = out.sumacf;
                end
            end
        end
        featureMat1 = timescaleMatDecay;
        featureMat2 = timescaleMatArea;

    case 'criticality'
        % A robust feature for measuring distance to bifurcations
        featureMat1 = zeros(numROIs,numSubjects);
        for i = 1:numSubjects
            fprintf(1,'Subject %u/%u\n',i,numSubjects);
            featureMat1(:,i) = getCriticality(subjectIDs(i),params,false);
        end
    end
else % A feature code string is provided. 
    % If the feature function returns a struct, use a cell array of the 
    % form {'feature', 'subfeature'} (as in, 'feature.subfeature').
    featureMat1 = zeros(numROIs,numSubjects);
    fWriter = reWriter();
    for i = 1:numSubjects
        reWrite(fWriter, 'Subject %u/%u', i, numSubjects);
        featureMat1(:,i) = getFeature(whatFeature, subjectIDs(i),params,false);
    end
end
end
