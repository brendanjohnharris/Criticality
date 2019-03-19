function [correlations, op_table] = find_correlation_directly(direction, op_file, input_file, inparallel, save_file, correlation_type, optional_cp_range, optional_etarange)
    % direction is a vector contains the direction of each feature1 for maximum turning point, -1 for minimum turning point (opposite of 'concavity')
    % if etarange is given as an input argument then it will override the etarange
    % given in the input file
    %% Checking Inputs
    tstart = tic;
    if nargin < 2 || isempty(op_file)
        op_file = 'test_op_file.txt';
    end
    if nargin < 3 
        input_file = [];
    end
    if nargin < 4 || isempty(inparallel)
        inparallel = 1;
    end
    if nargin < 5
        save_file = [];
    end
    if nargin < 6 || isempty(correlation_type)
        correlation_type = 'Pearson';
    end
    %% Input derivatives
    %delta = peakmax - peakmin;
    f = struct2cell(load(input_file)); % Parameters should be the only variable in input_file
    parameters = f{1};
    if nargin < 7 || ~isempty(optional_cp_range)
        parameters.cp_range = optional_cp_range; % Optional in the sense that if not given here should be given in the input file
    end
    if nargin == 8 && ~isempty(optional_etarange)
        parameters.etarange = optional_etarange;
    end
    op_table = SQL_add('ops', op_file, 0, 0);
    [op_table2, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    
    % Predict directions
    if nargin < 1 || isempty(direction)
        direction = zeros(1, height(op_table));
        fprintf('-----------Direction Predictions-----------\n')
        for n = 1:height(op_table)
           direction(n) = sign(predict_direction(op_table(n, :), mop_table, input_file, 0, [-5:0.5:5], [0.001, 0.04, 0.32, 0.64, 1.28]));
           direction_names = {'Down', 'Up'};
           fprintf('	%s: %s\n', op_table(n, :).Name{1}, direction_names{0.5*direction(n)+1.5})
        end
    end
    
    etarange = parameters.etarange;
    etalength = length(etarange);
    cp_range = parameters.cp_range;
    cp_length = length(cp_range);
    
%% Generate time series data
    fprintf('----------------Beginning Calculations----------------\n')
    time_series_data = time_series_generator('input_file', input_file, 'cp_range', cp_range, 'etarange', etarange);
    fprintf('----------------Time Series Generated----------------\n')
    if inparallel
        [~, feature_vals] = evalc("generate_feature_vals(time_series_data, op_table2, mop_table, 1);");
    else
        [~, feature_vals] = evalc("generate_feature_vals(time_series_data, op_table2, mop_table, 0);");
    end
    fprintf('----------------Feauture Values Calculated----------------\n')
%% Calculate correlations to the etarange
    correlations = zeros(etalength, height(op_table2));
    for x = 1:etalength
        correlations(x, :) = corr(feature_vals(1 + (x-1)*cp_length:x*cp_length, :), cp_range', 'Type', correlation_type)'; % Get vecotr of correlations, one for each feature
    end
        
    fprintf('----------------Complete----------------\n')
    
    time = toc(tstart);
    if ~isempty(save_file)
        save(save_file, 'correlations', 'etarange', 'cp_range', 'op_table', 'time')
    end
end
