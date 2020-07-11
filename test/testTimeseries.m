% Generate time series for the main analysis; this should only take a few
% minutes, and will produce an `inputs.mat` file, a `results` folder and 100
% `time_series_data` subfolders (each with a `timeseries.mat` file and an `inputs_out.mat` file)

clear all

inputs = make_input_struct(0, 'cp_range', -1:0.01:0, 'etarange', 0.01:0.01:1,...
                            'bifurcation_point', 0, 'initial_conditions', 0,...
                            'foldername', 'results', 'numpoints', 1000000,...
                            'parameters', [], 'savelength', 5000,...
                            'system_type', 'supercritical_hopf_radius_(strogatz)',...
                            'tmax', 1000, 'T', 500, 'save_cp_split', 100, ...
                            'randomise', 0, 'rngseed', 17062020, 'vocal', 1);                      

time_series_generator('input_struct', inputs);

save('./results/inputs.mat', 'inputs')