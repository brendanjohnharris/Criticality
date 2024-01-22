dryrun = false;
load("inputs_template.mat", "inputs")
system = inputs.system_type;

if ~dryrun
%     metas = 1:0.1:5;
    metas = 0.1:0.1:0.5;
    
    cp = -1:0.01:0.0; %
    inputs.cp_range = cp;

    for meta = metas
        dirp = ['Data/' system, '/', char(string(meta))];
        disp(dirp)
        inputs.parameters = meta;
        inputs.foldername = dirp;
        inputs.rngseed = randi(1000000);
        if isfolder(dirp)
%             rmdir(dirp, 's')
            continue
        end
        time_series_generator('input_struct', inputs);
        save(fullfile(dirp, 'inputs.mat'), 'inputs')
        cd(dirp)
        TS_init('timeseries.mat', 'radMops.txt', 'radOps.txt', 0);
        TS_compute(0, [], [], [], [], 0);
        save_data('./time_series_data.mat', system, 'paper', 'HCTSA.mat', './inputs.mat');
        group_by_noise('time_series_data.mat', 'time_series_data.mat')
        find_correlation('time_series_data.mat', 'Spearman', [-1, 0], 'time_series_data.mat');
        cd('../../../')
    end
end
