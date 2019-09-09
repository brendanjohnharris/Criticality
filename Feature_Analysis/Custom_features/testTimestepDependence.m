function out = testTimestepDependence(featurestr, subfeaturestr, inputs)
    fvals = [];
    if nargin < 3 || isempty(inputs)
        cpvals = -0.1;%[-1:0.02:-0.02];%[-1:0.1:-0.1, -0.01];
        etavals = 0.1;
        sampling_periods = [0.005:0.005:1];
    else
        cpvals = inputs.cp_range;
        etavals = inputs.etarange;
    end
    if nargin < 3 || isempty(inputs)
        for k = 1:length(sampling_periods)
            [z(k, :), ~, labels(k)] = time_series_generator('cp_range', cpvals, 'etarange', etavals, 'savelength', 50000);%, 'system_type', 'quadratic_potential');%, 'system_type', 'supercritical_hopf_radius_(strogatz)-non-reflecting');
        end
    else
        for k = 1:length(sampling_periods)
            [z(k, :), ~, labels(k)] = time_series_generator('input_struct', inputs, 'cp_range', cpvals, 'etarange', etavals);
        end
    end
    if isempty(subfeaturestr)
        subfeaturestr = 0;
    end
    %cplabels = cellfun(@(x) str2double(regexprep(x, '\|.*', '')), labels);
    %etalabels = cellfun(@(x) str2double(regexprep(x, '.*\|', '')), labels);
    for k = 1:length(sampling_periods)
            %disp(i), disp(t)
            x = z(k, :);
            res = eval(featurestr); % Uses timeseries 'x', if user enters string correctly
            for v = 1:length(subfeaturestr)
                if subfeaturestr~= 0
                    fvals(k, v) = res.(subfeaturestr{v});
                else
                    fvals(k, v) = res;
                end
            end
    end
    %cmap = inferno(length(etavals));
    for v = 1:length(subfeaturestr)
        figure, hold on
        corrvecx = [];
        corrvecy = [];
        plot(sampling_periods, fvals(:, v), '.', 'color', 'k')
        if subfeaturestr ~= 0
            title([featurestr, '.', subfeaturestr{v}], 'interpreter', 'none')
        else
            title([featurestr], 'interpreter', 'none')
        end
        %c = colorbar;
        %if length(etavals) > 1
        %    caxis([min(etavals), max(etavals)])
        %end
        %c.Label.String = '\eta';
        %c.Label.Rotation = 0;
        %c.Label.FontSize = 18;
        xlabel('$$\Delta t$$', 'interpreter', 'latex', 'fontsize', 18)
        ylabel('$$f$$', 'interpreter', 'latex', 'fontsize', 18)
        set(gcf, 'Color', 'w')
    end
    out.rows_cpvals = cpvals;
    out.columns_etavals = etavals;
    out.featurestrings = subfeaturestr;
    out.featurevals = fvals;
end
