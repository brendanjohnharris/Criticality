function stat = compareClassification(data, opid, statmethod, groupnames, makeplot)
    if size(data, 1) > 1 || ~isfield(data, 'Group_ID')
        error('data is incorrectlyf ormatted; must be one row tall and contain grouping IDs')
    end
    
    if nargin < 3 || isempty(statmethod)
        statmethod = 'Welch';
    end
    GroupIDs = unique(data.Group_ID);
    GroupIDs = GroupIDs(~isnan(GroupIDs));% Don't want to include ungrouped timeseries
    if nargin < 4 || isempty(groupnames)
        groupnames = arrayfun(@num2str, GroupIDs, 'un', 0);
    end
    if nargin < 5 || isempty(makeplot)
        makeplot = 1;
    end
    
    fvals = data.TS_DataMat(:, opid);  
    thisGroup = cell(length(GroupIDs), 1); 
    for u = 1:length(GroupIDs)
        thisGroup{u} = fvals(data.Group_ID == u);
    end
    
    switch statmethod
        case 'Welch'
            if length(GroupIDs) ~= 2; error('Welch t-test requires only 2 groups'); end
            [dec, P] = ttest2(thisGroup{1}, thisGroup{2}, 'vartype', 'unequal');
            %stat = STATS.tstat;
            stat = sign(dec-0.5).*P; % Negative if the null hypothesis should not be rejected
            titlestr = 'Welch''s t-test';
        
        case 'u_test'
            if length(GroupIDs) ~= 2; error('Mann-Whitney u-test requires only 2 groups'); end
            stat = ranksum(thisGroup{1}, thisGroup{2});
            %stat = STATS.tstat;
            titlestr = 'u-test';
            
            
        otherwise
            error('Not a supported statmethod')
    end
    
    if makeplot
        figure('Color', 'w')
        hold on
        for i = 1:length(GroupIDs)
           customHistogram(thisGroup{i}, linspace(min(fvals), max(fvals), 25));
        end
        ylabel('Frequency', 'fontsize', 14)
        xlabel('Feature Value', 'fontsize', 14)
        legend(groupnames)
        title(sprintf('%s\np-value = %0.3g', titlestr, stat))
    end

end

