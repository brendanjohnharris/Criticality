function yvals = get_noise_shift(data, opind, direction, plots)
    % 'directions' is either 0 (turning point is a global min.) or 1 
    % (turning point is a global max.). 
    if nargin < 3 || isempty(direction)
        %plot_feature_vals(opid, data(1:round(length(data)/5):end), 'noise', 0);
        %direction = input('Please review the feature values and decide if:\n\n 0: The turning point is a global min.\n 1: The turning point is a global max.\n\n');
        %close(gcf)
        directions = zeros(1, length(data));
        for ind = 1:length(data)
            fit = polyfit(data(ind).Inputs.cp_range, data(ind).TS_DataMat(:, opind)', 2);
            directions(ind) = -sign(fit(1));
        end
        direction = sign(nanmean(directions)); % Not always entirely accurate
        if direction == 0 || isnan(direction)
            warning(['The direction for operation ', num2str(opind), ' could not be concluded, and has been set as 1'])
            direction = 1;
        end
    end
    if nargin < 4 || isempty(plots)
        plots = 0;
    end
    xvals = cellfun(@(x) x.eta, {data.Inputs});
    yvals = zeros(1, length(xvals));
    for i = 1:length(yvals)
        if direction == 1
            [~, ind2] = max(data(i).TS_DataMat(:, opind));
        elseif direction == -1
            [~, ind2] = min(data(i).TS_DataMat(:, opind));
        end
        yvals(i) = data(i).Inputs.cp_range(ind2);
    end
    if plots
        figure
        plots(xvals, yvals, 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
        xlabel('Eta')
        ylabel('Control parameter at turning point')
        set(gcf,'color','w');
        ops = data.Operations;
        opname = ops.Name{opind};
        title(sprintf('Feature value turning points for %s', opname), 'interpreter', 'none')
    end
end