function out = test_a_feature(featurestr, subfeaturestr, inputs)
    fvals = [];
    if nargin < 3 || isempty(inputs)
        cpvals = [-1:0.1:-0.1, -0.01];
        etavals = [0.01, 0.1:0.1:1];%[0.3, 0.5, 1];[0.01:0.01:1];%
    else
        cpvals = inputs.cp_range;
        etavals = inputs.etarange;
    end
    for i = 1:length(cpvals)
        for t = 1:length(etavals)
            disp(i), disp(t)
            if nargin < 3 || isempty(inputs)
                x = time_series_generator('cp_range', cpvals(i), 'etarange', etavals(t), 'savelength', 50000);%, 'system_type', 'subcritical_hopf_radius_(strogatz)');
            else
                x = time_series_generator('input_struct', inputs, 'cp_range', cpvals(i), 'etarange', etavals(t));
            end
            res = eval(featurestr);
            for v = 1:length(subfeaturestr)
                fvals(i, t, v) = res.(subfeaturestr{v});
            end
        end
    end
    cmap = inferno(length(etavals));
    for v = 1:length(subfeaturestr)
        figure, hold on
        corrvecx = [];
        corrvecy = [];
        for i = 1:length(etavals)
            plot(cpvals, fvals(:, i, v), '-', 'color', cmap(i, :))
            corrvecx(end+1:end+length(cpvals)) = cpvals;
            corrvecy(end+1:end+length(cpvals)) = fvals(:, i, v);
        end
        title([subfeaturestr{v}, ': ', num2str(corr(corrvecx', corrvecy'))], 'interpreter', 'none')
        colormap(cmap)
        c = colorbar;
        caxis([min(etavals), max(etavals)])
        c.Label.String = '\eta';
        c.Label.Rotation = 0;
        c.Label.FontSize = 18;
        xlabel('$$\mu$$', 'interpreter', 'latex', 'fontsize', 18)
        ylabel('$$f$$', 'interpreter', 'latex', 'fontsize', 18)
        set(gcf, 'Color', 'w')
    end
    out.rows_cpvals = cpvals;
    out.columns_etavals = etavals;
    out.featurestrings = subfeaturestr;
    out.featurevals = fvals;
end
