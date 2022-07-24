
loadFile = './Data/18SubjfMRI/';
workFile = 'testSubjfMRIData.mat';

doBinarize = false;%true;
pThreshold = 0.05;
whatWeightMeasure = 'CS';%'NCD';
lag = [1, 34];


data = autoLoad(loadFile);
save(workFile, 'data')
calcfMRI({'CO_AutoCorr(x, params)', 'delayDistributions(x, params, 1)'}, {[], 'scaleSigmaDifference'}, workFile, lag);

%calcfMRI({'SB_MotifTwo(zscore(x),"mean")'}, {'uu'}, workFile, lag);
%calcfMRI({'DN_RemovePoints(zscore(x),"absfar",0.1)'}, {'ac2diff'}, workFile, lag);
%calcfMRI({'PP_Compare(x,''rav2'')'}, {'kscn_olapint'}, workFile, lag);
%calcfMRI({'ST_LocalExtrema(zscore(x),''l'',100)'}, {'meanrat'}, workFile, lag);

nodeDegrees(doBinarize, pThreshold, whatWeightMeasure, workFile);
regionVolumes(workFile);
averageSubject(workFile);
filterIsocortex(workFile);
data = autoLoad(workFile);

figure('color', 'w');
plot(data.RegionVolume, data.kin, '.k')
title(num2str(corr(data.RegionVolume, data.kin, 'type', 'spearman')))

figure('color', 'w')
rho = arrayfun(@(x) corr(data.kin, data.(['CO_AutoCorrx', num2str(x)]), 'Type', 'Spearman'), lag);
plot(lag, abs(rho), '.-k')

figure('color', 'w')
rho = arrayfun(@(x) partialcorr(data.kin, data.(['delayDistributionsx',...
        num2str(x), '1scaleSigmaDifference']), data.RegionVolume, 'Type', 'Spearman'), lag);
plot(lag, abs(rho), '.-k')

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