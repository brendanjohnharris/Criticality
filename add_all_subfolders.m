function add_all_subfolders
    home = pwd;
    paths = regexp(genpath(home),'[^;]*','match');
    paths = strsplit(paths{1}, ':');
    paths = paths(~contains(paths, [filesep, '.'])); % Leave out .git and other unwanted files
    for i = 1:length(paths)
        addpath(paths{i})
    end
end