function [OpsRanked, history, inmodel] = Creducefeatures(template, data, opargs, doPar, useGPU)
%CREDUCEFEATURES 
% Given a template model and a data struct, reduce the features mdl
% using matlab's own feature selection function
%
% opargs is a cell array containing name-value arguments of sequentialfs
    if nargin < 3 || isempty(opargs)
        opargs = {};
    end
    if nargin < 4 || isempty(doPar)
        doPar = 0;
    end
    if nargin < 5 || isempty(useGPU)
        useGPU = 0;
    end
    % Check the operations are consistent for traindata and testdata
    if ~checkConsistency(data, [0 1 1])
        error('The data must be consistent in operations')
    end
    % Then can just take the operations from the data
    operations = data.Operations;
    
    [X, Y] = reconstructDataMat(data);
    [X, Y] = ML_preprocess(X, Y, []);
%     if useGPU
%         X = gpuArray(X);
% %         Xte = gpuArray(Xte);
% %         Yte = gpuArray(Yte);
%     end
    
    % The criterion will be the loss of the model when tested on testdata
    [inmodel, history] = sequentialfs(@fun, X, Y, 'Options', statset('Display', 'iter', 'UseParallel', doPar));
    
    rankedIdxs = [find(history.In(1, :)); arrayfun(@(x) find(xor(history.In(x-1, :), history.In(x, :))), 2:size(history.In, 1))'];
    OpsRanked = operations(rankedIdxs, :);
    OpsRanked.Running_Criteria = history.Crit';
    
    function res = fun(Xtr, Ytr, Xte, Yte)
        mdl = Ctrain(template, {Xtr, Ytr}, useGPU);
        res = loss(mdl, Xte, Yte);
    end

end

