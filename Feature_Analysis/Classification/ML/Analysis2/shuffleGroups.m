function data = shuffleGroups(data, labelsOrDatamat)
%SHUFFLEGROUPS Shuffle the class labels of a group'd time_series_data
% 1 to shuffle all columns of the datamat individually
    if nargin < 2 || isempty(labelsOrDatamat)
        labelsOrDatamat = 1;
    end
    rng('default')
    for i = 1:size(data, 1)
        
        if ~labelsOrDatamat
            Group_IDs = data(i, :).Group_ID;
            Group_IDs = Group_IDs(randperm(length(Group_IDs)));
            data(i, :).Group_ID = Group_IDs;
        else
            TS_DataMat = data(i, :).TS_DataMat;
            for f = 1:size(TS_DataMat, 2)
                TS_DataMat(:, f) = TS_DataMat(randperm(size(TS_DataMat, 1)), f);
            end
            data(i, :).TS_DataMat = TS_DataMat;
        end
    end
end

