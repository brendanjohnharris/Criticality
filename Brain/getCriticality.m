function SSD = getCriticality(subID,params,doRandomize)
% Overload humanStructureFunction for arbitrary features.
%-------------------------------------------------------------------------------
% Computes low frequency power across ROIs for a given subject
%-------------------------------------------------------------------------------

% Check Inputs:
if nargin < 2
    params = GiveMeDefaultParams();
end
if nargin < 3
    doRandomize = false;
end
%-------------------------------------------------------------------------------
% Load in BOLD data
timeSeriesData = GiveMeTimeSeries(subID,params.data,doRandomize);
[timeSeriesLength,numRegions] = size(timeSeriesData);

% Compute sampling frequency (time / sample)
samplingPeriod = params.data.scanDuration/timeSeriesLength;

%-------------------------------------------------------------------------------
SSD = zeros(numRegions,1);
for i = 1:numRegions
    criticality = delayDistributions(timeSeriesData(:,i), 1, 1);
    SSD(i) = criticality.scaleSigmaDifference;
end

end
