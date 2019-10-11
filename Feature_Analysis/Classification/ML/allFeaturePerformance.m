function lossvec = allFeaturePerformance(template, data, numReps, pTrain)
    % template can be a character vector specifying a function of 'x' and 'y' that outputs
    % a model e.g. 'fitcsvm(x, x)'
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
    [X, Y] = ML_preprocess(X, Y, pTrain);
    [numObs, numFeatures] = size(X);

    lossvec = nan(numReps, 1);
    
    c = cvpartition(Y, 'HoldOut', 1-pTrain, 'Stratify', true);
    
    %% Main procedure
    fprintf('---------- Beginning Calculation ----------\n');
    for rep = 1:numReps
        crep = repartition(c);
        trainIdxs = training(crep);
        testIdxs = test(crep);
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
