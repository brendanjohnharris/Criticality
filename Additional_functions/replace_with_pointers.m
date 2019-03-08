function [time_series_data, TS_DataMat] = replace_with_pointers(time_series_data,savefile)
    %REPLACE_WITH_POINTERS 
    % Must have TS_DataMats witht he same number of columns I.e. same
    % number of operations
    if ischar(time_series_data)
        load(time_series_data, 'time_series_data')
    end
    if nargin < 2
        savefile = [];
    end
    TS_DataMat = vertcat(time_series_data.TS_DataMat);
    inputs = {time_series_data.Inputs};
    column_number = size(TS_DataMat, 2);
    rowcounter = 1;
    for i = 1:size(time_series_data, 1)
        time_series_data(i, :).TS_DataMat = pointTo('TS_DataMat', [rowcounter, 1], [rowcounter+length(inputs{i}.cp_range)-1, column_number]);
        rowcounter = rowcounter + length(inputs{i}.cp_range);
    end
    if ~isempty(savefile)
        save(savefile, 'time_series_data', 'TS_DataMat', '-v7.3')
    end
end

