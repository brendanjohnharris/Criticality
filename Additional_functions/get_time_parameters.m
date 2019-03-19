function [save_dt, save_tmax, savestep, dt] = get_time_parameters(tmax, numpoints, savelength, transient_cutoff)
    savestep = ceil((numpoints-transient_cutoff)./savelength);
    dt = tmax./numpoints;
    save_dt = savestep.*dt;
    save_tmax = save_dt*(length(transient_cutoff:savestep:numpoints-1)-1);
    
end
