function ops = countFeatures(fmat, numfs)
    fs = horzcat(fmat{numfs, :})';
    [unis, Idxs, is] = unique(fs, 'Rows');
    counts = tabulate(categorical(Idxs(is)));
    ops = cell2table(counts(:, [1, 2]), 'VariableNames', {'Operation_ID', 'Frequency'});
    ops = sortrows(ops, 2, 'Desc');
    for i = 1:size(ops)
        ops.Operation_ID{i} = mat2str(fs(str2double(ops(i, :).Operation_ID), :));
    end
end

