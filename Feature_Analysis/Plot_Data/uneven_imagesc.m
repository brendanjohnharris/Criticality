function uneven_imagesc(x, y, C, xory)
%UNEVEN_IMAGESC Use imagesc with a matrix that is not evenly sampled over the bounds of
% x OR y
    if strcmp(xory, 'x')
        inds = [x(:), y(:)];
    elseif strcmp(xory, 'y')
        inds = [y(:), x(:)];
    end
    
    for i = 1:size(inds, 1)
        
end

