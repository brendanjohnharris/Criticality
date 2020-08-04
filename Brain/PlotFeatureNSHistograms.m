function f = PlotFeatureNSHistograms()
%PLOTFEATURENSHISTOGRAMS 
    features = {'RLFP', 'criticality', {'CO_AutoCorr(x, 1)'}};
    featureLabels = {'RLFP', 'Summary Feature', 'AC\_1'};
    parcellation = 'DK';
    
%     features = {{'delayDistributions(x, 1, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 2, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 5, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 10, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 20, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 50, 1)', 'scaleSigmaDifference'},...
%         {'delayDistributions(x, 100, 1)', 'scaleSigmaDifference'}};
%     featureLabels = {};
    
    f = figure('color', 'w');
    hold on
    params = GiveMeDefaultParams(parcellation);
    subfile = load(params.data.subjectInfoFile);
    numSubjects = length(subfile.subs100.subs);
    
    %colors = [GiveMeColors(7); {[0, 0, 0]}];
    %colors{1, :} = [31 120 180]./256;
    
    for ff = 1:length(features)
        fMat = GroupTimeSeriesFeature(params,features{ff});
        
        for i = 1:numSubjects
            subID = subfile.subs100.subs(i);
            NS = ComputeNodeStrength(subID,params.data);
            VOL = GetRegionVolumes(subID,params.data);
            %[fCorr(i), fPval(i)] = corr(fMat(:, i),NS,'type','Spearman');
            [fCorr(i), fPval(i)] = partialcorr(fMat(:, i),NS,VOL,'type','Spearman');
        end
        %featureCorr(:, f) = fCorr;
        %featurePval(:, f) = fPval;
        customHistogram(fCorr, 15, [], 0);
    end
    
    legend(featureLabels)
    xlabel('Partial Spearman Correlation')
    ylabel('Number of Subjects')
    
end

