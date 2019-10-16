function data = shuffleGroups(data)
%SHUFFLEGROUPS Shuffle the class labels of a group'd time_series_data
    rng('default')
    for i = 1:size(data, 1)
        Group_IDs = data(i, :).Group_ID;
        Group_IDs = Group_IDs(randperm(length(Group_IDs)));
        data(i, :).Group_ID = Group_IDs;
    end
end

