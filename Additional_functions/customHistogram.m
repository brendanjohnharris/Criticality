function [origy, BinEdges] = customHistogram(X, BinEdges, cutoff, fillit, theColor)
    if ~isvector(X) && ~iscell(X) % Plot the columns of the matrix x
        X = arrayfun(@(u) X(:, u), 1:size(X, 2), 'un', 0);
    elseif isvector(X) && ~iscell(X)
        X = {X};
    end
    if nargin < 2 || isempty(BinEdges)
        BinEdges = 20;
    end
    if isscalar(BinEdges) && ~iscell(BinEdges)
        numBins = BinEdges;
        BinEdges = cell(1, length(X));
        for t = 1:length(X)
            binCs = linspace(min(X{t}), max(X{t}), numBins);
            dB = (binCs(2) - binCs(1))./2;
            BinEdges{t} = [binCs - dB, binCs(end) + dB];
        end
    elseif isvector(BinEdges) && ~iscell(BinEdges)
        BinEdges = {BinEdges};
    end  
    if nargin < 3
        cutoff = [];
    end
    if iscell(X) && isscalar(cutoff)
        cutoff = repmat(cutoff, 1, length(X));
    end
    if nargin < 4 || isempty(fillit)
        fillit = 0;
    end
    ax = gca;
    set(gcf, 'color', 'w')
    hold on
    for i = 1:length(X)
        if nargin < 5 || isempty(theColor)
            theColor = ax.ColorOrder(ax.ColorOrderIndex, :);
            advanceCO = 1;
        else
            advanceCO = 0;
        end
        binedges = BinEdges{i}(:);
        x = X{i};
        x = x(:); 
        z = binedges;
        y = histcounts(x, z);
        y = y(:);

        y = [y, y]';
        y = y(:);
        z = [z, z]';
        z = z(:);
        z = z(2:end-1);
        bincenters = mean([binedges(1:end-1), binedges(2:end)], 2);
        origy = histcounts(x, binedges);
        COind = ax.ColorOrderIndex;
        
        
        if ~isempty(cutoff)
            zidxs = z < cutoff;

            bidxs = bincenters < cutoff;
            if fillit
                b = bar(bincenters(bidxs), origy(bidxs), 1, 'edgecolor', 'none', 'FaceColor', theColor);
                b.FaceAlpha = 0.1;
                b.HandleVisibility = 'off';
                b = bar(bincenters(~bidxs), origy(~bidxs), 1, 'edgecolor', 'none', 'FaceColor', theColor);
                b.FaceAlpha = 0.3;
            else
                plot(z, y, ':', 'HandleVisibility', 'off', 'LineWidth', 2, 'Color', theColor)
                cy = y(~zidxs);
                cz = z(~zidxs);
                if isempty(cy), cy = NaN; end
                if isempty(cz), cz = NaN; end
                plot([NaN; cutoff; cutoff; cz], [NaN; 0; cy(1); cy], '-', 'HandleVisibility', 'on', 'LineWidth', 4, 'Color', theColor)
            end
        else
            if fillit
                b = bar(bincenters, origy, 1, 'edgecolor', 'none', 'FaceColor', theColor);
                b.FaceAlpha = 0.3;
            else
                plot(z, y, '-', 'LineWidth', 4, 'Color', theColor)
            end
        end
        ax.ColorOrderIndex = COind + advanceCO;
        if ax.ColorOrderIndex > size(ax.ColorOrder, 1)
            ax.ColorOrderIndex = 1;
        end
    end
    hold off
end

