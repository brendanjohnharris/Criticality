function averageSubject(workFile)
%averageSubject
    data = autoLoad(workFile);
    
    regionIDs = unique(data.regionID);
    
    newdata = table();
    
    for ri = 1:length(regionIDs)
        r = regionIDs(ri);
        subtbl = data(data.regionID == r, :);
        singlesubtbl = subtbl(1, :);
        % Assume the first 6 columns are the same accross subjects
        singlesubtbl{1, 7:end} = mean(subtbl{:, 7:end}, 1);
        newdata(end+1, :) = singlesubtbl;
    end
    data = removevars(newdata, 'subjectID');
    save(workFile, 'data');
end

