function PlotNSScatter(params,whatFeature)
% Overloading humanStructureFunction for arbitrary features
% ------------------------------------------------------------------------------
% Correlating group NS and RLFP - gives a scatter of RLFP and NS

%-------------------------------------------------------------------------------
% Parameters:
%-------------------------------------------------------------------------------
if nargin < 1
    params = GiveMeDefaultParams();
end
if nargin < 2
    whatFeature = 'criticality';
end

%-------------------------------------------------------------------------------
% Load data, compute LFP
%-------------------------------------------------------------------------------
% Compute group NS:
grpNS = GroupNodeStrength(params.data);

if ~iscell(whatFeature)
    switch whatFeature
    case 'RLFP'
        % Compute group RLFP:
        RLFPMat = GroupTimeSeriesFeature(params,whatFeature);
        grpTSstat = nanmean(RLFPMat,2);
    case 'fALFF'
        fALFFMat = GroupTimeSeriesFeature(params,whatFeature);
        grpTSstat = nanmean(fALFFMat,2);
    case 'timescale'
        % Compute timescale:
        [timescaleMatDecay,timescaleMatArea] = GroupTimeSeriesFeature(params,whatFeature);
        switch params.timescale.whatTimeScale
            case 'decay' % as Murray
                grpTSstat = nanmean(timescaleMatDecay,2);
            case 'area' % as Watanabe
                grpTSstat = nanmean(timescaleMatArea,2);
        end
    case 'criticality' 
        % Compute a robust feature for measuring distance to bifurcations
        SSDMat = GroupTimeSeriesFeature(params,whatFeature);
        grpTSstat = nanmean(SSDMat,2);
    end
else % Arbitrary feature. See overloaded groupTimeSeriesFeature.
    fMat = GroupTimeSeriesFeature(params,whatFeature);
    grpTSstat = nanmean(fMat,2);
    whatFeature = [whatFeature{:}];
end

%-------------------------------------------------------------------------------
%% Analysis
%-------------------------------------------------------------------------------
% Correlation (without controlling for region volume)
[r_raw,p_raw] = corr(grpNS,grpTSstat,'type','Spearman');

% Load volume data:
[~,grpVOL] = GroupRegionVolumes(params);

% Partial Correlation (controlling for region volume):
[r_corr,p_corr,resids] = partialcorr_with_resids(grpNS,grpTSstat,grpVOL,'type','Spearman','rows','complete');
grpNS_resid = resids(:,1);
grpTSstat_resid = resids(:,2);
dataWasUsed = ~isnan(grpTSstat);

%-------------------------------------------------------------------------------
%% Plots
%-------------------------------------------------------------------------------
% Scatter plot of NS against RLFP (uncorrected)
f = figure('color','w');
plot(grpNS,grpTSstat,'ok','MarkerFaceColor','k','LineWidth',2);
% lsline;
xlabel('Node strength')
ylabel(whatFeature)
% ylabel('Low frequency power')
axis('square')
fprintf(1,'Spearman correlation (NS--%s) %.3f\n',whatFeature,r_raw);
title({r_raw;p_raw})
f.Position(3:4) = [256,230];


%-------------------------------------------------------------------------------
% Scatter plot of residual NS against residual LFP
f = figure('color','w');
plot(grpNS_resid,grpTSstat_resid,'ok','MarkerFaceColor','k','LineWidth',2);
xlabel('Node Strength residual')
ylabel(sprintf('%s residual',whatFeature))
title({r_corr;p_corr})
fprintf(1,'Spearman correlation (residuals): %.3f\n',r_corr);
f.Position(3:4) = [256,230];

%-------------------------------------------------------------------------------
%% Repeat the scatter with labels corresponding to regions
f = figure('color','w');
scatter(grpNS_resid,grpTSstat_resid);
doAddLabels = true;
if doAddLabels
    a = (1:params.data.numAreas)';
    a = a(dataWasUsed);
    b = num2str(a);
    c = cellstr(b);
    % displacement so the text does not overlay the data points
    dx = 0.3;
    dy = 0.3;
    text(grpNS_resid+dx,grpTSstat_resid+dy,c);
end
xlabel('Node Strength residual')
ylabel(sprintf('%s residual',whatFeature))

%-------------------------------------------------------------------------------
%% Plot region volume against the time-series statistic
[r_vol,p_vol] = corr(grpVOL,grpTSstat,'type','Spearman');
f = figure('color','w');
plot(grpVOL,grpTSstat,'ok','MarkerFaceColor','k','LineWidth',2);
xlabel('Group-level volume')
ylabel(whatFeature)
title({r_vol;p_vol})

end
