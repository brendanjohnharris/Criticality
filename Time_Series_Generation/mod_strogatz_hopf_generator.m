function [timeSeriesData, labels, keywords] = mod_strogatz_hopf_generator(p, betarange)
% STROGATZ_HOPF_GENERATOR Produces time series for hctsa from the general 
%   normal form of a Hopf bifurcation as found in the Strogatz textbook.
%
%   Arguments can be omitted, with the function
%   reverting to default values.
%
%
%   'type' is either 'supercritical' or 'subcritical
%   
%   'theta_c' is the constant of phase velocity.
%
%   'tmax' is the length of the time series to be generated.
% 
%   's0' is a vector containing the initial position, in polar
%   coordinates.
%   
%   'bifurcation_point' is the value of the bifurcation parameter
%   for which the system bifurcates, used to assign the time series
%   appropriate keywords.
%
%   'eta' is a noise scaling coefficient (0 eliminates noise).
%
%   'rho' is a constant, not sure what it does.
%
%   'numpoints' defines the resolution of the computation
%
%   'savelength' is an integer, and defines the maximum length of the saved
%   time series. Note that the function does not save 'savelength'
%   consecutive timepoints but saves timepaints at regular intervals from
%   the timeseries generated; a lower 'savelength' reduces
%   resolution, but not scale.
%
%   'savedata' can be either 'true' or 'false', determining whether the
%   data and figure are saved or not.
%
%   'bistable_point' allows the definition of the start of the bistable
%   region, if it exists. Must be smaller than 'bifurcation_point'.
%
%   'transient_cutoff' removes a certain number of steps from the
%   beginning of the timeseries.
%
%   'method' is either 'Euler-Maruyama' or 'Heun'.
%
%   'showplot' can be either 'true' or 'false', determining whether the
%   trajectory plot is displayed.
%
%   'rngseed' can be defined (a positive integer) but by default stores the
%   state of Matlab's random number generator so that computations can be
%   repeated.
%
%   'foldername' is a string containing the name of the folder to be
%   created, and in which the results will be saved
%
%   'fullplot' can be either 'true' or 'false' and sets whether the
%   trajectory plot displays all time series points (including the
%   transient) or only those that are to be saved. 'true' means the
%   function takes sginificanlty longer than 'false'.
%
%   Note: Plotting functionality currently requires 'numSubplots' by Rob Campbell

    %% Parsing inputs 
    type = p.Results.type;
    %theta_c = p.Results.theta_c;
    tmax = p.Results.tmax;
    s0 = p.Results.s0;
    bifurcation_point = p.Results.bifurcation_point;
    eta = p.Results.eta;
    numpoints = p.Results.numpoints;
    savelength = p.Results.savelength;
    bistable_point = p.Results.bistable_point;
    transient_cutoff = p.Results.transient_cutoff;
    showplot = p.Results.showplot;
    method = p.Results.method;
    fullplot = p.Results.fullplot;
    rng(p.Results.rngseed)
    %% Calculating
    r = [zeros(length(betarange), 1) + s0(1), zeros(length(betarange), numpoints-1)];
    %theta = [zeros(length(betarange), 1) + s0(2), zeros(length(betarange), numpoints-1)];
    dt = tmax./numpoints;
    W = eta.*sqrt(dt).*randn(size(r)); % Has extra column, shouldn't matter
    switch type
        case 'supercritical'
            gamma = 0;
            lambda = -1;
        case 'subcritical'
            gamma = -1;
            lambda = 1;
        otherwise
            error("'%s' is not a supported bifurcation type", type)
    end
    switch method
        case 'Euler-Maruyama'
            for n = 1:numpoints-1
                %theta(:, n+1) = theta_c*(dt*n) + theta(:, 1); % Deterministic theta, using d0/dt = constant
                r(:, n+1) = r(:, n) + (gamma.*r(:, n).^5 + lambda.*(r(:, n).^3) + betarange'.*r(:, n)).*dt + W(:, n);
            end
        case 'Heun'
            for n = 1:numpoints - 1
                %theta(:, n+1) = theta_c*(dt*n) + theta(:, 1);
                rtemp = r(:, n) + (gamma.*r(:, n).^5 + lambda.*(r(:, n).^3) + betarange'.*r(:, n)).*dt + W(:, n);
                r(:, n+1) = r(:, n) + ((gamma.*r(:, n).^5 + lambda.*(r(:, n).^3) + betarange'.*r(:, n))...
                            + (gamma.*rtemp.^5 + lambda.*(rtemp.^3) + betarange'.*rtemp))*(dt/2)...
                            + W(:, n); % 0.5*(g(r) + g(rtemp))*E, g(r) = eta, E = W/eta
            end
        otherwise
            error("'%s' is not a supported integration method", method)
    end
    savestep = ceil((numpoints-transient_cutoff)./savelength);
    timeSeriesData = r(:, transient_cutoff:savestep:end-1);
    labels = arrayfun(@(x) sprintf('%g', x), betarange, 'UniformOutput', false)';
    if ~isempty(bistable_point)
        keywords(1:sum(betarange < bistable_point)) = {'Pre-bistable'};
        keywords(sum(betarange<bistable_point)+1:sum(betarange < bifurcation_point)) = {'Bistable'};
        keywords(sum(betarange<bifurcation_point)+1:length(betarange)) = {'Bifurcated'};
    else
        keywords(1:sum(betarange < bifurcation_point)) = {'Pre-bifurcation'};
        keywords(sum(betarange<bifurcation_point)+1:length(betarange)) = {'Bifurcated'};
    end
    keywords = keywords';
end
