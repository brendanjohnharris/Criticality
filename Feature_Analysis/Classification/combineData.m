function data = combineData(datas)
%COMBINEDATA Nothing special, just give time_series_data's and this
%will concatenate them.
    if size(datas, 2) > 1
        datas = datas'; % Column
    end
    filedatas = find(cellfun(@ischar, datas))';
    for i = filedatas
        S = load(datas{i}, 'time_series_data');
        datas{i} = S.time_series_data;
    end
    data = vertcat(datas{:});
end

