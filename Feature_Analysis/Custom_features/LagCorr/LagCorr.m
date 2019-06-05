function [res, extrares] = LagCorr(x)
    if iscolumn(x)
        x = [x(1:end-1), x(2:end)];
    elseif isrow(x)
        x = [x(1:end-1); x(2:end)]';
    else
        error('The time series must be a vector')
    end
    xmean = mean(x, 2);
    [xmean, idxs] = sort(xmean, 'ascend');
    x = x(idxs, :);
    
    
    
    % Values
    %subx = x(xmean > prctile(xmean, 70), :); % Greater than median
    %subx = x(xmean > mean(xmean), :); % Greater than mean
    %subx = x(xmean > prctile(xmean, 25), :); % Not in first quartile
    %subx = x(xmean > prctile(xmean, 60) & xmean < prctile(xmean, 80), :);
    %subx = x(x(:, 1) > prctile(x(:, 1), 70) & x(:, 1) < prctile(x(:, 1), 80), :); 
    
    %subx = x(x(:, 1) < 0.5 & x(:, 1) > 0.4 & x(:, 2) < 0.5 & x(:, 2) > 0.4, :); 
    nrm =  std(sign(x(:, 1) - xmean).*sqrt((x(:, 1) - xmean).^2 + (x(:, 2) - xmean).^2));
    %xmark = prctile(xmean, 60); %min(xmean) + 0.25.*(max(xmean) - min(xmean));
    subx = x(x(:, 2) > prctile(x(:, 2), 60), :);%x(xmean(:, 1) > prctile(xmean, 60), :); %x(xmean > xmark, :); %
    
%     figure
%     plot(subx(:, 1), subx(:, 2), 'ko', 'markersize', 1)
    
    res.uppercorr =  NormalWidth(subx(:, 1), subx(:, 2), nrm); % corr(subx(:, 1), subx(:, 2), 'type', 'Pearson');
    
    
    %subx = x(xmean < prctile(xmean, 30), :); % Less than median
    %subx = x(xmean <= mean(xmean), :); % Less than mean
    %subx = x(xmean <= prctile(xmean, 25), :); % In first quartile
    %subx = x(xmean <= prctile(xmean, 50), :);
    %subx = x(x(:, 1) <= prctile(x(:, 1), 10), :);
    
    %subx = x(x(:, 1) < 0.1 & x(:, 1) > 0 & x(:, 2) < 0.1 & x(:, 2) > 0, :); 
    subx =  x(x(:, 2) < prctile(x(:, 2), 40), :);% x(xmean < xmark, :); %

    
%     figure
%     plot(subx(:, 1), subx(:, 2), 'ko', 'markersize', 1)
    
    res.lowercorr =   NormalWidth(subx(:, 1), subx(:, 2), nrm); %corr(subx(:, 1), subx(:, 2), 'type', 'Pearson');
    
    
    
    res.diffcorr = res.uppercorr - res.lowercorr;

end

