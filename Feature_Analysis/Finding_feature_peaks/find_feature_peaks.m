function [peakparameters, etarange, peakvals, op_table] = find_feature_peaks(direction, op_file, parameter_file, inparallel, resolution, peak_bounds, save_file)
    % Should improve to work with multiple operations; use same time series
    % to improve efficiency
    % direction is a vector contains the direction of each feature1 for maximum turning point, -1 for minimum turning point (opposite of 'concavity')
    %% Checking Inputs
    tstart = tic;
    if nargin < 2 || isempty(op_file)
        op_file = 'test_op_file.txt';
    end
    if nargin < 3 
        parameter_file = [];
    end
    if nargin < 4 || isempty(inparallel)
        inparallel = 1;
    end
    if nargin < 5 || isempty(resolution)
        resolution = 1000;
    end
    if nargin < 6 || isempty(peak_bounds)
        peak_bounds = [0, 1];
    end
    if nargin < 7
        save_file = [];
    end
    % in_ops file can only contain one operation

    %% Input derivatives
    peakmin = peak_bounds(1);
    peakmax = peak_bounds(2); % Set the max possible peak; should be predetermined from the peak at the maximum value of eta
    r1 = ceil(1+sqrt(resolution)); % Minimises number of time series required, density of points calculated in first pass
    %delta = peakmax - peakmin;
    f = struct2cell(load(parameter_file)); % Parameters should be the only variable in input_file
    parameters = f{1};
    betarange1 = peakmin:1./r1:peakmax;
    op_table = SQL_add('ops', op_file, 0, 0);
    [op_table2, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    if nargin < 1 || isempty(direction)
        direction = zeros(1, height(op_table));
        fprintf('-----------Direction Predictions-----------\n')
        for n = 1:height(op_table) % Fix to work in parallel
           direction(n) = sign(predict_direction(op_table(n, :), mop_table, parameter_file, 0, [-5:0.5:5], [0.001, 0.04, 0.32, 0.64, 1.28]));
           direction_names = {'Down', 'Up'};
           fprintf('	%s: %s\n', op_table(n, :).Name{1}, direction_names{0.5*direction(n)+1.5})
        end
    end
    
    
    etarange = parameters.etarange;
    etalength = length(etarange);
    count = 0;
    
    
    %% Make output variables
    peakparameters = zeros(length(etarange), height(op_table2)); % operations in the same order, along columns, as the lines in the'op_file' input
    peakvals = peakparameters;
    %% Start FOR loop
    if inparallel
        D = parallel.pool.DataQueue;
        afterEach(D, @counting);
        parfor ind = 1:etalength
            %fprintf('Calculating: %g of %g\n', ind, etalength);
            eta = etarange(ind);
            %% First Pass
            p = parameters;
            p.betarange = betarange1;
            p.etarange = eta;
            [time_series_data1] = strogatz_hopf_generator('input_struct', p);
            feature_vals = generate_feature_vals(time_series_data1, op_table2, mop_table, 0);
            peak_ind = zeros(1, length(feature_vals, 2));
            for x = 1:size(feature_vals, 2)
                if direction(x) == 1
                    [~, peak_ind(x)] = max(feature_vals(:, x));
                elseif direction(x) == -1
                    [~, peak_ind(x)] = min(feature_vals(:, x));
                end
            end
            betarange2 = betarange1(max(1, min(peak_ind)-1)):1./resolution:betarange1(min(length(feature_vals), max(peak_ind)+1))+1/resolution; % + 1/r2 to be safe, min and max so that betarange2 covers the correct range for all features

            %% Second Pass
            p.betarange = betarange2;
            if direction == 1
                    [peakvals(ind, :), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table2, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            elseif direction == -1
                    [peakvals(ind, :), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table2, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            end
            send(D, ind);
        end
    else
        for ind = 1:etalength
            %fprintf('Calculating: %g of %g\n', ind, etalength);
            eta = etarange(ind);
            %% First Pass
            p = parameters;
            p.betarange = betarange1;
            p.etarange = eta;
            [time_series_data1] = strogatz_hopf_generator('input_struct', p);
            feature_vals = generate_feature_vals(time_series_data1, op_table2, mop_table, 0);
            for x = 1:size(feature_vals, 2)
                if direction(x) == 1
                    [~, peak_ind(x)] = max(feature_vals(:, x));
                elseif direction(x) == -1
                    [~, peak_ind(x)] = min(feature_vals(:, x));
                end
            end
            betarange2 = betarange1(max(1, min(peak_ind)-1)):1./resolution:betarange1(min(length(feature_vals), max(peak_ind)+1))+1/resolution; % + 1/r2 to be safe, min and max so that betarange2 covers the correct range for all features

            %% Second Pass
            p.betarange = betarange2;
            if direction == 1
                    [peakvals(ind, :), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table2, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            elseif direction == -1
                    [peakvals(ind, :), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table2, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            end
            counting
        end
    end  
    time = toc(tstart);
    if ~isempty(save_file)
        save(save_file, 'peakparameters', 'etarange', 'peakvals', 'op_table', 'time')
    end
    
    function counting(~)
        count = count + 1;
        fprintf('%g of %g complete, %g minutes remaining\n', count, etalength, round((etalength-count)*toc(tstart)/(60*count)))
    end
end
