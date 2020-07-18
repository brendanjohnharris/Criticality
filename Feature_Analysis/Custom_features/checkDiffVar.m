function out = checkDiffVar(sampling_period, savelength, inputs)
% Sampling_period shoudl be a vector containing the samplign periods over
% which samples will be sampled. Both smapling_period and the control
% parameter range should be EVENLY SPACED VECTORS for the colormap to make sense!!!!
    fvals = [];
    if nargin < 3
        inputs = [];
    end
    if nargin < 3 || isempty(inputs)
        cpvals = [-3:0.05:-0.05];%[-1:0.1:-0.1, -0.01];
        etavals = [0.05:0.05:1];%[0.01, 0.1:0.1:1];%[0.3, 0.5, 1];[0.01:0.01:1];%
    else
        cpvals = inputs.cp_range;
        etavals = inputs.etarange;
    end
    plotcellx = repmat({[]}, 1, length(cpvals.*length(sampling_period)));
    plotcelly = plotcellx;
    plotcelldt = plotcellx;
    plotcellcp = plotcellx;
    for el = 1:length(sampling_period)
    if nargin < 3 || isempty(inputs)
    	[z, ~, labels] = time_series_generator('cp_range',...
                        cpvals, 'etarange', etavals, 'sampling_period', sampling_period(el), 'savelength', savelength, 'T', sampling_period(el).*savelength);
    else
        [z, ~, labels] = time_series_generator('input_struct', inputs, 'cp_range',...
                        cpvals, 'etarange', etavals, 'sampling_period', sampling_period(el), 'savelength', savelength, 'T', sampling_period(el).*savelength);
   end
    cplabels = cellfun(@(x) str2double(regexprep(x, '\|.*', '')), labels);
    etalabels = cellfun(@(x) str2double(regexprep(x, '.*\|', '')), labels);

        for i = 1:length(cpvals)
            for t = 1:length(etavals)
                %if nargin < 3 || isempty(inputs)
                %    x = time_series_generator('cp_range',...
                %        cpvals(i), 'etarange', etavals(t), 'sampling_period', sampling_period(el), 'savelength', savelength, 'T', sampling_period(el).*savelength);
                %else
                %    x = time_series_generator('input_struct', inputs, 'cp_range',...
                %        cpvals(i), 'etarange', etavals(t), 'sampling_period', sampling_period(el), 'savelength', savelength, 'T', sampling_period(el).*savelength);
                %end

                x = z(((abs(cplabels - cpvals(i)) < abs(cpvals(i)*10^(-10))) &...
                (abs(etalabels - etavals(t)) < abs(etavals(t)*10^(-10)))), :); % Precision errors when converting to and from strings
                %fvals(i, t, el) = std((x(2:end) - x(1:end-1))./(sqrt(2)).*etavals(t));
                plotcellx{i}(end+1) = etavals(t).*sqrt(sampling_period(el));
                plotcelly{i}(end+1) = std((x(2:end) - x(1:end-1)));
                plotcelldt{i}(end+1) = sampling_period(el);
                plotcellcp{i}(end+1) = cpvals(i);
            end
        end
    end
    if length(sampling_period) > 1
        cmap = turbo(length(sampling_period));
    else
        cmap = turbo(length(plotcellcp));
    end
        figure, hold on
        %plotcell = arrayfun(@(x) reshape(fvals(:, :, x), numel(fvals(:, :, x)), 1), 1:size(fvals, 3), 'uniformoutput', 0);
        %BF_JitteredParallelScatter(plotcell, 1, 1, 0, struct('theColors', {repmat({[0 0 0]}, 1, size(fvals, 3))}))
        for i = 1:length(plotcellx)
            [~, ~, rnk] = unique(plotcelldt{i});
            plotcelldt{i} = rnk;
        end
        %for i = 1:length(plotcellx)
         %   [~, ~, rnk] = unique(plotcellcp{i});
        %    plotcellcp{i} = rnk;
        %end
        for i = 1:length(plotcellx)
            if length(sampling_period) > 1
                colrs = unique(plotcelldt{i});
            else
                colrs = unique(cellfun(@(x) x(1), plotcellcp));
                colrs = tiedrank(colrs);
            end

                if length(sampling_period) > 1
                    for u = 1:length(colrs)
                    x = plotcellx{i}(plotcelldt{i} == colrs(u));
                    y = plotcelly{i}(plotcelldt{i} == colrs(u));
                    plot(x, y, '.', 'color', cmap(colrs(u), :))
                    end
                else
                    x = plotcellx{i};
                    y = plotcelly{i};
                    plot(x, y, '.', 'color', cmap(colrs(i), :))
                end
        end
        %end
        colormap(cmap)
        c = colorbar;
        %if length(etavals) > 1
        %    caxis([min(etavals), max(etavals)])
        %end
        if length(sampling_period) > 1
            caxis([min(sampling_period), max(sampling_period)])
            %c.TickLabels = num2str(linspace(min(sampling_period), max(sampling_period), length(c.TickLabels)));
            c.Label.String = '\Delta t';
            c.Label.Rotation = 0;
            c.Label.FontSize = 18;
            xlabel('$$\frac{\eta}{\sqrt{\Delta t}}$$', 'interpreter', 'latex', 'fontsize', 18)
            ylabel('$$\sigma$$', 'interpreter', 'latex', 'fontsize', 18)
        else
            caxis([min(cpvals), max(cpvals)])
            %c.TickLabels = num2str(linspace(min(cpvals), max(cpvals), length(c.TickLabels)));
            c.Label.String = '\mu';
            c.Label.Rotation = 0;
            c.Label.FontSize = 18;
            xlabel('$$\frac{\eta}{\sqrt{\Delta t}}$$', 'interpreter', 'latex', 'fontsize', 18)
            ylabel('$$\sqrt{2}\cdot \sigma_{y''}$$', 'interpreter', 'latex', 'fontsize', 18)
            title(['$$\Delta t: ', num2str(sampling_period),'$$'], 'interpreter', 'LaTex', 'Fontsize', 20)
        end
       set(gcf, 'Color', 'w')
    h = refline(1, 0);
    h.Color = 'k';
    h.LineStyle = '--';
    out.rows_cpvals = cpvals;
    out.columns_etavals = etavals;
    %out.featurestrings = subfeaturestr;
    out.featurevals = fvals;
end
