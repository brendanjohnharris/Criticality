function [peakparameters, etarange, peakvals] = find_feature_peaks(direction, etarange, op_file, type, inparallel, resolution, peak_bounds, save_file, s0)
    % Should improve to work with multiple operations; use same time series
    % to improve efficiency
    %% Checking Inputs
    tstart = tic;
    if nargin < 2 || isempty(etarange)
        etarange = [0.02:0.02:0.32];
    end
    if nargin < 3 || isempty(op_file)
        op_file = 'test_op_file.txt';
    end
    if nargin < 4 || isempty(type)
        type = 'supercritical';
    end
    if nargin < 5 || isempty(inparallel)
        inparallel = 1;
    end
    if nargin < 6 || isempty(resolution)
        resolution = 1000;
    end
    if nargin < 7 || isempty(peak_bounds)
        peak_bounds = [0, 1];
    end
    if nargin < 8
        save_file = [];
    end
    if nargin < 9 || isempty(s0)
        s0 = [1, 0];
    end
    % in_ops file can only contain one operation
    peakmin = peak_bounds(1);
    peakmax = peak_bounds(2); % Set the max possible peak; should be predetermined from the peak at the maximum value of eta

    %% Input derivatives
    r1 = ceil(1+sqrt(resolution)); % Minimises number of time series required, density of points calculated in first pass
    %delta = peakmax - peakmin;
    betarange1 = peakmin:1./r1:peakmax;
    op_table = SQL_add('ops', op_file, 0, 0);
    [op_table, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    etalength = length(etarange);
    count = 0;
    
    
    %% Make output variables
    peakparameters = zeros(1, length(etarange));
    peakvals = peakparameters;
    %% Start FOR loop
    if inparallel
        D = parallel.pool.DataQueue;
        afterEach(D, @counting);
        parfor ind = 1:etalength
            %fprintf('Calculating: %g of %g\n', ind, etalength);
            eta = etarange(ind);
            %% First Pass
            [time_series_data1] = strogatz_hopf_generator('betarange', betarange1, 'type', type, 'etarange', eta, 's0', s0, 'vocal', 0);
            feature_val_vector = generate_feature_vals(time_series_data1, op_table, mop_table, 0);
            if direction
                [~, peak_ind] = max(feature_val_vector);
            else
                [~, peak_ind] = min(feature_val_vector);
            end
            betarange2 = betarange1(max(1, peak_ind-1)):1./resolution:betarange1(min(length(feature_val_vector), peak_ind+1))+1/resolution; % + 1/r2 to be safe

            %% Second Pass
            if direction 
                    [peakvals(ind), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta, 'vocal', 0), op_table, mop_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            else
                    [peakvals(ind), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta, 'vocal', 0), op_table, mop_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            end
            send(D, ind);
        end
    else
        for ind = 1:etalength
            counting
            %fprintf('Calculating: %g of %g\n', ind, etalength);
            eta = etarange(ind);
            %% First Pass
            [time_series_data1] = strogatz_hopf_generator('betarange', betarange1, 'type', type, 'etarange', eta, 's0', s0, 'vocal', 0);
            feature_val_vector = generate_feature_vals(time_series_data1, op_table, mop_table, 0);
            if direction
                [~, peak_ind] = max(feature_val_vector);
            else
                [~, peak_ind] = min(feature_val_vector);
            end
            betarange2 = betarange1(max(1, peak_ind-1)):1./resolution:betarange1(min(length(feature_val_vector), peak_ind+1))+1/resolution; % + 1/r2 to be safe

            %% Second Pass
            if direction 
                    [peakvals(ind), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta, 'vocal', 0), op_table, mop_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            else
                    [peakvals(ind), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta, 'vocal', 0), op_table, mop_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            end
            
        end
    end  
    time = toc(tstart);
    if ~isempty(save_file)
        save(save_file, 'peakparameters', 'etarange', 'peakvals', 'time')
    end
    
    function counting(~)
        count = count + 1;
        fprintf('%g of %g complete, %g minutes remaining\n', count, etalength, round((etalength-count)*toc(tstart)/(60*count)))
    end
end