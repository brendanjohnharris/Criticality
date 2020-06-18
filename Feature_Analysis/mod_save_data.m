function mod_save_data(filepath, keywords, source, datafile, inputfile, correlationfile, leaveflag, deletecurrent, TS_DataMat, Operations)
%SAVE_DATA Saves the data generated by 'TS_compute' and 'find_correlation'
%   into a file for easier access. It must be run within a folder
%   containing:
%       - A file of hctsa data (default: hctsa.mat)
%       - A file containing the parameters used to generate the data
%       (default: inputs.mat)
%       - A file containing the correlations of features to the control
%       parameter, usually a matrix whose first column is the spearman
%       correlations of the features identified in the second column
%       (default: correlation.mat)
%   
%   'filepath' is the location in which the data will be saved (including
%   the file name and extension!). If no such file is present, one will be created
%
%   'keywords' is a comma delimited string containing keywords for the time
%   series data, with no white space
%
%   'source' is a string contianing the function, original location or the
%   method used to collect the time series
%
%
%   (optional) 'datafile' is a string naming the file containing hctsa data (default:
%   HCTSA.mat)
%
%   (optional) 'inputfile' is a string naming the file containing parameter data (default:
%   inputs.mat)
%   
%   (optional) 'correlationfile' is a string naming the file containing correlations (default:
%   correlation.mat)
%
%   (optional) 'leaveflag' is a logical determining whether a flag is
%   left in the current folder to show it has already been added, and to
%   give the index in time_series_data of the current folder.
%
%   (optional) 'deletecurrent' is a logical specifying whether the
%   existing data file is to be deleted (default: false)

    %% Checking inputs
    tic
    if nargin < 4 || isempty(datafile)
        datafile = 'HCTSA.mat';
    end
    if nargin < 5 || isempty(inputfile)
        inputfile = 'inputs.mat';
    end
    if nargin < 6 || isempty(correlationfile)
        correlationfile = 'correlation.mat';
    end
    if nargin < 7 || isempty(leaveflag)
        leaveflag = true;
    end
    if nargin < 8 || isempty(deletecurrent)
        deletecurrent = false;
    end
    if ~exist(fullfile(cd, correlationfile), 'file') || ...
            ~exist(fullfile(cd, inputfile), 'file')
        error('One or more of the required files is missing')
    end
    if exist(fullfile(cd, 'flag.mat'), 'file')
        error('This folder has already been added')
    end
    %% Loading data
    %find_folder = which('save_data.m');
    %filepath = [find_folder(1:end-length('save_data.m')), filename];
    if deletecurrent && exist(filepath, 'file')
        delete(filepath)
    end
    if nargin < 2 || isempty(source)
        source = 'Unknown';
    end
    %[TS_DataMat, ~, Operations] = TS_LoadData(datafile);
    [~, opidxs] = sort(Operations.ID); % Sort Operations by ID
    Operations = Operations(opidxs, :);
    TS_DataMat = TS_DataMat(:, opidxs); % Sort datamat by moving columns
    p = load(inputfile);
    vars = fieldnames(p);
    inputs = p.(vars{1});
    temparameters = renameStructField(inputs, 'etarange', 'eta');
    c = load(correlationfile);
    vars = fieldnames(c);
    correlation = c.(vars{1});  
    load('correlation_inputs.mat')
    if ~exist(filepath, 'file')
        time_series_data = struct('TS_DataMat', {}, 'Operations', {}, 'Correlation', {}, 'Source', {}, 'Inputs', {}, 'Date', {}, 'Keywords', {}, 'Correlation_Type', {}, 'Correlation_Range', {});
        nrows = 0;
        save(filepath, 'time_series_data', 'nrows', '-v7.3')
    end
    m = matfile(filepath, 'Writable',true); 
    minflagid = size(m.time_series_data, 1); % !!!!!
    savestruct = repmat(struct('TS_DataMat', [], 'Operations', Operations, ...
            'Correlation', [], 'Source', source, ...
            'Inputs', [], 'Date', date, 'Keywords', keywords, 'Correlation_Type', correlation_type, 'Correlation_Range', correlation_range), length(inputs.etarange), 1);
    for i = 1:length(inputs.etarange)
        %fprintf('------------------------%g%% complete, %gs elapsed------------------------\n', round(100*(i-1)./length(parameters.etarange)), round(toc))
        savestruct(i, 1).TS_DataMat = TS_DataMat(1+length(inputs.cp_range)*(i-1):length(inputs.cp_range)*i, :);
        savestruct(i, 1).Correlation = correlation.Correlations{[cellfun(@(x) x, correlation.Eta)] == inputs.etarange(i)};
        [~, coridxs] = sort(savestruct(i, 1).Correlation(:, 2));
        savestruct(i, 1).Correlation = savestruct(i, :).Correlation(coridxs, :);
        temparameters.eta = inputs.etarange(i);
        savestruct(i, 1).Inputs = temparameters;
    end
    oldnrows = m.nrows;
    nrows = oldnrows + length(inputs.etarange);
    
    if isempty(m.time_series_data)
        m.time_series_data = savestruct;
    else
        m.time_series_data(oldnrows+1:nrows, 1) = savestruct; % Need faster way to modify time_series_data
    end
    m.nrows = nrows;
    if exist('m', 'var') && leaveflag
        flagid = nrows+1:nrows+length(inputs.etarange);
        save('flag.mat', 'flagid')
    end
    %cd(find_folder(1:end-12))
    %fprintf('------------------------100%% complete, %gs elapsed------------------------\n', round(toc))
end
