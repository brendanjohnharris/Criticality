function surf_supercritical_pitchfork_LE(cp_range, etarange)

    [CP, ETA] = meshgrid(cp_range, etarange);
    
    LE = zeros(size(CP));
    
    for m = 1:size(LE, 1)
        for n = 1:size(LE, 2)
            LE(m, n) = supercritical_pitchfork_LE(CP(m, n), ETA(m, n));
        end
    end
    surf(CP, ETA, LE)
    xlabel('Control Parameter')
    ylabel('Noise')
    zlabel('Lyapunov Exponent')
end

