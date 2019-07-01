function plot_range(inputs, whatPlot, sameScale, sameAxes)
%PLOT_RANGE
%   whatPlot is a character array containing code to generate ONE PLOT from
%   ONE TIMESERIES called x. i.e 'plot(x)'
    if ischar(inputs)
        load(inputs, 'inputs')
    end
    if nargin < 3 || isempty(sameScale)
        sameScale = 0;
    end
    if nargin < 4 || isempty(sameAxes)
        sameAxes = 0;
    end
    [xs, ~, labels] = time_series_generator('input_struct', inputs);
    cp_range = inputs.cp_range;
    etarange = inputs.etarange;
    m = length(cp_range);
    n = length(etarange);
    axx = [0 0];
    axy = [0 0];
    for u = 1:m
        if sameAxes
            subplot(m, 1, u)
            hold on
            title(['\mu = ', num2str(cp_range(u))])
        end
        for v = 1:n
            x = xs(strcmp(labels, [num2str(cp_range(u)), '|', num2str(etarange(v))]), :);
            if ~sameAxes
                subplot(m, n, sub2ind([n, m], v, u))
                title(['\mu = ', num2str(cp_range(u)), '     \eta = ', num2str(etarange(v))])
            end
            subwhatPlot = strrep(whatPlot, 'mu', num2str(cp_range(u)));
            subwhatPlot = strrep(subwhatPlot, 'eta', num2str(etarange(v)));
            eval(subwhatPlot)
            ax = axis;
            if any(ax([1 2]) > axx)
                axx = ax([1 2]);
            end
            if any(ax([3 4]) > axy)
                axy = ax([3 4]);
            end
        end
    end   
    if sameScale
        for u = 1:m
            for v = 1:n
                if ~sameAxes
                    subplot(m, n, sub2ind([m, n], u, v))
                else
                    subplot(m, 1, u)
                end
                axis([axx, axy])
            end
        end    
    end
    set(gcf, 'Color', 'w')
end

