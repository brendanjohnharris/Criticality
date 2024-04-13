function tbl = load18SubjfMRI()
%LOAD18SUBJFMRI Load data for the 18mice rs-fMRI dataset from the current directory
    thisDir = strrep(which(mfilename), [mfilename, '.m'], '');
    loadfileName = fullfile(thisDir, 'TS_Netmats_Matrix_corrected.mat');
    savefileName = fullfile(thisDir, [mfilename, '.mat']);
    structInfo = load(fullfile(thisDir, '18subj_joinedStructInfo.mat'), 'joinedStructInfo');
    structInfo = structInfo.joinedStructInfo;
    % The timeseries are already in standard hctsa format but with a
    % different ordering and labelling. See INP_rsfMRI.mat
    
    if isfile(savefileName)
        load(savefileName)
        return
    end
    %% Load and reshape timeseries    
    % The timeseries are in a struct called ts, see TS_Netmats_Matrix_corrected.mat

    load(loadfileName);
    timeSeriesData = reshape(ts.ts, ts.NtimepointsPerSubject, ts.Nsubjects.*ts.Nnodes)'; 

    % timeSeriesData is arrranged so that consecutive rows have data for
    % consecutive subjects (for the same region), and these blocks repeat
    % for each region. This assumes that the data in each column of ts is
    % neatly ordered by subject 'number'.


%% Construct labels
    for rID = 1:ts.Nnodes 
        for sID = 1:ts.Nsubjects
            subjectID((rID-1).*ts.Nsubjects + sID) = sID; 
            regionID((rID-1).*ts.Nsubjects + sID) = rID;
        end
    end
    % Labels are "subjectID|regionID"; arbitrary numbers to keep track of their order

%% Construct keywords   
    RegionName = arrayfun(@(x) structInfo.REGION{mod(x-1, height(structInfo))+1},...
        reshape(repmat(1:ts.Nnodes, ts.Nsubjects, 1), 1, []), 'UniformOutput', 0)'; 
    % Make keywords the region names. structInfo only has labels for 
    % one hemisphere, so duplicate keywords. This assumes that the rows
    % of structInfo are in the same order as the trimeseries

%% Remove the left hemisphere (first half of ts columns)
    filteridxs = reshape(repmat(1:ts.Nnodes, ts.Nsubjects, 1), 1, []) > ts.Nnodes./2;
    subjectID = subjectID(filteridxs)';
    regionID = regionID(filteridxs)' - min(regionID(filteridxs)) + 1;
    RegionName = RegionName(filteridxs);
    timeSeriesData = timeSeriesData(filteridxs, :);
    
    
%% Adjust    
    % Construct labels; "subjectID|regionID"
    %for i = 1:length(labels)
    %    labels{i} = ['SubjectID,', num2str(subjectID(i)), ',', 'RegionID,', num2str(regionID(i))];
    %end
    [~, structidxs] = sort(structInfo.regionID);
    % So, it is assumed the structInfo region ids correspond to the increasing regions in ts
    structInfo = structInfo(structidxs, :);
    RegionAcronym = structInfo.acronym(regionID); 
    RegionColor = structInfo.color_hex_triplet(regionID); 
    RegionDivision = structInfo.divisionLabel(regionID); 
    tbl = table(timeSeriesData, subjectID, regionID,...
                        RegionName, RegionAcronym, RegionColor, RegionDivision);
    save(savefileName, 'tbl',  '-v7.3')
end

