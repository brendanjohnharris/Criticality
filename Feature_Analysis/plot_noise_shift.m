function yvals = plot_noise_shift(data, opid, direction)
    % 'directions' is either 0 (turning point is a global min.) or 1 
    % (turning point is a global max.). 
    if nargin < 3 || isempty(direction)
        plot_feature_vals(opid, data(1:round(length(data)/5):end), 'noise', 0);
        direction = input('Please review the feature values and decide if:\n\n 0: The turning point is a global min.\n 1: The turning point is a global max.\n\n');
        close(gcf)
    end
    xvals = cellfun(@(x) x.eta, {data.Parameters});
    yvals = zeros(1, length(xvals));
    for i = 1:length(yvals)
        if direction == 1
            [~, ind] = max(data(i).TS_DataMat(:, opid));
        elseif direction == 0
            [~, ind] = min(data(i).TS_DataMat(:, opid));
        end
        yvals(i) = data(i).Parameters.betarange(ind);
    end
    figure
    plot(xvals, yvals, 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
    xlabel('Eta')
    ylabel('Control parameter at turning point')
    set(gcf,'color','w');
    ops = data.Operations;
    opname = ops.Name{opid};
    title(sprintf('Feature value turning points for %s', opname), 'interpreter', 'none')
end