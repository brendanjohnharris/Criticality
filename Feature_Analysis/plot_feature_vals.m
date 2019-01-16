function plot_feature_vals(op_id, data, on_what, combined)
        a = figure;
        if nargin < 4 || isempty(combined)
            combined = false;
        end
        if ~combined
            ps = numSubplots(length(data));
            set(a, 'units','normalized','outerposition',[0 0.5 1 0.5]);
        else
            legendcell = cell(1, size(data, 1));
            set(a, 'units','normalized','outerposition',[0.25 0.2 0.4 0.5]);
        end
        figure(a)
    for ind = 1:length(data)
        deltamu = data(ind).Inputs.cp_range;
        operations = [data(ind).Operations.ID];
        TS_DataMat = data(ind).TS_DataMat(:, op_id); % Only works for un-normalised data, and where operations is in order and 'continuous'
        [~, idxcor] = intersect(data(ind).Correlation(:, 2), operations);
        sortedcor = data(ind).Correlation(idxcor, :);
        %correlation = data(ind).Correlation(op_id, :);
        correlation = sortedcor(op_id, :);
        if ~combined
            subplot(ps(1), ps(2), ind)
        else
            hold on
        end
        % 
        %name = (time_series_data(ind).Inputs.cp_range(1));
        %a = figure('Name', sprintf("Spearman's Correlation for eta = %g", name));
        plot(deltamu, TS_DataMat, '-o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
        if strcmp(on_what, 'noise')
            if ~combined
                %title(['Noise: ', num2str(data(ind).Inputs.eta), ', ', 'Correlation: ', num2str(correlation(1))])
                title(['Noise: ', num2str(data(ind).Inputs.eta)])
            else
                legendcell{ind} = ['Noise: ', num2str(data(ind).Inputs.eta)];%, ', ', 'Correlation: ', num2str(correlation(1))];
            end       
        elseif strcmp(on_what, 'distance')
            if ~combined
                title(['Distance: ', num2str(data(ind).Inputs.cp_range(1))])
            else
                legendcell{ind} = ['Distance: ', num2str(data(ind).Inputs.cp_range(1))];
            end
        end
%         title(sprintf('%s\n(ID %g), Correlation: %.3g', ...
%             operations(([operations.ID] == correlation(:, 2))).Name,...
%             correlation(:, 2), correlation(:, 1)), 'interpreter', 'none')
        xlabel('Control Parameter')
        ylabel('Feature Value')
        %savefig(a, sprintf("Spearman's_Correlation_for_eta_=_%g.fig", name))
    end
    if combined && all(cellfun(@(x) ~isempty(x), legendcell))
       legend(legendcell)
    end  
    ops = data.Operations;
    opname = ops.Name{op_id};
    suptitle(strrep(opname, '_', ' '))
    set(a,'color','w');
end

