addpath(genpath('../'));
load('./time_series_data.mat');
mus = [-3, 0.0];
etas = [0.5, 1.5];

f = figure('Color', 'w');
ts = tiledlayout(f, 2, 2);
i = 0; axison = true;
for mu = mus
    for eta = etas
        i = i+1;
        ax = nexttile;
        if i > 1
            axison = false;
        end
        plotSystemDistribution(ax, time_series_data, mu, eta, [0, 1.35], 'axison', axison);
    end
end
set(f, 'visible', 'off'); 
set(f, 'Units', 'Inches', 'Position', [0, 0, 7, 5], 'PaperUnits', 'points');
exportgraphics(f,'fig5a.pdf')


f = figure('Color', 'w');
ts = tiledlayout(f, 2, 2);
i = 0;
for mu = mus
    for eta = etas
        i = i+1;
        ax = nexttile;
        plotSystemDynamics(ts, time_series_data, mu, eta);
    end
end