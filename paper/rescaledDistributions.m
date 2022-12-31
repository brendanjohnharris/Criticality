function f = rescaledDistributions(time_series_data, mus, etas)
%RESCALEDDISTRIBUTIONS 
    f = figure();
    data = time_series_data(1, :);
    inputs = data.Inputs;
    inputs.numpoints = [];
    inputs.savelength = [];
    inputs.T = 1000;
    inputs.foldername = [];
    inputs.tmax = 1010;
    inputs.sampling_period = 0.1;
    i = 0;
    xlims = [0, 5];
    xs = linspace(xlims(1), xlims(2), 100);
    hold on
    for mu = mus
        for eta = etas
            i = i+1;
            V = @(x) -mu.*x.^2./2 + x.^4./4;
            p = @(x) exp(-2.*V(x)/eta.^2);
            inputs.etarange = [eta];
            inputs.cp_range = [mu];
            x = time_series_generator('input_struct', inputs);
            sigma = 1./std(x(2:end) - x(1:end-1));
            ps = p(xs)./(sum(p(xs)).*(xs(2)-xs(1)).*sigma);
            plot(xs.*sigma, ps)
        end
    end
    xlim(xlims)
    hold off
end

