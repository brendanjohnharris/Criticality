% Load a time_series_data struct, then:

tbl = get_combined_feature_stats(time_series_data, {'Absolute_Correlation'}, {'Absolute_Correlation_Mean', 'Aggregated_Absolute_Correlation'}, [], 1);
tbl = tbl(tbl.Operation_ID <= 7873, :);% Remove custom features

% Fixed Noise
tbl = sortrows(tbl, 4, 'Desc', 'Comparison', 'abs', 'Missing', 'Last');
ps = tbl.Operation_ID(1:100); % Top 100 features
[~, ps, pnums] = pairwiseFeatureSimilarity(time_series_data, ps, 'Spearman');%, [19, 93]);
set(gca,'ColorScale','log')
% First cluster is 84 features large
fprintf('Fixed Noise: First cluster average correlation is %g\n', mean(tbl(ismember(tbl.Operation_ID, pnums(1:84)), :).('Absolute_Correlation_Mean')))
fprintf('Fixed Noise: Second cluster average correlation is %g\n', mean(tbl(ismember(tbl.Operation_ID, pnums(85:end)), :).('Absolute_Correlation_Mean')))

% Variable Noise
tbl = sortrows(tbl, 5, 'Desc', 'Comparison', 'abs', 'Missing', 'Last');
ps = tbl.Operation_ID(1:100);
[~, ps, pnums] = pairwiseFeatureSimilarity(time_series_data, ps, 'Spearman');%, [19, 93, 3535, 1711, 3332, 6275]);