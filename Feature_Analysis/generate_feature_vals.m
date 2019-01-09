function  feature_vals = generate_feature_vals(time_series_data, operations, master_operations, parallel)
    %time_series_data is a vector of time series data
    % operations and master_operations are hctsa style tables
    if isempty(master_operations)
        [operations, master_operations] = TS_LinkOperationsWithMasters(operations, SQL_add('mops', 'INP_mops.txt', 0, 0));
    end
    feature_vals = zeros(size(time_series_data, 1), height(operations));
    if parallel
        parfor i = 1:length(feature_vals)
            feature_vals(i, :) = TS_CalculateFeatureVector(time_series_data(i, :)', 0, operations, master_operations, [], 0);
        end
    else
        for i = 1:length(feature_vals)
            feature_vals(i, :) = TS_CalculateFeatureVector(time_series_data(i, :)', 0, operations, master_operations, [], 0);
        end
    end
end