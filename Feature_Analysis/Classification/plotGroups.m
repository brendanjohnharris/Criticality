function plotGroups(data, opid, superGroups)
    % Plot each row of the data struct in a different markers, and the
    % groups with different colours
    % superGroups is a cell 'vector' containing vectors of indices with
    % which to group rows of data. If empty, the groups will be taken as
    % the rows, individually
    % Make sure the groups are CONSISTENT IN ORDER FOR ALL TIMESERIES
    % ROWS!!!
    consistent = checkConsistency(data, [0, 1, 1]);
    if nargin < 3
        superGroups = [];
    end
    if ~isempty(superGroups)
        superData = struct();
        if ~consistent
            error('To use super groups the data rows must be consistent in operations')
        end
        for s = 1:length(superGroups)
            superData(s, :).TS_DataMat = (arrayfun(@(x) x.TS_DataMat, data(superGroups{s}, :), 'un', 0));
            superData(s, :).Inputs.cp_range = (arrayfun(@(x) x.Inputs.cp_range, data(superGroups{s}, :), 'un', 0));
            superData(s, :).Group_ID = (arrayfun(@(x) x.Group_ID, data(superGroups{s}, :), 'un', 0));
            superData(s, :).TS_DataMat = vertcat(superData(s, :).TS_DataMat{:});
            superData(s, :).Inputs.cp_range = horzcat(superData(s, :).Inputs.cp_range{:});
            superData(s, :).Group_ID = vertcat(superData(s, :).Group_ID{:});
            superData(s, :).Operations = data(1, :).Operations;
        end
        data = superData;
    end
    
    markers = {'o', 'x', 's', 'd', '+', '*', '^', 'v', '<', '>'};
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
    f = figure('color', 'w');
    ax = gca;
    hold on
    groupIDs = arrayfun(@(x) x.Group_ID, data, 'un', 0);
    groupIDs = unique([groupIDs{:}]);
    
    % Make some invisible line plots so the legend makes sense (e,g. 
    % legend({<row 1 name>, <row 2 name>, ..., <group 1 name>, <group 2 name>, ...})
    for i = 1:size(data, 1)
    	plot(NaN, NaN, 'marker', markers{i}, 'color', 'k', 'markerfacecolor', 'k', 'linestyle', 'none')
    end
    for v = 1:length(groupIDs)
        plot(NaN, NaN, 'marker', 'none', 'color', cmp(v, :), 'linewidth', 10)
    end
    
    for i = 1:size(data, 1)
        for v = 1:length(groupIDs)
            idxs = data(i, :).Group_ID == groupIDs(v);
            plot(data(i, :).Inputs.cp_range(idxs), data(i, :).TS_DataMat(idxs, data(i, :).Operations.ID == opid),...
                'color', cmp(v, :), 'marker', markers{i}, 'markerfacecolor', cmp(v, :), 'linestyle', 'none', 'markersize', 5);
        end
    end
    xlabel('Control Parameter')
    ylabel('Feature Value')
    if consistent % Operations are the same
        title(data(1, :).Operations.Name{data(1, :).Operations.ID == opid}, 'Interpreter', 'none')
    end
    ax.Box = 'on';
    hold off
end