function volumes = regionVolumes(workFile)
%REGIONVOLUMES
    data = autoLoad(workFile);
    data = data(~strcmp(data.RegionAcronym, 'SSp-un'), :); % Get rid of the unnassigned primary somatosensory area
    [regionAcronyms, ~, ia] = unique(data.RegionAcronym);
    volumes = GetROIVolumes(regionAcronyms);
    data.RegionVolume = volumes(ia); 
    save(workFile, 'data');
end

