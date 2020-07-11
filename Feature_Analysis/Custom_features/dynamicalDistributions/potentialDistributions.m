function fval = potentialDistributions(x, tau, centre)
% potentialDistributions Some features of time series distributions useful for estimating
% parameters of their generating stochastic differential equations.
%
% x: A vector, the input time series 
% p: A character vector specifying a potential form. c.f. 'TSG_Systems.m'
%
% fval: A structure of output features
    if nargin < 2 || isempty(tau)
        tau = 1;
    end
    if nargin < 3 || isempty(centre)
        centre = 0;
    end
    if isrow(x)
        x = x';
    end
    
    % Center and absolute-value the time series
    if centre
        x = x - median(x);
        x = abs(x);
    end
    
    % Delay embed at interval tau, m = 2
    y = x(tau+1:end);
    x = x(1:end-tau); % Lose a point here
    
    sigma = std(y - x);
    x = sort(x);
    ppoints = 0.01:0.01:1;
    samplepoints = prctile(x, 100.*ppoints);
    samplepoints = mean([samplepoints(1:end-1); samplepoints(2:end)], 1); % Make samplepoints the center of each percentile window 
    dist = fitdist(x, 'Kernel', 'Kernel', 'Normal');
    f = pdf(dist, samplepoints)';
    
    
    % Supercritical Hopf Radius
    V = @(f) -sigma.^2.*log(f);
    ft = fittype('-a*x^2 + b*x^4 + c', 'independent', {'x'}, 'coefficients', {'a', 'b', 'c'});
    thefit = fit(samplepoints', V(f), ft);
    [~, mu_conc] = differentiate(thefit, 0);
    fval.fitSupercriticalHopfRadius = mu_conc;
  
    % A plain quadratic potential
    V = @(f) -sigma.^2.*log(f);
    ft = fittype('-a*x^2 + b', 'independent', {'x'}, 'coefficients', {'a', 'b'});
    thefit = fit(samplepoints', V(f), ft);
    [~, mu_conc] = differentiate(thefit, samplepoints);
    fval.fitQuadraticPotential = mean(mu_conc);
  
end
