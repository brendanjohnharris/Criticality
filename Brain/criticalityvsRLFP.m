params = GiveMeDefaultParams();
RLFPMat = GroupTimeSeriesFeature(params,'RLFP');
SSDMat = GroupTimeSeriesFeature(params,'criticality');

scatter(RLFPMat(:), SSDMat(:), 100, '.')
xlabel('RLFP')
ylabel('RAD')
title(corr(RLFPMat(:), SSDMat(:),'type','Spearman'))
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
exportgraphics(gcf,'figa.pdf')


scatter(nanmean(RLFPMat,2), nanmean(SSDMat,2), 200, '.');
xlabel('RLFP')
ylabel('RAD')
title(corr(nanmean(RLFPMat,2), nanmean(SSDMat,2),'type','Spearman'))
set(gcf, 'visible', 'off'); 
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 5], 'PaperUnits', 'points');
exportgraphics(gcf,'figb.pdf')
