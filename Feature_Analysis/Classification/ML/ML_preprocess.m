function [X, Y, outIDs] = ML_preprocess(X, Y, pTrain, consistent)
%ML_PREPROCESS Preprocess a matrix and classification labels for
%criticality machine learning, in a consistent way.
% This consists of 5 steps:
%       - Remove any features with 0 variance 
%       - Remove any features with bad values (Nan, Inf)
%       - Remove any features that have perfect correlation with other features
%       - Remove any features for which it is possible to choose a training
%         subset (size specified by pTrain) that has zero variance
%       - Normalize with mixed sigmoid to handle outliers and/or bimodality
%
% If consistent is true, then no columns of X will be removed but it will
% still be normalised
    if nargin < 3 || isempty(pTrain)
        pTrain = [];
    end
    if nargin < 4 || isempty(consistent)
        consistent = 0;
    end
    if ~consistent
        cv = abs(corr(X));
        goodIdxs = true(1, size(X, 2));
        for i = size(X, 2):-1:1 % In reverse since the simpler features tend to be near the start of the datamat; would prefer to keep those
            if any(cv(i, [1:i-1, i+1:length(cv)]) == 1) % If this feature is perfectly correlated with any others
                goodIdxs(i) = false;
            end
            if any(isnan(cv(i, i))) % Any features with NaN autocorrelation (this includes any with NaN/inf values as well as 0 variance)
                goodIdxs(i) = false;
            end
            if ~isempty(pTrain)
                if mean(X(:, i) == mode(X(:, i))) >= pTrain % Is it possible to choose a pTrain subset that has zero variance? 
                    goodIdxs(i) = false;
                end
            end
        end
        X = X(:, goodIdxs);
    end
    X = BF_NormalizeMatrix(X, 'mixedSigmoid');
    outIDs = find(goodIdxs);
end

