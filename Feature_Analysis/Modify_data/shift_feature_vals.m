function data = shift_feature_vals(data, directions, shift_by_what, match_ranges)
    % shift_by_what is either a number, in which case it is the amount by
    % which the feature values in each row of data will be shifted, or a
    % specific character array 'peaks', which will shift the feature values
    % in the rows of the data so that their peak is at control parameter 0
    % match_ranges is vector specifying the range of the control parameter
    % to select from each row of data. 
    if strcmp(shift_by_what, 'Peaks')
        for x = 1:length(data)
            datamat = data(x).TS_DataMat;
            shift_ind = zeros(length(directions), 1);
            for n = 1:length(directions)
                shift_ind(n) = get_shift(datamat(:, n), directions(n));
            end
            shift_vec = data(x).Inputs.cp_range(shift_ind);
            data(x).Feature_Value_Shift = shift_vec;
            
            data(x).Inputs.cp_range = data(x).Inputs.cp_range - ...........
        end
        
    end
    
    
    
    function shift = get_shift(feature_vals, direction)
        if direction == 0
            shift = find(data(x).Inputs.cp_range == 0);
        else
            try
                if direction == 1
                    [~, shift] = max(feature_vals);
                elseif direction == -1
                    [~, shift] = min(feature_vals);
                end   
            catch 
                shift = find(data(x).Inputs.cp_range == 0);
            end
        end
    end
end

