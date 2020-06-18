function fillScatter(ax, colorMap)
%FILLSCATTER Give an axes that has one or more line objects in it, and fill
%the (circular) markers with colors drawn from a colormap over normalised Y values
% Will need to remove 'line' markers and overlay 'scatter' markers
    if nargin < 1 || isempty(ax)
        ax = gca;
    end
    if nargin < 2 || isempty(colorMap)
        colorMap = flipud(BF_getcmap('redyellowblue',6,0));
    end
    lineIdxs = arrayfun(@(x) isa(x,'matlab.graphics.chart.primitive.Line'), ax.Children);
    lines = ax.Children(lineIdxs);
    YData = arrayfun(@(x) x.YData, lines, 'UniformOutput', 0);
    YData = cell2mat(YData);
    CData = zscore(YData, [], 'all');
    for i = 1:length(lines)
        lines(i).Marker = 'none';
        colorMapData = interp1(linspace(min(CData(i, :)), max(CData(i, :)), size(colorMap, 1)), colorMap, CData(i, :), 'linear');
        scatter(lines(i).XData, lines(i).YData, 50, lines(i).Color, 'Filled')
        scatter(lines(i).XData, lines(i).YData, 25, colorMapData, 'Filled')
    end
    
end

