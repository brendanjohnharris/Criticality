function compareAnalysis2(filename1, filename2, depth)
    load(filename1)
    if nargin < 3
        depth = size(lossmat, 1);
    end
    plotdata = [arrayfun(@(x) lossmat(x, :), 1:depth, 'un', 0)];%, lossvec];
    plotdata = cellfun(@mean, plotdata);
    plot(1:depth, plotdata([1:depth]), '.-', 'MarkerSize', 20)
    hold on
    
    load(filename2)
    plotdata = [arrayfun(@(x) lossmat(x, :), 1:depth, 'un', 0)];%, lossvec];
    plotdata = cellfun(@mean, plotdata);
    plot(1:depth, plotdata([1:depth]), '.-', 'MarkerSize', 20)
    
    a = gca;
    set(gcf,'color','w');
    a.XTick = 1:depth+1;
    a.XTickLabels = [arrayfun(@num2str, 1:depth, 'un', 0), 'all'];
    ylabel('Misclassification rate')
    xlabel('Number of features')
end

