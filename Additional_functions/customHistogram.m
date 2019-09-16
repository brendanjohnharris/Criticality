function customHistogram(x, binedges, cutoff, fillit, theColor)
    if nargin < 3
        cutoff = [];
    end
    if nargin < 4 || isempty(fillit)
        fillit = 0;
    end
    ax = gca;
    if nargin < 5 || isempty(theColor)
        theColor = ax.ColorOrder(ax.ColorOrderIndex, :);
        advanceCO = 1;
    else
        advanceCO = 0;
    end
    binedges = binedges(:);
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
end

