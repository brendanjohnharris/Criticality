function histogramStat(data, theSingleStat, theStat)
    if nargin < 3 && (nargin == 2 && ~isempty(theSingleStat))
        theStat = theSingleStat;
        theSingleStat = [];
    elseif nargin < 3 || isempty(theStat) || nargin < 2 || isempty(theSingleStat)
        theStat = 'Aggregated_Absolute_Correlation';
        theSingleStat = [];
    end
    if ~isempty(theSingleStat)
        theSingleStat = {theSingleStat};
    end
    tbl = get_combined_feature_stats(data, theSingleStat, {theStat}, [], 1);
    
    X = tbl.(theStat);
    n = height(tbl);
    figure('Color', 'w')
    ax = gca;
    [hist1, bs] = customHistogram(X, 40, [], 1, 'k', 'k');
    hold on
    [hist11, bs11] = customHistogram(X, 40, [], 0, 'k');

    xlabel(theStat)
    ylabel('Frequency', 'FontSize', 15)
    if strcmp(theStat, 'Aggregated_Absolute_Correlation')
        xlim([0, 1])
        xlabel('$$|\rho_\mu^\mathrm{agg}|$$', 'Interpreter', 'LaTeX', 'FontSize', 16)
    elseif strcmp(theStat, 'Aggregated_Correlation')
        xlim([-1, 1])
        xlabel('$$\rho$$', 'Interpreter', 'LaTeX', 'FontSize', 16)
    else
        xlabel(theStat, 'Interpreter', 'none')
    end
    %title(sprintf('Mean Individual Feature Performance: %s Classifier (n = %i)', classifier, n))
    %legend(system, 'Null (Shuffled)', 'Location', 'NorthWest')
    ax = gca;
    ax.YAxis.TickValues = [0:200:1000];
    ax.XAxis.TickValues = [0:0.2:1];
    title(theStat, 'Interpreter', 'none')
end
