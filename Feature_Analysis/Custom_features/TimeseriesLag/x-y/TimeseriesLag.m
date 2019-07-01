function [fval, corrvec, diststd, samplepoints, ppoints] = TimeseriesLag(x, num)
    if nargin < 2 || isempty(num)
        num = 25;
    end
    if size(x, 1) > 1
        x = x';
    end
%   x | x_t+1 | Position
    res = [x(1:end-1); x(2:end); mean([x(1:end-1);  x(2:end)], 1)];
    [~, idxs] = sort(res(3, :));
    res = res(:, idxs);
    %wdth = num*(res(3, end) - res(3, 1));
    wdth = 100./num;
    %samplepoints = wdth:wdth:res(3, end)-wdth;
    ppoints = 0:wdth:100;
    samplepoints = prctile(res(2, :), ppoints);
    corrvec = zeros(1, length(samplepoints)-1);
    diststd = corrvec;

    %nrm = 1;%std(sign(res(1, :) - res(3, :)).*sqrt((res(1, :) - res(3, :)).^2 + (res(2, :) - res(3, :)).^2));
    %ress = res(:, filteridxs);
    %histogram2(sign(ress(1, :) - ress(3, :)).*sqrt((ress(1, :) - ress(3, :)).^2 + (ress(2, :) - ress(3, :)).^2), ress(3, :), 100)
    %histogram(ress(3, :), 100)
    for i = 1:length(corrvec)
        locdown = samplepoints(i);
        locup = samplepoints(i+1);
        
        
        
        residxs = (res(2, :) > locdown) & (res(2, :) < locup);
        %residxs = (loc-wdth <= res(3, :)) & (res(3, :) <= loc + wdth);
        %ressidxs = (loc-wdth <= ress(3, :)) & (ress(3, :) <= loc + wdth);
%         diststd(i) = max(histcounts(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs)...
%              - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2) ...
%              , 'normalization', 'count', 'binmethod', 'sqrt'));


        nrm = ppoints(i+1) - ppoints(i);
        diststd(i) = NormalWidth(res([1, 2], residxs), [], nrm);
%         nrm = 1;
%         
%         prc_x = tiedrank(res([1], residxs))./length(res([1], residxs));
%         prc_y = tiedrank(res([2], residxs))./length(res([2], residxs));
%         diststd(i) = NormalWidth([prc_x; prc_y], [], nrm);
        
        
%std(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs)...
 %            - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2));
        try
            corrvec(i) = corr(res(1, residxs)', res(2, residxs)');
        catch
            warning('No points found in the %sth window; NaN', i)
            corrvec(i) = NaN;
        end
        
        %if 1
            %figure
            %hist(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2), 25)
            %std(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2))
            %plot(sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2))
        %end
%         if i == 50
%             hist(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2), 25)
%             std(sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2))
%             figure
%         end
%         if i == 75
%             hist(sign(res(2, residxs) - res(1, residxs)).*sqrt((res(1, residxs) - res(3, residxs)).^2 + (res(2, residxs) - res(3, residxs)).^2), 25)
%         end       
        
    end
    samplepoints = mean([samplepoints(1:end-1); samplepoints(2:end)], 1); % Make samplepoints the center of each percentile window 
    ppoints = mean([ppoints(1:end-1); ppoints(2:end)], 1); % Make ppoints the center of each percentile window 
    resx = [ones(length(ppoints), 1), ppoints'];
    resy = diststd';
    B = resx\resy;
    fval.grad = B(2);
    fval.int = B(1);
end

