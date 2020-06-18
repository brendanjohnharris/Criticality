function stats = LINEST(y, x, const)
%LINEST Replicate the behaviour of Excel's LINEST linear fit function.
%     Inputs:
%         - y: The y-values of the data specified as a vector.
%         - x: Optional. A vector or array of x-values. If y is a row
%               vector, the rows of x are considered independent variables,
%               otherwise columns. The length fo y shoudl equal the number of
%               observations the relevant dimension of x.
%         - const: Optional. If true or omitted, the intercept is
%         calculated normally and is the LAST coefficient returned.
%               If false, the intercept is forced to 0. 
%     Outputs: A struct containing the regression coefficients, standard errors for each coefficient, 
%               an r^2 value, a standard error for the y estimate, the F-statistic, 
%               the degrees of freedom, the regression sum of squares
%               and the residual sum of squares. 
%               c.f https://support.office.com/en-us/article/linest-function-84d7d0d9-6e50-4101-977a-fa7abf772b6d
%     Note: LINEST normally checks for collinearity. Do that beforehand, Lazy.
    if nargin < 2 || isempty(x)
        x = 1:length(y);
        if iscolumn(y)
            x = x';
        end
    end
    if nargin < 3 || isempty(const)
        const = true;
    end
    if isrow(y)
        y = y';
        x = x'; % Each column is now an independent variable
    elseif ~iscolumn(y)
        error('The input y is not correctly shaped')
    end
    if size(x, 1) ~= length(y)
        error('The input x is not correctly shaped')
    end
    if const
        x = [x, ones(length(y), 1)]; % Append a constant variable to x
    end
    dm = inv(x'*x);
    beta = dm*x'*y;
    stats.m = beta;%
    if ~const
        stats.m = [stats.m, 0];
    end
    stats.df = size(x, 1) - length(stats.m) + ~const;%
    yy = x*beta;
    residuals = y - yy;
    stats.ssresid = sum(residuals.^2);%
    ssquared = residuals'*residuals/stats.df;
    stats.se =  sqrt(ssquared.*diag(dm));%
    
    if const
        sstot = sum((y-mean(y)).^2);
    else
        sstot = sum(y.^2);
    end
    stats.ssreg = sstot - stats.ssresid; %    
    stats.Rsquared = stats.ssreg./sstot;%
    stats.F = NaN;%
    stats.sey = std(yy);%
end
