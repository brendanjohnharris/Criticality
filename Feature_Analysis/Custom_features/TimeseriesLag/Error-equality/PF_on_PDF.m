function PF_on_PDF(x, mu)
    num = 1000;
    if size(x, 1) > 1
        x = x';
    end
    thevals = [x(1:end-1); x(2:end)];
    res = [mean([x(1:end-1);  x(2:end)], 1); x(2:end) - x(1:end-1)];
    [~, idxs] = sort(res(1, :));
    res = res(:, idxs);
    wdth = 100./num;
    ppoints = 0:wdth:100;
    samplepoints = prctile(res(1, :), ppoints);
    diststd = zeros(1, length(samplepoints)-1);
    samplepoints = mean([samplepoints(1:end-1); samplepoints(2:end)], 1); % Make samplepoints the center of each percentile window 
    ppoints = mean([ppoints(1:end-1); ppoints(2:end)], 1); % Make ppoints the center of each percentile window 
    dist = fitdist(x', 'Kernel', 'Kernel', 'Normal');
    f = pdf(dist, samplepoints)';
    F = cdf(dist, samplepoints)';
    y = std(res(2, :)).*(f);
    [r, m, b] = regression(F', y');
    
    PF = -mu.*samplepoints.^2./2 + samplepoints.^4./4;
    plot(ppoints, f), hold on, plot(ppoints, PF)
end

