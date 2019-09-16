function inputs = TranslateInputs(inputs)
% You migth give time_series_generator an input struct containing strings
% that reference other fields; this function replaces those with their
% numeric values. Only guaranteed (?) to work if references are not
% chained. If they are, whether this function throws an error or not
% depends on their order.

    fields = fieldnames(inputs);
    allowed_fields = {'input_file', 'foldername', 'system_type', 'criteria'}; % Exclude any fields that are supposed to be character arrays
    allowed_fields_idxs = ismember(fieldnames(inputs), allowed_fields);
    
    % Convert character inputs to strings, so that they throw an error if
    % the reference each other.
    for i = 1:length(fields)
        inputs.(fields{i}) = convertCharsToStrings(inputs.(fields{i}));
    end
    while any(structfun(@isstring, inputs).*~allowed_fields_idxs)
        for fld1 = 1:length(fields)
            ref = inputs.(fields{fld1});
            if isstring(ref) && all(~strcmp(fields{fld1}, allowed_fields))
                for fld2 = 1:length(fields)
                    ref = strrep(ref, fields{fld2}, ['(inputs.("', fields{fld2},'"))']);
                end
                try
                    inputs.(fields{fld1}) = eval(ref);
                catch
                    error('The character array references an unknown field, is incorrectly formatted or is circular')
                end
            end
        end
    end
    
    % And convert the strings back to chars, for consistency
    for i = 1:length(fields)
        inputs.(fields{i}) = convertStringsToChars(inputs.(fields{i}));
    end
end

