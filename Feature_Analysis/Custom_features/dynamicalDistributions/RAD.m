function f = RAD(x, center, tau)
    % RAD Compute the rescaled auto-density, a metric for inferring the
    % distance to criticality that is insensitive to uncertainty in the noise strength
    % INPUTS
    %   x:        A vector, the input time series
    %   center:   Whether to center the time series at 0 then take absolute values
    %   tau:      An integer; the embedding and differencing delay in units of the timestep
    % OUTPUTS
    %   f:        The RAD feature value
    if nargin < 2 || isempty(center)
        center = 0;
    end

    if nargin < 3 || isempty(tau)
        tau = 1;
    end

    if isrow(x)
        x = x';
    end

    if center
        x = x - median(x);
        x = abs(x);
    end

    % Delay embed at interval tau, m = 2
    y = x(tau + 1:end);
    x = x(1:end - tau);

    % Median split
    subMedians = x < median(x);
    superMedianSD = std(x(~subMedians));
    subMedianSD = std(x(subMedians));

    % Properties of the auto-density
    sigma_dx = std(y - x);
    densityDifference = 1 ./ superMedianSD - 1 ./ subMedianSD;

    f = sigma_dx .* densityDifference;
end
