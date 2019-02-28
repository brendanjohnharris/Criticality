function LE = supercritical_pitchfork_LE(cp_range, eta)
% Gives the Lyapunov exponent (approximately?) as a function of the control parameter and
% given a noise variance for a supercritical pithfork bifurcation ('Noise
% and Bifurcations' paper
    if size(cp_range, 1) > 1
        cp_range = cp_range';
    end

    cpm = cp_range(cp_range < 0);
    cp0 = cp_range(cp_range == 0);
    cpp = cp_range(cp_range > 0);
    
    
    
    LEm = (cpm./2).*(3.*(besselk(0.75, (cpm./eta).^2./4)./besselk(0.25, (cpm./eta).^2./4)) - 1);
    LE0 = {[], (-6.*eta.*pi./gamma(0.25).^2)};
    LE0 = LE0{length(cp0)+1}; % Shouldn't give any duplicate cp's
    LEp = -(cpp./2).*((3.*(besseli(0.75, (cpp./eta).^2./4) + besseli(-0.75, (cpp/eta).^2./4))./(besseli(0.25, (cpp./eta).^2./4) + besseli(-0.25, (cpp./eta).^2./4))) + 1);
    
    LE = [LEm, LE0, LEp];
end

