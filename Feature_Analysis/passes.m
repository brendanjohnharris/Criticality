   function [speakparameters, speakvals] = passes(setarange, sind, sbetarange1, stype, ss0, sop_table, sparallel2, sresolution, sdirection)
        [~, speakparameters, speakvals] = evalc('noisy_passes(setarange, sind, sbetarange1, stype, ss0, sop_table, sparallel2, sresolution, sdirection)');

        function [peakparameters, peakvals] = noisy_passes(etarange, ind, betarange1, type, s0, op_table, parallel2, resolution, direction)
                eta = etarange(ind);
                %% First Pass
                [time_series_data1] = strogatz_hopf_generator('betarange', betarange1, 'type', type, 'etarange', eta, 's0', s0);
                feature_val_vector = generate_feature_vals(time_series_data1, op_table, parallel2);
                if direction
                    [~, peak_ind] = max(feature_val_vector);
                else
                    [~, peak_ind] = min(feature_val_vector);
                end
                betarange2 = betarange1(max(1, peak_ind-1)):1./resolution:betarange1(min(length(feature_val_vector), peak_ind+1))+1/resolution; % + 1/r2 to be safe

                %% Second Pass
                if direction 
                    [peakvals, peakind] = max(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters = betarange2(peakind);
                else
                    [peakvals, peakind] = min(generate_feature_vals(...
                        strogatz_hopf_generator('betarange', betarange2, ...
                        'type', type, 'etarange', eta), op_table, 0));
                    peakparameters = betarange2(peakind);
                end
       end
end