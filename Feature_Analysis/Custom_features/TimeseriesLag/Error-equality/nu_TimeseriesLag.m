function [fval, corrvec, diststd, samplepoints, ppoints] = nu_TimeseriesLag(x, num, mu, plotcol, dt)
    if nargin < 2 || isempty(num)
        num = 1000;% 25 normally
    end
    if nargin < 3 || isempty(mu)
        mu = [];
    end
    if nargin < 4
        plotcol = [];
    end
    if nargin < 5
        dtmarker = 0;
        dt = 0.01;
    end
    if size(x, 1) > 1
        x = x';
    end
    thevals = [x(1:end-1); x(2:end)];
    res = [mean([x(1:end-1);  x(2:end)], 1); x(2:end) - x(1:end-1)];
    [~, idxs] = sort(res(1, :));
    res = res(:, idxs);
    wdth = 1./num;
    ppoints = 0:wdth:1;
    samplepoints = prctile(res(1, :), 100.*ppoints);
    samplepoints = mean([samplepoints(1:end-1); samplepoints(2:end)], 1); % Make samplepoints the center of each percentile window 
    ppoints = mean([ppoints(1:end-1); ppoints(2:end)], 1); % Make ppoints the center of each percentile window 
    dist = fitdist(x', 'Kernel', 'Kernel', 'Normal');
    f = pdf(dist, samplepoints)';
% % %     F = cdf(dist, samplepoints)';
% % %     polyf_wrtF = polyfit(F, f, 10);
%     polyf_wrtx = polyfit(samplepoints, f', 10);
% % %     dfdF = polyder(polyf_wrtF);
%     dfdx = polyder(polyf_wrtx);
% % %     meanfdfdx = median(polyval(dfdF, ppoints));
    y = (f);
% % %     m = meanfdfdx;
    b = NaN;
     if ~isempty(mu)
         P = @(r, mu) -mu.*r.^2./2 + r.^4./4;
     end
     if ~isempty(plotcol)
        plot(P(samplepoints, mu), log(f)', 'color', plotcol)%std(res(2, :)).*log(f)
     end

% % %     fval.grad = std(res(2, :)).*m;
% % %     fval.int = b;
% % %     fval.SDy = std(res(2, :));
% % %     fval.meanx = mean(res(1, :));
% % %     fval.widthratio = fval.SDy./fval.meanx;
% % %     if ~isempty(mu)
% % %         [rV, mV, bV] = regression(P(samplepoints, mu), log(f)');
% % %         fval.dlnfdV = sqrt(-1./mV);
% % %     end
    
% % %     V = @(f, dt) -(std(res(2, :))./sqrt(dt)).^2.*log(f)./2;
% % %     ft = fittype('-a*x^2/2 + x^4/4 + b', 'independent', {'x'}, 'coefficients', {'a', 'b'});
% % %     thefit = fit(samplepoints', V(f, dt), ft);
% % %     fval.Vfit = thefit.a; %By far the best. 0.98!
    V = @(f) -std(res(2, :)).^2.*log(f);
    ft = fittype('-a*x^2 + b*x^4 + c', 'independent', {'x'}, 'coefficients', {'a', 'b', 'c'});
    thefit = fit(samplepoints', V(f), ft);
    [~, mu_conc] = differentiate(thefit, 0);
    fval.mu_conc = mu_conc;
  
    V = @(f) -std(res(2, :)).^2.*log(f);
    ft = fittype('-a*x^2 + b', 'independent', {'x'}, 'coefficients', {'a', 'b'});
    thefit = fit(samplepoints', V(f), ft);
    [~, mu_conc] = differentiate(thefit, samplepoints);
    fval.quadratic_mu_conc = mean(mu_conc);
    
    
    fval.pdf_kurt = kurtosis(f);
    fval.vals_kurt = kurtosis(x);
    
    fval.reflectedSD = iqr([x, -x]./std(x(2:end) - x(1:end-1)));
    
    
    
    
    if ~isempty(mu) && dtmarker
        figure, hold on
        plot(samplepoints, P(samplepoints, mu))
        offset = mean(P(samplepoints, mu)' -  V(f, dt));
        plot(samplepoints, V(f, dt) + offset)
        xlabel('$$r$$', 'fontsize', 18, 'interpreter', 'Latex')
        ylabel('$$V(r)$$', 'fontsize', 18, 'interpreter', 'Latex')
        legend({'Actual', 'Estimated'}, 'Location', 'Northwest')
        set(gcf,'color','w'); 
        plot(samplepoints, thefit(samplepoints) - f(0))
        f
    end
end

