function [res, extrares] = PartitionValues(x, partitionType, partitionNum, makePlot, minLength)
%PARTITIONVALUES Partition the time series by value (not index/time) and
%   compute some statistics.
    
    if nargin < 4 || isempty(makePlot)
        makePlot = 0;
    end

    if nargin < 5 || isempty(minLength)
        minLength = 25;
    end
    
    if isnan(minLength)
        ignorelength = 1;
        minLength = 5;
    else 
        ignorelength = 0;
    end
        
    
    if minLength < 5
        error('The minimum length (arg. 5) must be greater than 4, or NaN')
    end

    if size(x, 1) > 1
        if size(x, 2) > 1
            error('The first input, x, must be a vector')
        end
        x = x';
    end
    
%% Partition the timeseries  
   
    switch partitionType
        case 'buffer'
            pmat = repmat(x, partitionNum, 1);
            [~, idxs] = sort(x, 'ascend');
            idxs = buffer(idxs, ceil(length(x)./partitionNum))';%floor(length(x)./partitionNum))';
%             if ~idxs(end, end)
%                 idxs = idxs(1:end-1, :); % Remove top portion of values. Fine if number of windows is large? 
%                 %idxs(1:end-1, idxs(1:end-1, :) == 0) = NaN; % What if there are legitimate zero values in the top portion of the time series?
%             end
            for i = 1:size(idxs, 1)
                pmat(i, setdiff(1:size(pmat, 2), idxs(i, :))) = NaN;
            end
            %............... Remove pairs that cross break...............
                 
        case 'values'
            pmat = repmat(x, partitionNum, 1);
            maxidxs = pmat(end, :) == max(x);
            df = (max(x) - min(x))/partitionNum;
            windowlims = min(x):df:max(x);
            for i = 1:partitionNum
                pmat(i, pmat(i, :) < windowlims(i) | pmat(i, :) >= windowlims(i+1)) = NaN;
            end
            pmat(end, maxidxs) = max(x); % Add back in the maximum values
            
        case 'percentile'
            pmat = repmat(x, 2, 1); % Only able to set cutoff for two parititions
            if partitionNum > 1 || partitionNum < 0
                error("If using partition type 'percentile' the third argument must be a percentage (between 0 and 1)")
            end
            p = prctile(x, partitionNum.*100);
            pmat(1, pmat(1, :) >= p) = NaN;
            pmat(2, pmat(2, :) < p) = NaN;
            
        case 'cumulativepercentile'
            pmat = repmat(x, 2, 1); % Only able to set cutoff for two parititions
            if partitionNum > 1 || partitionNum < 0
                error("If using partition type 'cumulativepercentile' the third argument must be a percentage (between 0 and 1)")
            end
            p = prctile(x, partitionNum.*100);
            pmat(1, pmat(1, :) > p) = NaN; % First row is full timeseries with top partition removed. See DN_RemovePoints_absfar
            % Second full timeseries; partitions accumulate
        
        otherwise
            error('Input 2 is not a supported partition type')
    end
    
%% For each partition...   
    avgACmat = cell(size(pmat, 1), 1);
    catACmat = zeros(size(pmat, 1), minLength);
    for i = 1:size(pmat)
        theRow = [NaN, pmat(i, :), NaN];
        startInds = find(~isnan(theRow(2:end)) & isnan(theRow(1:end-1))) + 1;
        endInds = find(~isnan(theRow(1:end-1)) & isnan(theRow(2:end)));
        avgACmat{i, :} = arrayfun(@(u, v) filterByLength(u, v, theRow), startInds, endInds, 'uniformoutput', 0);
        avgACmat{i, :} = avgACmat{i, :}(cellfun(@(r) ~isempty(r), avgACmat{i, :}));
        ACcat = CO_AutoCorr(theRow(~isnan(theRow)),[],'Fourier');
        if length(ACcat) < minLength
            catACmat(i, :) = NaN;
        else
            catACmat(i, :) = ACcat(1:minLength);
        end
    end
    
    if any(cellfun(@(d) isempty(d), avgACmat))
        if ignorelength
            warning('One or more of the partitions does not have at least %g consecutive values. Not returning average statistics.', minLength)
        else
            error('One or more of the partitions does not have at least %g consecutive values', minLength)
        end
        enough = 0;
    else
        enough = 1;
    end
        
    
%% Feature Values: Averages
    if enough
        % Mean of AC distribution
        res.maxpartmeanAC1 = statsOfCellVecs(avgACmat(end, :), 2, 'mean'); % Autocorrelation of upper partition
        res.maxpartmeanAC2 = statsOfCellVecs(avgACmat(end, :), 3, 'mean'); 
        res.maxpartmeanAC3 = statsOfCellVecs(avgACmat(end, :), 4, 'mean'); 
        res.maxpartmeanAC4 = statsOfCellVecs(avgACmat(end, :), 5, 'mean'); 

        res.minpartmeanAC1 = statsOfCellVecs(avgACmat(1, :), 2, 'mean'); % Autocorrelation of upper partition
        res.minpartmeanAC2 = statsOfCellVecs(avgACmat(1, :), 3, 'mean'); 
        res.minpartmeanAC3 = statsOfCellVecs(avgACmat(1, :), 4, 'mean'); 
        res.minpartmeanAC4 = statsOfCellVecs(avgACmat(1, :), 5, 'mean'); 

        res.diffmeanAC1 = res.maxpartmeanAC1 - res.minpartmeanAC1; % Difference between mean AC1 in upper and lower partitions
        res.diffmeanAC2 = res.maxpartmeanAC2 - res.minpartmeanAC2; 
        res.diffmeanAC3 = res.maxpartmeanAC3 - res.minpartmeanAC3;
        res.diffmeanAC4 = res.maxpartmeanAC4 - res.minpartmeanAC4;


        % SD of AC distribution
        res.maxpartSDAC1 = statsOfCellVecs(avgACmat(end, :), 2, 'SD'); % Autocorrelation of upper partition
        res.maxpartSDAC2 = statsOfCellVecs(avgACmat(end, :), 3, 'SD'); 
        res.maxpartSDAC3 = statsOfCellVecs(avgACmat(end, :), 4, 'SD'); 
        res.maxpartSDAC4 = statsOfCellVecs(avgACmat(end, :), 5, 'SD'); 

        res.minpartSDAC1 = statsOfCellVecs(avgACmat(1, :), 2, 'SD'); % Autocorrelation of upper partition
        res.minpartSDAC2 = statsOfCellVecs(avgACmat(1, :), 3, 'SD'); 
        res.minpartSDAC3 = statsOfCellVecs(avgACmat(1, :), 4, 'SD'); 
        res.minpartSDAC4 = statsOfCellVecs(avgACmat(1, :), 5, 'SD'); 

        res.diffSDAC1 = res.maxpartSDAC1 - res.minpartSDAC1; % Difference between SD of AC1 in upper and lower partitions
        res.diffSDAC2 = res.maxpartSDAC2 - res.minpartSDAC2; 
        res.diffSDAC3 = res.maxpartSDAC3 - res.minpartSDAC3;
        res.diffSDAC4 = res.maxpartSDAC4 - res.minpartSDAC4;   


        % Skewness of AC distribution
        res.maxpartskewAC1 = statsOfCellVecs(avgACmat(end, :), 2, 'skew'); % Autocorrelation of upper partition
        res.maxpartskewAC2 = statsOfCellVecs(avgACmat(end, :), 3, 'skew'); 
        res.maxpartskewAC3 = statsOfCellVecs(avgACmat(end, :), 4, 'skew'); 
        res.maxpartskewAC4 = statsOfCellVecs(avgACmat(end, :), 5, 'skew'); 

        res.minpartskewAC1 = statsOfCellVecs(avgACmat(1, :), 2, 'skew'); % Autocorrelation of upper partition
        res.minpartskewAC2 = statsOfCellVecs(avgACmat(1, :), 3, 'skew'); 
        res.minpartskewAC3 = statsOfCellVecs(avgACmat(1, :), 4, 'skew'); 
        res.minpartskewAC4 = statsOfCellVecs(avgACmat(1, :), 5, 'skew'); 

        res.diffskewAC1 = res.maxpartskewAC1 - res.minpartskewAC1; % Difference between skewness of AC1 in upper and lower partitions
        res.diffskewAC2 = res.maxpartskewAC2 - res.minpartskewAC2; 
        res.diffskewAC3 = res.maxpartskewAC3 - res.minpartskewAC3;
        res.diffskewAC4 = res.maxpartskewAC4 - res.minpartskewAC4;    


        % Kurtosis of AC distribution
        res.maxpartkurtAC1 = statsOfCellVecs(avgACmat(end, :), 2, 'kurt'); % Autocorrelation of upper partition
        res.maxpartkurtAC2 = statsOfCellVecs(avgACmat(end, :), 3, 'kurt'); 
        res.maxpartkurtAC3 = statsOfCellVecs(avgACmat(end, :), 4, 'kurt'); 
        res.maxpartkurtAC4 = statsOfCellVecs(avgACmat(end, :), 5, 'kurt'); 

        res.minpartkurtAC1 = statsOfCellVecs(avgACmat(1, :), 2, 'kurt'); % Autocorrelation of upper partition
        res.minpartkurtAC2 = statsOfCellVecs(avgACmat(1, :), 3, 'kurt'); 
        res.minpartkurtAC3 = statsOfCellVecs(avgACmat(1, :), 4, 'kurt'); 
        res.minpartkurtAC4 = statsOfCellVecs(avgACmat(1, :), 5, 'kurt'); 

        res.diffkurtAC1 = res.maxpartkurtAC1 - res.minpartkurtAC1; % Difference between kurtosis of AC1 in upper and lower partitions
        res.diffkurtAC2 = res.maxpartkurtAC2 - res.minpartkurtAC2; 
        res.diffkurtAC3 = res.maxpartkurtAC3 - res.minpartkurtAC3;
        res.diffkurtAC4 = res.maxpartkurtAC4 - res.minpartkurtAC4;
    end
    
    
    
%% Feature Values: Concatenated
    res.maxpartcatAC1 = catACmat(end, 2);
    res.maxpartcatAC2 = catACmat(end, 3);
    res.maxpartcatAC3 = catACmat(end, 4);
    res.maxpartcatAC4 = catACmat(end, 5);
    
    res.minpartcatAC1 = catACmat(1, 2);
    res.minpartcatAC2 = catACmat(1, 3);
    res.minpartcatAC3 = catACmat(1, 4);
    res.minpartcatAC4 = catACmat(1, 5);
    
    res.diffcatAC1 = res.maxpartcatAC1 - res.minpartcatAC1; % Difference between AC1 in concatenated upper and lower partitions
    res.diffcatAC2 = res.maxpartcatAC2 - res.minpartcatAC2;
    res.diffcatAC3 = res.maxpartcatAC3 - res.minpartcatAC3;
    res.diffcatAC4 = res.maxpartcatAC4 - res.minpartcatAC4;
    
%% Some useful(?) outputs that are not scalar
    extrares.pmat = pmat;
    extrares.avgACmat = avgACmat;
    extrares.catACmat = catACmat;
    extrares.partitionboundaries = [min(x); max(pmat, [], 2)];
    
    
    
%% Plot a few things
    if makePlot
        % Time series with partition boundaries
        figure
        %plot(repmat(1:size(pmat, 2), size(pmat, 1), 1)', pmat', '-')
        plot(x)
        hold on
        plot([0, length(x)], [extrares.partitionboundaries, extrares.partitionboundaries], '--r')
        set(gcf,'color','w');
        xlabel('t')
        ylabel('r')
        
        % Distribution of autocorrelation lag 1 across windows in the upper
        % and lower partitions
        figure
        u = avgACmat(1, :);
        v = avgACmat(end, :);
        histogram(cellfun(@(c) c(2), u{1}), 50);
        hold on
        histogram(cellfun(@(c) c(2), v{1}), 50);
        xlabel('Autocorrelation: Lag 1')
        ylabel('Frequency')
        set(gcf,'color','w');
        
        % Autocorrelation 1 of each partition, values concatenated
        figure
        centrevec = arrayfun(@(o) mean(extrares.partitionboundaries([o, o+1])), 1:length(extrares.catACmat(:, 2)));
        plot(centrevec, extrares.catACmat(:, 2), '-ko', 'markerfacecolor', 'k', 'markersize', 2)
        set(gcf, 'color', 'w')
    end

%% Smaller functions
    function AC = filterByLength(u, v, theRow)
        if length(theRow(u:v)) >= minLength
            AC = CO_AutoCorr(theRow(u:v),[],'Fourier');
            AC = AC(1:minLength);
        else
            AC = [];
        end
    end

    function thestat = statsOfCellVecs(slra, pos, whatstat)
        val = cellfun(@(c) c(pos), slra{1});
        switch whatstat
            case 'mean'
                thestat = nanmean(val);
             
            case 'SD'
                thestat = std(val, 'omitnan');
             
            case 'skew'
                thestat = skewness(val);
             
            case 'kurt'
                thestat = kurtosis(val);
            % Space to add more; must ignore NaNs
        end
    end
end
