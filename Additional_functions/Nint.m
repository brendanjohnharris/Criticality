function N = Nint(f, x, dx)
    if (nargin < 3 || isempty(dx)) && length(x) > 2
        dx = [];
    elseif (~isempty(x) && length(x) == 2) && (nargin < 3 || isempty(dx))
        dx = abs(diff(x))/1e-6;
    end
    if length(x) == 2
        x = x(1):dx:x(2);
    end
    
    if ~all(abs(diff(x) - dx) < 1e-9)
        error('The integration x values must be evenly spaced')
    end
    
    y = zeros(length(x), 1);
    try 
        y = f(x);
    catch
        for i = 1:length(x)
            y(i) = f(x(i));
        end
    end
    
    
    
end
