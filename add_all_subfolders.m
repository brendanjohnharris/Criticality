function add_all_subfolders
%ADD_ALL_SUBFOLDERS Adds all subdirectories of the current directory to the
%search path, recursively
    homedir = pwd;
    paths = regexp(genpath(homedir),['[^', pathsep, ']*'],'match');
    paths = paths(~contains(paths, [filesep, '.'])); % Leave out .git and other unwanted files
    for i = 1:length(paths)
        addpath(paths{i})
    end
end