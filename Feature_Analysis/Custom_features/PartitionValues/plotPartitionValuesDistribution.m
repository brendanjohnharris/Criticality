function plotPartitionValuesDistribution(timeseries, option)
% Timeseries is a matrix of time series, one per row
    figure
    if option == 1 % plot the distributions of autocorrelation of lag 1 for each window for each timeseries
        acvecU = [];
        acvecV = [];
        for i = 1:size(timeseries, 1)
            [~, ~, extrares] = PartitionValues(timeseries(i, :), 'buffer', 2);
            u = extrares.avgACmat(1, :); % Lower partition
            v = extrares.avgACmat(end, :); % Upper partition
            acvecU = [acvecU, cellfun(@(c) c(2), u{1})]; % AC1
            acvecV = [acvecV, cellfun(@(c) c(2), v{1})];
        end
        histogram(acvecU, 100)
        hold on
        histogram(acvecV, 100)
        set(gcf, 'color', 'w')
        xlabel('Autocorrelation at Lag 1')
        ylabel('Frequency')
        legend({'Lower half', 'Upper half'}, 'location', 'northwest')
    elseif option == 2
        lowAC = zeros(1, 100);
        highAC = zeros(1, 100);
        for i = 1:100
            res = PartitionValues(timeseries(i, :), 'buffer', 2);
            lowAC(i) = res.minpartcatAC1;
            highAC(i) = res.maxpartcatAC1;
        end
        histogram(lowAC, 20)
        hold on
        histogram(highAC, 20)
        set(gcf, 'color', 'w')
        xlabel('Autocorrelation at Lag 1')
        ylabel('Frequency')
        legend({'Lower half', 'Upper half'}, 'location', 'northwest')
    end
end

