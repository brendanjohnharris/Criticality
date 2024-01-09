addpath(genpath('../'));
load('./time_series_data.mat');
num_hctsa = 7873; % The number of hctsa features. Any above this are custom

% * Do a similar scatter for RAD, but varying measurement noise between the scatters
mops = SQL_add('mops', 'radMops.txt', 0, 0);
ops = SQL_add('ops', 'radOps.txt', 0, 0);
ops = ops(1, :);

input_file = time_series_data(1).Inputs;
input_file.save_cp_split = 0;
input_file.foldername = "";
cp_range = -1:0.1:0.0;
etarange = 0.01:0.1:1;

input_file.etarange = etarange;
input_file.cp_range = cp_range;

time_series_data = time_series_generator('input_struct', input_file);

[ops, mops] = TS_LinkOperationsWithMasters(ops, mops);
feature_vals = generate_feature_vals(time_series_data, ops, mops, 0);

f = figure();
hold on
plot_feature_vals_directly(ops, mops, input_file, cp_range, etarange)

% * Then do a summary figure that can go in the paper
