function f = plotCriticalitySurface()
%PLOTCRITICALITYSURFACE 
    params = GiveMeDefaultParams('DK');
    
    data = GroupTimeSeriesFeature(params,'criticality');
    data = normalize(mean(data, 2), 'range', [0, 1]);
    PlotCDataSurface(data,'aparc','l', 'lateral')
    axis equal
    ax = gca;
    ax.Visible = 'off';
    colormap(cbrewer('seq', 'Blues', 1000))
    c = findall(gcf,'type','ColorBar');
    delete(c)
end
