function cellOut = catCellEl(varargin)
%CATCELLEL Concatenate the elements of two or more equally sized cell
%arrays. Provide some cell arrays. If any argument is a number, it
%specifies in which dimension the elements will be concatenated. If any
%argument is a character, it specifies a delimeter for the concatenation of
%character array elements. Be careful when setting the catDir to 1 and using
%character arrays; concatenates, then flattens.
    dirIdxs = cellfun(@(x) isscalar(x) && isnumeric(x), varargin);
    if ~any(dirIdxs)
        catDir = 2; % Concatenate elements horizontally
    else
        catDir = varargin{dirIdxs};
        varargin = varargin(~dirIdxs);
    end
    
    deIdxs = cellfun(@(x) isscalar(x) && ischar(x), varargin);
    if ~any(deIdxs)
        delim = [];
    else
        delim = varargin{deIdxs};
        varargin = varargin(~deIdxs);
    end
    
    cellOut = varargin{1};
    for i = 2:length(varargin)
        cellOut = catEm(cellOut, varargin{i});
    end
    
    function out = catEm(A, B)
        if any(size(A) ~= size(B))
            error('The cell arays being concatenated have different sizes')
        end
        
        if ~isempty(delim)
            out = cellfun(@(X, D, Y) cat(catDir, X, D, Y), A, repmat({delim}, size(A)), B, 'un', 0);
        else
            out = cellfun(@(X, Y) cat(catDir, X, Y), A, B, 'un', 0);
        end
    end
            
end

