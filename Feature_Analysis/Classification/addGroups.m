function time_series_data = addGroups(time_series_data, muConditions, savefile)
% Each element of the cell array muConditions is a character array indicating a logical e.g. 'mu < 2'
% Each element specifies one group, which will be given an ID (number) that
% matches the index fo the correspoding condition
% Labels groups in each noise parameter block (row).
% Won't label groups with more than one ID; if a TS_DataMat row satisfies 
% two conditions, an error with be thrown
    if nargin < 3 
        savefile = [];
    end
    for i = 1:length(time_series_data)
        groupIDs = nan(size(time_series_data(i, :).TS_DataMat, 1), 1);
        mu = time_series_data(i, :).Inputs.cp_range;
        time_series_data(i, :).Group_Conditions = muConditions;
        for ID = 1:length(muConditions)
            if any(isnan(groupIDs) & eval(muConditions{ID}))
                error('The group conditions overlap')
            end
            groupIDs(eval(muConditions{ID})) = ID;
        end
        time_series_data(i, :).Group_ID = groupIDs;
    end
    if ~isempty(savefile)
        save(savefile, 'time_series_data')
    end
end

