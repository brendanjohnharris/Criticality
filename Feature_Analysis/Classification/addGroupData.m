function time_series_data = addGroupData(time_series_data, muConditions, groupNames, savefile, IDs)
% Each element of the cell array muConditions is a character array indicating a logical e.g. 'mu < 2'
% Each element specifies one group, which will be given an ID (number) that
% matches the index of the correspoding condition
% IDs is a vector of the same size as muConditions, specifying the numeric
% ids to give each group (default; 1, 2, 3, 4...)
% Labels groups in each noise parameter block (row).
% Won't label groups with more than one ID; if a TS_DataMat row satisfies 
% two conditions, an error with be thrown
    if nargin < 3
        groupNames = [];
    end
    if nargin < 4 
        savefile = [];
    end
    if nargin < 5 || isempty(IDs)
        IDs = 1:length(muConditions);
    end
    if ischar(time_series_data)
        load(time_series_data)
    end
    for i = 1:length(time_series_data)
        groupIDs = nan(size(time_series_data(i, :).TS_DataMat, 1), 1);
        Group_Names = cell(size(time_series_data(i, :).TS_DataMat, 1), 1);
        mu = time_series_data(i, :).Inputs.cp_range; % eval'd
        time_series_data(i, :).Group_Conditions = muConditions;
        for idx = 1:length(IDs)
            if any(isnan(groupIDs) & eval(muConditions{idx}))
                error('The group conditions overlap')
            end
            groupIDs(eval(muConditions{idx})) = IDs(idx);
            if ~isempty(groupNames)
                Group_Names(eval(muConditions{idx})) = groupNames(idx);
            end
        end
        time_series_data(i, :).Group_ID = groupIDs;
        if ~isempty(groupNames)
            time_series_data(i, :).Group_Names = unique(Group_Names, 'stable');
        end
    end
    if ~isempty(savefile)
        save(savefile, 'time_series_data')
    end

%     if nargin < 3
%         groupNames = [];
%     end
%     if nargin < 4 
%         savefile = [];
%     end
%     if nargin < 5 || isempty(IDs)
%         IDs = 1:length(muConditions);
%     end
%     for i = 1:length(time_series_data)
%         groupIDs = nan(size(time_series_data(i, :).TS_DataMat, 1), 1);
%         %Group_Names = cell(size(time_series_data(i, :).TS_DataMat, 1), 1);
%         mu = time_series_data(i, :).Inputs.cp_range; % eval'd
%         time_series_data(i, :).Group_Conditions = muConditions;
%         for idx = 1:length(IDs)
%             if any(isnan(groupIDs) & eval(muConditions{idx}))
%                 error('The group conditions overlap')
%             end
%             groupIDs(eval(muConditions{idx})) = IDs(idx);
%             if ~isempty(groupNames)
%                 time_series_data(i, :).Group_Names{idx} = groupNames(IDs(idx));
%             else
%                 time_series_data(i, :).Group_Names = arrayfun(@num2str, unique(time_series_data(1, :).Group_ID, 'sorted'), 'un', 0);
%             end
%         end
%         time_series_data(i, :).Group_ID = groupIDs;
%     end
%     if ~isempty(savefile)
%         save(savefile, 'time_series_data')
%     end
% end
end
