function st = plot_feature_vals(op_id, data, on_what, combined, reduced, correlated, dilution)
        % A (bit of a) mess
        % Do not use reduced if the data is a single row. Don't know what might happen...
        a = figure;
        if nargin < 4 || isempty(combined)
            combined = 1;
        end
        if nargin < 5 || isempty(reduced)
            reduced = 0;
            indvec = [];
        elseif length(reduced) > 1
            indvec = reduced;
            reduced = 1;
        else
            indvec = [];
        end
        if nargin < 6 || isempty(correlated)
            correlated = 0;
            tbl = [];
        elseif istable(correlated)
            tbl = correlated;
            correlated = 1;
        else
            tbl = [];
        end
        if nargin < 7
            dilution = 1;
        end
        if ~combined
            ps = numSubplots(length(data));
            set(a, 'units','normalized','outerposition',[0 0.5 1 0.5]);
        else
            legendcell = cell(1, size(data, 1));
            set(a, 'units','normalized','outerposition',[0.25 0.2 0.4*0.8*0.8 0.5*0.8]);
        end
        figure(a)
        if 1%size(data, 1) > 7
            if strcmp(on_what, 'noise')
                param = sort(arrayfun(@(x) x.Inputs.eta, data));
            elseif strcmp(on_what, 'distance')
                param = sort(arrayfun(@(x) x.Inputs.cp_range(1), data));
            end
            %spacervec = min(param):min(diff(param)):max(param);
            %cmp = parula(length(spacervec));
            cmp = inferno(length(param)); % Assume param is linearly spaced
            if length(param) ~= length(unique(param))
                error('Cannot colour lines by noise when there are duplicate values')
            end
        end
    if reduced
        plotStep = round(length(data)./length(indvec))-1;
        cbareta = [];
    else
        plotStep = 1;
    end
    if reduced
        cmap = inferno(length(1:plotStep:length(data)));%BF_getcmap('dark2', length(1:plotStep:length(data)));
        cmap = cmap(1:end, :);
        cbarcmap = [];
        if isempty(indvec)
            indvec = 1:plotStep:length(data);
        end
    elseif size(data, 1) <= 7
        cmap = inferno(length(data));%BF_getcmap('dark2', length(data));
        %cmap = cmap(1:end-1, :);
    end
    if size(data, 1) == 1
        cmap = [0 0 0];
        cmp = [0 0 0];
    end
    if ~reduced
        indvec = 1:length(data);
    end
    for ind = indvec
        deltamu = data(ind).Inputs.cp_range;
        operations = [data(ind).Operations.ID];
        TS_DataMat = data(ind).TS_DataMat(:, op_id); % Only works for un-normalised data, and where operations is in order and 'continuous'
        if correlated
            correlation_range = data(ind).Correlation_Range;
            idxs = (data(ind).Inputs.cp_range >= data(ind).Correlation_Range(1) & data(ind).Inputs.cp_range <= data(ind).Correlation_Range(2));
            idxs(setdiff(1:length(idxs), 1:dilution:length(idxs))) = false;
            TS_DataMat = TS_DataMat(idxs, :);
            deltamu = deltamu(idxs);
        end
        %[~, idxcor] = intersect(data(ind).Correlation(:, 2), operations);
        %sortedcor = data(ind).Correlation(idxcor, :);
        %%correlation = data(ind).Correlation(op_id, :);
        %correlation = sortedcor(op_id, :);
        if ~combined
            subplot(ps(1), ps(2), ind)
        else
            hold on
        end
        %
        %name = (time_series_data(ind).Inputs.cp_range(1));
        %a = figure('Name', sprintf("Spearman's Correlation for eta = %g", name));
        if ~combined || reduced
            plot(deltamu, TS_DataMat, '.-', 'MarkerSize', 10, 'Color', cmap(1, :), 'LineWidth', 2)
            cbarcmap(end+1, :) = cmap(1, :);
            cbareta(end+1) = data(ind).Inputs.eta;


            %p = fit(deltamu', TS_DataMat, 'smoothingspline', 'SmoothingParam', 0.999);
            %plot([min(deltamu):0.01:max(deltamu)] , p([min(deltamu):0.01:max(deltamu)]), '-', 'Color', cmap(1, :), 'HandleVisibility', 'off', 'LineWidth', 3)
            cmap = cmap(2:end, :);
            if strcmp(on_what, 'noise')
                if ~combined
                    %title(['Noise: ', num2str(data(ind).Inputs.eta), ', ', 'Correlation: ', num2str(correlation(1))])
                    title(['Noise: ', num2str(data(ind).Inputs.eta)])
                end
                    %legendcell{ind} = ['Noise: ', num2str(data(ind).Inputs.eta)];%, ', ', 'Correlation: ', num2str(correlation(1))];
                %end
            elseif strcmp(on_what, 'distance')
                if ~combined
                    title(['Distance: ', num2str(data(ind).Inputs.cp_range(1))])
                else
                    legendcell{ind} = ['Distance: ', num2str(data(ind).Inputs.cp_range(1))];
                end
            end
        else
            if size(data, 1) > 1
                colormap(cmp)
                c = colorbar;
                caxis([min(param), max(param)])
            end
            c.Label.Rotation = 0;
            c.Label.FontSize = 14;
            if strcmp(on_what, 'noise')
                plot(deltamu, TS_DataMat, '.', 'MarkerSize', 8, 'Color', cmp(param == data(ind).Inputs.eta, :))%, 'MarkerFaceColor', 'b')
                %scaleScatter(deltamu, TS_DataMat, 0.01, cmp(param == data(ind).Inputs.eta, :));
                c.Label.String = '\eta';
            elseif strcmp(on_what, 'distance')
                plot(deltamu, TS_DataMat, '.', 'MarkerSize', 8, 'Color', cmp(param == data(ind).Inputs.cp_range(1), :))%, 'MarkerFaceColor', 'b')
                %scaleScatter(deltamu, TS_DataMat, 0.01, cmp(param == data(ind).Inputs.cp_range(1), :));
                c.Label.String = '\Delta \mu';
            end
        end
%         title(sprintf('%s\n(ID %g), Correlation: %.3g', ...
%             operations(([operations.ID] == correlation(:, 2))).Name,...
%             correlation(:, 2), correlation(:, 1)), 'interpreter', 'none')
        xlabel('$$\mu$$', 'Interpreter', 'LaTeX', 'FontSize', 16)
        ylabel('Feature Value', 'FontSize', 14)
        %savefig(a, sprintf("Spearman's_Correlation_for_eta_=_%g.fig", name))
    end
    if reduced
        %legendcell = legendcell(1:plotStep:length(data));
            %plot(NaN, NaN)
            colormap(cbarcmap)
            caxis([min(param), max(param)])
            c = colorbar;
            c.Label.Rotation = 0;
            c.Label.FontSize = 16;
            c.Label.Position = c.Label.Position + [0.5, 0.03, 0];
            if strcmp(on_what, 'noise')
                c.Label.String = '\eta';
            elseif strcmp(on_what, 'distance')
                c.Label.String = '\Delta \mu';
            end
            if dilution
                offset = max(param)/10.5; % Adjust this to get the colorbar ticks correct
            else
                offset = max(param);
            end
            c.TickLabels = param(indvec);
            c.Ticks = linspace(offset, max(param)-offset, length(indvec));
    end
    if combined && all(cellfun(@(x) ~isempty(x), legendcell)) && (size(data, 1) <= 7 || reduced)
       legend(legendcell)
    end
    ops = data.Operations;
    opname = ops.Name{op_id};
    set(a,'color','w');
    ax = gca;
    ax.Box = 'on';
    st = sgtitle(strrep(opname, '_', '\_'));
    if combined && correlated
        if isempty(tbl)
            title('<Finding correlation, please wait>')
            drawnow
           % tbl = get_combined_feature_stats(data, {'Absolute_Correlation'}, {'Absolute_Correlation_Mean', 'Aggregated_Absolute_Correlation'}, [], 1);
           tbl = get_combined_feature_stats(data, {}, {'Aggregated_Correlation'}, [], 1);
        end
        thecorr = tbl.Aggregated_Correlation(tbl.Operation_ID == op_id);
        title(sprintf('$$\\rho_{\\mu}^{\\mathrm{agg}} = %.2g$$', thecorr), 'interpreter', 'latex', 'fontsize', 16)
        %st.Position(1) = ax.Position(1) + ax.Position(3)./2;
    end
end
