function mean_on_bifurcation_diagram(cp_range,system_type, eta, IC, parameters)
    
    ops = SQL_add('ops', 'INP_ops.txt', [], 0);
    op = ops(strcmp(ops.Name, 'standard_deviation'), :);
    f = figure;
    hold on
    switch system_type
        case 'supercritical_hopf_radius_(strogatz)-reflecting'
            line([cp_range(end), 0], [0, 0], 'LineStyle', '--')
            x = cp_range(1):(cp_range(end)-cp_range(1))/1000:cp_range(end);
            plot(x, sqrt(x), '-')
            ylim([-0.1*sqrt(x(end)), inf])
            
            r = time_series_generator('cp_range', cp_range, 'system_type', system_type,...
                'initial_conditions', IC, 'parameters', parameters, 'etarange', eta, 'vocal', 0);
            mu = mean(r, 2);
            %variance = (generate_feature_vals(r, op, [], 0)).^2;
            %errorbar(cp_range, mu, variance, 'o')
            sd = (generate_feature_vals(r, op, [], 0));
            errorbar(cp_range, mu, sd, 'o')
        case 'supercritical_hopf_radius_(strogatz)'
            line([cp_range(end), 0], [0, 0], 'LineStyle', '--')
            x = cp_range(1):(cp_range(end)-cp_range(1))/1000:cp_range(end);
            plot(x, sqrt(x), '-')
            ax = gca;
            ax.ColorOrderIndex = 1;
            plot(x, -sqrt(x), '-')
            
            r = time_series_generator('cp_range', cp_range, 'system_type', system_type,...
                'initial_conditions', IC, 'parameters', parameters, 'etarange', eta, 'vocal', 0);
            mu = mean(r, 2);
            %variance = (generate_feature_vals(r, op, [], 0)).^2;
            %errorbar(cp_range, mu, variance, 'o')
            sd = (generate_feature_vals(r, op, [], 0));
            errorbar(cp_range, mu, sd, 'o')
    end
    
    set(f,'color','w');
    xlabel('Control Parameter');
    ylabel('Mean Radius');
            
    

end

