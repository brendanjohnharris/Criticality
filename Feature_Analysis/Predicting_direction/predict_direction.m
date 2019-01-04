function [avg_direction, directions] = predict_direction(op_file, input_file, inparallel, plots, betarange, etarange)
    % Set a coarse beta and eta range for speed, but a MUST wide range for
    % generality and accuracy (enough to cover the range of peaks as well as extra so that the quadratic fit is accurate. The results will be innacurate at higher noises, so
    % increase the range of beta
    % If betarange and/or etarange are provided then they will be used over
    % the ranges contained in the input file
    if nargin < 4 || isempty(plots)
        plots = 0;
    end
    op_table = SQL_add('ops', op_file, 0, 0);
    [op_table, mop_table] = TS_LinkOperationsWithMasters(op_table, SQL_add('mops', 'INP_mops.txt', 0, 0));
    f = struct2cell(load(input_file));
    parameters = f{1};
    if nargin > 4 && ~isempty(betarange)
        parameters.betarange = betarange;
    end
    if nargin > 5 && ~isempty(etarange)
        parameters.etarange = etarange;
    end
    etarange = parameters.etarange;
    directions = zeros(1, length(etarange));
    if nargin < 3 || isempty(inparallel) || ~inparallel
        for ind = 1:length(etarange)
            p = parameters;
            p.etarange = etarange(ind);
            time_series_data = strogatz_hopf_generator('input_struct', p);
            feature_vals = generate_feature_vals(time_series_data, op_table, mop_table, 0);
            fit = polyfit(p.betarange, feature_vals',2);
            %m = (polyder(fit));
            %directions(ind) = -sign((polyval(m, p.betarange(end))- polyval(m, p.betarange(1)))/(p.betarange(end) - p.betarange(1)));     % Gets integral of concavity divided by length, i.e average concavity
            directions(ind) = -sign(fit(1));
            dir_vec = {'Down', 'Up'};
            if plots
                figure
                plot(p.betarange, feature_vals', 'o', 'markersize', 2)
                hold on
                title(sprintf('\\eta = %g, Direction: %g (%s)', etarange(ind), directions(ind), dir_vec{0.5.*directions(ind)+1.5}), 'interpreter', 'Tex') 
                Y = polyval(fit, p.betarange);
                plot(p.betarange, Y, ':')
            end
        end
    else 
        parfor ind = 1:length(etarange)
            p = parameters;
            p.etarange = etarange(ind);
            time_series_data = strogatz_hopf_generator('input_struct', p);
            feature_vals = generate_feature_vals(time_series_data, op_table, mop_table, 0);
            fit = polyfit(p.betarange, feature_vals', 2);
            %m = (polyder(fit));
            %directions(ind) = -sign((polyval(m, p.betarange(end))- polyval(m, p.betarange(1)))/(p.betarange(end) - p.betarange(1)));     % Gets integral of concavity divided by length, i.e average concavity
            directions(ind) = -sign(fit(1));
            dir_vec = {'Down', 'Up'};
            if plots
                figure
                plot(p.betarange, feature_vals', 'o', 'markersize', 2)
                hold on
                title(sprintf('\\eta = %g, Direction: %g (%s)', etarange(ind), directions(ind), dir_vec{0.5.*directions(ind)+1.5}), 'interpreter', 'Tex')
                Y = polyval(fit, p.betarange);
                plot(p.betarange, Y, ':')
            end
        end
    end
    avg_direction = mean(directions);
    
end