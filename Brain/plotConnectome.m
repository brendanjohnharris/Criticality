function f = plotConnectome()
%PLOTCONNECTOME 
    parcel = 'DK';
    params = GiveMeDefaultParams(parcel);
    subfile = load(params.data.subjectInfoFile);
    dataParams = params.data;
    
    subID = subfile.subs100.subs(1);
    %connMat = GiveMeSC(subID, params.data); % A matrix
    
    [connectomes,theDataFile] = GiveMeSC([],dataParams);
    load(theDataFile,'SIFT2_length');
    distances = SIFT2_length;
    connMat = GroupAdjConsistency(connectomes, distances, dataParams.threshold, dataParams.whichHemispheres);
    connMat = connMat(1:end, 1:end);
    
    
    switch dataParams.whatParcellation
    case {'DK','aparc'}
        fileName = fullfile('Data','volume','DK',sprintf('%u.nii',subID));
    case 'HCP'
        fileName = fullfile('Data','volume','HCP',sprintf('%u',subID),'HCPMMP1_standard.nii');
    case 'cust200'
        fileName = fullfile('Data','volume','cust200',sprintf('%u',subID),'custom200_standard.nii');
    end
    f = figure('color', 'w');
    hold on
    
    
    % Brain outline
    load('fsaverage_surface_data.mat')
    %rhv = rh_verts(:, [2, 1, 3]);
    %rhf = rh_faces(:, [2, 1, 3]);
    lhv = lh_verts(:, [2, 1, 3]);
    lhf = lh_faces(:, [2, 1, 3]);
    
    %surface.vertices = rhv;
    %surface.faces = rhf;
    %p = patch(surface, 'EdgeColor', 'none', 'FaceAlpha', 0.06);
    surface.vertices = lhv;
    surface.faces = lhf;
    p = patch(surface, 'EdgeColor', 'none', 'FaceAlpha', 0.06);
    
    % Load the image file
    inFile = load_nii(fileName);
    VOL = inFile.img;
    
    nodeprops = regionprops3(VOL);
    nodelocs = nodeprops.Centroid(1:end./2, :);
    nodelocs(:, 1) = normalize(nodelocs(:, 1), 'range', 0.9.*[min(lhv(:, 1)), max(lhv(:, 1))]+9); % A schematic, so fudge the locations a little until they match visually
    nodelocs(:, 2) = normalize(nodelocs(:, 2), 'range', 0.9.*[min(lhv(:, 2)), max(lhv(:, 2))]);
    nodelocs(:, 3) = normalize(nodelocs(:, 3), 'range', 0.9.*[min(lhv(:, 3)), max(lhv(:, 3))]);
    
    connMat(connMat < 0.01.*max(max(connMat))) = 0;
    G = graph(connMat, 'omitselfloops');
    widths = 15*G.Edges.Weight./max(G.Edges.Weight);
   
    p = plot(G, 'xdata', nodelocs(:, 1), 'ydata', nodelocs(:, 2), 'zdata', nodelocs(:, 3), 'NodeLabel', [], 'LineWidth', widths, 'EdgeColor', [0 0 0], 'NodeColor', 'r');
    
    
    sData = normalize(sum(connMat), 'range', [0.1, 40]); % This is an undirected graph
    
    for n = 1:length(sData)
        highlight(p, n, 'MarkerSize', sData(n))%NodeColor
    end
    
    axis equal
    ax = gca;
    ax.Visible = 'off';
    view([0, 0])
end

