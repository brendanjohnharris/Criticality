function [operations, lossmat] = FeatureWisePerformance(template, data, numReps, pTrain, doPar)
    timer = tic;
    if nargin < 3 || isempty(numReps)
        numReps = 20;
    end
    if nargin < 4 || isempty(pTrain)
        pTrain = 0.9;
    end
    if nargin < 5 || isempty(doPar)
        doPar = 0;
    end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    
    operations = data(1, :).Operations;
    
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    [X, Y] = ML_preprocess(X, Y, pTrain, 1);
    [numObs, numFeatures] = size(X);

    lossmat = nan(numFeatures, numReps);
    pl = struct('NumWorkers', 0);
    if doPar
        pl = gcp;
    end
    %% Main procedure
    fprintf('---------- Beginning Calculation ----------\n');
    if doPar
        parfor (rep = 1:numReps, pl.NumWorkers)
            lossvec = nan(numFeatures, 1);
            for f = 1:numFeatures
                fX = X(:, f);
                trainIdxs = randperm(numObs, round(numObs.*pTrain));
                testIdxs = setxor(trainIdxs, 1:numObs);
                if var(fX) ~= 0 % Then training will likely throw an error, and if it doesn't, will be useless
                    mdl = fitcecoc(fX(trainIdxs), Y(trainIdxs), 'Learners', template, 'ClassNames', categories(Y));
                    lossvec(f) = loss(mdl, fX(testIdxs), Y(testIdxs));
                end
            end
            lossmat(:, rep) = lossvec;
            fprintf('---------- Repetition %i performed, %i%% of features unusable, %is elapsed ----------\n', rep, round(mean(isnan(lossvec)), round(toc(timer))));
        end
    else
    	for rep = 1:numReps
            lossvec = nan(numFeatures, 1);
            for f = 1:numFeatures
                fX = X(:, f);
                trainIdxs = randperm(numObs, round(numObs.*pTrain));
                testIdxs = setxor(trainIdxs, 1:numObs);
                if var(fX) ~= 0 % Then training will likely throw an error, and if it doesn't, will be useless
                    mdl = fitcecoc(fX(trainIdxs), Y(trainIdxs), 'Learners', template, 'ClassNames', categories(Y));
                    lossvec(f) = loss(mdl, fX(testIdxs), Y(testIdxs));
                end
            end
            lossmat(:, rep) = lossvec;
            fprintf('---------- Repetition %i performed, %i%% of features unusable, %is elapsed ----------\n', rep, round(mean(isnan(lossvec)), round(toc(timer))));
        end
    end

    operations.Mean_Loss = nanmean(lossmat, 2);
    fprintf('---------- Finished, %is elapsed ----------\n', round(toc(timer)))
end
