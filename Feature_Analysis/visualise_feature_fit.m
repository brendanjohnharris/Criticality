function visualise_feature_fit(data, opids, num_per_feature)
    % Require three matrices; one for the feature value gradients, one for
    % the intercepts and one for their correlation
    tbl = get_combined_feature_stats(data, {'Absolute_Correlation', 'Feature_Value_Gradient', 'Feature_Value_Intercept'}, {}, [], 0);
    redo = 1;
    while redo 
        r = tbl{opids, contains(tbl.Properties.VariableNames, 'Correlation')}';
        m = tbl{opids, contains(tbl.Properties.VariableNames, 'Gradient')}';
        f0 = tbl{opids, contains(tbl.Properties.VariableNames, 'Intercept')}';
        %r = 1./r - 1;
        r = 0.1.*BF_NormalizeMatrix(r, 'maxmin');
        if nargin < 3 || isempty(num_per_feature)
            num_per_feature = size(f0, 1);
        end

        num_total = size(f0, 1);
        d = round(num_total./num_per_feature);

        feature_names = data(1).Operations.Name(opids);

        f = figure;
        hold on
        colours = get(gca, 'ColorOrder');
        for op = 1:length(opids)
            viscircles([m(1:d:end, op), f0(1:d:end, op)], r(1:d:end, op), 'Color', colours(mod(op, size(colours, 1)), :));
            h(op) = plot(NaN, NaN, '-', 'MarkerEdgeColor', colours(mod(op, size(colours, 1)), :));
        end
        %h(end+1) = plot(NaN, NaN, 'o', 'MarkerEdgeColor', 'k');
        %legend(h, [feature_names; '|r|'], 'Interpreter', 'None', 'FontSize', 12, 'Location', 'NorthOutside')
        axis equal
        xlimits = xlim;
        ylimits = ylim;
        plot([0 0], ylimits, 'k-', 'linewidth', 1); 
        plot(xlimits, [0 0], 'k-', 'linewidth', 1); 
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
        h = plot(NaN, NaN, 'ok');    
        legend(h, '$|r|$', 'Interpreter', 'LaTex', 'Fontsize', 18)
        redo = strcmp('y', input('Do you want to relabel (y/n)?\n', 's'));
    end
end

