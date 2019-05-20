function tbl = get_combined_feature_stats(data, single_stats, combined_stats, directions, new_table)
% GET_COMBINED_FEATURE_STATS Generate a table of feature value summary statistics using multiple datasets
%     Similarly to 'get_feature'stats', this function accepts some data in the 
%     form of a struct and returns a table of queried ssummary statistics. 
%     Unlike that function, however, this can be performed using data with 
%     multiple rows and can be used evaluate individual statistics on each row,
%     or statistics that require reference to other rows.
%     
%     Inputs-
%         
%         data:           A structure in the standard form, as produced by 'save_data'
%         
%         single_stats:   A cell array containing character vectors naming
%                         statistics to be applied to each row of data 
%                         individually; see 'get_feature_stats'. Can be left empty, 
%                         but some combined_stats require certain single_stats; see error lines in body
%                         
%         combined_stats: A cell array of the same form as single_stats, but 
%                         naming statistics relating to the data as a
%                         whole. See cases in body.
%         
%         directions:     A vector of feature directions (concavities); 
%                         -1 for downward pointing, +1 for upward pointing. 
%                         Only required for some statistics; see body.
%         
%         new_table:      A logical, specifying whether to return a table that
%                         does not include any single_stats (1); useful for removing single_stats 
%                         that are required by a combined_stat, but which are undesired.
%                   
%                         
%     Outputs-
%     
%         tbl:            A table of operation information and summary statistics
    
    table_container = cell(1, size(data, 1));
    for i = 1:length(table_container)
        table_container{i} = get_feature_stats(data(i, :), single_stats, directions, []);
    end
    original_tbl = merge_tables(table_container, arrayfun(@(x) ['data', num2str(x), '_'], 1:size(data, 1), 'UniformOutput', false));
    tbl = original_tbl;
    merged_table_size = size(tbl, 2);
    for the_stat = combined_stats
        try
            switch the_stat{1}
                case 'Correlation_Mean'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Correlation')&~contains(original_tbl.Properties.VariableNames, 'Absolute_Correlation');
                    the_stat_values = mean(original_tbl(:, what_columns));
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Correlation'", the_stat{1})
                    end
                    
                case 'Absolute_Correlation_Mean'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Absolute_Correlation');
                    the_stat_values = mean(original_tbl{:, what_columns}, 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Absolute_Correlation'", the_stat{1})
                    end
                    
                case 'Peak_Shift_Mean'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Peak_Shift');
                    the_stat_values = mean(original_tbl{:, what_columns}, 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Peak_Shift'", the_stat{1})
                    end
                                        
                case 'Feature_Value_Gradient_SD'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Gradient');
                    the_stat_values = std(original_tbl{:, what_columns},[], 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Feature_Value_Gradient'", the_stat{1})
                    end
                                        
                case 'Feature_Value_Intercept_SD'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = std(original_tbl{:, what_columns},[], 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Feature_Value_Intercept'", the_stat{1})
                    end
                
                case {'RMSE_Scaled_Feature_Value_Gradient', 'RMSE_Scaled_Feature_Value_Intercept'}
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = std(original_tbl{:, what_columns},[], 2);
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_RMSE');
                    mean_RMSE = mean(original_tbl{:, what_columns}, 2);
                    the_stat_values = the_stat_values./mean_RMSE;
                    
                case 'Relative_Feature_Value_Intercept_SD'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    the_stat_values = std(original_tbl{:, what_columns},[], 2);
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_RMSE');
                    mean_RMSE = mean(original_tbl{:, what_columns}, 2);
                    the_stat_values = the_stat_values./mean_RMSE;
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stats 'Feature_Value_Intercept' and 'Feature_Value_RMSE'", the_stat{1})
                    end
                                        
                case 'Feature_Value_Gradient_RMSE'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    y = num2cell(original_tbl{:, what_columns}, 2);
                    x = arrayfun(@(x) x.Inputs.eta, data)';
                    the_stat_values = sqrt(cell2mat(cellfun(@(y) immse(x, y), y, 'uniformoutput', 0)));
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Feature_Value_Intercept'", the_stat{1})
                    end
                                    
                case 'Aggregated_Absolute_Correlation'
                    if ~isempty(data(1).Correlation_Range)
                        idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2)); % Assumes all rows of data have the same cp_range and Correlation_Range
                    else
                        idxs = 1:length(data(1).Inputs.cp_range);
                    end
                    y = cell2mat(arrayfun(@(x) data(x, :).TS_DataMat(idxs, :), 1:size(data, 1), 'UniformOutput', 0)');
                    x = cell2mat(arrayfun(@(x) data(x, :).Inputs.cp_range(idxs), 1:size(data, 1), 'UniformOutput', 0))';
                    the_stat_values = abs(corr(y, x, 'Type', 'Pearson'));
                    
                case 'Aggregated_cp_RMSE'
                    if ~isempty(data(1).Correlation_Range)
                        idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2)); % Assumes all rows of data have the same cp_range and Correlation_Range
                    else
                        idxs = 1:length(data(1).Inputs.cp_range);
                    end
                    y = cell2mat(arrayfun(@(x) data(x, :).TS_DataMat(idxs, :), 1:size(data, 1), 'UniformOutput', 0)');
                    x = cell2mat(arrayfun(@(x) data(x, :).Inputs.cp_range(idxs), 1:size(data, 1), 'UniformOutput', 0))';
                    for opnum = 1:size(y, 2)
                        [p, ~, mu] = polyfit(y(:, opnum), x, 1);
                        xfit = polyval(p, y(:, opnum), [], mu);
                        the_stat_values(opnum) = std(x - xfit);
                    end
                                    
                case 'Feature_Value_Gradient_Absolute_Correlation'
                    what_columns = regexp(original_tbl.Properties.VariableNames, '.*\d+_Feature_Value_Gradient', 'match');
                    what_columns = cellfun(@(x) ~isempty(x), what_columns);
                    the_stat_values = abs(corr(arrayfun(@(x) x.Inputs.eta, data), original_tbl{:, what_columns}')');
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Feature_Value_Gradient'", the_stat{1})
                    end
                                    
                case 'Feature_Value_Intercept_Absolute_Correlation'
                    what_columns = regexp(original_tbl.Properties.VariableNames, '.*\d+_Feature_Value_Intercept');
                    what_columns = cellfun(@(x) ~isempty(x), what_columns);
                    the_stat_values = abs(corr(arrayfun(@(x) x.Inputs.eta, data), original_tbl{:, what_columns}')');                    
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat 'Feature_Value_Intercept'", the_stat{1})
                    end
                                    
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
                                    
                case 'Average_RMSE_Constant_Gradient'
                    % Get the linear fit of the intercepts
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    b = tbl{:, what_columns}';
                    noise = arrayfun(@(x) x.Inputs.eta, data);
                    m_b = corr(b, noise, 'Type', 'Pearson').*std(b, [], 1)'./std(noise);
                    b_b = mean(b, 1)' - m_b.*mean(noise);
                    % m_b and b_b have features down their rows
                    % Get the average gradient
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Gradient');
                    m = mean(tbl{:, what_columns}, 2); % Maybe use median instead of mean, for the features that spike dramatically near 0 noise?
                    % Calculate intercept estimates from intercept trend
                    b = m_b.*noise' + b_b;
                    RMSE = zeros(size(b));
                    % Only use control parameters that are in the
                    % correlation range: Assumes the correlation range is
                    % the same for all eta (might have to fix for
                    % subcritical)
                    idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2))';
                    % Calculate RMSE (of predicting CONTROL PARAMETER from
                    % FEATURE VALUES by PREDICTING THE FIT INTERCEPT and
                    % ASSUMING THE FIT GRADIENT IS CONSTANT
                    for n = 1:size(b, 2)
                        RMSE(:, n) = sqrt(sum((data(n).Inputs.cp_range(idxs) - ((data(n).TS_DataMat(idxs, :)' - b(:, n))./m)).^2, 2)./length(data(n).Inputs.cp_range(idxs)));
                    end
                    % Average these RMSE's for each feature (over the noise)
                    the_stat_values = mean(RMSE, 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stats 'Feature_Value_Intercept' and 'Feature_Value_Gradient'", the_stat{1})
                    end
                                        
                case 'Average_RMSE_Constant_Intercept'
                     % Get the linear fit of the gradients
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Gradient');
                    m = tbl{:, what_columns}';
                    noise = arrayfun(@(x) x.Inputs.eta, data);
                    m_m = corr(m, noise, 'Type', 'Pearson').*std(m, [], 1)'./std(noise);
                    b_m = mean(m, 1)' - m_m.*mean(noise);
                    % m_m (gradients of gradient) and b_m (intercepts of gradient) have features down their rows
                    % Get the average intercept
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Feature_Value_Intercept');
                    b = mean(tbl{:, what_columns}, 2); % Maybe use median instead of mean, for the features that spike dramatically near 0 noise?
                    % Calculate gradient estimates from intercept trend
                    m = m_m.*noise' + b_m;
                    RMSE = zeros(size(m));
                    % Only use control parameters that are in the
                    % correlation range: Assumes the correlation range is
                    % the same for all eta (might have to fix for
                    % subcritical)
                    idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2))';
                    % Calculate RMSE (of predicting CONTROL PARAMETER from
                    % FEATURE VALUES by PREDICTING THE FIT GRADIENT and
                    % ASSUMING THE FIT INTERCEPT IS CONSTANT
                    for n = 1:size(m, 2)
                        RMSE(:, n) = sqrt(sum((data(n).Inputs.cp_range(idxs) - ((data(n).TS_DataMat(idxs, :)' - b)./m(:, n))).^2, 2)./length(data(n).Inputs.cp_range(idxs)));
                    end
                    % Average these RMSE's for each feature (over the noise)
                    the_stat_values = mean(RMSE, 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stats 'Feature_Value_Intercept' and 'Feature_Value_Gradient'", the_stat{1})
                    end
                
                case 'Mean_Control_Parameter_RMSE'
                    what_columns = contains(original_tbl.Properties.VariableNames, 'Control_Parameter_RMSE');
                    the_stat_values = mean(tbl{:, what_columns}, 2);
                    if sum(what_columns) == 0
                        error("'%s' requires the single_stat'Control_Parameter_RMSE'", the_stat{1})
                    end
                 
                case 'Multiple_Linear_Regression_Coefficients'
                    the_stat_values = get_linear_model(data);
                
                case 'Multiple_Linear_Regression_RMSE'
                    [~, the_stat_values] = get_linear_model(data);
                
                case 'Multiple_Linear_Regression_Coefficients_Zero_Noise_Partial'
                    the_stat_values = get_linear_model(data, [], 0);
                
                case 'Multiple_Linear_Regression_RMSE_Zero_Noise_Partial'
                    [~, the_stat_values] = get_linear_model(data, [], 0);
                    
                    otherwisedit
                    error([the_stat{1}, ' is not a supported statistic'])
            end
        catch ME
            switch ME.identifier
                case 'MATLAB:sum:wrongInput'
                    error("The single_stats given do not include a valid statistic for the combined_stat '%s'", the_stat{1})
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

