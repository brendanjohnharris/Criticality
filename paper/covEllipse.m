function p = covEllipse(mu, sigma, varargin)
%ELLIPSE Plot an ellipse given centre and covariance matrix, using the fill
%function. Will sqrt the covariances so that they scale ellipse size linearly
% sqrt(Sigmas) correspond to 'radii', not 'diameters'
    if isrow(mu)
        mu = mu';
    end 
    [V, D] = eig(sigma);
    t = linspace(0, 2*pi);
    X = (V * sqrt(D))*[cos(t(:))'; sin(t(:))'];
    p = fill(X(1, :)+mu(1), X(2, :)+mu(2), varargin{:});
end 