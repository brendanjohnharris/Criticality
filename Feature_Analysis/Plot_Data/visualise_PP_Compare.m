function visualise_PP_Compare(cp_vals, noise_vals, l, how_long, system, standardise, tmax)
    % Please provide EITHER multiple cp_vals or noise_vals, not both (i.e
    % one must not be a vector)
    if nargin < 5 || isempty(system)
        system = 'supercritical_hopf_radius_(strogatz)';
    end
    if nargin < 6 || isempty(standardise)
        standardise = 1;
    end
    if nargin < 7 || isempty(tmax)
        tmax = 100;
    end
    time_series = time_series_generator('cp_range', cp_vals, 'etarange', noise_vals, 'system_type', system, 'savelength', how_long, 'tmax', tmax); 
    if length(cp_vals) == 1
        numplots = length(noise_vals);
    else
        numplots = length(cp_vals);
    end
    %% Take relevant parts from PP_Compare (using ravX_kscn_olapint only)
    % Take running average of input time series; l is the window size:
    time_series_d = filter(ones(1,l)/l,1,time_series, [], 2);
    % Standardise both time series
    if standardise
        ztime_series = zscore(time_series, [], 2);
        ztime_series_d = zscore(time_series_d, [], 2);
    end
    ylim1 = Inf;
    ylim2 = -Inf;
    figure
    set(gcf,'color','w');
    set(gcf,'units','normalized','outerpos',[0 0 1 1]);
    feature_val_vec = zeros(1, numplots);
    for t = 1:numplots
        subplot(numplots, 1, t)
        hold on
        ylim1 = min(ylim1, min([ztime_series(t, :), ztime_series_d(t, :)]));
        ylim2 = max(ylim2, max([ztime_series(t, :), ztime_series_d(t, :)]));
        plot(ztime_series(t, :), '-')
        plot(ztime_series_d(t, :), '-')
        legend({'Time Series', 'Moving Average'})
        ylabel('r', 'fontsize', 14, 'interpreter', 'tex')
        res = PP_Compare(time_series(t, :)', ['rav', num2str(l)]); % Why transposed?????
        feature_val_vec(t) = res.kscn_olapint;
        if length(cp_vals) == 1
            title(['Noise: ', num2str(noise_vals(t)), ' | ', 'Feature Value: ', num2str(round(feature_val_vec(t), 4))], 'Fontsize', 12)
        else
            title(['Control Parameter: ', num2str(cp_vals(t)), ' | ', 'Feature Value: ', num2str(round(feature_val_vec(t), 4))], 'Fontsize', 12)
        end
    end
    for t = 1:numplots
        subplot(numplots, 1, t)
        ylim([ylim1, ylim2])
    end
    ttl = suptitle(['PP Compare: rav', num2str(l), ' kscn olapint']);
    ttl.Position = [0.52, -0.05, 0];
    xlabel('t', 'fontsize', 14, 'interpreter', 'tex')
    
    
    %% Generate the histograms
    figure
    set(gcf,'color','w');
    set(gcf,'units','normalized','outerpos',[0 0 1 1]);
    xmax = -Inf;
    ymax = -Inf;
    for t = 1:numplots
        subplot(numplots, 2, 2.*t - 1)
        plot_PDF(ztime_series(t, :))
        a = gca;
        xmax = max(xmax, a.XLim(2));
        ymax = max(ymax, a.YLim(2));
        ylabel('Probability Density')
        subplot(numplots, 2, 2.*t)
        plot_PDF(ztime_series_d(t, :))
        a = gca;
        xmax = max(xmax, a.XLim(2));
        ymax = max(ymax, a.YLim(2));
        ylabel('Probability Density')
    end
    for t = 1:numplots
        subplot(numplots, 2, 2.*t - 1)
        
        if length(cp_vals) == 1
            anothertitle = (['Noise: ', num2str(noise_vals(t)), ' | ', 'Feature Value: ', num2str(round(feature_val_vec(t), 4))]);
        else
            anothertitle = (['Control Parameter: ', num2str(cp_vals(t)), ' | ', 'Feature Value: ', num2str(round(feature_val_vec(t), 4))]);
        end
        ax1 = gca;
        lft = ax1.OuterPosition(1);
        wdth = ax1.OuterPosition(3);
        dwdth = 1 + (ax1.OuterPosition(3) - ax1.Position(3))./ax1.Position(3);
        %wdth = ax1.OuterPosition(3);
        text((dwdth + (0.5 - lft - wdth)./wdth + 1 + (0.5 - lft - wdth)./wdth)./2, 1.15, anothertitle, 'Units', 'Normalized', 'HorizontalAlignment', 'center', 'Fontsize', 14)
        
        ylim([0, ymax])
        xlim([-xmax, xmax])
        subplot(numplots, 2, 2.*t)
        ylim([0, ymax])
        xlim([-xmax, xmax])
    end
    subplot(numplots, 2, 2.*numplots - 1)
    xlabel('Standardised Time Series Value')
    subplot(numplots, 2, 2.*numplots)
    xlabel('Standardised Time Series Value')
    
    subplot(numplots, 2, 1)
    text(0.5, 1.2, 'Time Series Distributions', 'Units', 'Normalized', 'HorizontalAlignment', 'center', 'Fontsize', 16, 'Fontweight', 'Bold')
    subplot(numplots, 2, 2)
    text(0.5, 1.2, 'Moving Average Distributions', 'Units', 'Normalized', 'HorizontalAlignment', 'center', 'Fontsize', 16, 'Fontweight', 'Bold')
end

function [f, ffit, xi, OI] = reduced_DN_CompareKSFit(x)
        % Bits copied from DN_CompareKSFit
        xStep = std(x)/100;
        [a, b] = normfit(x);
        peaky = normpdf(a,a,b);
        thresh = peaky/100;
        xf(1) = mean(x);
        ange = 10;
        while ange > thresh, xf(1) = xf(1)-xStep; ange = normpdf(xf(1),a,b); end
        xf(2) = mean(x);
        ange = 10;
        while ange > thresh, xf(2) = xf(2)+xStep; ange = normpdf(xf(2),a,b); end

        [f, xi] = ksdensity(x);
        xi = xi(f > 1E-6);

        xi = [floor(xi(1)*10)/10, ceil(xi(end)*10)/10];
        x1 = min([xf(1), xi(1)]);
        x2 = max([xf(2), xi(end)]);
    
        xi = linspace(x1,x2,1000);
        f = ksdensity(x,xi);
        ffit = normpdf(xi,a,b);
        OI = sum(f.*ffit*(xi(2)-xi(1)))*std(x);
end

function plot_PDF(x)
        [f, ffit, xi, OI] = reduced_DN_CompareKSFit(x);
        plot(xi, f, '-')
        hold on
        plot(xi, ffit, '-')
        a = gca;
        a.YLim(2) = 1.1.*a.YLim(2);
        legend({'Kernel-smoothed Distribution', 'Normal Fit Distribution'})
        title(['Overlap Integral: ', num2str(OI)])
end

