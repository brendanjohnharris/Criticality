function plotDiscrimination2(mdl)
%PLOTDISCRIMINATION Give me a model (ECOC) with TWO predictors, I'll plot the data
%   and draw the classification surface
    if size(mdl.X, 2) ~= 2
        error('The supplied model does not have only two predictors')
    end
    x = mdl.X(:, 1);
    y = mdl.X(:, 2);
    
    %% Create a grid and classify each point
    xax = linspace(min(x), max(x), 2000);
    yax = linspace(min(y), max(y), 2000);
    [X, Y] = meshgrid(xax, yax);
    XGrid = [X(:), Y(:)];
    pX = predict(mdl, XGrid);
    [pX, classLabels] = grp2idx(pX);
    pX = reshape(pX, size(X)); 
    
    %% Now search for edges and plot
    pX = edge(pX);
    [py, px] = find(pX);
    py = yax(py);
    px = xax(px);
    set(gcf, 'color', 'w')
    
    cmp =     [ 0.3020    0.6863    0.2902;
                0.8941    0.1020    0.1098;
                0.2157    0.4941    0.7216;
                0.5961    0.3059    0.6392;
                1.0000    0.4980         0;
                1.0000    1.0000    0.2000;
                0.6510    0.3373    0.1569;
                0.9686    0.5059    0.7490;
                0.6000    0.6000    0.6000
                0         0         0      ];
    cmp = cmp(1:length(unique(mdl.Y)), :);
    
    h = gscatter(x, y, mdl.Y, cmp);
    set(h, 'HandleVisibility', 'off')
    hold on
    pp = plot(px, py, '.k', 'MarkerSize', 10);
    pp.HandleVisibility = 'off';
    if ~isempty(mdl.PredictorNames)
        xlabel(mdl.PredictorNames{1}, 'Interpreter', 'none')
        ylabel(mdl.PredictorNames{2}, 'Interpreter', 'none')
    end
    
%     uniY = unique(mdl.Y);
%     for u = 1:length(uniY)
%         bnd = convhull(x(mdl.Y == uniY(u)), y(mdl.Y ==  uniY(u)));
%         pp = pchip(x(bnd), y(bnd));
%         bndy = ppval(pp, linspace(min(x), max(x), 100));
%         
%     end
    
    %% Plot dummies for proper legend
    lgd = legend;
    lgdlabels = lgd.String;
    for i = 1:size(mdl.X, 2)
        plot(NaN, NaN,'.', 'Color', cmp(i, :), 'markersize', 20);
    end
    delete(lgd)
    legend(lgdlabels)
end
