function [lossmat, fmat] = sequentialFeaturePerformance(template, data, numReps, pTrain, depth, doPar)
%SEQUENTIALFEATUREPERFORMANCE 
% Split data
% Find best feature on this one split instance and record feature and loss
% Find the best featuer that works in combination with this feature, record
% feature and loss
% Find best third feature and record, up to depth chosen
% Resplit data, repeat.
%
% lossmat is the matrix of losses; columns for each repetition, rows for
% each type of training (single featuere, two feature, etc.)
% fmat is a cell array of the same size; each element contains the idxs (! not IDs) of the
% features used to give the corresponding loss
    rng('shuffle')
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
    
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    
    [numObs, numFeatures] = size(X);

    lossmat = nan(depth, numReps);
    fmat = cell(size(lossmat));
    pl = struct('NumWorkers', 0);
    if doPar
        pl = gcp;
    end
    %% Main procedure
    fprintf('---------- Beginning Calculation ----------\n');
    parfor (rep = 1:numReps, pl.NumWorkers)
        topfs = [];
        for d = 1:depth
            flossvec = nan(numFeatures, 1);
            loopFs = setxor(1:numFeatures, topfs);
            for f = loopFs(:)'
                fX = X(:, [topfs, f]);
                trainIdxs = randperm(numObs, round(numObs.*pTrain));
                testIdxs = setxor(trainIdxs, 1:numObs);
                mdl = fitcecoc(fX(trainIdxs, :), Y(trainIdxs, :), 'Learners', template, 'ClassNames', categories(Y));
                flossvec(f) = loss(mdl, fX(testIdxs, :), Y(testIdxs, :));
            end
            [themin, theminIdx] = min(flossvec);
            topfs(d) = theminIdx;
            fmat{d, rep} = topfs;
            lossmat(d, rep) = themin;
        end
        
        fprintf('---------- Repetition %i performed, %is elapsed ----------\n', rep, round(toc(timer)));
    end

    fprintf('---------- Finished, %is elapsed ----------\n', round(toc(timer)))
end
