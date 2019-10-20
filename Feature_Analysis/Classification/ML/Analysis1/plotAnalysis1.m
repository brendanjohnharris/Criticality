function plotAnalysis1(filename, classifier, system)
%PLOTANALYSIS2 
    load(filename)
    meanloss = operations.Mean_Loss;
    n = size(lossmat, 2);
    shufflemeanloss = shuffleoperations.Mean_Loss;
    figure('Color', 'w')
    ax = gca;
    hist1 = customHistogram(meanloss, 50, [], 0, 'k');
    max1 = max(hist1);
    %yyaxis right
    %ax = gca;
    %ax.YAxis(2).Color = 'k';
    %ax.XAxis.Color = 'k';
    numbins = 4;
    tempax = axes();
    max2 = inf;
    while max2 > max1
        numbins = numbins + 1;
        hist2 = customHistogram(shufflemeanloss, numbins, [], 1, 'k');
        max2 = max(hist2);
    end
    delete(tempax);
    customHistogram(shufflemeanloss, numbins, [], 1, 'k');
    xlabel('Mean Misclassification Rate')
    ylabel('Frequency')
    title(sprintf('Mean Individual Feature Performance: %s Classifier (n = %i)', classifier, n))
    legend(system, 'Null (Shuffled Classes)', 'Location', 'NorthWest')
end
