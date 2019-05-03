function [p, f] = fft_power_spectrum(x, fs)
%FFT_POWER_SPECTRUM Generate a power spectrum using the fast fourier transform
%   x is timeseries, fs is sampling frequency. If x is a matrix, columns
%   should be timeseries
    if isrow(x)
        x = x';
    end
    x = x(2:end, :); % Discard first x value
    y = fft(x, [], 1);
    dx = 1/fs;
    Nq = 1/(2.*dx);
    N = size(y, 1);
    L = N*dx;
    if ~mod(L, 2)
        f = -Nq:1/L:Nq-1/L;
    else
        f = (-Nq+1/(2*L)):1/(L):(Nq-1/(2*L));
    end
    f = f(f >= 0);
    y = y(1:length(f), :);
    p = abs(y).^2./N;
    %p = p(f >= 0, :);
    p(2:end-1) = p(2:end-1).*2; % Since negative frequencies are removed)
    %p = p./max(p); % Normalise so that max power is 1. Maybe a better way?
end

