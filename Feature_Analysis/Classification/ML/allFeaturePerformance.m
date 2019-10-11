function lossvec = allFeaturePerformance(template, data, numReps, pTrain)
    % template can be a character vector specifying a function of 'x' and 'y' that outputs
    % a model e.g. 'fitcsvm(x, x)'
    rng('shuffle')
    timer = tic;
    if nargin < 3 || isempty(numReps)
        numReps = 20;
    end
    if nargin < 4 || isempty(pTrain)
        pTrain = 0.9;
    end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    
    operations = data(1, :).Operations;
    
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    
    [numObs, numFeatures] = size(X);

    lossvec = nan(numReps, 1);
    
    
    if strcmp(template.Method,  'NaiveBayes') % And maybe others
%         goodIdxs = var(X, [], 1) ~= 0 & ~any(isnan(var(X, [], 1), 1));
%         X = X(:, goodIdxs);
        cv = abs(corr(X));
        goodIdxs = true(1, size(X, 2));
        for i = size(X, 2):-1:1 % In reverse since the simpler features tend to be near the start of the datamat
            % (cv(i, goodIdxs) > 0.99 & cv(i, goodIdxs) < 1) | % Any features that are extremely well correlated
            if any(isnan(cv(i, i))) % Any features with NaN autocorrelation (this includes any with nan values as well as 0 variance)
                goodIdxs(i) = false;
            end
            if mean(X(:, i) == mode(X(:, i))) >= pTrain % Is it possible to choose a 0.9 subset that has zero variance? Assume pTrain > 0.5
                goodIdxs(i) = false;
            end
        end
        X = X(:, goodIdxs);
        X = BF_NormalizeMatrix(X, 'sigmoid'); % Normalize for good measure
    end
    
    
    %% Main procedure
    fprintf('---------- Beginning Calculation ----------\n');
    for rep = 1:numReps
        trainIdxs = randperm(numObs, round(numObs.*pTrain));
        testIdxs = setxor(trainIdxs, 1:numObs);
        x = X(trainIdxs, :);
        y = Y(trainIdxs);
        if ischar(template)
            mdl = eval(template);
        else
            mdl = fitcecoc(x, y, 'Learners', template, 'ClassNames', categories(Y));
        end
        lossvec(rep) = loss(mdl, X(testIdxs, :), Y(testIdxs));
        fprintf('---------- Repetition %i performed, %is elapsed ----------\n', rep, round(toc(timer)));
    end
    
    fprintf('---------- Finished, %is elapsed ----------\n', round(toc(timer)))
end
