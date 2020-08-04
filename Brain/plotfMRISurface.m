function plotfMRISurface(whatFeature)
if nargin < 1 || isempty(whatFeature)
    whatFeature = 'criticality';
end

% Parameters:
whichHemispheres = 'left';
whatParcellation = 'DK'; % 'HCP', 'DK', 'cust200'
surfaceParcellation = 'aparc';

params = GiveMeDefaultParams('DK');
params.data.whichHemispheres = whichHemispheres;
params.data.whatParcellation = whatParcellation;
params.data.surfaceParcellation = surfaceParcellation;
%===============================================================================

% Structural connectivity data:
[grpNS,adjMat] = GroupNodeStrength(params.data);
%[~,adjMat] = group_NS(whichHemispheres,whatParcellation,'SIFT2_connectome','consistency');

% Binarize:
adjMatBin = adjMat;
adjMatBin(adjMatBin > 0) = 1;

allEdges = adjMat(triu(true(size(adjMatBin))));
connectomeDensity = mean(adjMatBin(triu(true(size(adjMatBin)))));
minEdgeWeight = min(allEdges(allEdges>0));
maxEdgeWeight = max(allEdges(allEdges>0));


%-------------------------------------------------------------------------------
% RLFP:
    fMat = GroupTimeSeriesFeature(params, whatFeature);
    fMat = mean(fMat, 2);


    PlotCDataSurface(BF_NormalizeMatrix(fMat,'scaledSigmoid'),surfaceParcellation,'l','medial');
    axis equal
    set(gca, 'Visible', 'off')
    PlotCDataSurface(BF_NormalizeMatrix(fMat,'scaledSigmoid'),surfaceParcellation,'l','lateral');
    axis equal
    set(gca, 'Visible', 'off')
    NS_scaled = BF_NormalizeMatrix(sum(adjMat,2),'scaledSigmoid');
    PlotCDataSurface(NS_scaled,surfaceParcellation,'l','medial');
    axis equal
    set(gca, 'Visible', 'off')
    PlotCDataSurface(NS_scaled,surfaceParcellation,'l','lateral');
    axis equal
    set(gca, 'Visible', 'off')
end
