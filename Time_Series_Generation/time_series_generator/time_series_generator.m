function [timeSeriesData, inputs, labels, keywords] = time_series_generator(varargin)
    %TIME_SERIES_GENERATOR Generates time series of dynamical systems using a variety of input parameters
    %
    %   Input parameters (options) can be given as name-value pairs, in a struct,
    %   from a file or left as defaults (as below); these should be adjusted as necessary.
    %   Use 'inputs = make_input_struct();' to design a custom input strucure.
    %
    %   Additionally, any options that can be specified as a scalar can also be
    %   given as a character array that refers to one or more other options. For example,
    %   the input 'savelength' might be given (either as a function argument or
    %   in the appropriate field of an input structure/file) as '0.5.*numpoints'
    %
    %   EXAMPLES:
    %
    %       time_series_generator('input_file', 'someFile.mat');
    %
    %       [timeSeriesData, inputs, labels, keywords] = time_series_generator('input_struct', someStruct);
    %
    %       time_series_generator('cp_range', [-1, 0], 'etarange', [0.1, 1], 'foldername', 'aFolder');
    %
    %       time_series_generator('input_file', 'someFile.mat', 'T', '1.*tmax');
    %
    %   OUTPUTS:
    %
    %       timeSeriesData- The time series
    %
    %       inputs-         A structure containing the options and parameters
    %                       used to generate the time series, as well as any that were
    %                       calculated
    %
    %       labels-         A cell array labelling each row of timeSeriesData
    %                       by control and noise parameter ('cp|eta')
    %
    %       keywords-       A cell array indicating whether each time series was generated
    %                       before or after bifurcation
    %
    %
    %   INPUTS:
    %
    %       Dynamical System Options-----------------------------------------------
    %
    %           system_type:        A character array specifying the dynamical system
    %                               to be used for integration
    %
    %           cp_range:           A row vector containing the values of the control
    %                               parameter for which time series will be generated
    %
    %           etarange:           A row vector containing the values of the noise
    %                               parameter eta for which time series will be generated
    %
    %           initial_conditions: A number containing the initial conditions of
    %                               the simulation, or a vector of the same
    %                               length as cp_range
    %
    %           parameters:         A vector containing the value of any parameters
    %                               other than the control and noise
    %                               parameters. The form and type of this
    %                               option varies with the system.
    %
    %           bifurcation_point:  A number specifying the value of the control
    %                               parameter at which bifurcation occurs (Note:
    %                               This does NOT set the bifurcation point,
    %                               but is used to label the time series)
    %
    %
    %       Integration Options----------------------------------------------------
    %           The following options specify the length and integration step of
    %           the timeseries. Give ONLY TWO of the following three options:
    %
    %           tmax:               A number giving the time over which values will
    %                               be generated
    %
    %           numpoints:          The number of points to be generated during
    %                               integration (before transient removal)
    %
    %           dt:                 A number specifying the timestep of integration
    %
    %
    %       Output Timeseries Options----------------------------------------------
    %           The following options specify the length and sampling period of the
    %           output time series. Give ONLY TWO of the following three options:
    %
    %           T:                  A number giving the length, in seconds, of the
    %                               output time series. This function always
    %                               returns/saves the LAST T seconds of the
    %                               generated time series. Use this option to
    %                               remove transients.
    %
    %           savelength:         The number of points to be saved and returned
    %                               (following transient removal and downsampling)
    %
    %           sampling_period:    The time between points of the output time series
    %
    %
    %       Save Options-----------------------------------------------------------
    %
    %           foldername:         A character array containing the name of the
    %                               folder into which the results are saved; if
    %                               empty, no results will be saved
    %
    %           save_cp_split:      A positive integer specifying the (approximate)
    %                               number of subdirectories into which the results
    %                               will be saved (split by control parameter).
    %                               Useful for distributed computation.
    %
    %
    %       Other Inputs-----------------------------------------------------------
    %
    %           rngseed:            A number used as the seed of the random number
    %                               generator; set and disable 'randomise' to
    %                               duplicate previous results
    %
    %           randomise:          A binary; if true, the 'rngseed' will be ignored
    %                               and the random number generator shuffled
    %
    %           vocal:              A binary; true limits command line outputs
    %
    %           input_file:         A character array naming a mat file containing
    %                               a structure with fields containing all of the
    %                               above inputs (as returned by this function)
    %
    %           input_struct:       A struct containing the above parameters as
    %                               fields (use one of 'input_file', 'input_struct'
    %                               or neither
    %
    %           integrated_hctsa:   A structure containing options for
    %                               integrating hctsa calculations with time series
    %                               generation. If all fields are empty, time series
    %                               will be generated as normal. If not, a hctsa
    %                               file will be saved in place of a timeseries file.
    %
    %                               Useful when the time series would be too
    %                               large to save, or when there are too many
    %                               values of eta for time series to fit in
    %                               memory.
    %
    %                               The fields of this structure should be:
    %                                   - beVocal:    Logical
    %                                   - INP_ops:    Character vector, filename
    %                                   - INP_mops:   Character vector, filename
    %                                   - customFile: Character vector, filename
    %                                   - doParallel: Logical
    %
    %                               Refer to hctsa functions TS_init and
    %                               TS_compute for detail on these options' purposes.
    %
    %          criteria:            A string containing the criteria for
    %                               accepting timeseries, referring to the timeseries
    %                               'rout' (make sure it is a vectorised expression;
    %                               time series are contained in matrices, with
    %                               time increasing horizontally). If a generated
    %                               timeseries fails to pass this criteria,
    %                               it will be regenerated (up to a limit, 'maxAttempts').
    %                               E.g. 'mean(rout, 2) > 0'
    %
    %         maxAttempts:          A number, specifying how many times to try to
    %                               simulate a timeseries until it passes the criteria.
    %                               Any that do not pass by this maximum number of attemtps will be NaN

    %% Parse Inputs
    start = tic;
    p = inputParser;
    addParameter(p, 'cp_range', -0.5)
    addParameter(p, 'system_type', 'supercritical_hopf_radius_(strogatz)')
    addParameter(p, 'tmax', 1000)
    addParameter(p, 'initial_conditions', 0)
    addParameter(p, 'parameters', [])
    addParameter(p, 'bifurcation_point', 0)
    addParameter(p, 'etarange', 0.1)
    addParameter(p, 'numpoints', [])
    addParameter(p, 'savelength', 5000)
    addParameter(p, 'dt', [])
    addParameter(p, 'T', 'tmax')
    addParameter(p, 'sampling_period', [])
    addParameter(p, 'foldername', [])
    addParameter(p, 'rngseed', [])
    addParameter(p, 'randomise', 1)
    addParameter(p, 'vocal', 1)
    addParameter(p, 'save_cp_split', 0)
    addParameter(p, 'input_file', [])
    addParameter(p, 'input_struct', [])
    addParameter(p, 'integrated_hctsa', struct('beVocal', [], 'INP_ops', [], ...
        'INP_mops', [], 'customFile', [], 'doParallel', []))
    addParameter(p, 'criteria', 1) % Every timeseries will pass
    addParameter(p, 'maxAttempts', 100)
    parse(p, varargin{:})

    %% Check if extra arguments were given
    extra_vals = [];

    if ~isempty(p.Results.input_file) || ~isempty(p.Results.input_struct)
        extra_args = setdiff(p.Parameters, p.UsingDefaults); % Get the arguments that are not using defaults
        extra_args = extra_args(~strcmp(extra_args, 'input_file'));

        if ~isempty(extra_args)
            extra_vals = cell(size(extra_args));

            for k = 1:length(extra_args)
                extra_vals{k} = p.Results.(extra_args{k}); % Store extra values so they survive the load from the input file/struct
            end

        end

    end

    %% Check if an input file was specified or a struct was given
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

    %% Evaluate any options given as character arrays
    % Obviously you can't use too many of these, but it should work if none of
    % the references are chained
    p.Results = TranslateInputs(p.Results);

    %% Make sure that cp_range and eta are row vectors
    p.Results.cp_range = p.Results.cp_range(:)';
    p.Results.etarange = p.Results.etarange(:)';

    %% Unpack input parser struct, for easier access to variables (using an additional function)
    v2struct(p.Results)

    %% Randomise, or not, and add current rng state to struct
    if isempty(randomise)
        error('Randomise or not; make a decision (0 or 1)')
    end

    if randomise || isempty(rngseed)
        rng('shuffle')
        p.Results.rngseed = rng; % Update rngseed
    else
        rng(rngseed)
    end

    %% Calculate which of numsteps, tmax and dt were not specified
    lDt = isempty(dt); lTm = isempty(tmax); lN = isempty(numpoints);

    if ~lDt && ~lTm && ~lN

        if (tmax == dt .* numpoints)
            dt = tmax ./ numpoints;
            p.Results.dt = dt;
        else
            error('This combination of dt, tmax and numpoints is not consistent')
        end

    elseif lDt && ~lTm && ~lN
        dt = tmax ./ numpoints;
        p.Results.dt = dt;
    elseif ~lDt && lTm && ~lN
        tmax = numpoints .* dt;
        p.Results.tmax = tmax;
    elseif ~lDt && ~lTm && lN
        numpoints = round(tmax ./ dt); % ceil or round?
        p.Results.numpoints = numpoints;
    else
        error('Not enough inputs to determine the time parameters of integration')
    end

    %% Calculate which of T, savelength and sampling_period were not specified
    lT = isempty(T); lS = isempty(savelength); lSp = isempty(sampling_period);

    if ~lT && ~lS && ~lSp

        if (T == savelength .* sampling_period)
            T = savelength .* sampling_period;
            p.Results.T = T;
        else
            error('This combination of T, savelength and sampling_period is not consistent')
        end

    elseif lT && ~lS && ~lSp
        T = savelength .* sampling_period;
        p.Results.T = T;
    elseif ~lT && lS && ~lSp
        savelength = round(T ./ sampling_period);
        p.Results.savelength = savelength;
    elseif ~lT && ~lS && lSp
        sampling_period = T ./ savelength;
        p.Results.sampling_period = sampling_period;
    else
        error('Not enough inputs to determine the time parameters with which to save the timeseries')
    end

    %% Calculate additional variables from inputs and initialise
    transient_cutoff = numpoints - round(T ./ dt);
    %savestep = round((numpoints-transient_cutoff)./savelength);
    savestep = round(sampling_period ./ dt);
    rep_length = length(transient_cutoff:savestep:numpoints - 1);

    if ~isstruct(integrated_hctsa) && ~isempty(integrated_hctsa)
        error('The option ''integrated_hctsa'' must be a struct')
    end

    if isstruct(integrated_hctsa)
        no_hctsa = ~any(structfun(@(x) ~isempty(x), integrated_hctsa));
    else
        no_hctsa = isempty(integrated_hctsa);
    end

    if no_hctsa
        timeSeriesData = zeros(length(cp_range) .* length(etarange), rep_length);
    end

    savestruct = struct();
    %dt = tmax./numpoints;

    if isrow(initial_conditions)
        initial_conditions = initial_conditions';
    end

    initial_conditions = zeros(length(cp_range), 1) + initial_conditions;

    etaWriter = reWriter;
    attemptWriter = reWriter;

    if ~isscalar(criteria)
        inactivate(etaWriter);
    end

    %% Calculate time series values
    for i = 1:length(etarange)

        if vocal
            reWrite(etaWriter, '------------------------ %g%% complete, %gs elapsed ------------------------\n', ...
                round(100 * (i - 1) ./ length(etarange)), round(toc(start)));
        end

        eta = etarange(i);

        if isinf((numpoints - 1 - transient_cutoff) ./ savestep)
            error('Requested simulation has too many timesteps to be performed')
        end

        fails = true(length(cp_range), 1);
        rout = [fails .* initial_conditions, nan(length(cp_range), floor(((numpoints - 1 - transient_cutoff) ./ savestep) - 1))];

        if isempty(maxAttempts); maxAttempts = 1; end

        for attempt = 1:maxAttempts
            %% Run a script containing the systems
            TSG_systems

            if isscalar(criteria) || isempty(criteria)
                fails = false(length(cp_range), 1); % Let everything through
            else
                mu = cp_range'; %In case TSG_systems changed its size and the criteria references mu
                fails = ~eval(criteria);

                if vocal
                    reWrite(attemptWriter, '>>>>>> Attempt %i/%i: %i/%i timeseries passed criteria for eta = %g <<<<<<\n', ...
                        attempt, maxAttempts, sum(~fails), length(fails), etarange(i));
                end

            end

            rout(fails, :) = nan;

            if sum(fails) == 0
                break
            end

        end

        % Maybe a dirty fix
        if size(timeSeriesData, 2) - 1 == size(rout, 2)
            % The first data point is missing, probably because no subsampling took place
            rout = [initial_conditions, rout];
        end

        %% If not using integrated_hctsa
        if no_hctsa
            timeSeriesData((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = rout; % Copy to timeSeriesData
            %% Calculate feature values, create savestruct and fill static fields
        elseif i == 1
            % Calculate feature values
            datastruct = light_TS_compute(0, [], [], [], [], 0, light_TS_init( ...
                struct('timeSeriesData', rout, ...
                'labels', {cellstr(string(1:size(r, 1)))}, ...
                'keywords', {cellstr(string(1:size(r, 1)))}), ... % Won't need time series labels or keywords, so make dummy ones
                integrated_hctsa.INP_mops, integrated_hctsa.INP_ops, 0)); % Could separate, and assign individual variables, but not necessary.

            % Initialise structure
            savestruct = struct('TS_DataMat', {zeros(length(cp_range) .* length(etarange), height(datastruct.Operations))}, ...
                'TS_CalcTime', {zeros(length(cp_range) .* length(etarange), height(datastruct.Operations))}, ...
                'TS_Quality', {zeros(length(cp_range) .* length(etarange), height(datastruct.Operations))}, ...
                'Operations', datastruct.Operations, ...
                'MasterOperations', datastruct.MasterOperations, ...
                'fromDatabase', datastruct.fromDatabase, ...
                'gitInfo', datastruct.gitInfo);
            %'timeSeries', r(:, transient_cutoff:savestep:end-1), ... % For debugging

            % All fields except for TS_DataMat, TS_CalcTime, TS_Quality are static (same for each iteration)

            % Append the dynamic savestruct fields
            savestruct.TS_DataMat((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_DataMat;
            savestruct.TS_CalcTime((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_CalcTime;
            savestruct.TS_Quality((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_Quality;
            %% Calculate the feature values for this portion of time series, add to savestruct and clear the time series
        elseif i > 1
            % Calculate feature values
            datastruct = light_TS_compute(0, [], [], [], [], 0, light_TS_init( ...
                struct('timeSeriesData', rout, ...
                'labels', {cellstr(string(1:size(r, 1)))}, ...
                'keywords', {cellstr(string(1:size(r, 1)))}), ... % Won't need time series labels or keywords, so make dummy ones
                integrated_hctsa.INP_mops, integrated_hctsa.INP_ops, 0)); % Could separate, and assign individual variables, but not necessary.

            % Append the dynamic savestruct fields
            savestruct.TS_DataMat((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_DataMat;
            savestruct.TS_CalcTime((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_CalcTime;
            savestruct.TS_Quality((1 + length(cp_range) * (i - 1)):length(cp_range) * i, :) = datastruct.TS_Quality;
            %savestruct.timeSeries = [savestruct.timeSeries; r(:, transient_cutoff:savestep:end-1)]; % For debugging
        end

    end

    if no_hctsa
        %% Generate time series labels from the control and noise parameters ('cp|eta')
        labels = {};

        for n = etarange
            labels = [labels; arrayfun(@(x) sprintf('%g|%g', x, n), cp_range, 'UniformOutput', false)'];
        end

        %% Generate time series keywords
        keywords(1:sum(cp_range < bifurcation_point)) = {'Pre-bifurcation'};
        keywords(sum(cp_range < bifurcation_point) + 1:length(cp_range)) = {'Bifurcated'};
        keywords = repmat(keywords, 1, length(etarange))';

        %% Save results
        if ~isempty(foldername)

            while exist(foldername, 'dir') % If the folder already exists, change the foldername slightly

                if ~isstrprop(foldername(end), 'digit')
                    foldername = [foldername, '-1'];
                else
                    foldername = [foldername(1:find(foldername == '-')), num2str(str2double(foldername(find(foldername == '-') + 1:end)) + 1)];
                end

            end

            mkdir(foldername)

            if save_cp_split > 1
                %% Split cp_range
                num_per_split = floor((length(cp_range)) ./ save_cp_split);
                cp_split_idxs = [1:num_per_split:length(cp_range)];

                if cp_split_idxs(end) ~= length(cp_range)
                    cp_split_idxs(end + 1) = length(cp_range) + 1;
                else
                    cp_split_idxs(end) = cp_split_idxs(end) + 1;
                end

                for x = 1:length(cp_split_idxs) - 1
                    p.Results.cp_range = cp_range(cp_split_idxs(x):cp_split_idxs(x + 1) - 1);
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

        inputs = p.Results;
        %% If integrated_hctsa, save feature values and inputs
    else

        if ~isempty(foldername)

            while exist(foldername, 'dir') % If the folder already exists, change the foldername slightly

                if ~isstrprop(foldername(end), 'digit')
                    foldername = [foldername, '-1'];
                else
                    foldername = [foldername(1:find(foldername == '-')), num2str(str2double(foldername(find(foldername == '-') + 1:end)) + 1)];
                end

            end

            mkdir(foldername)

            inputs = p.Results;
            save(fullfile(foldername, 'HCTSA.mat'), '-struct', 'savestruct', '-v7.3')
            save(fullfile(foldername, 'inputs_out.mat'), 'inputs')
        end

    end

    %% Announce completion
    if vocal
        reWrite(etaWriter, '------------------------100%% complete, %gs elapsed------------------------\n', round(toc(start)));
    end

end
