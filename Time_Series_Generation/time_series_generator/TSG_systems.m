% This script contains the systems availiable to time_series_generator.
% To add a new system, remeber that it must:
%     - Increment from 1 to numpoints-1
%     - Refer to the evolving vector 'r' as the time series value; one element for every control parameter
%     - Assign 'r' to 'rout(fails)' whenever n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
%
% There are other requirements, but for simple functions of 'mu', 'r' and 'eta' just follow this template:
%
% case '<system name>''
%     for n = 1:numpoints-1
%         r = r + (<f(r, mu)>).*dt + (<g(r, eta)>).*sqrt(dt).*randn(Wl, 1);
%         if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
%             rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
%         end
%     end

%% Initialise some variables
r = zeros(sum(fails), 1) + initial_conditions(fails);
Wl = size(r, 1); % Length of noise vector
mu = cp_range(fails)';

%% Generate the timeseries
switch system_type
    case 'staircase'
        % This one works best with cp_range = -1, etarange = 1
        for n = 1:numpoints-1
            r = r + (sin(mu.*r)).*dt + (eta.*sqrt(dt).*randn(Wl, 1)+(0.01*abs(eta.*sqrt(dt).*randn(Wl, 1))));
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'saddle_node'
        for n = 1:numpoints-1
            r = r + (mu + (r.^2)).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
       
	case 'eta_normalised_saddle_node'
        for n = 1:numpoints-1
            r = r + (mu + (r.^2)).*dt + eta.*-mu.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'supercritical_hopf'
        for n = 1:numpoints-1
            r = r + (mu.*r - parameters(1).*r.*(abs(r)).^2).*dt;
            theta = angle(r);
            r = r + (cos(theta) + 1i.*sin(theta)).*eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'supercritical_hopf-varying_cp'
        for n = 1:numpoints-1
            r = r + (mu.*r - parameters(1).*r.*(abs(r)).^2).*dt;
            theta = angle(r);
            r = r + (cos(theta) + 1i.*sin(theta)).*eta.*sqrt(dt).*randn(Wl, 1);
            mu = mu + parameters(2).*dt;
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'simple_supercritical_beta_hopf'
        for n = 1:numpoints-1
            r = r + (mu.*r - parameters(1).*r.*(abs(r)).^2).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'supercritical_hopf_radius_(strogatz)'
        for n = 2:numpoints-1
            r = r + (mu.*r - (r.^3)).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        rout = abs(rout);
        
	case 'supercritical_hopf_radius_(strogatz)_pink'
        for n = 2:numpoints-1
            r = r + (mu.*r - (r.^3)).*dt + eta.*sqrt(dt).*pinknoise(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        rout = abs(rout);
        
	case 'supercritical_hopf_radius_(strogatz)_multiplicative'
        for n = 2:numpoints-1
            r = r + (mu.*r - (r.^3)).*dt + r.*eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        rout = abs(rout);

   case 'supercritical_hopf_radius_(strogatz)-non-reflecting'
        for n = 1:numpoints-1
            r = r + (mu.*r - (r.^3)).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end

    case 'subcritical_hopf_radius_(strogatz)'
        for n = 1:numpoints-1
            r = r + (-r.^5 + (r.^3) + mu.*r).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        rout = abs(rout);

    case 'quadratic_potential'
        for n = 1:numpoints-1
            r = r + (mu.*r).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        rout = abs(rout);
        
    case 'supercritical_pitchfork_(strogatz)'
        for n = 1:numpoints-1
            r = r + (mu.*r - (r.^3)).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        
    case 'subcritical_pitchfork_(strogatz)'
        for n = 1:numpoints-1
            r = r + (-r.^5 + (r.^3) + mu.*r).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        
    case 'subcritical_hopf_radius_(strogatz)_varying_cp'
        for n = 1:numpoints-1
            r = r + (-r.^5 + (r.^3) + mu.*r).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            r = abs(r);
            mu = mu + parameters(1).*dt; % The parameter is d(mu)/dt
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = r;
            end
        end
        
    % A sneaky way to handle 2nd order or 2D SDEs: r is a complex
    % variable, but the real and imaginary parts won't mingle.
    case 'vanderPol'
    	for n = 1:numpoints-1
            xp = real(r);
            yp = imag(r);
            
            x = xp + yp.*dt;
            y = yp + (mu.*(1-(xp).^2).*yp-xp).*dt + eta.*sqrt(dt).*randn(Wl, 1);
            
            r = x + 1i.*y;
            if n >= transient_cutoff && ~mod(n - transient_cutoff - 1, savestep)
                rout(fails, 1 + (n - transient_cutoff - 1)./savestep) = real(r);
            end
        end
        
    otherwise
        error("No match found for type '%s'", system_type)
end
