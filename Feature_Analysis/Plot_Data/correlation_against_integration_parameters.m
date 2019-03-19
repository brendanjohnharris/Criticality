function [c, x, y] = correlation_against_integration_parameters(data, op)
    %CORRELATION_AGAINST_INTEGRATION_PARAMETERS 
    % Assume that all combinations of time series lengths and timesteps are
    % represented, as well as that all rowshave identical parameters except
%     for:
%         - savelength
%         - tmax
%         - cp_range & etarange
    %% Get needed data
    s_t = zeros(size(data, 1), 2);
    
    for u = 1:size(data, 1)
        s_t(u, :) = [data(u).Inputs.savelength, data(u).Inputs.tmax];
    end
    s_t = unique(s_t, 'rows');

    
    numpoints = data(1).Inputs.numpoints; % The part where it is assumed numpoints is constant
    transient_cutoff = data(1).Inputs.transient_cutoff; % The part where it is assumed numpoints is constant
    tsteps = arrayfun(@(x) get_time_parameters(s_t(x, 2), numpoints, s_t(x, 1), transient_cutoff), 1:size(s_t, 1)); % Should be in the same order as s_t
    rounded_tsteps = round(log10(tsteps)*20)/20;
    r = zeros(size(s_t, 1), 1);
    
    inputs = {data.Inputs}; % Faster this way
    sv = arrayfun(@(x) x{1}.savelength, inputs);
    tm = arrayfun(@(x) x{1}.tmax, inputs);
    
    for i = 1:size(s_t, 1)
        subdata = data((sv == s_t(i, 1) & sv == s_t(i, 1)), :);
        subtbl = get_combined_feature_stats(subdata, {}, {'Aggregated_Absolute_Correlation'}, [], 1);
        r(i) = subtbl(subtbl.Operation_ID == op, :).Aggregated_Absolute_Correlation; % Should be in the same order as s_t
        fprintf(['--------------------------', num2str(round(100.*i./size(s_t, 1), 1)), '%% Complete--------------------------\n'])
    end
         
    %% Generate matrix to specify colors
%     [~, inds] = sort(rounded_tsteps);
    x = unique(rounded_tsteps);
    y = unique(s_t(:, 2));
    c = zeros(length(y), length(x));
    for z = 1:size(s_t, 1)
        rw = find(y == s_t(z, 2));
        cl = find(x == rounded_tsteps(z));
        c(rw, cl) = r(z);
    end
%     sorted_s_t = s_t(inds, :);
%     sorted_r = r(inds, :);
    
%    
%     %% Plot
%     cmp = BF_getcmap('blues', 9, 0, 1);
%     .............
end

