function fval = testSemianalyticTwoBin(param)
% Predict the upperprop feature values from only the control parameter and
% eta, for the supercritical hopf bifurcation from Strogatz (radius only)

   
    etavals = [0.005:0.005:1];
    cpvals = [-1:0.005:-0.005];
    dt = 0.01;
    
    fvals = nan(length(cpvals), length(etavals));
    
    for i = 1:length(etavals)
        for u = 1:length(cpvals)
            
            
            
            mu = cpvals(u);
            eta = etavals(i);
            
            p = @(x) exp(-2.*(-mu.*x.^2 + x.^4./2)/eta.^2);
            normfact = integral(p, 0, inf);
            pn = @(x) p(x)./normfact;   
            meanpn = integral(@(x) x.*pn(x), 0, inf);
            threshold = meanpn + param.*(eta*sqrt(dt));
    
            fval = integral(pn, threshold, inf);
            
            fvals(u, i) = fval;
        end 
        fprintf('%i of %i \n', i, length(cpvals))
    end
    
    % Plot the predicted values
    cmap = inferno(length(etavals));
    figure, hold on
    corrvecx = [];
    corrvecy = [];
    for i = 1:length(etavals)
        plot(cpvals, fvals(:, i), '.', 'color', cmap(i, :), 'markersize', 14)
        corrvecx(end+1:end+length(cpvals)) = cpvals;
        corrvecy(end+1:end+length(cpvals)) = fvals(:, i);
    end
    title(['\rho_p: ', num2str(corr(corrvecx', corrvecy'))], 'interpreter', 'TeX')
    colormap(cmap)
    c = colorbar;
    if length(etavals) > 1
        caxis([min(etavals), max(etavals)])
    end
    c.Label.String = '\eta';
    c.Label.Rotation = 0;
    c.Label.FontSize = 18;
    xlabel('$$\mu$$', 'interpreter', 'latex', 'fontsize', 18)
    ylabel('$$f$$', 'interpreter', 'latex', 'fontsize', 18)
    set(gcf, 'Color', 'w')
end

