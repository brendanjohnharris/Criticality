function [operations, lossmat] = FeatureWisePerformance(template, data, numReps, pTrain, doPar)%, shuffleLabels)
    timer = tic;
    if ischar(data)
        load(data)
        data = time_series_data;
    end
    if nargin < 3 || isempty(numReps)
        numReps = 20;
    end
    if nargin < 4 || isempty(pTrain)
        pTrain = 0.9;
    end
    if nargin < 5 || isempty(doPar)
        doPar = 0;
    end
    %if nargin < 6 || isempty(shuffleLabels)
    %    shuffleLabels = 0;
    %end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    
    operations = data(1, :).Operations;
    
    %% Load the data in matrix form
    [X, Y] = reconstructDataMat(data);
    [X, Y, outIds] = ML_preprocess(X, Y, pTrain, 1);
    [numObs, numFeatures] = size(X);

    lossmat = nan(numFeatures, numReps);
    pl = struct('NumWorkers', 0);
    if doPar
        pl = gcp;
    end
    %% Main procedure
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    %if shuffleLabels
    %   X = repmat(X(:, outIds == 1366), 1, size(X, 2));
    %end
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     if shuffleLabels
%         shuffleIdxs = randperm(size(X, 2));
%         X = X(:, shuffleIdxs);
%     end
    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    fprintf('---------- Beginning Calculation ----------\n');
    c = cvpartition(Y, 'HoldOut', 1-pTrain, 'Stratify', true);
    if doPar
%         parfor (rep = 1:numReps, pl.NumWorkers)
%             lossvec = nan(numFeatures, 1);
%             for f = 1:numFeatures
%                 % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                 if shuffleLabels
%                    rngstate = rng();
%                    rng('default') % So that this label shuffle is always the same
%                    sIdxs = randperm(length(Y), length(Y));
%                    Y = Y(sIdxs);
%                    rng(rngstate)
%                 end
%                 % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%                 fX = X(:, f);
%                 crep = repartition(c);
%                 trainIdxs = training(crep);
%                 testIdxs = test(crep);
%                 if var(fX) ~= 0 % Then training will likely throw an error, and if it doesn't, will be useless
%                     mdl = fitcecoc(fX(trainIdxs), Y(trainIdxs), 'Learners', template, 'ClassNames', categories(Y));
%                     lossvec(f) = loss(mdl, fX(testIdxs), Y(testIdxs));
%                 end
%             end
%             lossmat(:, rep) = lossvec;
%             fprintf('---------- Repetition %i performed, %i%% of features unusable, %is elapsed ----------\n', rep, round(mean(isnan(lossvec)), round(toc(timer))));
%         end
    else
        %repY = Y; %!!!!!!!!!!!!!!!!!
    	for rep = 1:numReps
            %Y = repY;
            lossvec = nan(numFeatures, 1);
            for f = 1:numFeatures
                fX = X(:, f);
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                %if shuffleLabels
                %   rngstate = rng();
                %   rng('default') % So that this label shuffle is always the same
                %   sIdxs = randperm(length(Y), length(Y));
                %   Y = Y(sIdxs);
                %   rng(rngstate)
                %end
                % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                crep = repartition(c);
                trainIdxs = training(crep);
                testIdxs = test(crep);
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
