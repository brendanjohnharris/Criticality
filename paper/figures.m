addpath(genpath('../'));
load('./time_series_data.mat');
num_hctsa = 7873; % The number of hctsa features. Any above this are custom

%% Figure 6
scatterScript

%% Remove the custom features
for r = 1:length(time_series_data)
    time_series_data(r).TS_DataMat = time_series_data(r).TS_DataMat(:, 1:num_hctsa);
    time_series_data(r).Operations = time_series_data(r).Operations(1:num_hctsa, :);
    idxs = time_series_data(r).Correlation(:, 2) <= num_hctsa;
    time_series_data(r).Correlation = time_series_data(r).Correlation(idxs, :);
end

%% Feature score tables
tbl = get_combined_feature_stats(time_series_data, {'Absolute_Correlation'}, {'Absolute_Correlation_Mean', 'Aggregated_Absolute_Correlation'}, [], 1);

%% Figure 2
histogramStat(time_series_data, 'Absolute_Correlation', 'Absolute_Correlation_Mean');
xlim([0, 1])
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
exportgraphics(gcf,'fig2a.pdf')

tbl = sortrows(tbl, 'Absolute_Correlation_Mean', 'Descend', 'ComparisonMethod', 'abs', 'MissingPlacement', 'last');
[pmat, ps, pnums] = pairwiseFeatureSimilarity(time_series_data, tbl.Operation_ID(1:100), 'spearman');
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 13, 13], 'PaperUnits', 'points');
exportgraphics(gcf,'fig2b.pdf')
[~, ~, idxs] = intersect(pnums, tbl.Operation_ID, 'stable');
writetable(tbl(idxs, :), 'fixedNoiseClusters.xls')

%% Figure 3
histogramStat(time_series_data, 'Aggregated_Absolute_Correlation');
xlim([0, 1])
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
exportgraphics(gcf,'fig3a.pdf')

tbl = sortrows(tbl, 'Aggregated_Absolute_Correlation', 'Descend', 'ComparisonMethod', 'abs', 'MissingPlacement', 'last');
[pmat, ps, pnums] = pairwiseFeatureSimilarity(time_series_data, tbl.Operation_ID(1:20), 'spearman');
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 13, 13], 'PaperUnits', 'points');
exportgraphics(gcf,'fig3b.pdf')
[~, ~, idxs] = intersect(pnums, tbl.Operation_ID, 'stable');
writetable(tbl(idxs, :), 'variableNoiseClusters.xls')

%% Figure 4
ops = [19, 93, 1763, 3332, 3535, 6275];
time_series_data = normalise_time_series_data(time_series_data, [-1, 0]);
visualise_feature_fit(time_series_data, ops, 101)
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 8, 8], 'PaperUnits', 'points');
exportgraphics(gcf,'fig4.pdf')
