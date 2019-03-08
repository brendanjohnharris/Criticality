function visualise_ST_LocalExtrema(cp_vals, noise_vals, l, how_long, system, standardise, tmax, overlap)
    % Please provide EITHER multiple cp_vals or noise_vals, not both (i.e
    % one must not be a vector)
    % Overlap should only be used when two time series are generated
    if nargin < 5 || isempty(system)
        system = 'supercritical_hopf_radius_(strogatz)';
    end
    if nargin < 6 || isempty(standardise)
        standardise = 1;
    end
    if nargin < 7 || isempty(tmax)
        tmax = 100;
    end
    if nargin < 8 || isempty(overlap)
        overlap = 0;
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
    if overlap
        hold on
        p1 = plot(time_series(1, :));
        
        plot(time_series(2, :));
        
        p1.Color(4) = 0.3;
        
        plot([partition_points(1:end-1)', partition_points(1:end-1)'], [ymin, ymax], '-w', 'LineWidth', 20)
        plot([partition_points(1:end-1)', partition_points(1:end-1)'], [ymin, ymax], '-k', 'LineWidth', 3)
        
        buffered1 = buffer(time_series(1, :), l);
        maxys1 = max(buffered1);
        minys1 = min(buffered1);
        maxxs1 = find(buffered1 == maxys1)';
        maxxs1 = maxxs1(:);
        minxs1 = find(buffered1 == minys1)';
        minxs1 = minxs1(:);
        plot(minxs1, minys1, 'ks', 'markerfacecolor', [0    0.4470    0.7410], 'markersize', 10)
        plot(maxxs1, maxys1, 'kd', 'markerfacecolor', [0    0.4470    0.7410], 'markersize', 10)
        quiver(minxs1', minys1, zeros(1, size(minxs1, 1)), maxys1-minys1, '--k', 'ShowArrowHead', 'off', 'Autoscale', 'off', 'LineWidth', 1.5)
        quiver(minxs1', maxys1, maxxs1' - minxs1', zeros(1, size(minxs1, 1)), '--k', 'ShowArrowHead', 'off', 'Autoscale', 'off', 'LineWidth', 1.5)
        
        
        buffered = buffer(time_series(2, :), l);
        maxys = max(buffered);
        minys = min(buffered);
        maxxs = find(buffered == maxys)';
        maxxs = maxxs(:);
        minxs = find(buffered == minys)';
        minxs = minxs(:);
        plot(minxs, minys, 'ks', 'markerfacecolor', [0.8500    0.3250    0.0980], 'markersize', 10)
        plot(maxxs, maxys, 'kd', 'markerfacecolor', [0.8500    0.3250    0.0980], 'markersize', 10)
        quiver(minxs', minys, zeros(1, size(minxs, 1)), maxys-minys, ':k', 'ShowArrowHead', 'off', 'Autoscale', 'off', 'LineWidth', 2)
        quiver(minxs', maxys, maxxs' - minxs', zeros(1, size(minxs, 1)), ':k', 'ShowArrowHead', 'off', 'Autoscale', 'off', 'LineWidth', 2)
       
        
        res1 = ST_LocalExtrema(time_series(1, :), 'l', l);
        res2 = ST_LocalExtrema(time_series(2, :), 'l', l);
        if length(cp_vals) == 1
                legend({['Noise: ', num2str(noise_vals(1)), ' | ', 'Feature Value: ', num2str(round(res1.diffmaxabsmin, 2))], ...
                    ['Noise: ', num2str(noise_vals(2)), ' | ', 'Feature Value: ', num2str(round(res2.diffmaxabsmin, 2))]});
            else
                legend({['Control Parameter: ', num2str(cp_vals(1)), ' | ', 'Feature Value: ', num2str(round(res1.diffmaxabsmin, 2))],...
                    ['Control Parameter: ', num2str(cp_vals(2)), ' | ', 'Feature Value: ', num2str(round(res2.diffmaxabsmin, 2))]});
        end
        if standardise
            ylabel('Standardised Radius', 'fontsize', 14, 'interpreter', 'tex')
        else
            ylabel('Radius', 'fontsize', 14, 'interpreter', 'tex')
        end
    else        
        for t = 1:numplots
            
            subplot(numplots, 1, t)
            hold on
            plot([partition_points(1:end-1)', partition_points(1:end-1)'], [ymin, ymax], '-w', 'LineWidth', 20)
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
            
            quiver(minxs', minys, zeros(1, size(minxs, 1)), maxys-minys, '--r', 'ShowArrowHead', 'off', 'Autoscale', 'off')
            quiver(minxs', maxys, maxxs' - minxs', zeros(1, size(minxs, 1)), '--r', 'ShowArrowHead', 'off', 'Autoscale', 'off')
            
            if standardise
                ylabel('Standardised Radius', 'fontsize', 14, 'interpreter', 'tex')
            else
                ylabel('Radius', 'fontsize', 14, 'interpreter', 'tex')
            end
            res = ST_LocalExtrema(time_series(t, :), 'l', l);
            if length(cp_vals) == 1
                title(['Noise: ', num2str(noise_vals(t)), ' | ', 'Feature Value: ', num2str(round(res.diffmaxabsmin, 2))], 'Fontsize', 12)
            else
                title(['Control Parameter: ', num2str(cp_vals(t)), ' | ', 'Feature Value: ', num2str(round(res.diffmaxabsmin, 2))], 'Fontsize', 12)
            end
        end
    end
    ttl = suptitle(strrep('ST_LocalExtrema: diffmaxabsmin', '_', ' '));
    ttl.Position = [0.52, -0.05, 0];
    set(gcf,'color','w');
    xlabel('t', 'fontsize', 14, 'interpreter', 'tex')
    set(gcf,'units','normalized','outerpos',[0 0 1 1]);
end

