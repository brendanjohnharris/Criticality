function [timeSeriesData, labels, keywords] = par_strogatz_hopf_generator(betarange, varargin)
% STROGATZ_HOPF_GENERATOR Produces time series for hctsa from the general 
%   normal form of a Hopf bifurcation as found in the Strogatz textbook.
%
%   Arguments can be omitted, with the function
%   reverting to default values.
%
%   'betarange' contains the values of the bifurcation
%   parameter for which time series will be generated.
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
%   function takes sginificantly longer than 'false'.

    %% Parsing inputs
    p = inputParser;
    addParameter(p,'type','supercritical')
    %addParameter(p,'theta_c',10)
    addParameter(p,'tmax',310)
    addParameter(p,'s0', [1, 0])
    addParameter(p,'bifurcation_point', 0)
    addParameter(p,'eta', 0)
    addParameter(p,'numpoints', 3100000)
    addParameter(p,'savelength', 30000)
    addParameter(p, 'savedata', false)
    addParameter(p, 'bistable_point', [])
    addParameter(p, 'transient_cutoff', 100000)
    addParameter(p, 'method', 'Euler-Maruyama')
    addParameter(p, 'showplot', true)
    addParameter(p, 'rngseed', rng)
    addParameter(p, 'foldername', [])
    addParameter(p, 'fullplot', false)
    parse(p,varargin{:})
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
    
    par = gcp;
    numworkers = par.NumWorkers;
    
    betaranges = mat2cell(betarange, 1, [zeros(1, numworkers - 1) + floor(length(betarange)./2), length(betarange) - sum(zeros(1, numworkers - 1) + floor(length(betarange)./2))]);
    timeSeriesData = cell(length(betaranges), 1);
    labels = timeSeriesData;
    keywords = timeSeriesData;
    
    parfor i = 1:length(betaranges)
        [timeSeriesData{i}, labels{i}, keywords{i}] = mod_strogatz_hopf_generator(p, betaranges{i});
    end   
    
    timeSeriesData = vertcat(timeSeriesData{:});
    labels = vertcat(labels{:});
    keywords = vertcat(keywords{:});
    
    
    %% Saving
    if p.Results.savedata
        if isempty(p.Results.foldername)
            folder = type;
        else
            folder = p.Results.foldername;
        end
        while exist(folder, 'dir')
            folder = [folder, 'i'];
        end
        mkdir(folder)
%         if exist('numSubplots.m', 'file')
%            print(gcf, fullfile(folder, 'trajectories.jpg'), '-djpeg', '-r600')
%         end
        save(fullfile(folder, sprintf('%s.mat', type)),...
            'timeSeriesData', 'labels', 'keywords')
        parameters = p.Results;
        save(fullfile(folder, 'parameters.mat'), 'parameters')
        %theta = theta(:, transient_cutoff:savestep:end);
        %t = (length(timeSeriesData):numpoints).*dt;
        %save(fullfile(folder, 'variables.mat'), 'r', 'theta', 't')
    end 
    delete(par)
end
