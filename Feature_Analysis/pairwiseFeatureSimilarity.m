function [pmat, ps, pnums] = pairwiseFeatureSimilarity(datamat, ps, metric, reduce)
%PAIRWIESEFEATURESIMILARITY
    if nargin < 3 || isempty(metric)
        metric = 'spearman';
    end
    if nargin < 4
        reduce = 0;
    end
    ops = [];
    if isstruct(datamat)
        ops = datamat(1, :).Operations; % Assume same ops for all rows
        datamat = extractDataMat(datamat, [], [], ps);
    end
    % if isscalar(ps)
    %     tbl = get_combined_feature_stats(time_series_data, {}, {'Aggregated_Absolute_Correlation'}, [], 1);
    %     tbl = sortrows(tbl, 4, 'Desc', 'Comparison', 'abs', 'Missing', 'Last');
    %     ps = tbl(1:ps).Operation_ID;
    % end
    ps = sort(ps, 'asc');
    %datamat = BF_NormalizeMatrix(datamat', 'zscore');
    %pmat = squareform(pdist(datamat', metric));
    pmat = 1-abs(corr(datamat, 'Type', metric));
    ord = BF_ClusterReorder(datamat', pmat);
    pmat = pmat(ord, ord);
    ps = ps(ord);

    figure('color', 'w')
    imagesc(pmat)
    ax = gca;
    %tickidxs = sort([ floor(linspace(length(ps)./4, length(ps), 4)), find(ps == 93), find(ps == 19)], 'asc');
    tickidxs = 1:length(ps);
    
    if isempty(reduce) || length(reduce) > 1 || reduce
        tickidxs = tickidxs(ismember(ps, reduce));
    end
    
    ax.XAxis.MinorTickValues = [];
    ax.YAxis.MinorTickValues = ax.XTick;
    ax.XAxis.TickValues = [];
    ax.YAxis.TickValues = tickidxs;

    pnums = ps;
    if ~isempty(ops)
        ps = cellsqueeze(arrayfun(@(x) ops(ops.ID == x, :).Name, ps, 'Un', 0));
    end
    ax.XAxis.TickLabels = [];
    ax.YAxis.TickLabels = ps(tickidxs);
    ax.FontSize = 8;
    ax.TickLabelInterpreter = 'none';
    ax.XAxis.TickLabelRotation = 90;
    set(gcf, 'color', 'w')

%     switch metric
%         case 'euclidean'
%             colormap(turbo(100))
%         case 'correlation'
%             colormap(cbrewer('div', 'RdBu', 100))
%     end
    %colormap(turbo(1000))
    colormap(flipud(gray(1000)));
    c = colorbar;
    %axis xy
    axis square
    ax.FontSize = 6;
    %caxis([0, 1])
    c.FontSize = 15;
    %c.Ticks = c.Ticks(1:2:end);
    c.Label.String = '$1-|\rho|$';
    c.Label.Interpreter = 'LaTeX';
    c.Label.FontSize = 28;
    c.Label.Rotation = 0;
    c.Label.Position = c.Label.Position.*[1.2, 1.025, 0];
    
    if isempty(reduce) || length(reduce) > 1 || reduce
        ax.FontSize = 10;
         c.Label.Position.*[1.3, 1.025, 0];
         %c.Ticks = c.Ticks(1):0.1:c.Ticks(end);
    end
    
    set(gca, 'TickLength',[0 0])    
end
