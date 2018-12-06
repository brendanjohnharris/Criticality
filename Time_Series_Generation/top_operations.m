function tbl = top_operations(on_what, N, data, absolute)
    %find_folder = which('save_data.m');
    %filepath = [find_folder(1:end-length('save_data.m')), filename];
    if nargin < 4 || isempty(absolute)
        absolute = true;
    end
    if nargin < 3 || isempty(data)
        load('time_series_data.mat', 'time_series_data')
        data = time_series_data;
    end
    if ~isempty(on_what)
        on_what = [on_what, '_dependance'];
    else
        on_what = '';
    end
    if isstring(data) || ischar(data)
        load(data, 'time_series_data')
        data = time_series_data;
    end
    % Time series must have the same Operations
    data = data(contains({data.Keywords}, on_what));
    Operation_ID = [data(1).Operations.ID]; % Fix so that data with different operations fields can be compared
    %unique(cell2mat(arrayfun(@(x) [data(x).Operations.ID], 1:length(data), 'UniformOutput', false)'));
    numops = length(Operation_ID);
    if nargin < 2 || isempty(N)
        N = numops;
    end
    Operation_Name = data(1).Operations.Name; % Same order as Operation_ID, currently
    corrs = zeros(numops, length(data));
    for n = 1:length(data)
        [~, idxcor] = intersect(data(n).Correlation(:, 2), Operation_ID);
        tempcorr = data(n).Correlation(:, 1);
        corrs(:, n) = tempcorr(idxcor);
    end
    if absolute
        Mean = nanmean(abs(corrs), 2);
        Standard_Deviation = nanstd(abs(corrs), 0, 2);
    else
        Mean = nanmean(corrs, 2);
        Standard_Deviation = nanstd(corrs, 0, 2);
    end
    sortScore = nanmean(abs(corrs), 2);
    %Score = Mean;
    [~, idxs] = sort(-sortScore);
    Operation_ID = Operation_ID(idxs);
    Operation_Name = Operation_Name(idxs);
    Correlation = corrs(idxs);
    %Mean = Mean(idxs);
    %Score = Score(idxs);
    Standard_Deviation = Standard_Deviation(idxs);
    tbl = table(Operation_ID, Operation_Name, Correlation);%, Standard_Deviation, Score);
    tbl = tbl(1:N, :);   
end
