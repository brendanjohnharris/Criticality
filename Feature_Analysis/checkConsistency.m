function [res, detres] = checkConsistency(data, checkWhat)
%CHECKCONSISTENCY Check that a data struct is consistent i.e. all rows have
%the same control parameter range and the same operations in the same order
%with the same names. res is a logical; passed or failed. detres gives more
%detail about which checks failed (order: cp_range, opids, opnames)
% checkWhat is a vector; what checks to perform to give res
    checkcell{1} = arrayfun(@(x) x.Inputs.cp_range, data, 'un', 0);
    checkcell{2} = arrayfun(@(x) x.Operations.ID, data, 'un', 0);
    checkcell{3} = arrayfun(@(x) x.Operations.Name, data, 'un', 0);
    if nargin < 2 || isempty(checkWhat)
        checkWhat = 1:length(checkcell);
    end
    if length(checkWhat) == length(checkcell) % In this case either all of the indices are supplied or a binary vector was given
        checkWhat = logical(checkWhat);
    end
    for i = 1:length(checkcell)
        detres(i) = cellElementComparison(checkcell{i});
    end 
    res = all(detres(checkWhat));
    
    function cres = cellElementComparison(slra)
        cres = all(cellfun(@(x) isequal(slra{1}, x), slra));
    end
end

