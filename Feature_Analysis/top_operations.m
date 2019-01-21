function tbl = top_operations(on_what, N, data, peak_shift, weight_by, directions)
    %find_folder = which('save_data.m');
    %filepath = [find_folder(1:end-length('save_data.m')), filename];
    
    % 'weight_by' is either 'mean', 'NaN' or 'peak_shift'
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
    if nargin < 4 || isempty(peak_shift)
        peak_shift = 0;
    end
    if nargin < 5 || isempty(weight_by)
        weight_by = 'mean';
    end
    if nargin < 6 || isempty(directions)
        directions = [];
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
    Operation_Keywords = data(1).Operations.Keywords; % Same order as Operation_ID, currently
    corrs = zeros(numops, length(data));
    for n = 1:length(data)
        [~, idxcor] = intersect(data(n).Correlation(:, 2), Operation_ID); 
        tempcorr = data(n).Correlation(:, 1);
        corrs(:, n) = tempcorr(idxcor); % Gets corrs in same order as Operation_ID's
    end
    
    
%% Determine the sortScore   
    
    
    Percent_Not_NaN = 100.*sum(~isnan(corrs), 2)./size(corrs, 2); % Currently in Operation_ID order
    Mean_Absolute_Correlation = nanmean(abs(corrs), 2); %In Operation order
    if peak_shift
        if size(data, 1) == 1
            Peak_Shift = zeros(length(Mean_Absolute_Correlation), 1);  % Maybe change variable name to distinguish from peak_shift
            for x = 1:length(Peak_Shift)
                Peak_Shift(x) = get_noise_shift(data, data.Operations.ID(x), directions(x), 0);
            end
        else
            Peak_Shift = NaN(length(Mean_Absolute_Correlation), 1);
        end
    end
    
    switch weight_by
        case 'mean'
            sortScore = Mean_Absolute_Correlation; %In Operation order
        case 'NaN'
            NaN_Weighted_Mean_Correlation = Mean_Absolute_Correlation.*Percent_Not_NaN./100; % In Operation order
            sortScore = NaN_Weighted_Mean_Correlation; % In Operation order
        case 'peak_shift'
            %sortScore = Mean_Absolute_Correlation./Peak_Shift; % In Operation order
            sortScore = 1./abs(Peak_Shift);
    end


% Sort the sortScore and get the indices to sort other variables
    [sorted_sortScore, idxs] = sort(-sortScore);  % Minus so that 'greatest' are 'last', sort score previously in same order as Percent_Not_NaN
    sorted_sortScore = -sorted_sortScore; % Minus so that greatest are first, NaN's are last. Now in order
    
%% Sort other variables
    Percent_Not_NaN = Percent_Not_NaN(idxs); % Now in order of score
    Mean_Absolute_Correlation = Mean_Absolute_Correlation(idxs); % Now in order of score
    Peak_Shift = Peak_Shift(idxs);% Now in order of score
    
    
    
    
%     if absolute
%         Mean = nanmean(abs(corrs), 2);
%         Standard_Deviation = nanstd(abs(corrs), 0, 2);
%     else
%         Mean = nanmean(corrs, 2);
%         Standard_Deviation = nanstd(corrs, 0, 2);
%     end
    Operation_ID = Operation_ID(idxs); % Gets Operation_IDs into score order
    Operation_Name = Operation_Name(idxs); %Gets Operation_Names in score order
    Operation_Keywords = Operation_Keywords(idxs); % Gets Operation_Keywords in score order
%     if size(data, 1) == 1
%         Correlation = corrs(idxs); % Get Correlation in score order
%         tbl = table(Operation_ID, Operation_Name, Operation_Keywords, Correlation);
%     else
        %Score = Mean;
%         if weight_by_NaN
%             NaN_Weighted_Mean_Correlation = sorted_sortScore;
%             tbl = table(Operation_ID, Operation_Name, Operation_Keywords, Mean_Absolute_Correlation, Percent_Not_NaN, NaN_Weighted_Mean_Correlation);
%         else
    tbl = table(Operation_ID, Operation_Name, Operation_Keywords, Mean_Absolute_Correlation, Percent_Not_NaN, Peak_Shift);
%        end
    tbl = tbl(1:N, :);  
    
end
