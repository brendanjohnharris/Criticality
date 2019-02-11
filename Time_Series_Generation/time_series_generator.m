function timeSeriesData = time_series_generator(varargin)
%TIME_SERIES_GENERATOR Generates time series using a variety of input parameters
%
%   Input arguments can be set or left as defaults (as below); make sure to
%   review the defaults set in the input parser and adjust as necessary. 
%   Note that the form and accepted types of the 'parameters' variable is
%   dependant on the specified system
% 
%     cp_range:           A vector containing the values of the control parameter for which time series will be generated
%     system_type:        A character array specifying the dynamical system to be used for integration
%     tmax:               A number giving the time over which values will be generated
%     initial_conditions: A number containing the initial conditions of the simulation
%     *parameters:        A vector containing the value of any parameters except for the control and noise parameters
%     bifurcation_point:  A number specifying the value of the control parameter at which bifurcation occurs
%     etarange:           A vector containign the values of the noise parameter eta for which time series will be generated
%     numpoints:          The number of points to be generated during integration (before transient removal)
%     savelength:         The number of points to be saved and returned (following transient removal and downsampling)
%     transient_cutoff:   The number of points to be removed from the beginning of the time series (before downsampling)
%     foldername:         A character array containing the name fo the folder into which the results are saved; if empty, no results will be saved
%     rngseed:            A number used as the seed of the random number generator; set and disable 'randomise' to duplicate previous results
%     randomise:          A binary; if true, the 'rngseed' will be ignored and the random number generator shuffled
%     vocal:              A binary; true limits command line outputs
%     save_cp_split:      A positive value specifying the (approximate) number of subdirectories 
%                           into which the results will be saved (split by control
%                           parameter). Useful for distributed hctsa calculation
%     input_file:         A character array naming a mat file containing a structure with fields containing all the above inputs (as returned by this function)
%     input_struct:       A struct containing the above parameters as fields (use either 'input_file', 'input_struct' or neither


%% Parse Inputs
    start = tic; % Start timer
    p = inputParser;
    addParameter(p, 'cp_range', [-1:0.1:1])
    addParameter(p, 'system_type', 'supercritical_hopf_radius_(strogatz)')
    addParameter(p, 'tmax', 1000)
    addParameter(p, 'initial_conditions', 1)
    addParameter(p, 'parameters', [])
    addParameter(p, 'bifurcation_point', 0)
    addParameter(p, 'etarange', 0.16)
    addParameter(p, 'numpoints', 1000000)
    addParameter(p, 'savelength', 5000)
    addParameter(p, 'transient_cutoff', 500000)
    addParameter(p, 'foldername', [])
    addParameter(p, 'rngseed', [])
    addParameter(p, 'randomise', 1)
    addParameter(p, 'vocal', 1)
    addParameter(p, 'save_cp_split', 0)
    addParameter(p, 'input_file', [])
    addParameter(p, 'input_struct', [])
    parse(p,varargin{:})
    
%% Check if extra arguments were given
    extra_vals = [];
    if ~isempty(p.Results.input_file) || ~isempty(p.Results.input_struct)
        extra_args = setdiff(p.Parameters, p.UsingDefaults); % Get the arguments that are not using defaults
        extra_args = extra_args(~strcmp(extra_args, 'input_file'));
        if ~isempty(extra_args)
            extra_vals = cell(size(extra_args));
            for k = 1:length(extra_args)
                extra_vals{k} = p.Results.(extra_args{k});  % Store extra values so they survive the load from the input file/struct
            end
        end
    end
    
%%  Check if an input file was specified or a struct was given
    if ~isempty(p.Results.input_file) && isempty(p.Results.input_struct)
        f = struct2cell(load(p.Results.input_file));
        p = struct('Results', f{1}); % p doesn't include extra input parser fields but is still in the same form
        input_file = p.Results.input_file;
    elseif ~isempty(p.Results.input_struct) && isempty(p.Results.input_file)
        p = struct('Results', p.Results.input_struct);
        input_file = p.Results.input_file;
    end
    
%% Change input parser to struct so that 'Results' field can be modified
    p = struct('Results', p.Results);
%    p.Results.input_file = input_file; % Make sure that the input file of these generated time series is the input file originally specified
    
%% If extra arguments were given, replace values
    if ~isempty(extra_vals)
        for m = 1:length(extra_args)
            p.Results.(extra_args{m}) = extra_vals{m};
        end
    end

%% Unpack input parser struct, for easier variable access (using an additional function)
    v2struct(p.Results)
    
%% Randomise, or not, and add current rng state to struct
    if randomise || isempty(rngseed)
        rng('shuffle')
        p.Results.rngseed = rng; % Update rngseed
    else
        rng(rngseed)
    end
 
%% Calculate additional variables from inputs
    savestep = ceil((numpoints-transient_cutoff)./savelength);
    timeSeriesData = repmat(zeros(length(cp_range), length(transient_cutoff:savestep:numpoints-1)), length(etarange), 1);
    dt = tmax./numpoints;
    
%% Calculate time series values
    for i = 1:length(etarange)
        if vocal
            fprintf('------------------------%g%% complete, %gs elapsed------------------------\n', round(100*(i-1)./length(etarange)), round(toc(start)))
        end
        eta = etarange(i);
        r = [zeros(length(cp_range), 1) + initial_conditions, zeros(length(cp_range), numpoints-1)];
        W = eta.*sqrt(dt).*randn(size(r)); % Need complex noise for systems with complex variables?
        switch system_type
            case 'staircase'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (sin(parameters(1).*r(:, n))).*dt + (W(:, n)+(0.01*abs(W(:, n)))); % All real
                end 
            
            case 'supercritical_hopf'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (cp_range'.*r(:, n) - parameters(1).*r(:, n).*(abs(r(:, n))).^2).*dt;
                    theta = angle(r(:, n+1));
                    r(:, n+1) = r(:, n+1) + (cos(theta) + 1i.*sin(theta)).*W(:, n); % Right way to add noise to complex??? Add before or after step???
                end

            case 'supercritical_hopf-varying_cp'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (cp_range'.*r(:, n) - parameters(1).*r(:, n).*(abs(r(:, n))).^2).*dt;
                    theta = angle(r(:, n+1));
                    r(:, n+1) = r(:, n+1) + (cos(theta) + 1i.*sin(theta)).*W(:, n); % Right way to add noise to complex??? Add before or after step???
                    cp_range = cp_range + parameters(2).*dt;
                end
                
%             case 'supercritical_hopf-x'
%                 for n = 1:numpoints-1
%                     r(:, n+1) = r(:, n) + (cp_range'.*r(:, n) - parameters(1).*r(:, n).*(abs(r(:, n))).^2).*dt + W(:, n);
%                 end
%                 r = real(r);
            
%             case 'supercritical_hopf_(real_parameters)-radius'
%                 for n = 1:numpoints-1
%                     r(:, n+1) = r(:, n) + ((cp_range'+1i).*r(:, n) - (parameters(1)+parameters(2)*1i).*r(:, n).*(abs(r(:, n))).^2).*dt + W(:, n);
%                 end
%                 r = abs(r);

            case 'simple_supercritical_beta_hopf'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (cp_range'.*r(:, n) - parameters(1).*r(:, n).*(abs(r(:, n))).^2).*dt + W(:, n); % All real
                end
            
            case 'supercritical_hopf_radius_(strogatz)'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (cp_range'.*r(:, n) - (r(:, n).^3)).*dt + W(:, n);
                end
                r = abs(r);
                
           case 'supercritical_hopf_radius_(strogatz)-non-reflecting'
                for n = 1:numpoints-1
                    r(:, n+1) = (r(:, n) + (cp_range'.*r(:, n) - (r(:, n).^3)).*dt + W(:, n));
                end
           
            case 'subcritical_hopf_radius_(strogatz)'
                for n = 1:numpoints-1
                    r(:, n+1) = r(:, n) + (-r(:, n).^5 + (r(:, n).^3) + cp_range'.*r(:, n)).*dt + W(:, n);
                end
                r = abs(r);
                
            otherwise
                error("No match found for type '%s'", system_type)     
        end
        timeSeriesData((1+length(cp_range)*(i-1)):length(cp_range)*i, :) = r(:, transient_cutoff:savestep:end-1); % Copy to timeSeriesData, remove transient and downsample
    end
    
%% Generate time series labels from the control and noise parameters ('cp|eta')
    labels = {};
    for n = etarange
        labels = [labels;arrayfun(@(x) sprintf('%g|%g', x, n), cp_range, 'UniformOutput', false)'];
    end

%% Generate time series keywords
    keywords(1:sum(cp_range < bifurcation_point)) = {'Pre-bifurcation'};
    keywords(sum(cp_range<bifurcation_point)+1:length(cp_range)) = {'Bifurcated'};
    keywords = repmat(keywords, 1, length(etarange))';
    
%% Save results
    if ~isempty(foldername)
        while exist(foldername, 'dir') % If the folder already exists, change the foldername slightly
            foldername = [foldername, 'i'];
        end
        mkdir(foldername)
        if  save_cp_split > 1
        %% Split cp_range
            num_per_split = floor((length(cp_range))./save_cp_split);
            cp_split_idxs = [1:num_per_split:length(cp_range)];  
            if cp_split_idxs(end) ~= length(cp_range)
                cp_split_idxs(end+1) = length(cp_range)+1;
            else
                cp_split_idxs(end) = cp_split_idxs(end)+1;
            end
            for x = 1:length(cp_split_idxs)-1
                p.Results.cp_range = cp_range(cp_split_idxs(x):cp_split_idxs(x+1)-1);
                subfoldername = ['time_series_data-', num2str(x)];
                split_ids = startsWith(labels, arrayfun(@(x) [num2str(x), '|'], p.Results.cp_range, 'uniformoutput', 0));
                S.timeSeriesData = timeSeriesData(split_ids, :);
                S.labels = labels(split_ids, :);
                S.keywords = keywords(split_ids, :);
                mkdir(fullfile(foldername, subfoldername))
                inputs = p.Results;
                save(fullfile(foldername, subfoldername, 'timeseries.mat'), '-struct', 'S', '-v7.3')
                save(fullfile(foldername, subfoldername, 'inputs_out.mat'), 'inputs')
            end    
        else
            inputs = p.Results;
            save(fullfile(foldername, 'timeseries.mat'), 'timeSeriesData', 'labels', 'keywords', '-v7.3')
            save(fullfile(foldername, 'inputs_out.mat'), 'inputs')
        end
    end
                
%% Announce completion
    if vocal
        fprintf('------------------------100%% complete, %gs elapsed------------------------\n', round(toc(start)))
    end
end

