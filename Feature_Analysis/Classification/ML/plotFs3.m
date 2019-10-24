function [f, ax] = plotFs3(data, template, numLobes, skipTimeseries)
    % Keywords must conain the supergroup, and vary ONLY in the supergroup
    % (which is the branch)
    if nargin < 4 || isempty(skipTimeseries)
        skipTimeseries = 0;
    end
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    f = figure('color', 'w');
    ax = subplot(1, 2, 1);
    ax2 = subplot(1, 2, 2);
    ax.Position = [0.1300 0.1100 0.7750 0.8150]; % The default;
    ax2.Position = ax.Position;
    ax2.Visible = 'off'; % ax2 is the foremost axes for plotting annotations
    ax2.Toolbar.Visible = 'off';
    axes(ax)
    hold on
    markers = {'o', 'x', 's', 'd', '+', '*', '^', 'v', '<', '>'};
    cmp = [ 0.3020    0.6863    0.2902;
            0.8941    0.1020    0.1098;
            0.2157    0.4941    0.7216;
            0.5961    0.3059    0.6392;
            1.0000    0.4980         0;
            1.0000    1.0000    0.2000;
            0.6510    0.3373    0.1569;
            0.9686    0.5059    0.7490;
            0.6000    0.6000    0.6000
            0         0         0      ];
    
    %[~, , sl] = reconstructDataMat(data);
    %% Train the model
    [mdl, X, Y, sl] = Ctrain(template, data, 0);
    GroupLabels = categories(Y);
    Groups = grp2idx(Y);
    [superGroupLabels, ~, superGroups] = unique({data.Keywords});
    for i = 1:length(superGroupLabels)
        superGroupLabels(i) = strrep(cellsqueeze(regexp(strsplit(superGroupLabels{i}, ','), '.*branch', 'match')), '_', ' ');
    end
    superGroups = arrayfun(@(x) superGroups(x), sl(:, 1));
    clusters = [];
    %% Get the points for each group
    for a = unique(Groups)'
        for b = unique(superGroups)'
            clusters = [clusters; [a, b]];
        end
    end
    clusterData = cell(size(clusters, 1), 1);
    
    
    %% Dilute everything
    df = randperm(size(X, 1), 1000);
    X = X(df, :);
    Y = Y(df, :);
    Groups = Groups(df, :);
    superGroups = superGroups(df, :);
    sl = sl(df, :);
    
    
    for idx = 1:length(clusterData)
        clusterData{idx} = X(Groups == clusters(idx, 1) & superGroups == clusters(idx, 2), :);
    end
    %% Plot the groups
    for i = 1:length(clusterData)
        p = plot3(clusterData{i}(:, 1), clusterData{i}(:, 2), clusterData{i}(:, 3), markers{clusters(i, 2)},...
            'Color', cmp(clusters(i, 1), :), 'MarkerFaceColor', cmp(clusters(i, 1), :), 'MarkerSize', 5);
        p.HandleVisibility = 'off';
    end
    lgdcell = {};
    %% Dummy legend plots
    for i = unique(Groups)'
        plot3(NaN, NaN, NaN, '-', 'Color', cmp(i, :), 'MarkerFaceColor', cmp(i, :), 'linewidth', 10)
        lgdcell{i} = GroupLabels{i};
    end
    for k = unique(superGroups)'
        i = i+1;
        plot3(NaN, NaN, NaN, 'LineStyle', 'none', 'Color', 'k', 'Marker',  markers{k}, 'MarkerFaceColor', 'k')
        lgdcell{i} = superGroupLabels{k};
    end
    lgdcell = titlecase(lgdcell);
    legend(lgdcell, 'AutoUpdate', 'off')
    
    % Plot the discrimination curve
    pp = plotDiscrimination3(mdl, 300, numLobes, 1);
    for i = 1:length(pp)
        pp(i).PickableParts = 'none';
    end
    fprintf('Rotate the figure to the desired position and then [Enter]:\n')
    pause
    ax.Toolbar.Visible = 'off';
    %% Select the points to plot as timeseries
    fprintf('Select a point and then a location to place the timeseries. CTRL-c to exit.\n')
    
    hold on
    ax2.Visible = 'off';
    set(ax, 'XLimMode', 'manual' )
    set(ax, 'YLimMode', 'manual' )
    set(ax, 'ZLimMode', 'manual' )
    set(ax2, 'XLimMode', 'manual' )
    set(ax2, 'YLimMode', 'manual' )
    xli = ax2.XLim; % Having these constant in most important
    yli = ax2.YLim;
    hold all
    while true && ~skipTimeseries
        loc = [];
        ax.PickableParts = 'visible';
        while isempty(loc)
            fprintf('Select a point then press [Enter]...\n')
            d = datacursormode;
            pause
            XG = getfield(getCursorInfo(d),'Position');
            locdists = sum((X - XG).^2, 2);
            [~, locidx] = min(locdists);
            loc = sl(locidx, :);
        end
        axes(ax2)
        hold(ax2, 'on')
        % Switch to the timeseries axes
        xh = abs(diff(xlim));
        yh = abs(diff(ylim));
        % Now regenerate the timeseries. These will NOT be identical to the
        % originals, but have the same parameters.
        inputs = data(loc(1), :).Inputs;
        inputs.cp_range = inputs.cp_range(loc(2)); % Since the cp_range matches the TS_DataMat rows
        if length(inputs.initial_conditions) > 1
            inputs.initial_conditions = inputs.initial_conditions(loc(2));
        end
        inputs.etarange = inputs.eta;
        inputs.save_cp_split = [];
        inputs.foldername = [];
        t = time_series_generator('input_struct', inputs);
        t = t(1:round(length(t)./15));
        delete(findall(gcf,'Type','hggroup'))
        fprintf('Select a location to place the timeseries...\n')
        axes(ax2)
        ax.PickableParts = 'none';
        [xg, yg] = ginput(1);
        % Want the time series to be, say, 7% the height of the axis?
        th = abs(diff(minmax(t)));
        % So scale t by yh./th
        t = t - mean(minmax(t));
        t = 2.*t.*0.05.*yh./th;
        % Then plot at the specified point. Use a length that is twice the
        % height
        tx = linspace(xg - 0.1.*yh, xg + 0.1.*yh, length(t));
        t = t + yg;
        polyout = polybuffer([tx', t'], 'lines', 0.01);
        plot(ax2, polyout, 'FaceColor', 'w', 'FaceAlpha', 1, 'EdgeColor', 'w');% 'EdgeColor', cmp(Groups(locidx), :), 'EdgeAlpha', 0.5, 'HoleEdgeColor', 'w', 'HoleEdgeAlpha', 0.75)
        plot(ax2, tx, t, 'color', cmp(Groups(locidx), :), 'LineWidth', 1)
        ax2.XLim = xli; ax2.YLim = yli; % Just in case
        ax2.Visible = 'off';
    end
end
