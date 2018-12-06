function [spearmans, pearsons, mu, r] = find_correlation(plots, file)
    %% Calculating
    if nargin < 2 || isempty(file) || ~exist(file, 'file')
        file = 'HCTSA_N.mat';
    end
    load(file, 'TS_DataMat', 'TimeSeries', 'Operations')
    % Assumes time series is named (labelled) with the value of its control parameter:
    
    %data = struct2cell(TimeSeries);
    
    %mu = str2double(cellfun(@(x) (x), regexp(data(1, :),...
        %'-?\d*\.?\d*','Match')))'; % '[-](\d?[.]\d*|\d*)|(\d?[.]\d*|\d*)'
    mu = str2double(TimeSeries.Name);
       
    % First column of 'r' is Pearson's (linear), second is Spearman's (rank):
    r = [corr(mu, TS_DataMat, 'type', 'Pearson')', corr(mu, TS_DataMat, 'type', 'Spearman')'];
    [~, idxs] = maxk(abs(r), length(r)); % Sort counts NaN's as largest
    IDs = [Operations.ID]; %Assumes operation indices match TS_DataMat columns
    % First colum of 'pearsons' and 'spearmans' is the correlation, the
    % second is the ID of the corresponding operation
    pearsons = [r(idxs(:, 1), 1), IDs(idxs(:, 1))];
    spearmans = [r(idxs(:, 2), 2), IDs(idxs(:, 2))]; 
    %% Plotting
    if nargin < 1 || isempty(plots) || plots
        ps = numSubplots(10);
        a = figure('Name', "Pearson's Correlation");
        set(a, 'units','normalized','outerposition',[0 0.5 1 0.5]);
        b = figure('Name', "Spearman's Correlation");
        set(b, 'units','normalized','outerposition',[0 0 1 0.5]);
        for n = 1:10
            figure(a)
            subplot(ps(1), ps(2), n)
            plot(mu, TS_DataMat(:, idxs(n, 1)), 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
            title(sprintf('Feature: %g, Correlation: %.3g', pearsons(n, 2), pearsons(n, 1)))
            xlabel('Control Parameter')
            ylabel('Feature Value')
        end
        for n = 1:10
            figure(b)
            subplot(ps(1), ps(2), n)
            plot(mu, TS_DataMat(:, idxs(n, 2)), 'o', 'MarkerSize', 2, 'MarkerFaceColor', 'b')
            title(sprintf('Feature: %g, Correlation: %.3g', spearmans(n, 2), spearmans(n, 1)))
            xlabel('Control Parameter')
            ylabel('Feature Value')  
        end
        savefig(a, "Pearson's_correlation.fig")
        savefig(b, "Spearman's_correlation.fig") 
    end
    %% Saving
    %save('correlations.mat', 'pearsons', 'spearmans')
    correlation = spearmans;
    pearson_correlation = pearsons;
    save('correlation.mat', 'correlation')
    save('pearson_correlation.mat', 'pearson_correlation')
end
