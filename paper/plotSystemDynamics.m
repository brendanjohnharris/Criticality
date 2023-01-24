function plotSystemDynamics(t, time_series_data, mu, eta, xlims, ylims, opts)
%PLOTSYSTEMDYNAMICS
    arguments
        t
        time_series_data
        mu
        eta
        xlims (2,1) double {mustBeFinite} = [0, 2];
        ylims (2, 1) double {mustBeFinite} = [0, 2];
        opts.axison (1, 1) = true;
    end
    axison = opts.axison;
    blue = [0,    0.4470,    0.7410];
    red = [0.8500,    0.3250,    0.0980];
    gray = [0.2, 0.2, 0.2];
    colororder([gray; blue; red])
    data = time_series_data(1, :);

    % Now get on to plotting everything. 
    % First the potential
%     title(sprintf('$$\\mu = %.2g, \\eta = %.2g$$', mu, eta), 'Interpreter', 'latex')


   
    inputs = data.Inputs;
    inputs.etarange = [eta];
    inputs.foldername = [];
    inputs.cp_range = [mu];
    inputs.numpoints = [];
    inputs.savelength = [];
    inputs.T = 1000;
    inputs.tmax = 2010;
    inputs.sampling_period = 0.1;
    x = time_series_generator('input_struct', inputs);
    xt = x(2:end);
    xt1 = x(1:end-1);
    ts = 0:inputs.sampling_period:inputs.sampling_period*(length(x)-1);

    plot([0, xlims(2)], [0, xlims(2)], '--', 'color', gray)
    hold on
    ax1 = gca;
%     plot([0, xlims(2)], [0, -xlims(2)], '--', 'color', gray)
    ax1.Box = 'on';

    x_ = xt;
    y_ = xt1;
    T = [cos(-pi/4), -sin(-pi/4); cos(-pi/4), sin(-pi/4)];
    T(1, 1) = T(1, 1)/std(xt - xt1);
    T = [cos(pi/4), -sin(pi/4); cos(pi/4), sin(pi/4)]*T;
    xy = T*[x_; y_];
    x_ = xy(1, :);
    y_ = xy(2, :);
    s = scatter(x_, y_, 2, blue, 'filled', 'MarkerFaceAlpha', 0.05);
    p1 = covEllipse([mean(x_), mean(y_)], cov([x_' y_']).*2, ...
        blue, 'FaceAlpha', 0.1, 'EdgeColor', blue);
    x_ = xt;
    y_ = xt1;
    s = scatter(x_, y_, 2, red, 'filled', 'MarkerFaceAlpha', 0.05);
    C = cov([x_' y_']).*2;
    display(C)
    p2 = covEllipse([mean(x_), mean(y_)], C, ...
        red, 'FaceAlpha', 0.1, 'EdgeColor', red);
    % axis square
    if axison
        legend([p2, p1], {"$$\hat{x}_t = x_t$$", "$$\hat{x}_t = x_t$$"}, 'Interpreter', 'LaTeX')
    end

%     s = scatter(x_, y_, 2, 'filled', 'color', red, 'MarkerFaceAlpha', 0.1);
%     covEllipse([mean(x_), mean(y_)], [var(x_), 0; 0, var(y_)].*2, ...
%         red, 'FaceAlpha', 0.2, 'EdgeColor', red);
%     x_ = x_./std(y_);
%     s = scatter(x_, y_, 2, 'filled', 'color', blue, 'MarkerFaceAlpha', 0.1);
%     covEllipse([mean(x_), mean(y_)], [var(x_), 0; 0, var(y_)].*2, ...
%         blue, 'FaceAlpha', 0.2, 'EdgeColor', blue);

    
    
    title(sprintf('$$\\mu = %.2g, \\eta = %.2g$$', mu, eta), 'Interpreter', 'latex')
    ax1.XLim = xlims;
    ax1.YLim = ylims;
    if axison
        ylabel("$$\hat{x}_{t-1}$$", 'Interpreter', 'latex')
        xlabel("$$\hat{x}_t$$", 'Interpreter', 'latex')
    else
        ax1.YTickLabel = [];
        ax1.XTickLabel = [];
        
    end

%     ax2 = axes(t);
%     ax2.XAxisLocation = 'top';
%     ax2.YAxisLocation = 'right';
%     ax2.Color = 'none';
%     ax2.Box = 'off';

   % Plot original axis lines
   

%     plot(x, ts, 'parent', ax1)
% And the AC
%     r = autocorr(x, 'numlags', 100);
%     plot(r)
% 
% 
% 
% 
%     xlabel("$$x$$", 'Interpreter', 'latex')
%     ax1 = gca;
%     ax1.Box = 'off';
%     ax2 = axes(t);
%     ax2.XAxisLocation = 'top';
%     ax2.YAxisLocation = 'right';
%     ax2.Color = 'none';
%     ax2.Box = 'off';
    
end

