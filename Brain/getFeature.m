function f = getFeature(whatFeature,subID,params,doRandomize)
% Overload humanStructureFunction for arbitrary features.
%-------------------------------------------------------------------------------
% Computes low frequency power across ROIs for a given subject
%-------------------------------------------------------------------------------

% Check Inputs:
if ~iscell(whatFeature)
    whatFeature = {whatFeature};
end
if nargin < 3
    params = GiveMeDefaultParams();
end
if nargin < 4
    doRandomize = false;
end
%-------------------------------------------------------------------------------
% Load in BOLD data
timeSeriesData = GiveMeTimeSeries(subID,params.data,doRandomize);
[timeSeriesLength,numRegions] = size(timeSeriesData);

% Compute sampling frequency (time / sample)
samplingPeriod = params.data.scanDuration/timeSeriesLength;

%-------------------------------------------------------------------------------
f = zeros(numRegions,1);
for i = 1:numRegions
    x = timeSeriesData(:,i); % whatFeature should refer to x or y
    y = zscore(x);
    ff = eval(whatFeature{1});
    if length(whatFeature) == 2
        f(i) = ff.(whatFeature{2});
    else
        f(i) = ff;
    end
end

end
