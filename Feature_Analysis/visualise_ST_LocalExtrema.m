function visualise_ST_LocalExtrema(cp_vals, noise_vals, l, how_long, system, standardise, tmax)
    % Please provide EITHER multiple cp_vals or noise_vals, not both (i.e
    % one must not be a vector)
    if nargin < 5 || isempty(system)
        system = 'supercritical_hopf_radius_(strogatz)';
    end
    if nargin < 6 || isempty(standardise)
        standardise = 1;
    end
    if nargin < 7 || isempty(tmax)
        tmax = 100;
    end
    time_series = time_series_generator('cp_range', cp_vals, 'etarange', noise_vals, 'system_type', system, 'savelength', how_long, 'tmax', tmax); 
    if standardise
        time_series = zscore(time_series, 0, 2);
    end
    if length(cp_vals) == 1
        numplots = length(noise_vals);
    else
        numplots = length(cp_vals);
    end
    partition_points = l:l:size(time_series, 2);
    figure
    ymax = max(max(time_series)) + 0.1.*abs(max(max(time_series)));
    ymin = min(min(time_series)) - 0.1.*abs(min(min(time_series)));
    for t = 1:numplots
        subplot(numplots, 1, t)
        hold on
        plot([partition_points(1:end-1)', partition_points(1:end-1)'], [ymin, ymax], '--k')
        plot(time_series(t, :))
        % Find extrema, using the same method as ST_LocalExtrema
        buffered = buffer(time_series(t, :), l);
        maxys = max(buffered);
        minys = min(buffered);
        maxxs = find(buffered == maxys)';
        maxxs = maxxs(:);
        minxs = find(buffered == minys)';
        minxs = minxs(:);
        plot(minxs, minys, 'ks', 'markerfacecolor', 'k', 'markersize', 10)
        plot(maxxs, maxys, 'kd', 'markerfacecolor', 'k', 'markersize', 10)
        ylabel('r', 'fontsize', 14, 'interpreter', 'tex')
        res = ST_LocalExtrema(time_series(t, :), 'l', l);
        if length(cp_vals) == 1
            title(['Noise: ', num2str(noise_vals(t)), ' | ', 'Feature Value: ', num2str(round(res.diffmaxabsmin, 2))], 'Fontsize', 12)
        else
            title(['Control Parameter: ', num2str(cp_vals(t)), ' | ', 'Feature Value: ', num2str(round(res.diffmaxabsmin, 2))], 'Fontsize', 12)
        end
    end
    ttl = suptitle(strrep('ST_LocalExtrema: diffmaxabsmin', '_', ' '));
    ttl.Position = [0.52, -0.05, 0];
    set(gcf,'color','w');
    xlabel('t', 'fontsize', 14, 'interpreter', 'tex')
    set(gcf,'units','normalized','outerpos',[0 0 1 1]);
end

