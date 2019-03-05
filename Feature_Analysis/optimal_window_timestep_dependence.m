function [dts, optimal_windows, savelengths_or_tmaxs, aggregated_correlations] = optimal_window_timestep_dependence(data, varying_parameter)
    % Only time series data in a specific format will work; !!!!!!!!!!only varying in
    % save_length/tmax, cp and eta !!!!!!!!!!!!
    % Currently only valid for ST_LocalExtreman[p]_diffmaxabsmin
    if strcmp(varying_parameter, 'savelength')
        savelengths = unique(arrayfun(@(x) x.Inputs.savelength, data));
        optimal_windows = zeros(size(savelengths));
        dts = optimal_windows;
        aggregated_correlations = zeros(size(data, 1)./length(savelengths), length(dts));
    elseif strcmp(varying_parameter, 'tmax')
       	tmaxs = unique(arrayfun(@(x) x.Inputs.tmax, data));
        optimal_windows = zeros(size(tmaxs));
        dts = optimal_windows;
        aggregated_correlations = zeros(size(data, 1)./length(tmaxs), length(dts));        
    end
            
    for i = 1:length(optimal_windows)
        % Find the optimal window length
        if strcmp(varying_parameter, 'savelength')
            subdata = data(arrayfun(@(x) x.Inputs.savelength == savelengths(i), data), :);
        elseif strcmp(varying_parameter, 'tmax')
            subdata = data(arrayfun(@(x) x.Inputs.tmax == tmaxs(i), data), :);
        end

            aggregated_correlation_table = get_combined_feature_stats(subdata, {}, {'Aggregated_Absolute_Correlation'}, [], 1);

            aggregated_correlation_table = sortrows(aggregated_correlation_table, 1, 'descend', 'MissingPlacement', 'last'); % Sort on opid
            aggregated_correlations(:, i) = aggregated_correlation_table.Aggregated_Absolute_Correlation;

            % Sort on correlation
            aggregated_correlation_table = sortrows(aggregated_correlation_table, size(aggregated_correlation_table, 2), 'descend', 'MissingPlacement', 'last');
            top_op = aggregated_correlation_table(2, :).Operation_Name; 
            top_op_parameter = extractBetween(top_op, 'ST_LocalExtrema_n', '_diffmaxabsmin');
            if isempty(top_op_parameter)
                error('Something is wrong. Most likely is that you are using the wrong operation')
            end
            top_op_parameter = str2num(top_op_parameter{1});
            % Below, as in ST_LocalExtrema
            if strcmp(varying_parameter, 'savelength')
                window_length = floor(savelengths(i)/top_op_parameter);
                %buffer_length = savelengths(i) - mod(savelengths(i), window_length);

                % Get the the timestep between each saved point
                save_dt = get_time_parameters(data(1).Inputs.tmax, data(1).Inputs.numpoints, savelengths(i), data(1).Inputs.transient_cutoff); % !!!MUST HAVE ALL OF THESE EXCEPT FOR SAVELENGTHS THE SAME!!!

                % Calculate simulation time used in the windows
                window_time = (window_length).*save_dt;
            else
                window_length = floor(data(1).Inputs.savelength/top_op_parameter); % Assume all savelengths are the same
                % Get the the timestep between each saved point
                save_dt = get_time_parameters(tmaxs(i), data(1).Inputs.numpoints, data(1).Inputs.savelength, data(1).Inputs.transient_cutoff); % !!!MUST HAVE ALL OF THESE EXCEPT FOR TMAX THE SAME!!!
                % Calculate simulation time used in the windows
                window_time = (window_length).*save_dt;
            end

            optimal_windows(i) = window_time;
            dts(i) = save_dt;
    end   
    if strcmp(varying_parameter, 'savelength')
        savelengths_or_tmaxs = savelengths;
    elseif strcmp(varying_parameter, 'tmax')
        savelengths_or_tmaxs = tmaxs;
    end
end

