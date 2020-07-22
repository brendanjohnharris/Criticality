function slra = cellsqueeze(slra)
% CELLSQUEEZE Remove elements of a cell array that are empty and raise any
% 1x1 cell elements.
% If slra is multidimensional, it will be flattened by concatenating its
% columns.
    slra = slra(:);
    fullinds = ~cellfun(@isempty, slra);
    slra = slra(fullinds);
    deepinds = cellfun(@(x) numel(x) == 1 && iscell(x), slra);
    slra(deepinds) = cellfun(@(x) x{1}, slra(deepinds), 'uniformoutput', 0);
    
    while prod(size(slra)) == 1 && iscell(slra)
    	slra = slra{1};
    end
end

