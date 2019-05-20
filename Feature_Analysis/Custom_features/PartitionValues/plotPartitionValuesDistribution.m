function plotPartitionValuesDistribution(timeseries, option)
% Timeseries is a matrix of time series, one per row
    if option == 1 % plot the distributions of autocorrelation of lag 1 for each window for each timeseries
        acvecU = [];
        acvecV = [];
        for i = 1:size(timeseries, 1)
            [~, extrares] = PartitionValues(timeseries(i, :), 'buffer', 2);
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
    elseif option == 2 % Add the distributions of mutliple timeseries together
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
    elseif option == 3 % Part 1 but with 'vals'
        acvecU = [];
        acvecV = [];
        for i = 1:size(timeseries, 1)
            [~, extrares] = PartitionValues(timeseries(i, :), 'values', 2);
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
    elseif option == 4 % Plot autocorrelation as a function of 'height'
        percents = 1:100;
        for i = 1:size(timeseries, 1)
            [~, extrares] = PartitionValues(timeseries(i, :), 'buffer', 100, 0, NaN);
            ACmat(i, :) = extrares.catACmat(:, 2);
        end
        plot(percents, mean(ACmat, 1), '-o', 'markersize', 1)
    elseif option == 5 % Plot how the autocorrelation changes with increasing partition height
        heightvec = 4:4:100;
        for u = 1:size(timeseries, 1)
            for i = 1:20
                [res, extrares] = PartitionValues(timeseries(i, :), 'percentile', 2*i./100, 0, NaN);
                try
                    maxACvec(u, i) = res.maxpartmeanAC1;
                    minACvec(u, i) = res.minpartmeanAC1;
                catch
                    maxACvec(u, i) = NaN;
                    minACvec(u, i) = NaN;
                end
            end
        end 
        maxACvec = nanmean(maxACvec, 1);
        minACvec = nanmean(minACvec, 1);
        
    end
end

