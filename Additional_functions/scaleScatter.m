function [f, ax] = scaleScatter(x, y, r, color, xoryscale)
%SCALESCATTER Scatter the specified points so that their radisu scales with
%the axes
    if nargin < 4
        color = 'k';
    end
    if nargin < 5 || isempty(xoryscale)
        xoryscale = 1; % 1 for x
    end
    x = x(:);
    y = y(:);
    rcell = cell(1, length(x));
    if length(x) ~= length(y)
        error('The vectors must contain an equal number of points')
    end
    for i = 1:length(x)
        rcell{i} = rectangle('Position', [x(i)-r, y(i)-r, 2*r, 2*r], 'Curvature', [1, 1],...
            'FaceColor', color, 'EdgeColor', color, 'LineWidth', 0.0001);
    end
    % Now that all the data is plotted, get the axis limits
    ax = gca;
    yli = ax.YLim;
    xli = ax.XLim;
    yscale = ax.Position(4);
    xscale = ax.Position(3);
    if xoryscale == 1
        upx = 0;
        upy = r.*xscale./yscale;
    elseif xoryscale == 2
        upx = r.*yscale./xscale;
        upy = 0;
    end
    for i = 1:length(x)
        rcell{i}.Position = rcell{i}.Position + [0, 0, 2*upx, 2*upy];
    end
    ax.XLim = xli;
    ax.YLim = yli;
end

