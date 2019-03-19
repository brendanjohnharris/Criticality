function visualise_feature_fit(data, opids, num_per_feature)
    % Require three matrices; one for the feature value gradients, one for
    % the intercepts and one for their correlation
    tbl = get_combined_feature_stats(data, {'Absolute_Correlation', 'Feature_Value_Gradient', 'Feature_Value_Intercept'}, {}, [], 0);
    redo = 1;
    f = figure;
    while redo 
        delete(f)
        r = tbl{opids, contains(tbl.Properties.VariableNames, 'Correlation')}';
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
        cmp = parula(size(m, 1));
        feature_names = data(1).Operations.Name(opids);

        f = figure;
        hold on
        colours = get(gca, 'ColorOrder');
        g = [];
        for op = 1:length(opids)
            disp(feature_names{op}), disp(opids(op))
            viscircles([m(:, op), f0(:, op)], r(:, op), 'Color', colours(mod(op, size(colours, 1)), :));    
            h(op) = plot(NaN, NaN, '-', 'Color', colours(mod(op, size(colours, 1)), :));
        end
        %h(end+1) = plot(NaN, NaN, 'o', 'MarkerEdgeColor', 'k');
        %legend(h, [feature_names; '|r|'], 'Interpreter', 'None', 'FontSize', 12, 'Location', 'NorthOutside')
        axis equal
        ax = gca;
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
        legend(h, feature_names, 'Interpreter', 'None')
        xlabel('Feature Value Gradient')
        ylabel('Feature Value Intercept')
        set(gcf,'color','w');
        % Need to find a way to label the groups of circles (maybe
        % interactive?)
        set(gca,'children',flipud(get(gca,'children')))
        set(gcf,'units','normalized','outerpos',[0 0 1 1]);
        fprintf('Select where to place the feature names, until I can think of a better way:\n')
        for op = 1:length(opids)
            fprintf([feature_names{op}, ', see the legend for its colour\n'])
            gtext(feature_names{op}, 'Interpreter', 'None')
        end  
        legend off
        redo = strcmp('y', input('Do you want to relabel (y/n)?\n', 's'));
    end
    for op = 1:length(opids)
        disp(feature_names{op}), disp(opids(op))
        for i = 1:size(m, 1)
            filledCircle([m(i, op), f0(i, op)], r(i, op), 100, cmp(normetarange(i), :));
        end
        plot(m(:, op), f0(:, op), '-k')%, 'MarkerFaceColor', 'k')
    end
    h = plot(NaN, NaN, 'ok');    
    legend(h, '$|r|$', 'Interpreter', 'LaTex', 'Fontsize', 18)
    colormap(cmp)
    c = colorbar;
    c.Label.String = '\eta';
    c.Label.Rotation = 0;
    axis equal
    c.Label.FontSize = 23;
    c.Label.Position = [3, 0.5, 0];
end

