function out = test_a_feature(featurestr, subfeaturestr, inputs, p, makeplot)
% Parameter is 'p' in feature string
    fvals = [];
    if nargin < 3 || isempty(inputs)
        cpvals = [-1:0.05:-0.01];%[-1:0.1:-0.1, -0.01];
        etavals = [0.05:0.05:1];%[0.01, 0.1:0.1:1];%[0.3, 0.5, 1];[0.01:0.01:1];%
    else
        cpvals = inputs.cp_range;
        etavals = inputs.etarange;
    end
    if nargin < 4 
        p = [];
    end
    if nargin < 5 || isempty(makeplot)
        makeplot = 1;
    end
    if nargin < 3 || isempty(inputs)
    	[z, ~, labels] = time_series_generator('cp_range', cpvals, 'etarange', etavals, 'savelength', 5000, 'T', 'tmax./2');%, 'system_type', 'quadratic_potential');%, 'system_type', 'supercritical_hopf_radius_(strogatz)-non-reflecting');
    else
    	[z, ~, labels] = time_series_generator('input_struct', inputs, 'cp_range', cpvals, 'etarange', etavals);
    end
    subfeaturestr_check = ~isempty(subfeaturestr);
    cplabels = cellfun(@(x) str2double(regexprep(x, '\|.*', '')), labels);
    etalabels = cellfun(@(x) str2double(regexprep(x, '.*\|', '')), labels);
    for i = 1:length(cpvals)
        for t = 1:length(etavals)
            %disp(i), disp(t)
            x = z(((abs(cplabels - cpvals(i)) < abs(cpvals(i)*10^(-10))) &...
                (abs(etalabels - etavals(t)) < abs(etavals(t)*10^(-10)))), :); % Precision errors when converting to and from strings
            res = eval(featurestr); % Uses timeseries 'x', if user enters string correctly
            for v = 1:max(length(subfeaturestr), 1)
                if subfeaturestr_check ~= 0
                    fvals(i, t, v) = res.(subfeaturestr{v});
                else
                    fvals(i, t, 1) = res;
                end
            end
        end
    end
    if makeplot
        cmap = inferno(length(etavals));
        for v = 1:max(length(subfeaturestr), 1)
            figure, hold on
            corrvecx = [];
            corrvecy = [];
            for i = 1:length(etavals)
                plot(cpvals, fvals(:, i, v), '.', 'color', cmap(i, :), 'markersize', 18)
                corrvecx(end+1:end+length(cpvals)) = cpvals;
                corrvecy(end+1:end+length(cpvals)) = fvals(:, i, v);
            end
            if subfeaturestr_check ~= 0
                title([featurestr, '.', subfeaturestr{v}, ': ', num2str(corr(corrvecx', corrvecy'))], 'interpreter', 'none')
            else
                title([featurestr, ': ', num2str(corr(corrvecx', corrvecy'))], 'interpreter', 'none')
            end
            colormap(cmap)
            c = colorbar;
            if length(etavals) > 1
                caxis([min(etavals), max(etavals)])
            end
            c.Label.String = '\eta';
            c.Label.Rotation = 0;
            c.Label.FontSize = 18;
            xlabel('$$\mu$$', 'interpreter', 'latex', 'fontsize', 18)
            ylabel('$$f$$', 'interpreter', 'latex', 'fontsize', 18)
            set(gcf, 'Color', 'w')
        end
    end
    out.rows_cpvals = cpvals;
    out.columns_etavals = etavals;
    out.featurestrings = subfeaturestr;
    out.featurevals = fvals;
end
