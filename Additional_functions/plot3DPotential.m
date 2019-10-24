function plot3DPotential()
    f = figure('Color', 'w');
    ax = gca;
    % Need two things; colored potential surface, balls
    V = @(u, r) -(u.*r.^2./2 + r.^4./4);
    x = linspace(-3, 2, 300); % The control parameter
    y = linspace(-3, 3, 300); % The radius
    xm = linspace(-3, 2, 5); % The control parameter
    ym = linspace(-3, 3, 100); % The radius
    [X, Y] = meshgrid(x, y);
    [Xm, Ym] = meshgrid(xm, ym);
    Z = V(X, Y);
    Zm = V(Xm, Ym);

    hold on
    
    m = mesh(Xm, Ym, Zm);
    m.FaceColor = 'none';
    m.EdgeColor = 'k';
    m.MeshStyle = 'column';
    
    cmp = repmat([0.3020    0.6863    0.2902], sum(x < -1), 1);
    cmp2 = interpColors([0.3020    0.6863    0.2902],[0.8941    0.1020    0.1098], sum(x >= -1));
    %cmp2 = mat2cell(cmp2, ones(size(cmp2, 1), 1), size(cmp2, 2));
    cmp = [cmp; cmp2];
    cmp = permute(cmp, [3, 1, 2]);
    cmp = repmat(cmp, size(Y, 1), 1, 1);
    s = surf(X, Y, Z, cmp);
    s.EdgeColor = 'none';
    
    % Plot three spheres; good, shaky, bad
    hold on
    r = 0.2;
    for i = 1:3
        [xs, ys, zs] = sphere(50);
        xs = xs.*r;
        ys = ys.*r;
        zs = zs.*r;
        h = surf(xs + xm(i+1), ys, zs+r, repmat(permute([128, 128, 128]./256, [1, 3, 2]), size(xs, 1), size(xs, 2)));
        h.EdgeColor = 'none';
        material(h, 'shiny')
    end
    axis equal
    drawnow
    zlim([-3, inf])
    xlim([-3, 2])
    ylim([-3, 3])
    
    lighting('Gouraud')
    material(s, 'dull')
    view(54, 28)
    camlight headlight
    ax.Visible = 'off';
    %camlight left
end

