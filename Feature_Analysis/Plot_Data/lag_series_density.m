function lag_series_density(x)
    x1 = x(2:end);
    x = x(1:end-1);
    x1(isnan(x)) = NaN;
    x(isnan(x1)) = NaN;
    xmean = mean([x; x1], 1);
    med = mean(xmean);
    plot(x1, x, 'ko', 'markersize', 1)
    %[N, C] = hist3([x', x1'], [100, 100]);
    %contourf(C{1}, C{2}, N, 1000, 'linestyle', 'none')
    histogram2(x, x1, 100, 'facecolor', 'flat', 'DisplayStyle', 'tile')
    a = gca;
    xli = a.XLim;
    yli = a.YLim;
    refline(-1, 2.*med)
    a.XLim = xli;
    a.YLim = yli;
    a.GridLineStyle = 'none';
    set(gcf, 'Color', 'w')
    %caxis([25, inf])
end

