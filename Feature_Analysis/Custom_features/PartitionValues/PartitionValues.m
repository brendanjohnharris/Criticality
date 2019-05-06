function [res, pmat, extrares] = PartitionValues(x, partitionType, partitionNum, makePlot)
%PARTITIONVALUES Partition the time series by value (not index/time) and
%compute some statistics.
%   
%   INPUTS--
%       x:              A single time series
%
%       partitionType:  Either 'buffer' (partition using time series length) or 
%                       'values' (partition by time series value extremes)
%
%       partitionNum:   A 0 < number < length(x), giving the number of partitions
%
%       makePlot:       0 or 1, plot the partitioned timeseries
    
    if nargin < 4 || isempty(makePlot)
        makePlot = 0;
    end

    minLength = 5;

    if size(x, 1) > 1
        if size(x, 2) > 1
            error('The first input, x, must be a vector')
        end
        x = x';
    end
    
%% Partition the timeseries  
    pmat = repmat(x, partitionNum, 1);
    maxidxs = pmat == max(x);
   
    switch partitionType
        case 'buffer'
            [~, idxs] = sort(x, 'ascend');
            idxs = buffer(idxs, floor(length(x)./partitionNum))';
            if ~idxs(end, end)
                idxs = idxs(1:end-1, :); % Remove top portion of values. Fine if number of windows is large?
            end
            for i = 1:size(idxs, 1)
                pmat(i, setdiff(1:size(pmat, 2), idxs(i, :))) = NaN;
            end
                 
        case 'values'
            df = (max(x) - min(x))/partitionNum;
            windowlims = min(x):df:max(x);
            for i = 1:partitionNum
                pmat(i, pmat(i, :) < windowlims(i) | pmat(i, :) >= windowlims(i+1)) = NaN;
            end
            pmat(maxidxs) = max(x); % Add back in the maximum values
        
        otherwise
            error('Input 2 is not a supported partition type')
    end
    
    if makePlot
        plot(repmat(1:size(pmat, 2), size(pmat, 1), 1)', pmat', '-')
    end
    
%% Calculate something for each partition    
    avgACmat = cell(size(pmat, 1), 1);
    catACmat = zeros(size(pmat, 1), minLength);
    for i = 1:size(pmat)
        theRow = [NaN, pmat(i, :), NaN];
        startInds = find(~isnan(theRow(2:end)) & isnan(theRow(1:end-1))) + 1;
        endInds = find(~isnan(theRow(1:end-1)) & isnan(theRow(2:end)));
        avgACmat{i, :} = arrayfun(@(u, v) filterByLength(u, v, theRow), startInds, endInds, 'uniformoutput', 0);
        avgACmat{i, :} = avgACmat{i, :}(cellfun(@(r) ~isempty(r), avgACmat{i, :}));
        ACcat = CO_AutoCorr(theRow(~isnan(theRow)),[],'Fourier');
        catACmat(i, :) = ACcat(1:minLength);
    end
    
    if any(cellfun(@(d) isempty(d), avgACmat))
        error('One or more of the partitions does not have at least %g consecutive values', minLength)
    end
        
%% Feature Values: Averages
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
    
%% Some useful(?) outputs, that won't fit into hctsa
    extrares.avgACmat = avgACmat;
    extrares.catACmat = catACmat;

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
                thestat = mean(val);
             
            case 'SD'
                thestat = std(val);
             
            case 'skew'
                thestat = skewness(val);
             
            case 'kurt'
                thestat = kurtosis(val);
            % Space to add more
        end
    end
end
