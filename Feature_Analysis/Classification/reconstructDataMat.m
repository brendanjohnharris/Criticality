function [DataMat, GroupLabels, StructLocation] = reconstructDataMat(data, groupLabels)
% StructLocation is a matrix, each row corresponds to a row of the output datamat, the
% first column correpsonds to a row of the input data struct and the second
% column to the row of the TS_DataMat in the row of the data struct.
    [~, consistency] = checkConsistency(data);
    if ~(consistency(2) && consistency(3))
        error('The data must be consistent in operations')
    end
    if nargin < 2 || isempty(groupLabels)
        if isfield(data, 'Group_Names')
            groupLabels = arrayfun(@(x) x.Group_Names, data, 'un', 0);
        else
            error('Please provide group labels, or add them to time_series_data')
        end
    end
    GroupIDs = arrayfun(@(x) x.Group_ID, data, 'uniform', 0);
    for i = 1:length(data)
        groupLabels{i} = {groupLabels{i}{GroupIDs{i}}}';
    end
    DataMat = arrayfun(@(x) x.TS_DataMat, data, 'un', 0);
    
    StructLocation = cell(size(DataMat));
    for r = 1:length(DataMat)
        mts = size(DataMat{r}, 1);
        StructLocation{r} = horzcat(repmat(r, mts, 1), (1:mts)');
    end
    DataMat = vertcat(DataMat{:});
    groupIDs = vertcat(GroupIDs{:});
    groupLabels = vertcat(groupLabels{:});
    StructLocation = vertcat(StructLocation{:});
    [groupLabels, ~, Group_IDs] = unique(groupLabels, 'stable');
    GroupLabels = categorical(Group_IDs, unique(Group_IDs, 'sorted'), groupLabels);
end

