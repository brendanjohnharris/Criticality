function [mdl, X, labels] = Ctrain(template, data, useGPU)
%CTRAIN 
% template is a template for fitcecoc
    if nargin < 3 || isempty(useGPU)
        useGPU = 0;
    end
    featurenames = [];
    if iscell(data) % You have the datamats and labels already
        X = data{1};
        labels = data{2};
        if length(data) > 2
            featurenames = data{3};
        end
    else % You give a time_series_data struct
        % Check that the data class labels are correct
        if length(unique(data(1, :).Group_ID)) ~= length(data(1, :).Group_Names)
            error('The number of unique group IDs does not match the number of Group_Names. Perhaps you are still using an old addGroupData?')
        end
        [X, labels] = reconstructDataMat(data);
        if checkConsistency(data, [0, 1, 1])
            featurenames = data(1, :).Operations.Name;
        end
    end
    [X, labels, subIDs] = ML_preprocess(X, labels, []);
    featurenames = featurenames(subIDs);
    if useGPU
        X = gpuArray(X);
    end
    mdl = fitcecoc(X, labels, 'Learners', template, 'ClassNames', categories(labels), 'PredictorNames', featurenames);
end
