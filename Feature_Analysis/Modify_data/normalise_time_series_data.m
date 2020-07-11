function data = normalise_time_series_data(data, what_range, normMethod)
%NORMALISE_TIME_SERIES_DATA Normalise the TS_Datamat contained in
%time_series_data (using aggregated feature values)
    if nargin < 2
        what_range = [];
    end
    if nargin < 3
        normMethod = 'maxmin';
    end
    % Get the unstacking indices
    unstack_inds = {};
    therange = {};
    for i = 1:size(data, 1)
        where_start = size(unstack_inds, 1);
        unstack_inds{i, 1} = zeros(size(data(i).TS_DataMat, 1), 1) + i;
        if ~isempty(what_range)
            therange{end+1} = (data(i).Inputs.cp_range >= what_range(1) & data(i).Inputs.cp_range <= what_range(2))';
        end
    end
    
    % Get the stacked TS_DataMat
    stacked_mat = cell(size(data, 1), 1);
    for y = 1:size(data, 1)
        stacked_mat{y} = data(y).TS_DataMat(therange{y}, :);
        subunstack = unstack_inds{y};
        unstack_inds{y} = subunstack(therange{y}, :);
        data(y).Inputs.cp_range = data(y).Inputs.cp_range(therange{y}');
    end
    stacked_mat = cell2mat(stacked_mat);
    unstack_inds = cell2mat(unstack_inds);
    stacked_mat(isnan(stacked_mat)) = 0; % if nan, set to 0
    stacked_mat = BF_NormalizeMatrix(stacked_mat, normMethod);
    for x = 1:size(data, 1)
        data(x, :).TS_DataMat = stacked_mat(unstack_inds == x, :);
    end
end

