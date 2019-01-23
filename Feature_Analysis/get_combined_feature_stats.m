function tbl = get_combined_feature_stats(data, single_stats, combined_stats, directions)
    table_container = cell(1, size(data, 1));
    for i = 1:length(table_container)
        table_container{i} = get_feature_stats(data(i, :), single_stats, directions, []);
    end
    tbl = merge_tables(table_container, arrayfun(@(x) ['data', num2str(x), '_'], 1:size(data, 1), 'UniformOutput', false));
    
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
                
                case 'Feature_Val_Gradient' || 'Feature_Val_Intercept'
                    %asdasdadadsdas

                otherwise
                    warning([the_stat, ' is not a supported statistic, and will be ignored.\n%s'])
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
end

