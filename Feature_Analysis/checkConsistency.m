function [res, detres] = checkConsistency(data)
%CHECKCONSISTENCY Check that a data struct is consistent i.e. all rows have
%the same control parameter range and the same operations in the same order
%with the same names. res is a logical; passed or failed. detres gives more
%detail about which checks failed (order: cp_range, opids, opnames)
    checkcell{1} = arrayfun(@(x) x.Inputs.cp_range, data, 'un', 0);
    checkcell{2} = arrayfun(@(x) x.Operations.ID, data, 'un', 0);
    checkcell{3} = arrayfun(@(x) x.Operations.Name, data, 'un', 0);
    res = 1;
    for i = 1:length(checkcell)
        detres(i) = cellElementComparison(checkcell{i});
        res = detres(i).*res;
    end 
    function cres = cellElementComparison(slra)
        cres = all(cellfun(@(x) isequal(slra{1}, x), slra));
    end
end

