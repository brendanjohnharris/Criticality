function tbl = morph_to_hctsa(data)
%MORPH_TO_HCTSA Restructure given time series data into a form used in hctsa
%   The resulting table is for use in TS_init or TS_CalculateFeatureVector.
%   Performs the same function as hctsa's SQL_add with the 'ts' option, but
%   on in-memory data.
%   WARNING     Does not perform the same chekcs of time series quality as
%               SQL_add. Use with caution.
%
%   INPUT:
%       data:   A structure that should be identical in formatting to one
%               loaded from an hctsa input file

%% Check that the structure of 'data' is correct
    if ~isfield(data,'timeSeriesData') || ~isfield(data,'labels') || ~isfield(data,'keywords') ...
                 || ~(isnumeric(data.timeSeriesData)) ...
                || ~iscell(data.labels) || ~iscell(data.keywords)
            error('One or more of the fields of the given structure is incorrectly formatted. Refer to the hctsa docs on how the construct an input file')
    end
    
%% Build table columns. Final table will need to have ID, Name, Keywords, Length and Data
    Name = data.labels;
    if isrow(Name), Name = Name'; end
    Keywords = data.keywords;
    if isrow(Keywords), Keywords = Keywords'; end
    Data = num2cell(data.timeSeriesData', 1)';
    ID = (1:length(Data))';
    Length = zeros(length(Data), 1) + size(data.timeSeriesData, 2);
    
%% Make table
    tbl = table(ID,Name,Keywords,Length,Data);
end

