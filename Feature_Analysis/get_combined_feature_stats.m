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

