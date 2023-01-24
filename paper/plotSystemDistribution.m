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
        opts.rescale = false;
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


    inputs = data.Inputs;
    inputs.etarange = [eta];
    inputs.foldername = [];
    inputs.cp_range = [mu];
    inputs.numpoints = [];
    inputs.savelength = [];
    inputs.T = 1000;
    inputs.tmax = 1010;
    inputs.sampling_period = 0.1;
    x = time_series_generator('input_struct', inputs);
    ts = 0:inputs.sampling_period:inputs.sampling_period*(length(x)-1);

    if opts.rescale
        sigma = 1./std(x(2:end) - x(1:end-1));
    else
        sigma = 1;
    end


    % Now get on to plotting everything. 
    % First the potential
    title(sprintf('$$\\mu = %.2g, \\eta = %.2g$$', mu, eta), 'Interpreter', 'latex')
    if axison
        if opts.rescale
            xlabel("$$x\sigma$$", 'Interpreter', 'latex')
        else
            xlabel("$$x$$", 'Interpreter', 'latex')
        end
    end

    yyaxis('left')
    xs = linspace(xlims(1), xlims(2), 100);
    V = @(x) -mu.*x.^2./2 + x.^4./4;
%     plot(xs, V(xs), 'parent', ax, 'color', gray)
    fill([0, xs.*sigma, xs(end)*sigma], [0, V(xs), 0], gray, 'FaceAlpha', 0.0, 'EdgeColor', gray, 'LineWidth', 2)
    ylim(ax, vlims)
    if axison
        ylabel("$$V(x)$$", 'Interpreter', 'latex')
    else
        ax.YTickLabel = [];
    end
   
   
    yyaxis(ax, 'right')


    % Then the distribution
    p = @(x) exp(-2.*V(x)/eta.^2);
    ps = p(xs)./(sum(p(xs)).*(xs(2)-xs(1)).*sigma);
%     plot(xs, ps, 'color', blue, 'linewidth', 5)
    xlim(ax, xlims)
    fill([0, xs.*sigma, xs(end).*sigma], [0, ps, 0], blue, 'FaceAlpha', 0.5, 'edgecolor', blue, 'LineWidth', 2)
    ylim(ax, plims)
    if axison
        ylabel("$$p(x)$$", 'Interpreter', 'latex')
    else
        ax.XTickLabel = [];
        ax.YTickLabel = [];
    end


    % Label the autocorrelation
%     plot(x, ts, 'parent', ax1)
% And the AC
    r = autocorr(x, 'numlags', 2);
    dy = (plims(2) - plims(1))*0.1;
    dx = (xlims(2) - xlims(1))*0.1;
    text((xlims(1)+dx), (plims(end)-dy), sprintf("$$r_{t-1} = %.2g$$", r(2)), 'Interpreter', 'latex')

end

