function [stat, thisGroup] = compareClassification(data, opid, statmethod, groupnames, makeplot)
    if ~isfield(data, 'Group_ID')
        error('Data must contain grouping IDs, i.e. use addGroups()')
    end
    
    % If data contains more than one row, check that the format is valid
    % and then agglomerate. All rows must have the same (two) groups.
    [~, checkVec] = checkConsistency(data);
    if ~all(checkVec([2, 3]))
        error('The data is not consistent; it must have the same operations in the same order')
    end
    if nargin < 3 || isempty(statmethod)
        statmethod = 'welch_t_test';
    end
    GroupIDs = arrayfun(@(x) x.Group_ID, data, 'uniform', 0);
    GroupIDs = [GroupIDs{:}];
    GroupIDs = GroupIDs(~isnan(GroupIDs));% Don't want to include ungrouped timeseries
    GroupIDs = unique(GroupIDs);
    if length(GroupIDs) > 2
        error('For now, the data must contain only two groups')
    end
    if nargin < 4 || isempty(groupnames)
        groupnames = arrayfun(@num2str, GroupIDs, 'un', 0);
    end
    if nargin < 5 || isempty(makeplot)
        makeplot = 1;
    end
    thisGroup = cell(length(GroupIDs), 1);
    for i = 1:size(data, 1)
        fvals = data(i, :).TS_DataMat(:, opid);  
        for u = 1:length(GroupIDs)
            thisGroup{u} = [thisGroup{u}; fvals(data(i, :).Group_ID == u)];
        end
    end
    
%% Then calculate the statistics    
    switch statmethod
        case 'welch_t_test'
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
        ax = gca;
        cmp = [ 0.3020    0.6863    0.2902;
                0.8941    0.1020    0.1098;
                0.2157    0.4941    0.7216;
                0.5961    0.3059    0.6392;
                1.0000    0.4980         0;
                1.0000    1.0000    0.2000;
                0.6510    0.3373    0.1569;
                0.9686    0.5059    0.7490;
                0.6000    0.6000    0.6000
                0         0         0      ];
        ax.ColorOrder = cmp;
        hold on
        for i = 1:length(GroupIDs)
           customHistogram(thisGroup{i}, linspace(min(thisGroup{i}), max(thisGroup{i}), 25));
        end
        ylabel('Frequency', 'fontsize', 14)
        xlabel('Feature Value', 'fontsize', 14)
        legend(groupnames)
        title(sprintf('%s: %s\np-value = %0.3g', titlestr, data(1, :).Operations.Name{data(1, :).Operations.ID == opid}, stat), 'interpreter', 'none')
    end
end

