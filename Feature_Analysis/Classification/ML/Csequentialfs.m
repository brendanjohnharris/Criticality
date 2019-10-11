function [operations, selectedOpIdxs] = Csequentialfs(template, data, cutoffConditions, numFolds, doPar)
%CSEQUENTIALFS 
% Given a template and some data, repeatedly train a model to find the
% feature with the lowest (average, over 10 folds) loss. Then, find the
% feature with that gives the greatest improvement to this lossin
% conjunction with the first selected feature, and so on...
% cutoffConditions is a vector condaining the following values:
%
% [<loss cutoff>, <num features>, <watch increase>]
%
% <loss cutoff> is the desired loss value (e.g. accuracy)
% <num features> is the number of features desired for the final model
% <watch increase> is a binary; if 1, the selection algorithm will stop
% when the best feature first increases the loss
    timer = tic;
    if nargin < 3 || isempty(cutoffConditions)
        cutoffConditions = [0.01, inf, 1];
    end
    if nargin < 4 || isempty(numFolds)
        numFolds = 10;
    end
    if nargin < 5 || isempty(doPar)
        doPar = 0;
    end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    
    operations = data(1, :).Operations;
    featureIDs = operations.ID;
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    [X, Y, subIDs] = ML_preprocess(X, Y);
    featureIDs = featureIDs(subIDs);
    [numObs, numFeatures] = size(X);
    
    %fX = zeros(numObs, 1);
    fX = double.empty(numObs, 0);
    selectedOpIdxs = [];
    featureRec = 1:numFeatures; % Record the original order of the features
    operations.Running_Loss = inf(height(operations), 1);
    lowestLoss = inf;
    featureWriter = reWriter();
    
    while lowestLoss > cutoffConditions(1) && sum(~isinf(operations.Running_Loss)) < cutoffConditions(2) && (~cutoffConditions(3) || min(operations.Running_Loss) == lowestLoss)
        featureLoss = inf(1, numFeatures);
        
        if doPar
            %% Parallel
            fprintf('---------- %i/%i features selected, %is elapsed ----------\n', sum(~isinf(operations.Running_Loss)), size(X, 2), round(toc(timer)))
            Xpar = X(:, featureRec); % To avoid broadcast
            parfor fi = 1:numFeatures
                foldLoss = zeros(1, numFolds);
                %f = featureRec(fi);
                nextfX = Xpar(:, fi); % Just this feature
                % Find cross validation indices
                crossInds = buffer(randperm(numObs, numObs), numFolds)'; % If I ask for buffers of length 10 but transpose, I will have a matrix with 10 columns (buffers); the values aren't ordered
                % Train and compute loss for each feature
                for c = 1:numFolds
                    outInds = crossInds(:, c); % Select one buffer to leave out
                    outInds = outInds(outInds > 0);
                    inInds = setxor(1:numObs, outInds);
                    if numFolds == 1
                        mdl = fitcecoc([fX, nextfX], Y, 'Learners', template, 'ClassNames', categories(Y));
                        foldLoss(c) = loss(mdl, [fX, nextfX], Y);
                    else
                        mdl = fitcecoc([fX(inInds, :), nextfX(inInds, :)], Y(inInds), 'Learners', template, 'ClassNames', categories(Y));
                        foldLoss(c) = loss(mdl, [fX(outInds, :), nextfX(outInds, :)], Y(outInds));
                    end
                end
                featureLoss(fi) = mean(foldLoss);
            end
        else
            %% Serial
            for fi = 1:numFeatures
                foldLoss = zeros(1, numFolds);
                f = featureRec(fi);
                featureWriter.reWrite('---------- Calculating loss for feature %i/%i (%i/%i features selected, %is elapsed) ----------\n',...
                                        fi, numFeatures, size(fX, 2), size(X, 2), round(toc(timer)));
                nextfX = X(:, f); % Just this feature
                % Find cross validation indices
                crossInds = buffer(randperm(numObs, numObs), numFolds)'; % If I ask for buffers of length 10 but transpose, I will have a matrix with 10 columns (buffers); the values aren't ordered
                % Train and compute loss for each feature
                for c = 1:numFolds
                    outInds = crossInds(:, c); % Select one buffer to leave out
                    outInds = outInds(outInds > 0);
                    inInds = setxor(1:numObs, outInds);
                    if numFolds == 1
                        mdl = fitcecoc([fX, nextfX], Y, 'Learners', template, 'ClassNames', categories(Y));
                        foldLoss(c) = loss(mdl, [fX, nextfX], Y);
                    else
                        mdl = fitcecoc([fX(inInds, :), nextfX(inInds, :)], Y(inInds), 'Learners', template, 'ClassNames', categories(Y));
                        foldLoss(c) = loss(mdl, [fX(outInds, :), nextfX(outInds, :)], Y(outInds));
                    end
                end
                featureLoss(fi) = mean(foldLoss);
            end
        end
        
        [lowestLoss, topf] = min(featureLoss); % featureLoss had losses by feature loop index (i.e. indices of featureRec)
        topf = featureRec(topf); % Get the original feature Idx
        % Record the loss and the top feature
        operations(topf, :).Running_Loss = lowestLoss;
        selectedOpIdxs(end+1) = featureIDs(topf); % This IS the opID, matching the ID in 'operations'
        numFeatures = numFeatures - 1;
        featureRec = setxor(topf, featureRec);
        fX = [fX, X(:, topf)]; % Ready for the next round
    end  
    featureWriter.reWrite('---------- %i/%i features selected, %is elapsed ----------\n', size(fX, 2), size(X, 2), round(toc(timer)));
    operations = sortrows(operations, find(strcmp('Running_Loss', operations.Properties.VariableNames)), 'Ascend');
end
