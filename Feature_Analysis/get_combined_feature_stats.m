function tbl = get_combined_feature_stats(data, single_stats, combined_stats, directions, new_table)
    table_container = cell(1, size(data, 1));
    for i = 1:length(table_container)
        table_container{i} = get_feature_stats(data(i, :), single_stats, directions, []);
    end
    tbl = merge_tables(table_container, arrayfun(@(x) ['data', num2str(x), '_'], 1:size(data, 1), 'UniformOutput', false));
    merged_table_size = size(tbl, 2);
    for the_stat = combined_stats
        try
            switch the_stat{1}
                case 'Correlation_Mean'
                    what_columns = contains(tbl.Properties.VariableNames, 'Correlation')&~contains(tbl.Properties.VariableNames, 'Absolute_Correlation');
                    the_stat_values = mean(tbl(:, what_columns));
                case 'Absolute_Correlation_Mean'
                    what_columns = contains(tbl.Properties.VariableNames, 'Absolute_Correlation');
                    the_stat_values = mean(tbl{:, what_columns}, 2);

                case 'Peak_Shift_Mean'
                    what_columns = contains(tbl.Properties.VariableNames, 'Peak_Shift');
                    the_stat_values = mean(tbl{:, what_columns}, 2);
                    
                case 'Feature_Value_Gradient_SD'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Gradient');
                    the_stat_values = std(tbl{:, what_columns},[], 2);
                    
                case 'Feature_Value_Intercept_SD'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = std(tbl{:, what_columns},[], 2);
                    
                case 'Relative_Feature_Value_Intercept_SD'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = std(tbl{:, what_columns},[], 2);
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_RMSE');
                    mean_RMSE = mean(tbl{:, what_columns}, 2);
                    the_stat_values = the_stat_values./mean_RMSE;
                    
                case 'Feature_Value_Gradient_RMSE'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    y = num2cell(tbl{:, what_columns}, 2);
                    x = arrayfun(@(x) x.Inputs.eta, data)';
                    the_stat_values = sqrt(cell2mat(cellfun(@(y) immse(x, y), y, 'uniformoutput', 0)));
                
                case 'Aggregated_Absolute_Correlation'
                    idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2)); % Assumes all rows of data have the same cp_range and Correlation_Range
                    y = cell2mat(arrayfun(@(x) data(x, :).TS_DataMat(idxs, :), 1:size(data, 1), 'UniformOutput', 0)');
                    x = cell2mat(arrayfun(@(x) data(x, :).Inputs.cp_range(idxs), 1:size(data, 1), 'UniformOutput', 0))';
                    the_stat_values = abs(corr(y, x, 'Type', 'Pearson'));
                
                case 'Feature_Value_Gradient_Absolute_Correlation'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Gradient');
                    the_stat_values = abs(corr(arrayfun(@(x) x.Inputs.eta, data), tbl{:, what_columns}')');
                
                case 'Feature_Value_Intercept_Absolute_Correlation'
                    what_columns = contains(tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = abs(corr(arrayfun(@(x) x.Inputs.eta, data), tbl{:, what_columns}')');                    
                
                case {'Normalised_Feature_Value_Gradient_SD', 'Normalised_Feature_Value_Intercept_SD'} % Should eventually integrate into find_correlation
                    % Gives the gradient of values up until 0
                    idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2))'; % Assume cp_range and correlation range are the same for all rows
                    x = data(1).Inputs.cp_range(idxs);
                    y = BF_NormalizeMatrix(cell2mat(arrayfun(@(x) x.TS_DataMat(idxs, :), data, 'uniformoutput', 0)), 'maxmin');
                    y = permute(reshape(y', size(y, 2), length(x), size(y, 1)/length(x)), [2 1 3]);
                    r = zeros(size(y, 3), size(y, 2));
                    for i = 1:size(y, 3)
                        r(i, :) = corr(x', y(:, :, i));
                    end
                    SDy = permute(std(y, 1), [3 2 1]);
                    SDx = std(x);
                    m = r.*(SDy./SDx);
                    b = permute(mean(y, 1), [3 2 1]) - m.*mean(x);
                    if strcmp(the_stat{1}, 'Normalised_Feature_Value_Gradient_SD')
                        the_stat_values = std(m, 1)';
                    elseif strcmp(the_stat{1}, 'Normalised_Feature_Value_Intercept_SD')
                        the_stat_values = std(b, 1)';
                    end                      

                otherwise
                    error([the_stat{1}, ' is not a supported statistic'])
            end
        catch ME
            switch ME.identifier
                case 'MATLAB:sum:wrongInput'
                    error('The single_stats given do not include a valid statistic for the combined_stat %s', the_stat{1})
                otherwise
                    rethrow(ME)
            end
        end
        tbl = [tbl, table(the_stat_values, 'VariableNames', the_stat)];
    end
    if new_table
        tbl = tbl(:, [1:3, merged_table_size+1:end]); %New table has only op information and combined stats
    end
end

