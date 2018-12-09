function plot_feature_vals(op_id, data, on_what)
        a = figure('Name', sprintf("Spearman's Correlation"));
        ps = numSubplots(length(data));
        set(a, 'units','normalized','outerposition',[0 0.5 1 0.5]);
        figure(a)
    for ind = 1:length(data)
        deltamu = data(ind).Parameters.betarange;
        operations = [data(ind).Operations.ID];
        TS_DataMat = data(ind).TS_DataMat(:, op_id); % Only works for un-normalised data, and where operations is in order and 'continuous'
        [~, idxcor] = intersect(data(ind).Correlation(:, 2), operations);
        sortedcor = data(ind).Correlation(idxcor, :);
        %correlation = data(ind).Correlation(op_id, :);
        correlation = sortedcor(op_id, :);
        subplot(ps(1), ps(2), ind)
        % 
        %name = (time_series_data(ind).Parameters.betarange(1));
        %a = figure('Name', sprintf("Spearman's Correlation for eta = %g", name));
        plot(deltamu, TS_DataMat, 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
        if strcmp(on_what, 'noise')
            title(['Noise: ', num2str(data(ind).Parameters.eta), ', ', 'Correlation: ', num2str(correlation(1))])
        elseif strcmp(on_what, 'distance')
            title(['Distance: ', num2str(data(ind).Parameters.betarange(1))])
%         title(sprintf('%s\n(ID %g), Correlation: %.3g', ...
%             operations(([operations.ID] == correlation(:, 2))).Name,...
%             correlation(:, 2), correlation(:, 1)), 'interpreter', 'none')
        xlabel('Control Parameter')
        ylabel('Feature Value')
        %savefig(a, sprintf("Spearman's_Correlation_for_eta_=_%g.fig", name))
    end
end

