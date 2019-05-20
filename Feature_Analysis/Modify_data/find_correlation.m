function find_correlation(datafile, correlation_type, what_range, savefile)
%   'what_range' is a two element vector, defining the range of control
%   parameters that will be used to calculate correlations
%   Should be run AFTER group_by_noise, if that function is neccessary
    %% Calculating
%     if nargin < 1 || isempty(plots)
%         plots = false;
%     end
    if nargin < 1 || isempty(datafile)
        datafile = 'time_series_data';
    end
    if nargin < 2 || isempty(correlation_type)
        correlation_type = 'Spearman';
    end
    if nargin < 3
        error('Please provide a range over which to calculate the feature value correlations');
    end
    if nargin < 4 || isempty(savefile)
        savefile = datafile;
    end
    if ~ischar(datafile)
        time_series_data = datafile;
    else 
        load(datafile, 'time_series_data')
    end
    % Assume the 'cp_range' in the input file is in order and
    % repeated consistently over 'etarange'
    for i = 1:size(time_series_data, 1)
        data = time_series_data(i, :);
        [~, lowidx] = min(abs(data.Inputs.cp_range - what_range(1)));
        [~, highidx] = min(abs(data.Inputs.cp_range - what_range(2)));
        if ~isempty(highidx)
            what_range_idxs = [lowidx:highidx]; % Since all sections of datamat have the same cp range, can use this for all
        else
            what_range_idxs = [lowidx:length(data.Inputs.cp_range)]; % Since all sections of datamat have the same cp range, can use this for all
        end

        %data = struct2cell(TimeSeries);

        %mu = str2double(cellfun(@(x) (x), regexp(data(1, :),...
            %'-?\d*\.?\d*','Match')))'; % '[-](\d?[.]\d*|\d*)|(\d?[.]\d*|\d*)'
        mu = data.Inputs.cp_range(what_range_idxs)'; % Get cp_range in right shape
        %correlation_cell = cell(1, length(time_series_data(i, :).Inputs.etarange));
        %for i = 1:length(parameters.etarange)
            trimmedsubDataMat = data.TS_DataMat(what_range_idxs, :);
            switch correlation_type
                case 'Spearman'
                    r = corr(mu, trimmedsubDataMat, 'type', 'Spearman')';

                case 'Pearson'
                    r = corr(mu, trimmedsubDataMat, 'type', 'Pearson')';
            end
            [~, idxs] = maxk(abs(r), length(r)); % Sort counts NaN's as largest
            IDs = [data.Operations.ID]; %Assumes operation indices match TS_DataMat columns
            % First colum of entries of correlation_cell is the correlation, the
            % second is the ID of the corresponding operation
            % pearsons = [r(idxs(:, 1), 1), IDs(idxs(:, 1))];
            time_series_data(i, :).Correlation = [r(idxs(:, 1), 1), IDs(idxs(:, 1))]; 
            time_series_data(i, :).Correlation_Type = correlation_type;
            time_series_data(i, :).Correlation_Range = what_range;
    end
    %% Saving
    correlation_range = what_range;
    save('correlation_inputs.mat', 'correlation_type', 'correlation_range')
    save(savefile, 'time_series_data', '-v7.3', '-nocompression')
    %save('pearson_correlation.mat', 'pearson_correlation')
end
