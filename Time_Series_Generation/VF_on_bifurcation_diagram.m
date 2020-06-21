function f = VF_on_bifurcation_diagram(system_type, lims)
    if nargin < 2 || isempty(lims)
        lims = [-1, 1];
    end
    le = min(lims);
    ri = max(lims);
    f = figure;
    hold on
    xfin = le:0.001:ri;
    xcoa = le+0.1:0.1:ri+0.1;
    switch system_type
        case 'supercritical_hopf_radius_(strogatz)'
            line(lims, [0, 0], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2.5)
            y = real(sqrt(xfin));
            plot(xfin, y, '-k', 'LineWidth', 2.5)
            ylim([-0.1*sqrt(xfin(end)), inf])
            [X, Y] = meshgrid(xcoa, 0.1:0.1:max(y));
            u = 0.*X;
            v = 0.05.*(X.*Y - Y.^3);
        case 'supercritical_hopf_radius_(strogatz)-non_reflecting'
            line(lims, [0, 0], 'LineStyle', '--')
            y = real(sqrt(xfin));
            plot(xfin, y, '-')
            ax = gca;
            ax.ColorOrderIndex = 1;
            plot(xfin, -y, '-')
            [X, Y] = meshgrid(xcoa, -max(y):0.1:max(y));
            u = 0.*X;
            v = 0.05.*(X.*Y - Y.^3);
        case 'subcritical_hopf_radius_(strogatz)'
            line([0, ri], [0, 0], 'LineStyle', '--')
            line([le, 0], [0, 0], 'LineStyle', '-')
            yfin = sqrt(1 - sqrt(4*xfin(xfin >= -0.25 & xfin <= 0) + 1))/sqrt(2);
            plot(xfin(xfin >= -0.25 & xfin <= 0), yfin, '--')
            ax = gca;
            ax.ColorOrderIndex = 1;
            yfin = sqrt(1 + sqrt(4*xfin(xfin >= -0.25) + 1))/sqrt(2);
            plot(xfin(xfin >= -0.25), yfin, '-')
            [X, Y] = meshgrid(xcoa, 0:0.1:max(yfin));
            u = 0.*X;
            v = 0.05.*(X.*Y + Y.^3 - Y.^5);
            
        case 'subcritical_hopf_radius_variable'
            line([0, ri], [0, 0], 'LineStyle', '--')
            line([le, 0], [0, 0], 'LineStyle', '-')
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
    quiver(X,Y,u,v, 'color', 'r')
    %ncquiverref(X,Y,u,v)
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

