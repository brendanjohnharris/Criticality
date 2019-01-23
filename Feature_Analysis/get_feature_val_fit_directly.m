function [m, b] = get_feature_val_fit_directly(op_file, input_file, inparallel, save_file, optional_cp_range, optional_etarange)
    %% Checking Inputs
    tstart = tic;
    if nargin < 1 || isempty(op_file)
        op_file = 'test_op_file.txt';
    end
    if nargin < 2 
        input_file = [];
    end
    if nargin < 3 || isempty(inparallel)
        inparallel = 1;
    end
    if nargin < 4
        save_file = [];
    end
    %% Input derivatives
    %delta = peakmax - peakmin;
    f = struct2cell(load(input_file)); % Parameters should be the only variable in input_file
    parameters = f{1};
    if nargin < 5 || ~isempty(optional_cp_range)
        parameters.cp_range = optional_cp_range; % Optional in the sense that if not given here should be given in the input file
    end
    if nargin == 6 && ~isempty(optional_etarange)
        parameters.etarange = optional_etarange;
    end
    op_table = SQL_add('ops', op_file, 0, 0);
    [op_table2, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    
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
%% Calculate fit
    m = zeros(etalength, height(op_table2));
    b = m;
    for ind = 1:etalength
        x = etarange;
        y = feature_vals(ind, :);
        n = etalength;
        m = (n.*sum(x.*y) - sum(x).*sum(y))./(n.*sum(x.^2) - sum(x).^2);
        b = (sum(y).*(sum(x.^2)) - sum(x).*sum(x.*y))./(n.*(sum(x.^2))-sum(x).^2);
    end
        
    fprintf('----------------Complete----------------\n')
    
    time = toc(tstart);
    if ~isempty(save_file)
        save(save_file, 'm', 'b', 'etarange', 'cp_range', 'op_table', 'time')
    end
end

end

