function [sampling_periods, window_lengths, aggregated_correlations, optimal_window_lengths] = optimal_window_timestep_dependence(data, makeplot, logx, cutoff)
    % Only time series data in a specific format will work; !!!!!!!!!!only varying in
    % T, cp and eta !!!!!!!!!!!!
    % Currently only valid for ST_LocalExtreman_n[p]_diffmaxabsmin
    % Should give a more precise description of the format. Only vary in T,
    % for now. b

    %savelengths = arrayfun(@(x) x.Inputs.savelength, data);

    if nargin < 2 || isempty(makeplot)
        makeplot = 0;
    end
    if nargin < 3 || isempty(logx)
        logx = 1;
    end
    if nargin < 4
        cutoff = [];
    end
    f = figure;
    sampling_periods = unique(arrayfun(@(x) x.Inputs.sampling_period, data));

    Ts = arrayfun(@(x) x.Inputs.T, data);
    if ~all(Ts == Ts(1))
        error('All lengths, in seconds (T), of the saved time series should be the same')
    end
    window_counts = extractBetween(data(1, :).Operations.Name, 'ST_LocalExtrema_n', '_diffmaxabsmin'); % ASSUME ALL OPERATIONS FIELDS ARE THE SAME!!!
    window_lengths = (Ts(1)./cellfun(@(x) str2double(x), window_counts));

    aggregated_correlations = zeros(length(window_lengths), length(sampling_periods));


    for i = 1:length(sampling_periods)
        subdata = data(arrayfun(@(x) x.Inputs.sampling_period == sampling_periods(i), data), :);
        aggregated_correlation_table = get_combined_feature_stats(subdata, {}, {'Aggregated_Absolute_Correlation'}, [], 1);
        aggregated_correlation_table = sortrows(aggregated_correlation_table, 1, 'ascend', 'MissingPlacement', 'last'); % Sort on opid
        aggregated_correlations(:, i) = aggregated_correlation_table.Aggregated_Absolute_Correlation;
    end

    [~, optimal_windows] = max(aggregated_correlations, [], 1);
    optimal_window_lengths = window_lengths(optimal_windows);

    %if ~isempty(cutoff)
    %    aggregated_correlations(aggregated_correlations < cutoff) = cutoff;
    %end
    if logx
        X = log10(sampling_periods);
    else
        X = sampling_periods;
    end
    if makeplot == 1
        p = pcolor(X, window_lengths, aggregated_correlations);
        p.EdgeColor = 'none';
        shading interp
        cmp = turbo(1000);
        colormap(cmp)
        ylim([0, 250])
        ylabel('Window Length (s)', 'fontsize', 14)

    elseif makeplot == 2
        cmp = turbo(1000);
        colormap(cmp)
        col = arrayfun(@(x) max(aggregated_correlations(:, x)), 1:length(sampling_periods))';
        scatter(X, optimal_window_lengths, 50, col, 'filled')
        ylabel('Optimal Window Length (s)', 'fontsize', 14)
    end
    if logx
        xlabel('$\log_{10}(\Delta t)$', 'Interpreter', 'LaTeX', 'fontsize', 14)
    else
        xlabel('$\Delta t$', 'Interpreter', 'LaTeX', 'fontsize', 14)
    end
    title('ST_LocalExtrema_diffmaxabsmin Aggregated Correlation', 'Interpreter', 'none', 'fontsize', 14)
    colorbar
    c = colorbar;
    c.Label.Position = [3, 0.5, 0];
    c.Label.String = '|\rho|';
    c.Label.Rotation = 0;
    c.Label.FontSize = 23;
    caxis([0, 1])
    set(gcf,'color','w');
    if ~isempty(cutoff)
        caxis([cutoff, 1])
        c.TickLabels{1} = ['<', num2str(cutoff)];
        c.Label.Position(2) = mean([cutoff, 1]);
    end
end




%     if strcmp(varying_parameter, 'savelength')
%         savelengths = unique(arrayfun(@(x) x.Inputs.savelength, data));
%         optimal_window_lengths = zeros(size(savelengths));
%         sampling_periods = optimal_window_lengths;
%         aggregated_correlations = zeros(size(data, 1)./length(savelengths), length(sampling_periods));
%     elseif strcmp(varying_parameter, 'T')
%        	tmaxs = unique(arrayfun(@(x) x.Inputs.tmax, data));
%         optimal_window_lengths = zeros(size(tmaxs));
%         sampling_periods = optimal_window_lengths;
%         aggregated_correlations = zeros(size(data, 1)./length(tmaxs), length(sampling_periods));
%     end
%
%     for i = 1:length(optimal_window_lengths)
%         if only_optimal
%             % Find the optimal window length
%             if strcmp(varying_parameter, 'savelength')
%                 subdata = data(arrayfun(@(x) x.Inputs.savelength == savelengths(i), data), :);
%             elseif strcmp(varying_parameter, 'T')
%                 subdata = data(arrayfun(@(x) x.Inputs.tmax == tmaxs(i), data), :);
%             end
%
%             aggregated_correlation_table = get_combined_feature_stats(subdata, {}, {'Aggregated_Absolute_Correlation'}, [], 1);
%
%             aggregated_correlation_table = sortrows(aggregated_correlation_table, 1, 'descend', 'MissingPlacement', 'last'); % Sort on opid
%             aggregated_correlations(:, i) = aggregated_correlation_table.Aggregated_Absolute_Correlation;
%
%             % Sort on correlation
%             aggregated_correlation_table = sortrows(aggregated_correlation_table, size(aggregated_correlation_table, 2), 'descend', 'MissingPlacement', 'last');
%             top_op = aggregated_correlation_table(2, :).Operation_Name;
%             top_op_parameter = extractBetween(top_op, 'ST_LocalExtrema_n', '_diffmaxabsmin');
%             if isempty(top_op_parameter)
%                 error('Something is wrong. Most likely is that you are using the wrong operation')
%             end
%             top_op_parameter = str2num(top_op_parameter{1});
%             % Below, as in ST_LocalExtrema
%             if strcmp(varying_parameter, 'savelength')
%                 window_length = floor(savelengths(i)/top_op_parameter);
%                 %buffer_length = savelengths(i) - mod(savelengths(i), window_length);
%
%
%                 % Calculate simulation time used in the windows
%                 window_time = (window_length).*save_dt;
%             else
%                 window_length = floor(data(1).Inputs.savelength/top_op_parameter); % Assume all savelengths are the same
%                 % Get the the timestep between each saved point
%                 save_dt = get_time_parameters(tmaxs(i), data(1).Inputs.numpoints, data(1).Inputs.savelength, data(1).Inputs.transient_cutoff); % !!!MUST HAVE ALL OF THESE EXCEPT FOR TMAX THE SAME!!!
%                 % Calculate simulation time used in the windows
%                 window_time = (window_length).*save_dt;
%             end
%
%             optimal_window_lengths(i) = window_time;
%         end
%     end
%     if strcmp(varying_parameter, 'savelength')
%         savelengths_or_tmaxs = savelengths;
%     elseif strcmp(varying_parameter, 'tmax')
%         savelengths_or_tmaxs = tmaxs;
%     end
% end
%
