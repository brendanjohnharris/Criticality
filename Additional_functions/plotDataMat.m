function [f, ax] = plotDataMat(datamat, normdir, customMap, groupdim)
%PLOTDATAMAT Plot a matrix with a focus on aesthetic
% groupdim: 1 for column grouping, 2 for row grouping
    if nargin < 2
        normdir = [];
    end
    if nargin < 3 || isempty(customMap)
        customMap = flipud(BF_getcmap('redyellowblue',6,0));
    end
    if nargin < 4
        groupdim = [];
    end
    if ~isempty(groupdim)
        groupdim = -groupdim + 3;
    end
    f = gcf;
    ax = gca;
    if ~isempty(normdir)
        datamat = zscore(datamat, [], normdir);
    end
    if isempty(groupdim)
        imagesc(datamat)
        colormap(ax, customMap)
        caxis([-1, 1])
    else
        hold on
        for i = 1:size(datamat, groupdim)
            if groupdim == 1
                submat = datamat(i, :); % Get the ith row to plot
            elseif groupdim == 2
                submat = datamat(:, i);
            end 
            submat(isnan(submat)) = 0;
            submat(submat > 1.5) = 1.5;
            submat(submat < -1.5) = -1.5;
            submat = round(mat2gray(submat).*100);
            colorMap = flipud(interpColors([1 1 1], customMap(i, :), 100));
            if groupdim == 1
                image(1, i, ind2rgb(submat, colorMap))
            elseif groupdim == 2
                image(i, 1, ind2rgb(submat, colorMap))
            end
        end
        axis tight
        axis ij
        hold off
    end
    if ~isempty(normdir)
        for i = 1:size(datamat, -normdir+3)
            if normdir == 2
                yline(i-0.5, '-k');
            elseif normdir == 1
                xline(i-0.5, '-k');
            end
        end
    end
    ax.XTickLabels = {};
    ax.YTickLabels = {};
    ax.XTick = [];
    ax.YTick = [];
    axis square
    set(gcf, 'color', 'w')
    ax.Box = 'on';
end

