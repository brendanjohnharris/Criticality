function find_correlation(datafile, inputfile, correlation_type, what_range)
%   'what_range' is a two element vector, defining the range of control
%   parameters that will be used to calculate correlations
    %% Calculating
%     if nargin < 1 || isempty(plots)
%         plots = false;
%     end
    if nargin < 1 || isempty(datafile) || ~exist(datafile, 'file')
        datafile = 'HCTSA.mat';
    end
    if nargin < 2 || isempty(inputfile) || ~exist(inputfile, 'file')
        inputfile = 'inputs.mat';
    end
    if nargin < 3 || isempty(correlation_type)
        correlation_type = 'Spearman';
    end
    if nargin < 4
        error('Please provide a range over which to calculate the feature value correlations');
    end
    %% Ensure that time series in hctsa file are ordered
    m = matfile(datafile, 'Writable', true);
    TimeSeries = m.TimeSeries;
    [~, TSidxs] = sort(TimeSeries.ID);
    TimeSeries = TimeSeries(TSidxs, :);
    m.TimeSeries = TimeSeries;
    TS_DataMat = m.TS_DataMat;
    TS_DataMat = TS_DataMat(TSidxs, :);
    m.TS_DataMat = TS_DataMat;
    
    
    %% Load the other required variables
    Operations = m.Operations;
    % Assumes the 'cp_range' in the input file is in order and
    % repeated consistently over 'etarange'
    
    f = struct2cell(load(inputfile));
    parameters = f{1}; % Ignore the name of the variable saved in the parameter (input) file
    
    what_range_idxs = [find(parameters.cp_range == what_range(1)):find(parameters.cp_range == what_range(2))]; % Since all sections of datamat have the same cp range, can use this for all
    
    %data = struct2cell(TimeSeries);
    
    %mu = str2double(cellfun(@(x) (x), regexp(data(1, :),...
        %'-?\d*\.?\d*','Match')))'; % '[-](\d?[.]\d*|\d*)|(\d?[.]\d*|\d*)'
    mu = parameters.cp_range(what_range_idxs)'; % Get cp_range in right shape
    correlation_cell = cell(1, length(parameters.etarange));
    for i = 1:length(parameters.etarange)
        subDataMat = TS_DataMat(1+length(parameters.cp_range)*(i-1):length(parameters.cp_range)*i, :);
        trimmedsubDataMat = subDataMat(what_range_idxs, :);
        switch correlation_type
            case 'Spearman'
                r = corr(mu, trimmedsubDataMat, 'type', 'Spearman')';
            
            case 'Pearson'
                r = corr(mu, trimmedsubDataMat, 'type', 'Pearson')';
        end
        [~, idxs] = maxk(abs(r), length(r)); % Sort counts NaN's as largest
        IDs = [Operations.ID]; %Assumes operation indices match TS_DataMat columns
        % First colum of entries of correlation_cell is the correlation, the
        % second is the ID of the corresponding operation
        % pearsons = [r(idxs(:, 1), 1), IDs(idxs(:, 1))];
        correlation_cell{i} = [r(idxs(:, 1), 1), IDs(idxs(:, 1))]; 
    end
    %% Saving
    %save('correlations.mat', 'pearsons', 'spearmans')
    correlation = table(num2cell(parameters.etarange)', correlation_cell');
    correlation.Properties.VariableNames = {'Eta','Correlations'};
    
    %pearson_correlation = pearsons;
    save('correlation.mat', 'correlation')
    save('correlation_type.mat', 'correlation_type')
    %save('pearson_correlation.mat', 'pearson_correlation')
end
