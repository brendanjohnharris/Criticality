function points = cartesian_product(varargin)
%CARTESIAN_PRODUCT Compute the cartesian product of any number of vectors
%   The cartesian product of two sets, for two sets/vectors, is the set
%   containing all possible ordered pairs with one element from each
%   corresponding set. 
%   This function extends this notion to N vectors, such that (a x b x c) is
%   the cartesian product (a x b) x c, with grouping parentheses
%   removed.
%
%   Inputs-
%       varargin: Any number of vectors (specified individually or as a cell array), or a single matrix (where each column
%       represents a vector)

%% Ensure all inputs are column vectors
    try
        if length(varargin) == 1 && ~iscell(varargin{1})% The input is a matrix
            vecs = num2cell(varargin{1}, 1);
        elseif length(varargin) == 1 && iscell(varargin{1})
            vecs = cellfun(@(x) x(:), varargin{1}, 'uniformoutput', 0);
        else
            vecs = cellfun(@(x) x(:), varargin, 'uniformoutput', 0);
        end
    catch
        error('Bad Inputs')
    end
    N = length(vecs);
    [vecgrid{1:N}] = ndgrid(vecs{:});
    points = arrayfun(@(x) vecgrid{x}(:), (1:N), 'UniformOutput', 0);
    points = cell2mat(points);
    points = unique(points, 'rows');
end
