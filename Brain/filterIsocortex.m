function filterIsocortex(workFile)
%FILTERISOCORTEX
    data = autoLoad(workFile);
    
    
    idxs = strcmp(data.RegionDivision, 'Isocortex');
    
    data = data(idxs, :);
    
    save(workFile, 'data');
end

