function combineBatchFiles(filename)
    % Modified from distributed_hctsa
    % filename must include extension
    if nargin < 1 || isempty(filename)
        filename = 'HCTSA_subset.mat';
    end
    files = dir('./');

    % Filter out any directory/file starting with '.'
    for k = length(files):-1:1
        if strcmp(files(k).name(1),'.')
            files(k) = [];
        end
    end

    isDirectory = [files.isdir];
    directories = files(isDirectory);
    directoryNames = {directories.name};
    numFiles = length(directoryNames);

    % Do the first one
    copyfile(fullfile(directoryNames{1}, filename),'./HCTSA.mat');

    for i = 2:numFiles
        newFile = fullfile(directoryNames{i}, filename);
        TS_combine('HCTSA.mat',newFile,false,false,'HCTSA_combined.mat'); 
        delete('HCTSA.mat');
        movefile('HCTSA_combined.mat','HCTSA.mat');
    end
end