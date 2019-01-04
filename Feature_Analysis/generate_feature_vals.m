function  feature_val_vector = generate_feature_vals(time_series_data, operations, master_operations, parallel)
    %time_series_data is a vector of time series data
    %operations is a hctsa type table containing a single! operation
    % master_operations is a table as well
    if isempty(master_operations)
        [operations, master_operations] = TS_LinkOperationsWithMasters(operations, SQL_add('mops', 'INP_mops.txt', 0, 0));
    end
    feature_val_vector = zeros(size(time_series_data, 1), 1);
    if parallel
        parfor i = 1:length(feature_val_vector)
            feature_val_vector(i) = TS_CalculateFeatureVector(time_series_data(i, :)', 0, operations, master_operations, [], 0);
        end
    else
        for i = 1:length(feature_val_vector)
            [~, feature_val_vector(i)] = evalc("TS_CalculateFeatureVector(time_series_data(i, :)', 0, operations, master_operations, [], 0)");
        end
    end
end