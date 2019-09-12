function [pmat, ps] = pairwiseFeatureSimilarity(datamat, ps, metric)
%PAIRWIESEFEATUREDISTANCE Summary of this function goes here
%   Detailed explanation goes here
    if nargin < 3 || isempty(metric)
        metric = 'euclidean';
    end
   
    pmat = BF_pdist(datamat, metric);
    imagesc(pmat)
    ax = gca;
    tickidxs = [1, linspace(length(ps)./10, length(ps), 10)];
    ax.XAxis.MinorTickValues = 1:size(datamat, 1);
    ax.YAxis.MinorTickValues = ax.XTick;
    ax.XAxis.TickValues = tickidxs;
    ax.YAxis.TickValues = tickidxs;
    ax.XAxis.TickLabels = ps(tickidxs);
    ax.YAxis.TickLabels = ps(tickidxs);
    set(gcf, 'color', 'w')
    
%     switch metric
%         case 'euclidean'
%             colormap(inferno(100))
%         case 'correlation'
%             colormap(cbrewer('div', 'RdBu', 100))
%     end
    colormap(inferno(100))
    c = colorbar;
    axis xy
end

