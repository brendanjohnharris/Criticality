function f = delayDistributions(x, tau)
% delayDistributions Some features of time series distributions useful for estimating
% parameters of their generating stochastic differential equations.
%
% x: A vector, the input time series 
% tau: An integer; the embedding and differencing delay in units of the timestep
%
% f: A structure of output features

    if nargin < 2 || isempty(tau)
        tau = 1;
    end
    if isrow(x)
        x = x';
    end
    
    % Delay embed at interval tau, m = 2
    y = x(tau+1:end);
    x = x(1:end-tau); % Lose a point here
    
    % Rotate the embedding by pi/4, scaling xt
    xt = (x+y)./2;
    yt = y - x;
    
    % Median-split properties
    f.median = median(x);
    subMedians = x < f.median;
    f.superMedianCorr = corr(xt(~subMedians), yt(~subMedians));
    f.subMedianCorr = corr(xt(subMedians), yt(subMedians));
    f.diffMedianCorr = f.superMedianCorr - f.subMedianCorr;
    f.superMedianSD = std(x(~subMedians));
    f.subMedianSD = std(x(subMedians));
    f.diffMedianSD = f.superMedianSD - f.subMedianSD;
    
    % Delay distribution properties
    f.sigma_dx = std(yt);
    f.densityDifference = 1./f.superMedianSD - 1./f.subMedianSD;
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    f.scaleSigmaDifference = f.sigma_dx.*f.densityDifference;
    %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    f.delayDensityRatio = f.sigma_dx./std(xt);
    f.scaleDensityDifference = f.sigma_dx.*(1./(max(x(~subMedians)) - f.median) - 1./(f.median - min(x(subMedians))));
    f.logSigmaDifference = f.sigma_dx.*(log(f.superMedianSD) - log(f.subMedianSD));
    f.loggradSigmaDifference = f.logSigmaDifference./(mean(xt(~subMedians)) - mean(xt(subMedians)));
    f.autocorrelationApproximation = (var(xt) - var(yt))./(var(xt) + var(yt));
    
    pdf = ksdensity(x, linspace(0, max(x), 100));
    idx = find(linspace(0, max(x), 100) > f.median, 1, 'first');
    f.scaleDensityFit = f.sigma_dx.*(mean(pdf(idx:end)) - mean(pdf(1:idx-1)));
    f.what = std(xt(subMedians))./std(yt);
    
    
    % Miscellaneous
    f.symmetricKurtosis = kurtosis([-x; x]);
    f.symmetricSD = std([-x; x])./f.sigma_dx;
end

