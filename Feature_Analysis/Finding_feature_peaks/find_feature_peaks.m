function [peakparameters, etarange, peakvals, op_table] = find_feature_peaks(direction, op_file, parameter_file, inparallel, resolution, peak_bounds, save_file)
    % Should improve to work with multiple operations; use same time series
    % to improve efficiency
    % direction is 1 for maximum turning point, -1 for minimum turning point (opposite of 'concavity')
    %% Checking Inputs
    tstart = tic;
    if nargin < 1 || isempty(direction)
       direction = sign(predict_direction(op_file, parameter_file, inparallel, 0, [-5:0.5:5], [0.001, 0.04, 0.32, 0.64, 1.28])); % Could just move the values so their minimum is at zero, take the absolute value, find the index of the new max
       direction_names = {'minimum', 'maximum'};
       fprintf('It is predicted that the values of this feature have a %s\n', direction_names{0.5*direction+1.5})
    end
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
    [op_table, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    etarange = parameters.etarange;
    etalength = length(etarange);
    count = 0;
    
    
    %% Make output variables
    peakparameters = zeros(length(etarange), height(op_table)); % operations in the same order, along columns, as the lines in the'op_file' input
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
            feature_vals = generate_feature_vals(time_series_data1, op_table, mop_table, 0);
            if direction == 1
                [~, peak_ind] = max(feature_vals);
            elseif direction == -1
                [~, peak_ind] = min(feature_vals);
            end
            betarange2 = betarange1(max(1, min(peak_ind)-1)):1./resolution:betarange1(min(length(feature_vals), max(peak_ind)+1))+1/resolution; % + 1/r2 to be safe, min and max so that betarange2 covers the correct range for all features

            %% Second Pass
            p.betarange = betarange2;
            if direction == 1
                    [peakvals(ind, :), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            elseif direction == -1
                    [peakvals(ind, :), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table, mop_table, 0));
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
            feature_vals = generate_feature_vals(time_series_data1, op_table, mop_table, 0);
            if direction == 1
                [~, peak_ind] = max(feature_vals);
            elseif direction == -1
                [~, peak_ind] = min(feature_vals);
            end
            betarange2 = betarange1(max(1, min(peak_ind)-1)):1./resolution:betarange1(min(length(feature_vals), max(peak_ind)+1))+1/resolution; % + 1/r2 to be safe, min and max so that betarange2 covers the correct range for all features

            %% Second Pass
            p.betarange = betarange2;
            if direction == 1
                    [peakvals(ind, :), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table, mop_table, 0));
                    peakparameters(ind, :) = betarange2(peakind);
            elseif direction == -1
                    [peakvals(ind, :), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('input_struct', p), op_table, mop_table, 0));
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
