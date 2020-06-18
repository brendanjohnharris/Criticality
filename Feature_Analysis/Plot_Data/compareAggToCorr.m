function compareAggToCorr(data, opids)
%COMPAREAGGTOCORR 
    f = figure('Color', 'w');
    tbl = get_combined_feature_stats(data, {'Correlation'}, {'Correlation_Mean', 'Aggregated_Correlation'}, [], 1);
    subtbl = tbl(intersect(tbl.Operation_ID, opids), :);
    
    bar(subtbl.Correlation_Mean, 0.8, 'FaceColor', [0.8 0.8 0.8])
    hold on
    bar(subtbl.Aggregated_Correlation, 0.5, 'FaceColor', [0.4 0.4 0.4])
    ax = gca;
    set(gcf, 'Color', 'w')
    ylabel('Pearson''s Correlation')
    ax.XTickLabels = strrep(subtbl.Operation_Name, '_', '\_');
    legend('Mean', 'Aggregated (\rho)', 'Location', 'NorthWest', 'Interpreter', 'tex')
    set(gca,'View',[90 -90])
    set(gca, 'xdir', 'reverse'); 
    
end

