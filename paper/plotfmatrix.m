addpath(genpath('../'));
load('./time_series_data.mat');

fmatrix = BF_NormalizeMatrix(time_series_data(51).TS_DataMat(:, 1:7873));
fmatrix = fmatrix(:, all(~isnan(fmatrix)));
cmp = cbrewer('div', 'RdYlBu', 10);
figure()
colormap(cmp)
imagesc(fmatrix(:, BF_ClusterReorder(fmatrix)))
set(gca,'visible','off')
exportgraphics(gcf, "fmatrix.pdf")

% fmatrix = extractDataMat(time_series_data);
% fmatrix = BF_NormalizeMatrix(fmatrix(:, 1:7873));
% fmatrix = fmatrix(:, all(~isnan(fmatrix)));
% cmp = cbrewer('div', 'RdBu', 10);
% figure()
% colormap(cmp)
% imagesc(fmatrix(:, BF_ClusterReorder(fmatrix(1:3:end, :))))
% set(gca,'visible','off')
% exportgraphics(gcf, "fmatrix_full.pdf")