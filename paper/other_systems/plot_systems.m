systems = {"quadratic_potential", ...
               "supercritical_hopf_radius_(strogatz)", ...
               "supercritical_hopf_radius_(strogatz)_pink", ...
               "supercritical_hopf_radius_(strogatz)_brownian", ...
               "supercritical_pitchfork_(strogatz)", ...
           };

features = [2 1 3 4];

hm = pwd();

ff = [];

for i = 1:length(systems)
    system = systems{i};
    cd(strcat('./Data/', system, '/results/'))
    load('time_series_data.mat')
    T = get_combined_feature_stats(time_series_data, {}, {'Aggregated_Correlation'}, [], 1);
    y = (T.Aggregated_Correlation(features));

    ff(end + 1, :) = y;
    cd(hm)
end

colors = inferno(5);
colors = colors([1 3 4 5], :);
f = figure('Color', 'w');
ax = axes(f);
colororder(colors(end:-1:1, :))
hold on
plot(ff, 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 10)
L = legend(ax, strrep(T.Operation_Name(features), "_", "\_"), 'Location', 'southwest');
L.ItemTokenSize = [15, 18];
ax.XTickLabel = {"Quadratic", "Radial Hopf", "Radial Hopf (pink)", "Radial Hopf (brown)", "Pitchfork"};
ax.XTick = 1:length(systems);
ax.XLim = [0.75, 5.25];
ax.XTickLabelRotation = 0;
ax.YLabel.String = "$$\rho^\textrm{var}_\mu$$";
ax.YLabel.Interpreter = "LaTeX";
f.PaperPosition = [0 0 20 8];
ax.Box = 1;
ax.YLim = [-0.2, 1];
yline(ax, 0.0, '--', 'HandleVisibility', 'off')

saveas(f, "systemcomparison.svg")
