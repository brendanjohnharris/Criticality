function out = twoBin(x, mu, color, p)
    if nargin < 2
        mu = [];
    end
    if nargin < 3 || isempty(color)
        color = [ 0 0 0 ];
    end
    if nargin < 4 || isempty(p)
        p = 1;
    end
    
    %x = x./std((x(2:end) - x(1:end-1)));%zscore(x);
    
    
    res = [x(1:end - 1); x(2:end)];%[mean([x(1:end-1);  x(2:end)], 1); x(2:end) - x(1:end-1)];
    [~, idxs] = sort(res(1, :));
    res = res(:, idxs);
    loweridxs = res(1, :) <= median(res(1, :));
    upperidxs = res(1, :) > median(res(1, :));
    loweres = res(:, loweridxs);
    upperes = res(:, upperidxs);
    
    res_eq = [mean([x(1:end-1);  x(2:end)], 1); x(2:end) - x(1:end-1)];
    [~, idxs_eq] = sort(res_eq(1, :));
    res_eq = res_eq(:, idxs_eq);
    loweridxs_eq = res_eq(1, :) <= median(res_eq(1, :));
    upperidxs_eq = res_eq(1, :) > median(res_eq(1, :));
    loweres_eq = res_eq(:, loweridxs_eq);
    upperes_eq = res_eq(:, upperidxs_eq);
% ----Plot the two halves--------------------------------------------------
%     figure, hold on
%     plot(loweres(1, :), loweres(2, :), 'ko', 'markersize', 1)
%     plot(upperes(1, :), upperes(2, :), 'ro', 'markersize', 1)
% -------------------------------------------------------------------------
    %fprintf('The difference in SD_y is %g percent (%g) of the total SD_y\n', 100.*(std(upperes(2, :)) - std(loweres(2, :)))./std(res(1, :)), (std(upperes(2, :)) - std(loweres(2, :))))
    out.diffSDx = std(upperes(1, :)) - std(loweres(1, :));
    %out.SDy = std(upperes(2, :)) - std(loweres(2, :));
    %out.SDydiffSDx = out.SDy./out.diffSDx;
    
    %----------------------------------------------------------------------
    out.diffcorr = corr(upperes(1, :)', upperes(2, :)') - corr(loweres(1, :)', loweres(2, :)');
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    out.uppercorr = corr(upperes(1, :)', upperes(2, :)');
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    out.lowercorr = corr(loweres(1, :)', loweres(2, :)');
    %----------------------------------------------------------------------
    out.medloc = std(res_eq(2, :))./x(find(x == median(res(1, :)), 1));
    
    upper_SD_dt = std(upperes_eq(2, :));
    upper_SD_r_eq = std(upperes_eq(1, :));
    lower_SD_dt = std(loweres_eq(2, :));
    out.sigma = std(res_eq(2, :));
    
    %----------------------------------------------------------------------
    out.corr_RMSE = sqrt(1 - (out.sigma./std(upperes(2, :))).^2) - sqrt(1 - (out.sigma./std(loweres(2, :))).^2);
    %----------------------------------------------------------------------
    
    out.checkequality = upper_SD_dt./std(upperes_eq(1, :)) - lower_SD_dt./std(loweres_eq(1, :));%(std(upperes(2, :)) - std(upperes_eq(1, :)))./std(x);%sqrt(1 - (upper_SD_dt./std(upperes_eq(1, :))).^2) - corr(upperes(1, :)', upperes(2, :)');
    
    out.diff_SD_r_eq = (1./std(upperes_eq(1, :)) - 1./std(loweres_eq(1, :)));
    
    %----------------------------------------------------------------------    
    out.corr_equiv = std(res_eq(2, :)).*(1./std(upperes_eq(1, :)) - 1./std(loweres_eq(1, :)));
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------    
    out.corr_equiv_nosigma = (1./std(upperes_eq(1, :)) - 1./std(loweres_eq(1, :)));
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------    
    out.corr_equiv_upper =  std(res_eq(2, :))./std(upperes_eq(1, :));
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------    
    out.corr_equiv_lower =  std(res_eq(2, :))./std(loweres_eq(1, :));
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------    
    out.corr_equiv_all =  std(res_eq(2, :))./std(res_eq(1, :));
    %----------------------------------------------------------------------
    
    out.corr_equiv_density = std(res_eq(2, :)).*(1./(max(upperes_eq(1, :)) - min(upperes_eq(1, :))) - 1./(max(loweres_eq(1, :)) - min(loweres_eq(1, :))));
    
    
    uv = max(upperes_eq(1, :)) - min(upperes_eq(1, :));
    lv = max(loweres_eq(1, :)) - min(loweres_eq(1, :));
    logdiffequiv = std(res_eq(2, :)).*(log(std(upperes_eq(1, :))) - log(std(loweres_eq(1, :))));%std(res_eq(2, :)).*(log(uv) - log(lv));
    out.loggrad = logdiffequiv./(mean(upperes_eq(1, :)) - mean(loweres_eq(1, :)));%%%%% Optimal 2 bin so far
    
    out.densitygrad = std(res_eq(2, :)).*(-log(25000./uv) - -log(25000./lv))./(mean(upperes_eq(1, :)) - mean(loweres_eq(1, :)));
    
    %----------------------------------------------------------------------  
    fx = @(x, y) var(((x) + (y))./sqrt(2));
    fy = @(x, y) var(((y) - (x))./sqrt(2));
    out.modCorr = fx(upperes(1, :), upperes(2, :)) - fx(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------  
    c = @(x, y) (fx(x, y) - fy(x, y))./(fx(x, y) + fy(x, y));
    out.modCorr2 = c(upperes(1, :), upperes(2, :)) - c(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------
    c = @(x, y) (fx(x, y));%-fy(x, y));%(fx(x, y));%-fy(x, y));
    out.modCorr3 = c(upperes(1, :), upperes(2, :)) - c(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------
    c = @(x, y) (fx(x, y) + fy(x, y));
    out.modCorr4 = c(upperes(1, :), upperes(2, :)) - c(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------  
    out.covdiff = propcov(upperes(1, :)', upperes(2, :)') - propcov(loweres(1, :)', loweres(2, :)');
    %----------------------------------------------------------------------   
    %----------------------------------------------------------------------    
    
    out.covEigs =  covEigs(upperes(1, :)', upperes(2, :)') - covEigs(loweres(1, :)', loweres(2, :)');
    %----------------------------------------------------------------------
    
    %----------------------------------------------------------------------
    c = @(x, y) (fy(x, y));%-fy(x, y));%(fx(x, y));%-fy(x, y));
    out.modCorr6 = c(upperes(1, :), upperes(2, :)) - c(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    c = @(x, y) fy(x, y)./fx(x, y);%-fy(x, y));%(fx(x, y));%-fy(x, y));
    out.modCorr7 = c(upperes(1, :), upperes(2, :)) - c(loweres(1, :), loweres(2, :));
    %----------------------------------------------------------------------
    
    out.med = median(x);
    
    out.dkurt = kurtosis([-x, x]);
    
% ----Plot the difference over the potential function----------------------
    if ~isempty(mu)
        hold on
        samplepoints = linspace(0, max(x));
        P = @(r, mu)   -mu.*r + r.^3; %%-mu + 3.*r.^2;%-mu.*r.^2./2 + r.^4./4;
        plot(samplepoints, P(samplepoints, mu), 'Color', color)
        %u = std(res_eq(2, :)).*(log(std(upperes_eq(1, :))));
        %l = std(res_eq(2, :)).*(log(std(loweres_eq(1, :))));
        u = corr(upperes(1, :)', upperes(2, :)');%log(std(upperes_eq(1, :)));%
        l = corr(loweres(1, :)', loweres(2, :)');%log(std(loweres_eq(1, :)));%
        ofst = l - P([mean(upperes_eq(1, :)), mean(loweres_eq(1, :))], mu);
        scatter([mean(upperes_eq(1, :)), mean(loweres_eq(1, :))], [u, l]-ofst, 50, color, 'filled');%, 'markersize', 4, 'markerfacecolor', color, 'color', color)
    end
% -------------------------------------------------------------------------  
% ------------------------------------------------------------------------- 
    thresh = mean(res(1, :))+p*std(res_eq(2, :));
    out.upperpropsigma = sum(res(1, :) >=thresh)./(sum(res(1, :) <= thresh)+sum(res(1, :) >= thresh));
    
    thresh = mean(res(1, :))+p*std(x);
    out.upperprop = sum(res(1, :) >=thresh)./(sum(res(1, :) <= thresh)+sum(res(1, :) >= thresh));
    
    thresh = p*std(res_eq(2, :));
    out.upperpropnomeansigma = sum(res(1, :) >=thresh)./(sum(res(1, :) <= thresh)+sum(res(1, :) >= thresh));
% ------------------------------------------------------------------------- 
% ------------------------------------------------------------------------- 
    out.meanscaled = mean(res(1, :))+std(res_eq(2, :));
    
    function res = propcov(x, y)
        res = cov(x, y);
        res = res(2);
    end
    function res = covEigs(x, y)
        res = cov(x, y);
        res = eig(res);
        res = res(end);
    end
end

