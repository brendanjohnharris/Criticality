function stat_mat = compare_feature_stats(op_ids, tbl, data, single_stats, combined_stats, directions)
    if nargin > 2 || isempty(tbl)
        tbl = get_combined_feature_stats(data, single_stats, combined_stats, directions, 1);
    end
    stat_mat = BF_NormalizeMatrix(tbl{op_ids, 4:end}, 'maxmin');
    imagesc(stat_mat)
    stat_names = tbl.Properties.VariableNames;
    set(gca,'TickLabelInterpreter','none')
    xticks(1:length(stat_names))
    yticks(1:length(op_ids))
    xticklabels(stat_names(4:end))
    yticklabels(op_ids)
    h = colorbar
    ylabel(h, 'Normalised Value')
    reply = input('Do you want to reverse any of these statistics? If so, enter their positions (left to right):');
    if ~isempty(reply)
        for i = reply
            stat_mat(:, i) = - stat_mat(:, i);
        end
        stat_mat = BF_NormalizeMatrix(stat_mat, 'maxmin');
    end
    [idxs, dists] = BF_ClusterReorder(stat_mat, 'Euclidean');
    stat_mat = stat_mat(idxs, :);
    imagesc(stat_mat)
    xticks(1:length(stat_names))
    yticks(1:length(op_ids))
    xticklabels(stat_names(4:end))
    yticklabels(op_ids(idxs))
    set(gca,'TickLabelInterpreter','none')
    h = colorbar;
    ylabel(h, 'Normalised Value')
    
end

