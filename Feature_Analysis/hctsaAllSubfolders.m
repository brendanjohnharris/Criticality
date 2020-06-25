function hctsaAllSubfolders(combine, varargin)
%HCTSAALLSUBFOLDERS Provide the usual HCTSA arguments; the first (INP_ts)
% will name the time series file to search for in each subdirectory but
% INP_mops/ops should be referenced from the CURRENT DIRECTORY. There will be one
% outputFile in each subdirectory. combine is a logical; join with an
% existing 'HCTSA.mat' file or not.
% (varargin = INP_ts, INP_mops, INP_ops, beVocal, outputFile)
    if isempty(combine)
        combine = 1;
    end
    D = parallel.pool.DataQueue;
    h = waitbar(0, 'Please wait ...');
    afterEach(D, @nUpdateWaitbar);
    p = 1; 
    
    homedir = pwd;
    paths = regexp(genpath(homedir),['[^', pathsep, ']*'],'match');
    paths = paths(~contains(paths, [filesep, '.']));
    paths = paths(~strcmp(paths, homedir)); % Remove the current folder
    if isempty(paths)
        error('This folder contains no subfolders')
    end
    %varargin{2} = ['../', varargin{2}];
    %varargin{3} = ['../', varargin{3}];
    for i = 1:length(paths)
        subvarargin = varargin;
        subvarargin{1} = fullfile(paths{i}, subvarargin{1});
        subvarargin{5} = fullfile(paths{i}, subvarargin{5});
        if ~isfile(subvarargin{5})
            TS_init(subvarargin{:})
        end
        hctsafile = fullfile(paths{i}, 'HCTSA.mat');
        suphctsafile = fullfile(paths{i}, 'HCTSA_updated.mat');
        TS_compute(1, [], [], [], subvarargin{5}, 0)
        if isfile(hctsafile) && combine
            % Join the hctsa files together
            TS_combine(hctsafile,subvarargin{5}, 1, 1, suphctsafile, 1)
        end
        send(D, i);
    end
    close(h)
    
    function nUpdateWaitbar(~)
        waitbar(p/length(paths), h);
        p = p + 1;
    end
end

