function [avg_direction, directions] = predict_direction(ops, mops, input_file, plots, cp_range, etarange, inparallel)
    % Set a coarse beta and eta range for speed, but a MUST wide range for
    % generality and accuracy (enough to cover the range of peaks as well as extra so that the quadratic fit is accurate. The results will be innacurate at higher noises, so
    % increase the range of beta
    % If cp_range and/or etarange are provided then they will be used over
    % the ranges contained in the input file
    if nargin < 4 || isempty(plots)
        plots = 0;
    end
    if isstring(ops) || ischar(ops)
        ops = SQL_add('ops', op_file, 0, 0);
    end
    if nargin < 2 || isempty(mops)
        mops = SQL_add('mops', 'INP_mops.txt', 0, 0);
    end
    if nargin < 7 || isempty(inparallel)
        inparallel = 0;
    end
    [ops, mops] = TS_LinkOperationsWithMasters(ops, mops);
    f = struct2cell(load(input_file));
    parameters = f{1};
    if nargin > 4 && ~isempty(cp_range)
        parameters.cp_range = cp_range;
    end
    if nargin > 5 && ~isempty(etarange)
        parameters.etarange = etarange;
    end
    etarange = parameters.etarange;
    directions = zeros(1, length(etarange));
%     if nargin < 3 || isempty(inparallel) || ~inparallel
        for ind = 1:length(etarange)
            p = parameters;
            p.etarange = etarange(ind);
            time_series_data = time_series_generator('input_struct', p);
            if inparallel
                [~, feature_vals] = evalc("generate_feature_vals(time_series_data, ops, mops, 1);");
            else
                [~, feature_vals] = evalc("generate_feature_vals(time_series_data, ops, mops, 0);");
            end
            fit = polyfit(p.cp_range, feature_vals',2);
            directions(ind) = -sign(fit(1));
            dir_vec = {'Down', 'Up'};
            if plots
                figure
                plot(p.cp_range, feature_vals', 'o', 'markersize', 2)
                hold on
                title(sprintf('\\eta = %g, Direction: %g (%s)', etarange(ind), directions(ind), dir_vec{0.5.*directions(ind)+1.5}), 'interpreter', 'Tex') 
                Y = polyval(fit, p.cp_range);
                plot(p.cp_range, Y, ':')
            end
        end
    avg_direction = mean(directions);
end
