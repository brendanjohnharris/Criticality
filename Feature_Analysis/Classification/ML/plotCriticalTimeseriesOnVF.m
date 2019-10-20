function [f, ax] = plotCriticalTimeseriesOnVF()
% Start by plotting the bifurcation diagram and vector field
    f = VF_on_bifurcation_diagram('subcritical_hopf_radius_(strogatz)', [-0.5, 0.25]);
    ax = gca;
    ax.XAxis.Direction = 'reverse';
    bdidxs = strcmp(arrayfun(@(x) x.Type, ax.Children, 'un', 0), 'quiver');
    bd = ax.Children(~bdidxs);
    qd = ax.Children(bdidxs);
    for i = 1:length(bd)
        bd(i).Color = 'k';
        bd(i).LineWidth = 1;
    end
    for i = 1:length(qd)
        qd(i).Color = [152, 152, 152]./256;
    end
    title('')
    xlim([-0.5, 0.25])
    ylim([-0.1, 1.15])
    xlabel('')
    ylabel('')
    
% Get timeseries for the lower branch
    t = inf;
    while any(t > 0.08)
        t = time_series_generator('system_type', 'subcritical_hopf_radius_(strogatz)_varying_cp',...
        'cp_range', -0.5, 'etarange', 0.01, 'initial_conditions', 0,...
        'parameters', '0.5./tmax', 'tmax', 1000, 'numpoints', 100000, 'savelength', 2000, 'T', 1000);
    end
    % Explode a little for clarity
    t = 2.*t;
% Plot with colour
    G = [0.3020    0.6863    0.2902];
    R = [0.8941    0.1020    0.1098];
    intrpd = interpColors(G, R, length(t)./2);
    colormapline(linspace(-0.5, 0, length(t)), t, [], [repmat(G, length(t)./2, 1); intrpd]);
% Then get a nice timeseries and plot it on the upper branch
	t = 0;
    while any(t < 1./sqrt(2)-0.05)
        t = time_series_generator('system_type', 'subcritical_hopf_radius_(strogatz)_varying_cp',...
        'cp_range', -0.24, 'etarange', 0.01, 'initial_conditions', sqrt(1 + sqrt(4*(-0.24) + 1))/sqrt(2),...
        'parameters', '0.49./tmax', 'tmax', 1000, 'numpoints', 100000, 'savelength', 2000, 'T', 1000);
    end
    % Explode a little for clarity
    tmean = sqrt(1 + sqrt(4.*linspace(-0.23, 0.25, length(t)) + 1))./sqrt(2);
    t = 2.*(t-tmean) + tmean;
    colormapline(linspace(-0.25, 0.25, length(t)), t, [], [flipud(intrpd); repmat(G, length(t)./2, 1)]);
    axis square
    ax.Visible = 'off';
end

