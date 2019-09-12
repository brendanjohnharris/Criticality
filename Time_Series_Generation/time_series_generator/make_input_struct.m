function input_struct = make_input_struct(interactive, varargin)
%MAKE_TEMPLATE_STRUCT Make an input structure for time_series_generator
% A structure with fields required by time_series_generator will be
% returned. If no input arguments are given then a GUI will open, to interactively create the structure. 
% For an empty structure, use 'make_input_struct(0)'. To fill in fields 
% from the command widnow or a function, use the name-value pairs (see time_series_generator) after the first argument.
    if nargin < 1
        interactive = 1;
    end

    p = inputParser;
    addParameter(p, 'cp_range', [])
    addParameter(p, 'system_type', [])
    addParameter(p, 'tmax', [])
    addParameter(p, 'initial_conditions', [])
    addParameter(p, 'parameters', [])
    addParameter(p, 'bifurcation_point', [])
    addParameter(p, 'etarange', [])
    addParameter(p, 'numpoints', [])
    addParameter(p, 'savelength', [])
    addParameter(p, 'dt', [])
    addParameter(p, 'T', [])
    addParameter(p, 'sampling_period', [])
    addParameter(p, 'foldername', [])
    addParameter(p, 'rngseed', [])
    addParameter(p, 'randomise', [])
    addParameter(p, 'vocal', [])
    addParameter(p, 'save_cp_split', [])
    addParameter(p, 'input_file', [])
    addParameter(p, 'input_struct', [])
    addParameter(p, 'integrated_hctsa', struct('beVocal', [], 'INP_ops', [],...
                        'INP_mops', [], 'customFile', [], 'doParallel', []))
    parse(p,varargin{:})

    if interactive
        system_type_options = {'staircase', 'saddle_node', 'supercritical_hopf',...
            'supercritical_hopf-varying_cp', 'simple_supercritical_beta_hopf', ...
            'supercritical_hopf_radius_(strogatz)', ...
            'supercritical_hopf_radius_(strogatz)-non-reflecting', ...
            'subcritical_hopf_radius_(strogatz)'};
        
        input_struct = design_input_struct(system_type_options);
    else
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
        if ~isempty(extra_vals)
            for m = 1:length(extra_args)
                p.Results.(extra_args{m}) = extra_vals{m};
            end
        end
        fields = fieldnames(p.Results);
        allowed_fields = {'input_file', 'foldername', 'system_type'}; % Exclude any fields that are supposed to be character arrays
        for fld1 = 1:length(fields)
            ref = p.Results.(fields{fld1});
            if ischar(ref) && all(~strcmp(fields{fld1}, allowed_fields))
                for fld2 = 1:length(fields)
                    if isscalar(p.Results.(fields{fld2}))
                        ref = strrep(ref, fields{fld2}, num2str(p.Results.(fields{fld2})));
                    end
                end
                if any(isletter(ref))
                    error('The character array references an unknown field, or is incorrectly formatted')
                end
                p.Results.(fields{fld1}) = eval(ref);
            end
        end
        input_struct = p.Results;
    end
end
