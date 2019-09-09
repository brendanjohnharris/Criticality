function plot_feature_vals(op_id, data, on_what, combined, reduced)
        % A real shamble
        
        
        a = figure;
        if nargin < 4 || isempty(combined)
            combined = false;
        end
        if nargin < 5 || isempty(reduced)
            reduced = 0;
        end
        if ~combined
            ps = numSubplots(length(data));
            set(a, 'units','normalized','outerposition',[0 0.5 1 0.5]);
        else
            legendcell = cell(1, size(data, 1));
            set(a, 'units','normalized','outerposition',[0.25 0.2 0.4 0.5]);
        end
        figure(a)
        if size(data, 1) > 7
            if strcmp(on_what, 'noise')
                param = sort(arrayfun(@(x) x.Inputs.eta, data));
            elseif strcmp(on_what, 'distance')
                param = sort(arrayfun(@(x) x.Inputs.cp_range(1), data));
            end
            %spacervec = min(param):min(diff(param)):max(param);
    %------------------------Edit to change colormap-----------------------
            %cmp = parula(length(spacervec));
            cmp = inferno(length(param)); % Assume param is linearly spaced
    %----------------------------------------------------------------------
            if length(param) ~= length(unique(param))
                error('Cannot colour lines by noise when there are duplicate values')
            end
        end
    if reduced
        plotStep = round(length(data)./4)-1;
    else
        plotStep = 1;
    end
    if reduced
        cmap = inferno(length(1:plotStep:length(data))+1);%BF_getcmap('dark2', length(1:plotStep:length(data)));
        cmap = cmap(1:end-1, :);
        cbarcmap = [];
    elseif size(data, 1) <= 7
        cmap = inferno(length(data)+1);%BF_getcmap('dark2', length(data));
        cmap = cmap(1:end-1, :);
    end
    for ind = 1:plotStep:length(data)
        deltamu = data(ind).Inputs.cp_range;
        operations = [data(ind).Operations.ID];
        TS_DataMat = data(ind).TS_DataMat(:, op_id); % Only works for un-normalised data, and where operations is in order and 'continuous'
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
        if size(data, 1) <= 7 || ~combined || reduced
            plot(deltamu, TS_DataMat, '.-', 'MarkerSize', 12.5, 'Color', cmap(1, :), 'LineWidth', 2.5)
            cbarcmap(end+1, :) = cmap(1, :);
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
            colormap(cmp)
            c = colorbar;
            caxis([min(param), max(param)])
            c.Label.Rotation = 0;
            c.Label.FontSize = 14;
            if strcmp(on_what, 'noise')
                plot(deltamu, TS_DataMat, '.', 'MarkerSize', 10, 'Color', cmp(param == data(ind).Inputs.eta, :))%, 'MarkerFaceColor', 'b')   
                %scaleScatter(deltamu, TS_DataMat, 0.01, cmp(param == data(ind).Inputs.eta, :));
                c.Label.String = '\eta';
            elseif strcmp(on_what, 'distance')
                plot(deltamu, TS_DataMat, '.', 'MarkerSize', 10, 'Color', cmp(param == data(ind).Inputs.cp_range(1), :))%, 'MarkerFaceColor', 'b')
                %scaleScatter(deltamu, TS_DataMat, 0.01, cmp(param == data(ind).Inputs.cp_range(1), :));
                c.Label.String = '\Delta \mu';
            end
        end
%         title(sprintf('%s\n(ID %g), Correlation: %.3g', ...
%             operations(([operations.ID] == correlation(:, 2))).Name,...
%             correlation(:, 2), correlation(:, 1)), 'interpreter', 'none')
        xlabel('Control Parameter')
        ylabel('Feature Value')
        %savefig(a, sprintf("Spearman's_Correlation_for_eta_=_%g.fig", name))
    end
    if reduced
        %legendcell = legendcell(1:plotStep:length(data));
            %plot(NaN, NaN)
            colormap(cbarcmap)
            c = colorbar;
            c.Label.Rotation = 0;
            c.Label.FontSize = 14;
            if strcmp(on_what, 'noise')
                c.Label.String = '\eta';
            elseif strcmp(on_what, 'distance')
                c.Label.String = '\Delta \mu';
            end
    end
    if combined && all(cellfun(@(x) ~isempty(x), legendcell)) && (size(data, 1) <= 7 || reduced)
       legend(legendcell)
    end  
    ops = data.Operations;
    opname = ops.Name{op_id};
    suptitle(strrep(opname, '_', '\_'))
    set(a,'color','w');
end

