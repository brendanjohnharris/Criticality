function plot_feature_vals_directly(ops, mops, input_file, cp_range, etarange)
%   Modification of 'predict_direction' that only plots the feature values
    if isstring(ops) || ischar(ops)
        ops = SQL_add('ops', op_file, 0, 0);
    end
    if nargin < 2 || isempty(mops)
        mops = SQL_add('mops', 'INP_mops.txt', 0, 0);
    end
    [ops, mops] = TS_LinkOperationsWithMasters(ops, mops);
    f = struct2cell(load(input_file));
    parameters = f{1};
    if nargin > 3 && ~isempty(cp_range)
        parameters.cp_range = cp_range;
    end
    if nargin > 4 && ~isempty(etarange)
        parameters.etarange = etarange;
    end
    etarange = parameters.etarange;
    for ind = 1:length(etarange)
        p = parameters;
        p.etarange = etarange(ind);
        time_series_data = time_series_generator('input_struct', p);
        feature_vals = generate_feature_vals(time_series_data, ops, mops, 0);
        figure
        plot(p.cp_range, feature_vals', 'o', 'markersize', 2)
        title(sprintf('\\eta = %g', etarange(ind)), 'interpreter', 'Tex') 
    end
end

