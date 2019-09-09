function test_a_feature_parameter(featurestr, subfeaturestr, inputs, parameter)
% parameter in feature string is 'p'
    mean_eta_corr = zeros(1, length(parameter));
    agg_corr = zeros(1, length(parameter));
    for i = 1:length(parameter)
        p = parameter(i);
        [~, out] = evalc("test_a_feature(featurestr, subfeaturestr, inputs, p, 0)");
        mean_eta_corr(i) = nanmean(corr(out.columns_etavals', out.featurevals', 'type', 'spearman'));
        cpvals = repmat(out.rows_cpvals(:), length(out.columns_etavals), 1);
        fvals = out.featurevals(:);
        agg_corr(i) = corr(cpvals, fvals, 'type', 'pearson');
        fprintf('%i of %i complete\n', i, length(parameter))
    end
    figure
    plot(parameter, agg_corr, '.-')
    hold on
    plot(parameter, mean_eta_corr, '.-')
    hold off
    set(gcf, 'color', 'w')
    legend({'Aggregated Correlation (Pearson)', 'Mean Eta Correlation (Spearman)'})
    ylabel('Correlation')
    xlabel('Parameter')
end

