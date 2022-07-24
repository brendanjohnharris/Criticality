addpath(genpath('../'));
load('./time_series_data.mat');
num_hctsa = 7873; % The number of hctsa features. Any above this are custom

%% Remove the custom features
for r = 1:length(time_series_data)
    time_series_data(r).TS_DataMat = time_series_data(r).TS_DataMat(:, 1:num_hctsa);
    time_series_data(r).Operations = time_series_data(r).Operations(1:num_hctsa, :);
    idxs = time_series_data(r).Correlation(:, 2) <= num_hctsa;
    time_series_data(r).Correlation = time_series_data(r).Correlation(idxs, :);
end

%% Figure 1
histogramStat(time_series_data, 'Absolute_Correlation', 'Absolute_Correlation_Mean');
xlim([0, 1])
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
saveas(gcf,'fig1a.pdf')
% ..... part b.....

%% Figure 2
histogramStat(time_series_data, 'Aggregated_Absolute_Correlation');
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
saveas(gcf,'fig2a.pdf')
% ..... part b.....