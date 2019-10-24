function [f, ax] = plotFs2(data, template)
    % Keywords must conain the supergroup, and vary ONLY in the supergroup
    % (which is the branch)
    if ~checkConsistency(data, [0, 1, 1])
        error('The data is not consistent in operations')
    end
    f = figure('color', 'w');
    ax = gca;
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
    df = randperm(size(X, 1), 500);
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
        p = plot(clusterData{i}(:, 1), clusterData{i}(:, 2), markers{clusters(i, 2)},...
            'Color', cmp(clusters(i, 1), :), 'MarkerFaceColor', cmp(clusters(i, 1), :), 'MarkerSize', 5);
        p.HandleVisibility = 'off';
    end
    lgdcell = {};
    %% Dummy legend plots
    for i = unique(Groups)'
        plot(NaN, NaN, '-', 'Color', cmp(i, :), 'MarkerFaceColor', cmp(i, :), 'linewidth', 10)
        lgdcell{i} = GroupLabels{i};
    end
    for k = unique(superGroups)'
        i = i+1;
        plot(NaN, NaN, 'LineStyle', 'none', 'Color', 'k', 'Marker',  markers{k}, 'MarkerFaceColor', 'k')
        lgdcell{i} = superGroupLabels{k};
    end
    lgdcell = titlecase(lgdcell);
    legend(lgdcell, 'AutoUpdate', 'off')
    
    % Plot the discrimination curve
    plotDiscrimination2(mdl, 1)
    
    %% Select the points to plot as timeseries
    fprintf('Select a point and then a location to place the timeseries. CTRL-c to exit.\n')
    xh = abs(diff(xlim));
    yh = abs(diff(ylim));
    while true
        loc = [];
        while isempty(loc)
            fprintf('Select a point...\n')
            [xg, yg] = ginput(1);
            locdists = sum((X - [xg, yg]).^2, 2);
            [~, locidx] = min(locdists);
            loc = sl(locidx, :);
        end
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
        t = t(1:round(length(t)./20));
        fprintf('Select a location to place the timeseries...\n')
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
        plot(polyout, 'FaceColor', 'w', 'FaceAlpha', 1, 'EdgeColor', 'w');% 'EdgeColor', cmp(Groups(locidx), :), 'EdgeAlpha', 0.5, 'HoleEdgeColor', 'w', 'HoleEdgeAlpha', 0.75)
        plot(tx, t, 'color', cmp(Groups(locidx), :), 'LineWidth', 1.5)
        loc = [];
    end
    axis tight
end
