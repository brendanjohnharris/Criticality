function compareAggToCorr(data, opids)
%COMPAREAGGTOCORR 
    tbl = get_combined_feature_stats(data, {'Correlation'}, {'Correlation_Mean', 'Aggregated_Correlation'}, [], 1);
    subtbl = tbl(intersect(tbl.Operation_ID, opids), :);
    plotmat = [subtbl.Correlation_Mean, subtbl.Aggregated_Correlation];
    bar(plotmat, 1)
    ax = gca;
    set(gcf, 'Color', 'w')
    ylabel('Pearson''s Correlation')
    ax.XTickLabels = strrep(subtbl.Operation_Name, '_', '\_');
    legend('Mean', 'Aggregated')
end

