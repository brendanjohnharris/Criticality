function lag_series_density(x, V)
%   V is a string; a piece of code evaluating a potential as a function of 'r'
    if nargin < 2
        V = [];
    end
    x1 = x(2:end);
    x = x(1:end-1);
    x1(isnan(x)) = NaN;
    x(isnan(x1)) = NaN;
    xscerr = (x1 - x)./sqrt(2);
    r = mean([x; x1], 1)./sqrt(2);
    med = median(r);
    if ~isempty(V)
        Vr = eval(V);
    else
        Vr = x;
    end
    %plot(x1, x, 'ko', 'markersize', 1)
    %[N, C] = hist3([x', x1'], [100, 100]);
    %contourf(C{1}, C{2}, N, 1000, 'linestyle', 'none')
    %figure
    %histogram2(x, x1, 50, 'facecolor', 'flat', 'DisplayStyle', 'tile'), a = gca; a.GridLineStyle = 'none'; set(gcf, 'Color', 'w')
    %figure
    histogram2(r, xscerr, 50, 'facecolor', 'flat', 'DisplayStyle', 'tile')
    a = gca;
%     xli = a.XLim;
%     yli = a.YLim;
    hold on
    %plot([med, med], [a.YLim(1), a.YLim(2)], '-r')
%     a.XLim = xli;
%     a.YLim = yli;
    a.GridLineStyle = 'none';
    set(gcf, 'Color', 'w')
    %caxis([25, inf])
    hold off
end

