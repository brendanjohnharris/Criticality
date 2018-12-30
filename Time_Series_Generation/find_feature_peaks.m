function [peakparameters, etarange, peakvals] = find_feature_peaks(direction, etarange, op_file, type, parallel, resolution, peak_bounds)
    %% Checking Inputs
    if nargin < 2 || isempty(etarange)
        etarange = [0.02:0.02:0.32];
    end
    if nargin < 3 || isempty(op_file)
        op_file = 'test_op_file.txt';
    end
    if nargin < 4 || isempty(type)
        type = 'supercritical';
    end
    if nargin < 5 || isempty(parallel)
        parallel = 1;
    end
    if nargin < 6 || isempty(resolution)
        resolution = 1000;
    end
    if nargin < 7 || isempty(peak_bounds)
        peak_bounds = [0, 1];
    end
    % in_ops file can only contain one operation
    peakmin = peak_bounds(1);
    peakmax = peak_bounds(2); % Set the max possible peak; should be predetermined from the peak at the maximum value of eta

    %% Input derivatives
    r1 = ceil(1+sqrt(resolution)); % Minimises number of time series required, density of points calculated in first pass
    %delta = peakmax - peakmin;
    betarange1 = peakmin:1/r1:peakmax;
    op_table = SQL_add('ops', op_file, 0, 0);

    %% Make output variables
    peakparameters = zeros(1, length(etarange));
    peakvals = peakparameters;

    %% Start FOR loop
    if parallel
        parfor ind = 1:length(etarange)
            eta = etarange(ind);

            %% First Pass
            [time_series_data1] = strogatz_hopf_generator('betarange', betarange1, 'type', type, 'etarange', eta);
            feature_val_vector = generate_feature_vals(time_series_data1, op_table, parallel);
            if direction
                [~, peak_ind] = max(feature_val_vector);
            else
                [~, peak_ind] = min(feature_val_vector);
            end
            betarange2 = betarange1(max(1, peak_ind-1)):1/resolution:betarange1(min(length(feature_val_vector), peak_ind+1))+1/resolution; % + 1/r2 to be safe

            %% Second Pass
            if direction 
                    [peakvals(ind), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters(ind) = betarange2(peakind);
                else
                    [peakvals(ind), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            end
        end
    else
        for ind = 1:length(etarange)
            eta = etarange(ind);

            %% First Pass
            [time_series_data1] = strogatz_hopf_generator('betarange', betarange1, 'type', type, 'etarange', eta);
            feature_val_vector = generate_feature_vals(time_series_data1, op_table, parallel);
            if direction
                [~, peak_ind] = max(feature_val_vector);
            else
                [~, peak_ind] = min(feature_val_vector);
            end
            betarange2 = betarange1(max(1, peak_ind-1)):1/resolution:betarange1(min(length(feature_val_vector), peak_ind+1))+1/resolution; % + 1/r2 to be safe

            %% Second Pass
            if direction 
                    [peakvals(ind), peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters(ind) = betarange2(peakind);
                else
                    [peakvals(ind), peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters(ind) = betarange2(peakind);
            end
        end
    end  
end