function plotSystemDistribution(ax, time_series_data, mu, eta, xlims, vlims, plims, opts)
%PLOTSYSTEMDISTRIBUTION
    arguments
        ax
        time_series_data
        mu
        eta
        xlims (2,1) double {mustBeFinite} = [0, 1.5];
        vlims (2, 1) double {mustBeFinite} = [0, 0.8];
        plims (2, 1) double {mustBeFinite} = [0, 4];
        opts.axison (1, 1) = true;
    end
    axison = opts.axison;
    blue = [0,    0.4470,    0.7410];
    red = [0.8500,    0.3250,    0.0980];
    gray = [0.2, 0.2, 0.2];
    colororder([gray; blue; red])
    % First find the data row with mu = mu and eta = eta
%     for r = 1:size(time_series_data, 1)
%         t = time_series_data(r, :);
%         if abs(t.Inputs.eta - eta) < 0.0001
%             data = time_series_data(r, :);
%             break
%         end
%     end
%     cp_range = data.Inputs.cp_range;
%     idx = find(cp_range == mu, 1);
    data = time_series_data(1, :);

    % Now get on to plotting everything. 
    % First the potential
    title(sprintf('$$\\mu = %.2g, \\eta = %.2g$$', mu, eta), 'Interpreter', 'latex')
    if axison
        xlabel("$$x$$", 'Interpreter', 'latex')
    end

    yyaxis('left')
    xs = linspace(xlims(1), xlims(2), 100);
    V = @(x) -mu.*x.^2./2 + x.^4./4;
%     plot(xs, V(xs), 'parent', ax, 'color', gray)
    fill([0, xs, xs(end)], [0, V(xs), 0], gray, 'FaceAlpha', 0.7, 'EdgeColor', gray, 'LineWidth', 2)
    ylim(ax, vlims)
    if axison
        ylabel("$$V(x)$$", 'Interpreter', 'latex')
    else
        ax.YTickLabel = [];
    end
   
   
    yyaxis(ax, 'right')


    % Then the distribution
    p = @(x) exp(-2.*V(x)/eta.^2);
    ps = p(xs)./(sum(p(xs)).*(xs(2)-xs(1)));
%     plot(xs, ps, 'color', blue, 'linewidth', 5)
    xlim(ax, xlims)
    fill([0, xs, xs(end)], [0, ps, 0], blue, 'FaceAlpha', 0.5, 'edgecolor', blue, 'LineWidth', 2)
    ylim(ax, plims)
    if axison
        ylabel("$$p(x)$$", 'Interpreter', 'latex')
    else
        ax.XTickLabel = [];
        ax.YTickLabel = [];
    end
end

