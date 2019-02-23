function surf_feature_vals(data, op_id)
    figure
    eta = arrayfun(@(x) data(x).Inputs.eta, 1:size(data, 1));
    eta = cell2mat(arrayfun(@(x) repmat(eta(x), 1, 701), 1:length(eta), 'uniformoutput', 0));
    cp = cell2mat(arrayfun(@(x) data(x).Inputs.cp_range, 1:size(data, 1), 'uniformoutput', 0));
    ops = cell2mat(cellfun(@(x) x(:, op_id)', {data.TS_DataMat}, 'uniformoutput', 0));
    
    
    [xq, yq] = meshgrid(arrayfun(@(x) data(x).Inputs.eta, 1:size(data, 1)), data(1).Inputs.cp_range);
    vq = griddata(eta, cp, ops, xq, yq);
    surf(xq, yq, vq, 'EdgeColor', 'interp')
    camlight
    set(gcf,'color','w');
    xlabel('Noise')
    ylabel('Control Parameter')
    zlabel('Feature Values')
    title(data(1).Operations.Name{op_id}, 'interpreter', 'none')
    view(64, 32)
end

