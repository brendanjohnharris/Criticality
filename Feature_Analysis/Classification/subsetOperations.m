function data = subsetOperations(data, opids)
%SUBSETOPERATIONS Give vector of operation IDs, get data with only those
%operations
    for i = 1:size(data, 1)
        idxs = ismember(data(i, :).Operations.ID, opids(:));
        data(i, :).Operations = data(i, :).Operations(idxs, :);
        data(i, :).TS_DataMat = data(i, :).TS_DataMat(:, idxs);
        data(i, :).Correlation = data(i, :).Correlation(ismember(data(i, :).Correlation(:, 2), opids), :);
    end
end

