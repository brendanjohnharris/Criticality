function dataout = sort_data(datain)
    % This function shouldn't be necessary
    dataout = struct(datain);
    for ind = 1:size(datain, 1)
        data = datain(ind, :);
        [~, idxs] = sort(data.Operations.ID);
        data.Operations = data.Operations(idxs, :);
        data.TS_DataMat = data.TS_DataMat(:, idxs); % TS_Datamat should be in the same order as Operations
        if ~isempty(data.Correlation)
            [~, idxcor] = sort(data.Correlation(:, 2)); % Correlation may not be in the same order as Operations, but is labelled with feature IDs
            data.Correlation = data.Correlation(idxcor, :);
        end
        dataout(ind, :) = data;
    end
end

