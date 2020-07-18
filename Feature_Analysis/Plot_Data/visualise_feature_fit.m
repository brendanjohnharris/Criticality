function visualise_feature_fit(data, opids, num_per_feature)
    % Require three matrices; one for the feature value gradients, one for
    % the intercepts and one for their correlation
    % Please use normalise_time_series_data on data before this function.
    tbl = get_combined_feature_stats(data, {'Absolute_Correlation', 'Feature_Value_Gradient', 'Feature_Value_Intercept'}, {}, [], 0);
    redo = 1;
    f = figure;

    while redo
        delete(f)
        outercircles = [];
        r = tbl{opids, contains(tbl.Properties.VariableNames, 'Correlation')}';
        ri = r;
        m = tbl{opids, contains(tbl.Properties.VariableNames, 'Gradient')}';
        f0 = tbl{opids, contains(tbl.Properties.VariableNames, 'Intercept')}';
        etarange = arrayfun(@(x) x.Inputs.eta, data);
        [~, normetarange] = sort(etarange);
        %r = 1./r - 1;
        %r = 0.05.*BF_NormalizeMatrix(r, 'maxmin');
        %r = 0.05.*rescale(r);
        if nargin < 3 || isempty(num_per_feature)
            num_per_feature = size(f0, 1);
        end

        num_total = size(f0, 1);
        d = round(num_total./num_per_feature);
        m = m(1:d:end, :);
        r = 0.05.*rescale(r(1:d:end, :));
        f0 = f0(1:d:end, :);
        cmp = inferno(size(m, 1));
        feature_names = data(1).Operations.Name(opids);

        f = figure;
        ax = gca;
%         ax.ColorOrder = [0 0.4470 0.7410;... %turbo(length(opids)+1)
%     0.8500    0.3250    0.0980;...
%     0.3718    0.7176    0.3612;...
%     0.9718    0.5553    0.7741;...
%     0.6400    0.6400    0.6400;...
%     0.6859    0.4035    0.2412;...
%     0.6365    0.3753    0.6753;...
%     0 0 0];
        corder = [GiveMeColors(length(opids)); {[0, 0, 0]}];
        corder{1, :} = [31 120 180]./256; % A better first colour
        ax.ColorOrder = vertcat(corder{:});
        hold on
        colours = get(gca, 'ColorOrder');
        g = [];
        for op = 1:length(opids)
            disp(feature_names{op}), disp(opids(op))
            viscircles([m(:, op), f0(:, op)], r(:, op), 'Color', colours(mod(op, size(colours, 1)), :), 'LineWidth', 10, 'EnhanceVisibility', 0);
            outercircles(op) = 2*(length(opids) - op + 1); % To keep track of where this object is in the stack. How many back from end of stack
            h(op) = plot(NaN, NaN, '-', 'Color', colours(mod(op, size(colours, 1)), :));
        end
        %h(end+1) = plot(NaN, NaN, 'o', 'MarkerEdgeColor', 'k');
        %legend(h, [feature_names; '|r|'], 'Interpreter', 'None', 'FontSize', 12, 'Location', 'NorthOutside')
        axis equal
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        legend(h, feature_names, 'Interpreter', 'None')
        xlabel('Gradient')
        ylabel('Intercept')
        ax.XLim = [-max(abs(ax.XLim)), max(abs(ax.XLim))];
        ax.YTick = 0:0.2:2;
        set(gcf,'color','w');
        % Need to find a way to label the groups of circles (maybe
        % interactive?)
        set(gca,'children',flipud(get(gca,'children')))
        set(gcf,'units','normalized','outerpos',[0 0 1 1]);
%         fprintf('Select where to place the feature names, until I can think of a better way:\n')
%         for op = 1:length(opids)
%             fprintf([feature_names{op}, ', see the legend for its colour\n'])
%             gtext(feature_names{op}, 'Interpreter', 'None')
%         end
         legend off
%         redo = strcmp('y', input('Do you want to relabel (y/n)?\n', 's'));
        redo = 0;
    end
    for op = 1:length(opids)
        disp(feature_names{op}), disp(opids(op))
        axStack = ax.Children;
        stackInd = length(axStack) - outercircles(op) + 1;
        set(gca,'Children',[axStack(stackInd); axStack(1:stackInd-1); axStack(stackInd+1:end)]) % Reorder the stack to put the relevant outer circle at the top
        for i = 1:size(m, 1)
            filledCircle([m(i, op), f0(i, op)], r(i, op), 100, cmp(normetarange(i), :));
        end
        %plot(m(:, op), f0(:, op), '-k')%, 'MarkerFaceColor', 'k')
    end
    for op = 1:length(opids)
    	lgdGroup(op) = plot(NaN, NaN, 'o', 'Color', colours(mod(op, size(colours, 1)), :),...
                'MarkerFaceColor', colours(mod(op, size(colours, 1)), :), 'MarkerSize', 12);
        lgdGroup(op).DisplayName = ['\fontname{Helvetica} ', strrep(feature_names{op}, '_', '\_')];
    end
    %lgdGroup = [plot(NaN, NaN, 'ok', 'MarkerSize', 15), lgdGroup];
    %lgdGroup(1).DisplayName = ['\fontname{Times}', sprintf('| r |: %.2g � %.2g', min(min(ri)), max(max(ri)))];
    lgd = legend(lgdGroup, 'Interpreter', 'Tex', 'Fontsize', 10, 'Location', 'NorthWest');
    lgd.Box = 'on';
    lgdT = title(lgd, 'Feature Name');
    axis equal
    c = colorbar;
    colormap(cmp)
    c.Label.String = '\eta';
    c.Label.Rotation = 0;
    c.Label.FontSize = 23;
    c.YTick = linspace(min(c.YTick), max(c.YTick), 5);
    c.Label.Position = [3, 0.55, 0];
    fprintf('Minimum radius has a correlation of %0.3g, maximum is %.3g\n', min(min(ri)), max(max(ri)))
end
