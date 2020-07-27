function add_all_subfolders()
%ADD_ALL_SUBFOLDERS Adds all subdirectories of the current directory to the
%search path, recursively. If available, uses .gitignore file to ignore data folders.
    homedir = pwd;
    try
        paths = regexp(genpath(homedir),['[^', pathsep, ']*'],'match');
        paths = paths(~contains(paths, [filesep, '.'])); % Leave out .git and other unwanted files
        % Read the .gitignore file to find folders to exclude
        fid = fopen('.gitignore');
        ign = textscan(fid, '%s');
        fclose(fid);
        ign = ign{1};
        ign = ign(~cellfun(@isempty, regexp(ign, '[/][*]{2}$|[/]$|', 'match'))); % Only these things are folders
        %ign = catCellEl(ign, repmat({'$'}, size(ign)));
        ign = strrep(ign, '**', '.*');
        ign = strrep(ign, '/', ['\', filesep]);
        ign = cellfun(@(x) ~cellfun(@isempty, regexp(paths, x, 'match')), ign, 'UniformOutput', 0);
        ign = logical(sum(vertcat(ign{:}), 1));
        paths = paths(~ign); % Phew
    catch
        warning('Error gitting your subfolders. Adding ALL subfolders...')
        paths = regexp(genpath(homedir),['[^', pathsep, ']*'],'match');
        paths = paths(~contains(paths, [filesep, '.'])); % Leave out .git and other unwanted files
    end
    
    for i = 1:length(paths)
        addpath(paths{i})
    end
end
