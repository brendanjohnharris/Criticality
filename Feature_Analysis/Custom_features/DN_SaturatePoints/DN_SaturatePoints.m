function out = DN_SaturatePoints(y,removeHow,p)
% DN_SaturatePoints How time-series properties change as it is artificially
% saturated at a certain threshold.
%
% A modification of DN_RemovePoints:
% ------------------------------------------------------------------------------
% DN_RemovePoints   How time-series properties change as points are removed.
%
% A proportion, p, of points are removed from the time series according to some
% rule, and a set of statistics are computed before and after the change.
%
%---INPUTS:
% y, the input time series
% removeHow, how to remove points from the time series:
%               (i) 'absclose': those that are the closest to the mean,
%               (ii) 'absfar': those that are the furthest from the mean,
%               (iii) 'min': the lowest values,
%               (iv) 'max': the highest values,
%               (v) 'random': at random.
%
% p, the proportion of points to remove
%
%---OUTPUTS: Statistics include the change in autocorrelation, time scales, mean,
% spread, and skewness.
%
% NOTE: This is a similar idea to that implemented in DN_OutlierInclude.

%% Preliminaries
% ------------------------------------------------------------------------------
N = length(y); % time-series length
doPlot = 0; % plot output

% ------------------------------------------------------------------------------
%% Check inputs
% ------------------------------------------------------------------------------
if nargin < 2 || isempty(removeHow)
    removeHow = 'absfar'; % default
end
if nargin < 3 || isempty(p)
    p = 0.1; % 10%
end

% ------------------------------------------------------------------------------
switch removeHow
    %case 'absclose' % remove a proportion p of points closest to the mean
    %    [~, is] = sort(abs(y),'descend');
    %case 'absfar' % remove a proportion p of points furthest from the mean
    %    [~, is] = sort(abs(y),'ascend');
    case 'min'
        [~, is] = sort(y,'descend'); % remove a proportion p of points with the lowest values
    case 'max'
        [~, is] = sort(y,'ascend'); % remove a proportion p of points with the highest values
    %case 'random'
    %    is = randperm(N);
    otherwise
        error('Unknwon method ''%s''',removeHow);
end
sat = y(is(round(N*(1-p))));% The saturation value
rKeep = sort(is(1:round(N*(1-p))),'ascend');
y_trim = y;
y_trim(setdiff(1:length(y), rKeep)) = sat;

if doPlot
    figure('color','w')
    hold off
    plot(y,'ok');
    hold on;
    plot(rKeep,y_trim,'.r')
    hold off;
    histogram(y_trim,50)
end

acf_y = SUB_acf(y,8);
acf_y_trim = SUB_acf(y_trim,8);

if doPlot
    figure('color','w')
    hold off;
    plot(acf_y,':b'); hold on;
    plot(acf_y_trim,':r');
end

% ------------------------------------------------------------------------------
%% Compute output statistics
% ------------------------------------------------------------------------------
out.fzcacrat = CO_FirstZero(y_trim,'ac')/CO_FirstZero(y,'ac');
out.ac2rat = acf_y_trim(2)/acf_y(2); % includes the sign
out.ac2diff = abs(acf_y_trim(2)-acf_y(2));
out.ac3rat = acf_y_trim(3)/acf_y(3); % includes the sign
out.ac3diff = abs(acf_y_trim(3)-acf_y(3));
out.sumabsacfdiff = sum(abs(acf_y_trim-acf_y));
out.mean = mean(y_trim);
out.median = median(y_trim);
out.std = std(y_trim);
out.skewnessrat = skewness(y_trim)/skewness(y); % Statistics Toolbox
out.kurtosisrat = kurtosis(y_trim)/kurtosis(y); % Statistics Toolbox


% ------------------------------------------------------------------------------
function acf = SUB_acf(x,n)
    % computes autocorrelation of the input sequence, x, up to a maximum time
    % lag, n
    acf = zeros(n,1);
    for i = 1:n
        acf(i) = CO_AutoCorr(x,i-1,'Fourier');
    end
end

end
