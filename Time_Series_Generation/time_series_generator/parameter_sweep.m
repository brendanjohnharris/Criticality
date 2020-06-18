function parameter_sweep(template_file, input_fields, input_ranges, savefile, savefolder)
%PARAMETER_SWEEP Generate time series input files in separate folders
%varying by specified inputs
%   Input Arguments-
%       template_file:      A character array specifying a file containing a structure of the form
%                           required and produced by time_series_data. Fields to be swept can
%                           be either empty or filled, but any contained value will be ignored
%       
%       input_fields:       A 1D cell array containing the names of the input fields
%                           which will be swept over. 
%
%       input_ranges:       A cell array containing vectors that specify
%                           the range over which each input will be swept.
%                           Must be the same length as input_fields
%
%       savefile:           A character vector specifying the stem of the
%                           files to which the input files will be saved.
%                           If these will be used with
%                           'PBS_generate_time_series.sh', this should be
%                           'inputs'.
%       savefolder:         A character vector specifying the stem of
%                           folders to which input files will be saved; for
%                           'PBS_generate_time_series.sh',
%                           'time_series_data'.
%
%   Note that if more than one input_fields/input_ranges is supplied, the
%   cartesian product of all input_ranges will be used to generate a time
%   series with every possible combination of input_ranges
    if nargin < 5
        savefolder = [];
    end
%% Calculate the cartesian product
    input_points = cartesian_product(input_ranges); % Should be returned in column order of input_ranges
%% Load the input template
    S = load(template_file, 'inputs');
    for u = 1:size(input_points, 1)
        for v = 1:length(input_fields)
            S.inputs.(input_fields{v}) = input_points(u, v);
        end
        if ~isempty(savefolder)
            save([savefolder, '-', num2str(u), savefile, '-', num2str(u), '.mat'], '-struct', 'S')
        else
            save([savefile, '-', num2str(u), '.mat'], '-struct', 'S')
        end
    end
end

