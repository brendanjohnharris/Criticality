function tbl = top_operations(on_what, N, data, weight_by_NaN)
    %find_folder = which('save_data.m');
    %filepath = [find_folder(1:end-length('save_data.m')), filename];
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
    if nargin < 4 || isempty(weight_by_NaN)
        weight_by_NaN = false;
    end
    % Time series must have the same Operations
    data = data(contains({data.Keywords}, on_what));
    Operation_ID = [data(1).Operations.ID]; % Fix so that data with different operations can be compared???
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
        corrs(:, n) = tempcorr(idxcor); % Gets corrs in same order as Operation_ID's
    end
    Percent_Not_NaN = 100.*sum(~isnan(corrs), 2)./size(corrs, 2); % Currently in Operation_ID order
    if weight_by_NaN 
        sortScore = nanmean(abs(corrs), 2).*Percent_Not_NaN./100; % In Operation order
    else
        sortScore = nanmean(abs(corrs), 2); %In Operation order
    end
    [sorted_sortScore, idxs] = sort(-sortScore);  % Minus so that 'greatest' are 'last', sort score previously in same order as Percent_Not_NaN
    sorted_sortScore = -sorted_sortScore; % Minus so that greatest are first, NaN's are last. Now in order
    Percent_Not_NaN = Percent_Not_NaN(idxs); % Now in order of score
%     if absolute
%         Mean = nanmean(abs(corrs), 2);
%         Standard_Deviation = nanstd(abs(corrs), 0, 2);
%     else
%         Mean = nanmean(corrs, 2);
%         Standard_Deviation = nanstd(corrs, 0, 2);
%     end
    Operation_ID = Operation_ID(idxs); % Gets Operation_IDs into score order
    Operation_Name = Operation_Name(idxs); %Gets Operation_Names in score order
    if size(data, 1) == 1
        Correlation = corrs(idxs); % Get Correlation in score order
        tbl = table(Operation_ID, Operation_Name, Correlation);
    else
        %Score = Mean;
        if weight_by_NaN
            NaN_Weighted_Mean_Correlation = sorted_sortScore;
            tbl = table(Operation_ID, Operation_Name, NaN_Weighted_Mean_Correlation, Percent_Not_NaN);
        else
            Mean_Absolute_Correlation = sorted_sortScore;
            tbl = table(Operation_ID, Operation_Name, Mean_Absolute_Correlation, Percent_Not_NaN);
        end
    end
    %Mean = Mean(idxs);
    %Score = Score(idxs);
    %Standard_Deviation = Standard_Deviation(idxs);
    %, Standard_Deviation, Score);
    tbl = tbl(1:N, :);   
end
