function pp = plotDiscrimination3(mdl, smoothedresolution, unsmoothedresolution, noscatter)
%PLOTDISCRIMINATION3 Give me a model (ECOC) with THREE predictors, I'll plot the data
%   and draw the classification surface
% Make sure you have compiled the 'Criticality/Additional_functions/Matlab_Central_File_Exchange/smoothpatch/' mex files
% If plotting a classifier with more than one surface (e.g. rbf SVM) use
% plotDiscrimination3 first to determine how many, and provide it as the
% third argument
    if nargin < 2 || isempty(smoothedresolution)
        smoothedresolution = 150;
    end
    if nargin < 3 || isempty(unsmoothedresolution)
        unsmoothedresolution = 50;
    end
    if nargin < 4 || isempty(noscatter)
        noscatter = 0;
    end
    if unsmoothedresolution < 10
        skipcheck = unsmoothedresolution;
    else
        skipcheck = 0;
    end
    if size(mdl.X, 2) ~= 3
        error('The supplied model does not have exactly three (3) [III] predictors')
    end
    x = mdl.X(:, 1);
    y = mdl.X(:, 2);
    z = mdl.X(:, 3);
    f = gcf;
    %% Create a grid and classify each point
    xax = linspace(min(x), max(x), unsmoothedresolution);
    yax = linspace(min(y), max(y), unsmoothedresolution);
    zax = linspace(min(z), max(z), unsmoothedresolution);
    [X, Y, Z] = meshgrid(xax, yax, zax);
    XGrid = [X(:), Y(:), Z(:)];
    pX = predict(mdl, XGrid);
    [pX, classLabels] = grp2idx(pX);
    pX = reshape(pX, size(X)); 
    
    %% Now search for edges and plot
    pX = edge3(pX, 'ApproxCanny', 0.1);
    [py, px, pz] = ind2sub(size(pX), find(pX));
    py = yax(py);
    px = xax(px);
    pz = zax(pz);
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
    
    uniclasses = unique(mdl.Y);
    hold on
    if ~noscatter
        for cl = 1:length(uniclasses)
            thisc = uniclasses(cl);
            h = plot3(x(mdl.Y == thisc), y(mdl.Y == thisc), z(mdl.Y == thisc), '.', 'Color', cmp(cl, :), 'MarkerSize', 10);
            set(h, 'HandleVisibility', 'off')
        end
    end
    grid on
    pp = scatter3(px, py, pz, 50, 'k', 'filled', 'MarkerFaceAlpha', 0.1, 'MarkerEdgeAlpha', 0.1);
    set(pp, 'HandleVisibility', 'off')
    if ~isempty(mdl.PredictorNames)
        xlabel(mdl.PredictorNames{1}, 'Interpreter', 'none')
        ylabel(mdl.PredictorNames{2}, 'Interpreter', 'none')
        zlabel(mdl.PredictorNames{3}, 'Interpreter', 'none')
    end
    %% How does this look
    
    if skipcheck
        numClusters = num2str(skipcheck);
    else
        numClusters = input('Does this look good? <Enter> if so, otherwise enter the number of surface clusters to proceed to smoothing:\n', 's');
    end
    switch numClusters
        case ''
             %% Plot dummies for proper legend
            lgd = legend;
            for i = 1:length(uniclasses)
                plot3(NaN, NaN, NaN,'.', 'Color', cmp(i, :), 'markersize', 20);
            end
            delete(lgd)
            legend(categories(mdl.Y))
            pp.HandleVisibility = 'off';
            return
        otherwise
            numClusters = round(str2double(numClusters));
            if isnan(numClusters)
                return
            end
    end
    delete(pp)
    
    fprintf('Recalculating with a larger grid...\n')
    xax = linspace(min(x), max(x), smoothedresolution);
    yax = linspace(min(y), max(y), smoothedresolution);
    zax = linspace(min(z), max(z), smoothedresolution);
    [X, Y, Z] = meshgrid(xax, yax, zax);
    XGrid = [X(:), Y(:), Z(:)];
    pX = predict(mdl, XGrid);
    [pX, classLabels] = grp2idx(pX);
    pX = reshape(pX, size(X)); 
    
    fprintf('Finding edges...\n')
    pX = edge3(pX, 'ApproxCanny', 0.1);
    [py, px, pz] = ind2sub(size(pX), find(pX));
    py = yax(py);
    px = xax(px);
    pz = zax(pz);
    p = [px', py', pz'];
    
    fprintf('Finding clusters.\n')
    if numClusters == 1
        clusterCats = ones(length(px), 1);
    else
        clusterCats = clusterdata(p, 'MaxClust', 3, 'Linkage', 'centroid', 'SaveMemory', 'on');;
    end
    %mex smoothpatch_curvature_double.c -v
    %mex smoothpatch_inversedistance_double.c -v
    uniCats = unique(clusterCats);
    for i = 1:length(uniCats)
        idxs = clusterCats == uniCats(i);
        t = struct('faces', MyCrustOpen(p(idxs, :)), 'vertices', p(idxs, :));
        t = smoothpatch(t, 0, 10, 1, 10);
        pp(i) = trisurf(t.faces, t.vertices(:,1), t.vertices(:,2), t.vertices(:,3),'facecolor','c','edgecolor','b');
        pp(i).HandleVisibility = 'off';
        pp(i).FaceColor = 'k';
        pp(i).EdgeColor = 'none';
        pp(i).EdgeAlpha = 0;
        pp(i).FaceAlpha = 0.25;
        pp(i).FaceLighting = 'flat';
        
    end
    light('Position', [0 0 1000], 'Style', 'local')
    
    if ~noscatter
        lgd = legend;
        for i = 1:length(uniclasses)
            plot3(NaN, NaN, NaN,'.', 'Color', cmp(i, :), 'markersize', 20);
        end
        delete(lgd)
        lgd = legend(categories(mdl.Y));
        lgd.Location = 'northeast';
    end
%     uniY = unique(mdl.Y);
%     for u = 1:length(uniY)
%         bnd = convhull(x(mdl.Y == uniY(u)), y(mdl.Y ==  uniY(u)));
%         pp = pchip(x(bnd), y(bnd));
%         bndy = ppval(pp, linspace(min(x), max(x), 100));
%         
%     end
       
   
end
