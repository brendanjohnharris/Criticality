function group_by_noise(data, newfile)
% GROUP_BY_NOISE Groups time_series_data rows by their noise parameter
% value, assuming all other inputs (except for control parameter range) are
% constant. Should be run BEFORE find_correlation
    if nargin < 2 || isempty(newfile)
        newfile = 'grouped_time_series_data.mat';
    end
    if ischar(data)
        load(data)
    elseif isstruct(data)
        time_series_data = data;
        clear data
    end
    % Assume Operations are the same for each row
    all_etas = arrayfun(@(x) time_series_data(x).Inputs.eta, 1:size(time_series_data, 1));
    all_etas_unique = unique(all_etas);
    S.time_series_data = time_series_data(1, :); % Remember; assumes all non-eta-dependant fields are constant (Including fields of Inputs)!!!!!
    
    S.time_series_data.TS_DataMat = [];
    S.time_series_data = repmat(time_series_data(1, :), length(all_etas_unique), 1);
    for i = 1:length(all_etas_unique)
        fprintf('-----------------------------%g%% Complete-----------------------------\n', floor(100.*i./length(all_etas_unique)))
        eta = all_etas_unique(i);
        idxs = find(all_etas == eta);
        TS_DataMat = time_series_data(idxs(1)).TS_DataMat;
        cp_range = time_series_data(idxs(1)).Inputs.cp_range;
        for x = idxs(2:end)
            TS_DataMat = [TS_DataMat; time_series_data(x).TS_DataMat];
            cp_range = [cp_range, time_series_data(x).Inputs.cp_range];
        end
        [~, sort_idxs] = sort(cp_range);
        cp_range = cp_range(sort_idxs);
        TS_DataMat = TS_DataMat(sort_idxs, :); % Now sorted by increasing control parameter
        S.time_series_data(i).TS_DataMat = TS_DataMat;
        S.time_series_data(i).Inputs.cp_range = cp_range;
        S.time_series_data(i).Inputs.eta = eta;
    end
    S.nrows = size(S.time_series_data, 1);
    fprintf('-----------------------------Saving-----------------------------\n')
    save_size = whos('S');
    if save_size.bytes > 1024^3
        fprintf('------------------------The time series data is %g GiB in size. This may take some time------------------------\n', save_size.bytes./(1024.^3))
    end
    save(newfile, '-struct', 'S', '-v7.3')
end

