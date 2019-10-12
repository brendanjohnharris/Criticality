function [lossmat, fmat, trainlossmat] = sequentialFeaturePerformance(template, data, numReps, pTrain, depth, doPar)
%SEQUENTIALFEATUREPERFORMANCE 
% Split data
% Find best feature on this one split instance and record feature and loss
% Find the best feature that works in combination with this feature, record
% feature and loss
% Find best third feature and record, up to depth chosen
% Resplit data, repeat.
%
% lossmat is the matrix of losses; columns for each repetition, rows for
% each type of training (single featuere, two feature, etc.)
% fmat is a cell array of the same size; each element contains the idxs (! not IDs) of the
% features used to give the corresponding loss
    timer = tic;
    if nargin < 3 || isempty(numReps)
        numReps = 20;
    end
    if nargin < 4 || isempty(pTrain)
        pTrain = 0.9;
    end
    if nargin < 5 || isempty(depth)
        depth = 2;
    end
    if nargin < 6 || isempty(doPar)
        doPar = 0;
    end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    
    operations = data(1, :).Operations;
    featureIDs = operations.ID;
    
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    [X, Y, subIDs] = ML_preprocess(X, Y, pTrain);
    featureIDs = featureIDs(subIDs);
    [numObs, numFeatures] = size(X);

    lossmat = nan(depth, numReps);
    trainlossmat = lossmat; 
    fmat = cell(size(lossmat));
    pl = struct('NumWorkers', 0);
    if doPar
        pl = gcp;
    end
    
    c = cvpartition(Y, 'HoldOut', 1-pTrain, 'Stratify', true);
    
    %% Main procedure
    fprintf('---------- Beginning Calculation ----------\n');
    if doPar
        parfor (rep = 1:numReps, pl.NumWorkers)
            topfs = [];
            crep = repartition(c);
            trainIdxs = training(crep);
            testIdxs = test(crep);
            for d = 1:depth
                flossvec = nan(numFeatures, 1);
                loopFs = setxor(1:numFeatures, topfs);
                for f = loopFs(:)'
                    fX = X(:, [topfs, f]);
                    mdl = fitcecoc(fX(trainIdxs, :), Y(trainIdxs, :), 'Learners', template, 'ClassNames', categories(Y));
                    flossvec(f) = loss(mdl, fX(trainIdxs, :), Y(trainIdxs, :)); % Evaluate for the next depth using training data
                end
                [themin, theminIdx] = min(flossvec); % This gives the best feature (INDEX) for this depth
                topfs(d) = theminIdx; % THIS IS THE FEATURE INDEX, NOT ID
                trainlossmat(d, rep) = themin;
                % ----------- Evaluate this feature set using the test data ----------
                fX = X(:, topfs);
                testmdl = fitcecoc(fX(trainIdxs, :), Y(trainIdxs, :), 'Learners', template, 'ClassNames', categories(Y));
                testloss = loss(testmdl, fX(testIdxs, :), Y(testIdxs, :));
                fmat{d, rep} = featureIDs(topfs); % THESE ARE THE FEATURE IDS, AS IN OPERATIONS, not INDICES
                lossmat(d, rep) = testloss;
                % ----------------------------------------------------------------
            end

            fprintf('---------- Repetition %i performed, %is elapsed ----------\n', rep, round(toc(timer)));
        end
    else
        for rep = 1:numReps
            topfs = [];
            crep = repartition(c);
            trainIdxs = training(crep);
            testIdxs = test(crep);
            for d = 1:depth
                flossvec = nan(numFeatures, 1);
                loopFs = setxor(1:numFeatures, topfs);
                for f = loopFs(:)'
                    fX = X(:, [topfs, f]);
                    mdl = fitcecoc(fX(trainIdxs, :), Y(trainIdxs, :), 'Learners', template, 'ClassNames', categories(Y));
                    flossvec(f) = loss(mdl, fX(trainIdxs, :), Y(trainIdxs, :)); % Evaluate for the next depth using training data
                end
                [themin, theminIdx] = min(flossvec); % This gives the best feature (INDEX) for this depth
                topfs(d) = theminIdx; % THIS IS THE FEATURE INDEX, NOT ID
                trainlossmat(d, rep) = themin;
                % ----------- Evaluate this feature set using the test data ----------
                fX = X(:, topfs);
                testmdl = fitcecoc(fX(trainIdxs, :), Y(trainIdxs, :), 'Learners', template, 'ClassNames', categories(Y));
                testloss = loss(testmdl, fX(testIdxs, :), Y(testIdxs, :));
                fmat{d, rep} = featureIDs(topfs); % THESE ARE THE FEATURE IDS, AS IN OPERATIONS, not INDICES
                lossmat(d, rep) = testloss;
                fprintf('Depth %i/%i Complete, %is elapsed\n', d, depth, round(toc(timer)))
                % ----------------------------------------------------------------
            end

            fprintf('---------- Repetition %i performed, %is elapsed ----------\n', rep, round(toc(timer)));
        end
    end
    fprintf('---------- Finished, %is elapsed ----------\n', round(toc(timer)))
end
