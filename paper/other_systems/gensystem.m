% * Does RAD perform as well for other normal forms? Set up a simulation of other normal forms matching the subcritical hopf dataset, then compute RAD, AC, and SD on this dataset.
% * I'm thinking transcritical, subcritical hopf/pitchfork, and sadle-node

% ? Start with subcritical hopf, should be easy. We will have to shift the window back a little to avoid the exact critical point, and reject any trajectories that cross the unstable threshold.
system = 'supercritical_hopf_radius_(strogatz)';
dryrun = false;

if ~dryrun
    testTimeseries(system, ['./Data/' system '/'], 0)
    cd(['./Data/' system '/results/'])
    TS_init('timeseries.mat', 'radMops.txt', 'radOps.txt', 0);
    TS_compute(0, [], [], [], [], 0);
    save_data('./time_series_data.mat', system, 'paper', 'HCTSA.mat', '../inputs.mat');
    group_by_noise('time_series_data.mat', 'time_series_data.mat')
    find_correlation('time_series_data.mat', 'Pearson', [-1, 0], 'time_series_data.mat');
    cd('../../../')
end

% cd(['./Data/' system '/results/'])
% plot_feature_vals(93, time_series_data, 'noise', true, [1, 25, 50, 75, 100], true)