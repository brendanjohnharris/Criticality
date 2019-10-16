function plotAnalysis2(filename)
%PLOTANALYSIS2 
    figure
    load(filename)
    d = size(lossmat, 1);
    BF_JitteredParallelScatter([arrayfun(@(x) lossmat(x, :), 1:d, 'un', 0), lossvec], 1, 1, 0)
    a = gca;
    for i = 1:length(a.Children)
    a.Children(i).Color = 'k';
    end
    set(gcf,'color','w');
    a.XTick = 1:d+1;
    a.XTickLabels = [arrayfun(@num2str, 1:d, 'un', 0), 'all'];
    ylabel('Misclassification rate')
    xlabel('Number of features')
    %ylim([0, inf])
end

