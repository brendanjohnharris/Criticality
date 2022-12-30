function plotSystemDynamics(t, time_series_data, mu, eta)
%PLOTSYSTEMDYNAMICS
    arguments
        t
        time_series_data
        mu
        eta
    end
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
    inputs.tmax = 1010;
    inputs.sampling_period = 0.1;
    x = time_series_generator('input_struct', inputs);
    ts = 0:inputs.sampling_period:inputs.sampling_period*(length(x)-1);
%     plot(x, ts, 'parent', ax1)
% And the AC
    r = autocorr(x, 'numlags', 100);
    plot(r)




    xlabel("$$x$$", 'Interpreter', 'latex')
    ax1 = gca;
    ax1.Box = 'off';
    ax2 = axes(t);
    ax2.XAxisLocation = 'top';
    ax2.YAxisLocation = 'right';
    ax2.Color = 'none';
    ax2.Box = 'off';



end

