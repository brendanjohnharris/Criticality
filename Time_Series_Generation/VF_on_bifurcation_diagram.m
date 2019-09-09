function h = VF_on_bifurcation_diagram(system_type)
    f = figure;
    hold on
    xfin = -1:0.001:1;
    xcoa = -0.9:0.1:0.9;
    switch system_type
        case 'supercritical_hopf_radius_(strogatz)'
            line([0, 1], [0, 0], 'LineStyle', '--')
            plot(xfin, sqrt(xfin), '-')
            ylim([-0.1*sqrt(xfin(end)), inf])
            [X, Y] = meshgrid(xcoa, 0.1:0.1:1);
            u = 0.*X;
            v = 0.05.*(X.*Y - Y.^3);
        case 'supercritical_hopf_radius_(strogatz)-non_reflecting'
            line([0, 1], [0, 0], 'LineStyle', '--')
            plot(xfin, sqrt(xfin), '-')
            ax = gca;
            ax.ColorOrderIndex = 1;
            plot(xfin, -sqrt(xfin), '-')
            [X, Y] = meshgrid(xcoa, -1:0.1:1);
            u = 0.*X;
            v = 0.05.*(X.*Y - Y.^3);
        case 'subcritical_hopf_radius_(strogatz)'
            line([0, 1], [0, 0], 'LineStyle', '--')
            line([-1, 0], [0, 0], 'LineStyle', '-')
            yfin = sqrt(1 - sqrt(4*xfin(xfin >= -0.25 & xfin <= 0) + 1))/sqrt(2);
            plot(xfin(xfin >= -0.25 & xfin <= 0), yfin, '--')
            ax = gca;
            ax.ColorOrderIndex = 1;
            yfin = sqrt(1 + sqrt(4*xfin(xfin >= -0.25) + 1))/sqrt(2);
            plot(xfin(xfin >= -0.25), yfin, '-')
            [X, Y] = meshgrid(xcoa, 0:0.1:max(yfin));
            u = 0.*X;
            v = 0.05.*(X.*Y + Y.^3 - Y.^5);
            
    end
    quiver(X,Y,u,v, 'color', 'k')
    %quiver_tri(X,Y,u,v, 0.015, 22.5, 0.015);
    %set(h,'MaxHeadSize',1e2,'AutoScaleFactor',1);
    ylim([-0.1, max(max(Y))+0.05])
    
    title(['System: ', system_type], 'interpreter', 'none')
    a = plot(NaN, 'o', 'color', [0.8500, 0.3250, 0.0980]);
    b = plot(NaN, '-', 'color', [0.8500, 0.3250, 0.0980]);
    %legend([a, b], {'Mean', 'Standard Deviation'}, 'Location', 'northwest')
    set(f,'color','w');
    xlabel('Control Parameter');
    ylabel('Equilibrium Radius');
end

