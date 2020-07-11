% Generate a time_series_data.mat file and perform the main analysis; use after
% `testTimeseries.m` and following `testHCTSA.md`

% Don't want to save this first structure to disk; too large
time_series_data = save_data([], 'supercritical,strogatz,hopf,radius', 'time_series_generator', 'HCTSA_updated.mat', 'inputs_out.mat', 0, 0, 1);

% This one is much smaller
group_by_noise(time_series_data, './time_series_data.mat');

find_correlation('time_series_data.mat', 'Spearman', [-1, 0], 'time_series_data.mat');

load('time_series_data.mat')
tbl = get_combined_feature_stats(time_series_data, {'Absolute_Correlation'}, {'Absolute_Correlation_Mean', 'Aggregated_Absolute_Correlation'}, [], 1);
tbl = sortrows(tbl, 5, 'Desc', 'Comparison', 'abs', 'Missing', 'Last');
writetable(tbl, 'testAnalysis.xlsx') % Feature Rankings

% Plot the feature values for a feature (ID's are contianed in time_series_data struct, under Operations field)
plot_feature_vals(93, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1) % SD
plot_feature_vals(93, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1) % AC
plot_feature_vals(3535, time_series_data, 'noise', 1, [1, 25, 50, 75, 100], 1) % SB_MotifTwo_mean_uu

% Scatter all features
meanAgainstAggregated(tbl, 1)

% Feature Bubble Plot
data = normalise_time_series_data(time_series_data, [-1, 0]);
visualise_feature_fit(data, [19, 93, 1763, 3332, 3535, 6275], 101)