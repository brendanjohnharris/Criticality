function PlotNSIndividual(params,whatFeature,nSubj)
% ------------------------------------------------------------------------------
% Correlating group NS and RLFP - gives a scatter of RLFP and NS, withotu
% averaging subjects.

%-------------------------------------------------------------------------------
% Parameters:
%-------------------------------------------------------------------------------
if nargin < 1
    params = GiveMeDefaultParams();
end
if nargin < 2
    whatFeature = 'criticality';
end
if nargin < 3
    nSubj = [];
end

subfile = load(params.data.subjectInfoFile);

%-------------------------------------------------------------------------------
% Load data, compute LFP
%-------------------------------------------------------------------------------
% Compute group NS:
grpNS = GroupNodeStrength(params.data);

if ~iscell(whatFeature)
    switch whatFeature
    case 'RLFP'
        % Compute group RLFP:
        fMat = GroupTimeSeriesFeature(params,whatFeature);
    case 'fALFF'
        fMat = GroupTimeSeriesFeature(params,whatFeature);
    case 'timescale'
        % Compute timescale:
        [timescaleMatDecay,timescaleMatArea] = GroupTimeSeriesFeature(params,whatFeature);
        switch params.timescale.whatTimeScale
            case 'decay' % as Murray
                fMat = timescaleMatDecay;
            case 'area' % as Watanabe
                fMat = timescaleMatArea;
        end
    case 'criticality' 
        % Compute a robust feature for measuring distance to bifurcations
        fMat = GroupTimeSeriesFeature(params,whatFeature);
    end
else % Arbitrary feature. See overloaded groupTimeSeriesFeature.
    fMat = GroupTimeSeriesFeature(params,whatFeature);
    whatFeature = [whatFeature{:}];
end

subIDs = randperm(size(fMat, 2), nSubj);
subNums = subfile.subs100.subs;

if ~isempty(nSubj)
    fMat = fMat(:, subIDs);
end

%grpNS = repmat(grpNS, 1, size(fMat, 2));
grpNS = fMat; % For size
for subj = 1:length(subIDs)
    grpNS(:, subj) = ComputeNodeStrength(subNums(subIDs(subj)),params.data);
end

% Load volume data:
grpVOL = grpNS; % Right size
for i = 1:length(subIDs)
    grpVOL(:, i) = GetRegionVolumes(subNums(subIDs(i)),params.data);
end

grpNS = grpNS(:);
fMat = fMat(:);
grpVOL = grpVOL(:);

%-------------------------------------------------------------------------------
%% Analysis
%-------------------------------------------------------------------------------
% Correlation (without controlling for region volume)
[r_raw,p_raw] = corr(grpNS,fMat,'type','Spearman');

% Partial Correlation (controlling for region volume):
[r_corr,p_corr,resids] = partialcorr_with_resids(grpNS,fMat,grpVOL,'type','Spearman','rows','complete');
grpNS_resid = resids(:,1);
fMat_resid = resids(:,2);
dataWasUsed = ~isnan(fMat);

whatFeature = strrep(whatFeature, '_', '\_');

%-------------------------------------------------------------------------------
%% Plots
%-------------------------------------------------------------------------------
% Scatter plot of NS against RLFP (uncorrected)
f = figure('color','w');
plot(grpNS,fMat,'.k','MarkerFaceColor','k');
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
plot(grpNS_resid,fMat_resid,'.k','MarkerFaceColor','k');
xlabel('Node Strength residual')
ylabel(sprintf('%s residual',whatFeature))
title({r_corr;p_corr})
fprintf(1,'Spearman correlation (residuals): %.3f\n',r_corr);
f.Position(3:4) = [256,230];

%-------------------------------------------------------------------------------
% %% Repeat the scatter with labels corresponding to regions
% f = figure('color','w');
% scatter(grpNS_resid,fMat_resid);
% doAddLabels = true;
% if doAddLabels
%     a = (1:params.data.numAreas)';
%     a = a(dataWasUsed);
%     b = num2str(a);
%     c = cellstr(b);
%     % displacement so the text does not overlay the data points
%     dx = 0.3;
%     dy = 0.3;
%     text(grpNS_resid+dx,fMat_resid+dy,c);
% end
% xlabel('Node Strength residual')
% ylabel(sprintf('%s residual',whatFeature))

%-------------------------------------------------------------------------------
%% Plot region volume against the time-series statistic
[r_vol,p_vol] = corr(grpVOL,fMat,'type','Spearman');
f = figure('color','w');
plot(grpVOL,fMat,'.k','MarkerFaceColor','k');
xlabel('Group-level volume')
ylabel(whatFeature)
title({r_vol;p_vol})

end
