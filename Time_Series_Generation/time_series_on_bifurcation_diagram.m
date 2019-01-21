function time_series_on_bifurcation_diagram(cp,system_type, eta, IC, parameters)
%TIME_SERIES_ON_BIFURCATION_DIAGRAM Plot a single time series over the
%bifurcation diagram of a specified system
%   Input arguments specify both how the time series will be generated and
%   the nature of the bifurcation diagram that is plotted.
%
%   cp:             A number, the control parameter of the system
%   system_type:    A character vector specifying the system type, as
%                   accepted by 'time_series_generator'
%   eta:            A number specifying the level of noise in the time
%                   series
%   IC:             A number giving the initial conditions of the
%                   integration (real, complex or possibly a vector,
%                   depending on the system chosen)
%   parameters:     Any extra parameters, as required by the system chosen
%                   (details contained in 'time_series_generator' or readMe)
    ops = SQL_add('ops', 'INP_ops.txt', [], 0);
    op = ops(strcmp(ops.Name, 'standard_deviation'), :);
    f = figure;
    hold on
    switch system_type
        case 'supercritical_hopf_radius_(strogatz)-reflecting'
            line([0, 1], [0, 0], 'LineStyle', '--')
            x = -1:0.01:1;
            plot(x, sqrt(x), '-')
            ylim([-0.1*sqrt(x(end)), inf])
        case 'supercritical_hopf_radius_(strogatz)'
            line([0, 1], [0, 0], 'LineStyle', '--')
            x = -1:0.01:1;
            plot(x, sqrt(x), '-')
            ax = gca;
            ax.ColorOrderIndex = 1;
            plot(x, -sqrt(x), '-')
    end
    
    r = time_series_generator('cp_range', cp, 'system_type', system_type,...
        'initial_conditions', IC, 'parameters', parameters, 'etarange', eta, 'vocal', 0);
    title(['System: ', system_type, ', Control Parameter: ', cp, ', Eta: ', eta], 'interpreter', 'none')
    a = plot(NaN, 'o', 'color', [0.8500, 0.3250, 0.0980]);
    b = plot(NaN, '-', 'color', [0.8500, 0.3250, 0.0980]);
    %legend([a, b], {'Mean', 'Standard Deviation'}, 'Location', 'northwest')
    plot(-1:2/length(r):1-2/length(r), r, 'color', [0.8500, 0.3250, 0.0980])
    xline(cp, '--', 'color', [0.8500, 0.3250, 0.0980])
    set(f,'color','w');
    xlabel('Control Parameter');
    ylabel('Mean Radius');
end

