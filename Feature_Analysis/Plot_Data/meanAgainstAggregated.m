function f = meanAgainstAggregated(data, emph)
%MEANAGAINSTAGGREGATED Plot the mean correlation of all features in a data
%set against their aggregated correlations
    if nargin < 2 || isempty(emph)
        emph = 0;
    end
    figure('color', 'w')
    if istable(data)
        tbl = data;
    else
        tbl = get_combined_feature_stats(data, {'Absolute_Correlation'},...
            {'Absolute_Correlation_Mean', 'Aggregated_Absolute_Correlation'}, [], 1);
    end
    if ~emph
        gS = 1;
    else
        gS = 0.6;
    end
    x = tbl.Absolute_Correlation_Mean;
    y = tbl.Aggregated_Absolute_Correlation;
    s = scatter(x, y, 0.6, 'k');
    s.MarkerFaceColor = repmat(gS, 1, 3);
    s.MarkerEdgeColor = s.MarkerFaceColor;
    %s.MarkerFaceAlpha = gS;
    %s.MarkerEdgeAlpha = gS;
    xlabel('$\langle \abs{\rho_{\mu}} \rangle_{\eta}$', 'FontSize', 18, 'Interpreter', 'LaTeX')
    ylabel('$|\rho_{\mu}^{\mathrm{agg}}|$', 'FontSize', 18, 'Interpreter', 'LaTeX')
    hold on
    if emph
        % Emphasise the salient features
        idxs = [19, 93, 1763, 3332, 3535, 6275]; %[19, 93, 1711, 3349, 3535, 6275];
        offsetX = [-0.02 0.03 0 0 0 0];
        offsetY = [0.005, -0.065, 0.07, 0.035, -0.075, -0.035]';
        colors = GiveMeColors(length(idxs));
        colors{1, :} = [31 120 180]./256; % A better first colour
        for i = 1:length(idxs)
            idx = (tbl.Operation_ID == idxs(i));
            text(x(idx)+offsetX(i), y(idx)+offsetY(i), tbl.Operation_Name(idx), 'interpreter',...
                'none', 'HorizontalAlignment', 'right', 'Color', colors{i}.*0.85, 'FontSize', 12);
            scatter(x(idx), y(idx), 100, 'MarkerFaceColor', colors{i}, 'MarkerEdgeColor', 'k')
            idxs(i) = find(idx);
        end
    end
    ax = gca;
    ax.XTick = [0:0.2:1];
    ax.YTick = [0:0.2:1];
    grid on
    %axis square
    hold off
end

