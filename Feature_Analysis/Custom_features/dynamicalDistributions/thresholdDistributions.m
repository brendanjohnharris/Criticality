function f = thresholdDistributions(x, p, tau)
% thresholdDistributions Some features of time series distributions useful for estimating
% parameters of their generating stochastic differential equations.
%
% x: A vector, the input time series 
% tau: A float; the threshold offset from the mean
%
% f: A structure of output features

    if nargin < 2 || isempty(p)
        p = 1;
    end
    if nargin < 3 || isempty(tau)
        tau = 1;
    end
    if nargin < 4 || isempty(centre)
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

    
    
    thresh = mean(x)+p*sigma;
    f.upperPropMeanSigma = sum(x >= thresh)./(sum(x <= thresh)+sum(x >= thresh));
    
    thresh = mean(x)+p*std(x);
    f.upperPropMeanSD = sum(x >= thresh)./(sum(x <= thresh)+sum(x >= thresh));
    
    thresh = p*sigma;
    f.upperPropSigma = sum(x >=thresh)./(sum(x <= thresh)+sum(x >= thresh));
  
end
