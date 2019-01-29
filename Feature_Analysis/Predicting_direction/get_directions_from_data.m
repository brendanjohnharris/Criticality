function [directions, ops] = get_directions_from_data(data, cp_range)
    % cp_range is a two element vector
    % Resulting vector should be in the same order as the data given
    % Directions contained in repository should be in order of operation ID
    ops = data.Operations;
    directions = zeros(1, height(ops));
    for opind = 1:length(directions)
        feature_vals = data.TS_DataMat(:, opind);
        [~, minrange] = min(abs(data.Inputs.cp_range - cp_range(1)));
        [~, maxrange] = min(abs(data.Inputs.cp_range - cp_range(2)));
        fit = polyfit(data.Inputs.cp_range(minrange:maxrange), feature_vals(minrange:maxrange)', 2);
        directions(opind) = -sign(fit(1));
    end
end

