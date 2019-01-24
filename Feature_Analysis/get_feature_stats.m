function tbl = get_feature_stats(data, what_stats, directions, optional_stats)
% data must be of height 1
% what_stats is a cell array containing the statistics to be added to
% the resulting table
% The order of what_stats determines the order of the table columns
% Custom statistics are entered as cell arrays with rows of the form {Statistic
% name, statistic form}
% Note that second element of the cell array shoudl be a character
% vector containing a set of operations that references only variables
% entered in 'what_stats'
%
% MAKE SURE DIRECTIONS IS SORTED IN OP ID ORDER!!!
    
%% Sort data by operation ID. It should be already, but it can't hurt
    data = sort_data(data);
    
%% Get feature identifiers
    Operation_ID = data.Operations.ID;
    Operation_Name = data.Operations.Name;
    Operation_Keywords = data.Operations.Keywords;
    tbl = table(Operation_ID, Operation_Name, Operation_Keywords);

%% Add optional statistics
    for the_stat = what_stats
        switch the_stat{1}
            case 'Correlation'
                the_stat_values = data.Correlation(:, 1);
            
            case 'Absolute_Correlation'
                the_stat_values = abs(data.Correlation(:, 1));
                
            case 'Peak_Shift'
                the_stat_values = zeros(length(Operation_ID), 1);
                for x = 1:length(the_stat_values)
                    the_stat_values(x) = get_noise_shift(data, data.Operations.ID(x), directions(x), 0);
                end
            
            case {'Feature_Value_Gradient', 'Feature_Value_Intercept'}
                % Gives the gradient of values up until 0
                idxs = (data.Inputs.cp_range >= data.Correlation_Range(1) & data.Inputs.cp_range <= data.Correlation_Range(2));
                x = data.Inputs.cp_range(idxs);
                y = data.TS_DataMat(idxs, :);
                r = data.Correlation(:, 1); % So the fit is for whatever values where used in correlation finding. Remember correlation is sorted by op id
                m = r.*(std(y)./std(x))';
                b = mean(y, 1)' - m.*mean(x);
                if strcmp(the_stat{1}, 'Feature_Value_Gradient')
                    the_stat_values = m;
                elseif strcmp(the_stat{1}, 'Feature_Value_Intercept')
                    the_stat_values = b;
                end
                
            otherwise
                warning([the_stat, ' is not a supported statistic, and will be ignored.\n%s'],...
                    'Either check its name is spelt correctly or enter it as a custom statistic')
        end
        tbl = [tbl, table(the_stat_values, 'VariableNames', the_stat)];
    end
    
%% Add custom statistics
    for ind = 1:size(optional_stats, 1)
        optional_stat_name = optional_stats{ind, 1};
        [~, optional_stat_values] = evalc(optional_stats{ind, 2});
        tbl = [tbl, table(optional_stat_values, 'VariableNames', optional_stat_name)];
    end
end

