
loadFile = './Data/18SubjfMRI/';
workFile = 'testSubjfMRIData.mat';

doBinarize = false;%true;
pThreshold = 0.05;
whatWeightMeasure = 'CS';%'NCD';
lag = [1, 34];


data = autoLoad(loadFile);
save(workFile, 'data')
calcfMRI({'CO_AutoCorr(x, params)', 'delayDistributions(x, params, 1)'}, {[], 'scaleSigmaDifference'}, workFile, lag);

nodeDegrees(doBinarize, pThreshold, whatWeightMeasure, workFile);
regionVolumes(workFile);
averageSubject(workFile)
data = autoLoad(workFile);

figure('color', 'w');
plot(data.RegionVolume, data.kin, '.k')
title(num2str(corr(data.RegionVolume, data.kin, 'type', 'spearman')))

figure('color', 'w')
rho = arrayfun(@(x) corr(data.kin, data.(['CO_AutoCorrx', num2str(x)]), 'Type', 'Spearman'), lag);
plot(lag, abs(rho))

figure('color', 'w');
plot(data.kin, data.CO_AutoCorrx34, '.k')
title(num2str(corr(data.kin, data.CO_AutoCorrx34, 'type', 'spearman')))

figure('color', 'w')
[r,p,res] = partialcorr_with_resids(data.kin, data.CO_AutoCorrx34, data.RegionVolume, 'Type', 'Spearman');
plot(res(:, 1), res(:, 2), '.k')
title(num2str(r))

figure('color', 'w')
[r,p,res] = partialcorr_with_resids(data.kin, data.delayDistributionsx341scaleSigmaDifference, data.RegionVolume, 'Type', 'Spearman');
plot(res(:, 1), res(:, 2), '.k')
title(num2str(r))