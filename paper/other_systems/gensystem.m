% Run this script for the following systems:
% systems = {"quadratic_potential", ...
%                "supercritical_hopf_radius_(strogatz)", ...
%                "supercritical_hopf_radius_(strogatz)_pink", ...
%                "supercritical_hopf_radius_(strogatz)_brownian", ...
%                "supercritical_pitchfork_(strogatz)", ...
%            };

% * Does RAD perform as well for other normal forms and types of noise?
system = 'supercritical_hopf_radius_(strogatz)_pink';
dryrun = false;

if ~dryrun

    if isfolder(['./Data/' system '/'])
        rmdir(['./Data/' system '/'], 's')
    end

    testTimeseries(system, ['./Data/' system '/'], 0)
    cd(['./Data/' system '/results/'])
    TS_init('timeseries.mat', 'radMops.txt', 'radOps.txt', 0);
    TS_compute(0, [], [], [], [], 0);
    delete('./time_series_data.mat');
    save_data('./time_series_data.mat', system, 'paper', 'HCTSA.mat', '../inputs.mat');
    group_by_noise('time_series_data.mat', 'time_series_data.mat')
    find_correlation('time_series_data.mat', 'Spearman', [-1, 0], 'time_series_data.mat');
    cd('../../../')
end

%%
cd(['./Data/' system '/results/'])
load('time_series_data.mat')
plot_feature_vals(1, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)
plot_feature_vals(2, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)
plot_feature_vals(3, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)
plot_feature_vals(4, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)
plot_feature_vals(5, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)
cd('../../../')
