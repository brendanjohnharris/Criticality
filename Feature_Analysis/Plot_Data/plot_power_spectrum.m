function plot_power_spectrum(inputs, plot_type, method, logt, smoothrep)
% PLOT_POWER_SPECTRUM Visualise time series by their fourier transform
% method should be: 'pspectrum' or 'fft_power_spectrum', or you can try
% your luck with pwelch or periodogram etc.
% 'smooth' should be a number giving the number of time series used to smooth (by averaging) 
% the power spectrum. If no smoothing, use empty or 1.


    if nargin < 3 || isempty(method)
        method = 'pspectrum';
    end
    if nargin < 4 || isempty(logt)
        logt = 0;
    end
    if nargin < 5 || isempty(smoothrep)
        smoothrep = [];
    end
    if ischar(inputs)
        load(inputs)
    elseif ~isstruct(inputs)
        error("The 'inputs' argument must be either a character vector or a structure")
    end
    if length(inputs.cp_range) > 1 && length(inputs.etarange) > 1
        error('Only one of the control and noise parameters can vary')
    end
    fg = figure;
    
    if ~isempty(smoothrep) && smoothrep > 1 && length(inputs.cp_range) > 1 && length(inputs.etarange) == 1
        inputsdash = inputs;
        inputsdash.cp_range = repmat(inputs.cp_range, 1, smoothrep);
        [timeSeriesData, inputsout] = time_series_generator('input_struct', inputsdash);
        fs = 1./(inputsout.sampling_period);
        inputsout.cp_range = inputs.cp_range;
        [ps, f] = eval([method, '(timeSeriesData'', fs)']);
        %p = reshape(ps', length(inputs.cp_range), [], smoothrep);
        %p = permute(reshape(ps', [], smoothrep, size(ps', 2)), [2 3 1]);
        %p = mat2cell(ps', repmat(length(inputs.cp_range), 1, smoothrep), size(ps', 2));
        [r,c] = size(ps');
        p = permute(reshape(ps,[c,r/smoothrep,smoothrep]),[2,1,3]);
        p = mean(p, 3);
    else
        [timeSeriesData, inputsout] = time_series_generator('input_struct', inputs);
        fs = 1./(inputsout.sampling_period);
        [ps, f] = eval([method, '(timeSeriesData'', fs)']);
        p = ps';
        if ~isempty(smoothrep) && smoothrep > 1
            p = zeros(size(p, 1), size(p, 2), smoothrep);
            p(:, :, 1) = ps';
            for u = 2:smoothrep
                [timeSeriesData, inputsout] = time_series_generator('input_struct', inputs);
                [ps, f] = eval([method, '(timeSeriesData'', fs)']);
                p(:, :, u) = ps';
            end
            p = mean(p, 3);
        end
    end

    if logt
        f = log10(f');
    else
        f = f';
    end
    
    switch plot_type
        %%
        case 'overlap'
            hold on
            for i = 1:size(p, 1)
                subp = p(i, :);
                %plot(log10(f), log10(p))
                plot(f, log10(subp))
            end
            if length(inputsout.cp_range) > 1 && length(inputsout.etarange) == 1
                lgd = legend(cellfun(@(x) num2str(x), num2cell(inputsout.cp_range), 'UniformOutput', 0));
                title(lgd, 'Control Parameter');
                title(['Hopf Bifurcation Power Spectra: \eta = ', num2str(inputsout.etarange)], 'interpreter', 'tex')
            elseif length(inputsout.cp_range) == 1 && length(inputsout.etarange) > 1
                lgd = legend(cellfun(@(x) num2str(x), num2cell(inputsout.etarange), 'UniformOutput', 0));
                title(lgd, 'Noise Parameter');
                title(['Hopf Bifurcation Power Spectra: \mu = ', num2str(inputsout.cp_range)], 'interpreter', 'tex')            
            end
            ylabel('log_{10}(Power)', 'interpreter', 'TeX')
            if logt
                a = gca;
                a.XTickLabel = cellfun(@(x) ['10^{', x, '}'], a.XTickLabel, 'UniformOutput', 0);
            end
            xlabel('Frequency (Hz)', 'interpreter', 'TeX')
        %%
        case 'carpet'
            if length(inputsout.cp_range) > 1 && length(inputsout.etarange) == 1
                [X, Y] = ndgrid(inputsout.cp_range, f);
                pcolor(X, Y, log10(p))
                shading interp
                c = colorbar;
                %c.Label.Position = [3, 0.5, 0];
                c.Label.String = 'log_{10}(Power)';
                %c.Label.Rotation = 0;
                c.Label.FontSize = 12;
                title(['Hopf Bifurcation Power Spectra: \eta = ', num2str(inputsout.etarange)], 'interpreter', 'tex')
                xlabel('Control Parameter')
            elseif length(inputsout.cp_range) == 1 && length(inputsout.etarange) > 1
                [X, Y] = ndgrid(inputsout.etarange, f);
                pcolor(X, Y, log10(p))
                shading interp
                c = colorbar;
                %c.Label.Position = [3, 0.5, 0];
                c.Label.String = 'log_{10}(Power)';
                %c.Label.Rotation = 0;
                c.Label.FontSize = 12;
              
                title(['Hopf Bifurcation Power Spectra: \mu = ', num2str(inputsout.cp_range)], 'interpreter', 'tex')   
                xlabel('Noise Parameter')
            end
            if logt
                a = gca;
                a.XTickLabel = cellfun(@(x) ['10^{', x, '}'], a.XTickLabel, 'UniformOutput', 0);
            end
            xlabel('Frequency (Hz)', 'interpreter', 'TeX')
        %%     
        case 'surf'  
            if length(inputsout.cp_range) > 1 && length(inputsout.etarange) == 1
                [X, Y] = ndgrid(inputsout.cp_range, f);
                surf(X, Y, log10(p))
                shading interp
                c = colorbar;
                %c.Label.Position = [3, 0.5, 0];
                c.Label.String = 'log_{10}(Power)';
                %c.Label.Rotation = 0;
                c.Label.FontSize = 12;
                title(['Hopf Bifurcation Power Spectra: \eta = ', num2str(inputsout.etarange)], 'interpreter', 'tex')
                xlabel('Control Parameter')
                
            elseif length(inputsout.cp_range) == 1 && length(inputsout.etarange) > 1
                [X, Y] = ndgrid(inputsout.etarange, f);
                surf(X, Y, log10(p))
                shading interp
                c = colorbar;
                %c.Label.Position = [3, 0.5, 0];
                c.Label.String = 'log_{10}(Power)';
                %c.Label.Rotation = 0;
                c.Label.FontSize = 12;
              
                title(['Hopf Bifurcation Power Spectra: \mu = ', num2str(inputsout.cp_range)], 'interpreter', 'tex')   
                xlabel('Noise Parameter')
            end
            if logt
                a = gca;
                a.XTickLabel = cellfun(@(x) ['10^{', x, '}'], a.XTickLabel, 'UniformOutput', 0);
            end
            xlabel('Frequency (Hz)', 'interpreter', 'TeX')
            view(3)  
        %%
        otherwise
            close(fg)
            error('Not a supported plot type')
    end
    set(gcf, 'color', 'w')    

end
