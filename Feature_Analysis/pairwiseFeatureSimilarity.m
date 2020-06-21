function [pmat, ps] = pairwiseFeatureSimilarity(datamat, ps, metric)
%PAIRWIESEFEATURESIMILARITY
    if nargin < 3 || isempty(metric)
        metric = 'spearman';
    end
    %datamat = BF_NormalizeMatrix(datamat', 'zscore');
    %pmat = squareform(pdist(datamat', metric));
    pmat = abs(corr(datamat));
    ord = BF_ClusterReorder(datamat', 1-pmat);
    pmat = pmat(ord, ord);
    ps = ps(ord);
    
    figure('color', 'w')
    imagesc(pmat)
    ax = gca;
    tickidxs = sort([ floor(linspace(length(ps)./4, length(ps), 4)), find(ps == 93), find(ps == 19)], 'asc');
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
    %colormap(inferno(100))
    colormap(parula)
    c = colorbar;
    axis xy
end

