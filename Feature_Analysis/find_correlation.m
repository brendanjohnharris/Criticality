function find_correlation(plots, datafile, parameterfile)
    %% Calculating
    if nargin < 1 || isempty(plots)
        plots = false;
    end
    if nargin < 2 || isempty(datafile) || ~exist(datafile, 'file')
        datafile = 'HCTSA.mat';
    end
    if nargin < 3 || isempty(parameterfile) || ~exist(parameterfile, 'file')
        parameterfile = 'parameters.mat';
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
    % Assumes the 'betarange' in the parameters file is in order and
    % repeated consistently over 'etarange'
    
    load(parameterfile)
    
    %data = struct2cell(TimeSeries);
    
    %mu = str2double(cellfun(@(x) (x), regexp(data(1, :),...
        %'-?\d*\.?\d*','Match')))'; % '[-](\d?[.]\d*|\d*)|(\d?[.]\d*|\d*)'
    mu = parameters.betarange';
    correlation_cell = cell(1, length(parameters.etarange));
    for i = 1:length(parameters.etarange)
        % r is spearmans correlation coefficient
        r = corr(mu, TS_DataMat(1+length(parameters.betarange)*(i-1):length(parameters.betarange)*i, :), 'type', 'Spearman')'; % mu wrong shape!!!???!!
        [~, idxs] = maxk(abs(r), length(r)); % Sort counts NaN's as largest
        IDs = [Operations.ID]; %Assumes operation indices match TS_DataMat columns
        % First colum of entries of correlation_cell is the correlation, the
        % second is the ID of the corresponding operation
        % pearsons = [r(idxs(:, 1), 1), IDs(idxs(:, 1))];
        correlation_cell{i} = [r(idxs(:, 1), 1), IDs(idxs(:, 1))]; 
        
        %% Plotting
        if plots
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
    end
    %% Saving
    %save('correlations.mat', 'pearsons', 'spearmans')
    correlation = table(num2cell(parameters.etarange)', correlation_cell');
    correlation.Properties.VariableNames = {'Eta','Correlations'};
    %pearson_correlation = pearsons;
    save('correlation.mat', 'correlation')
    %save('pearson_correlation.mat', 'pearson_correlation')
end
