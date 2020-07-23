function [kin, kout] = nodeDegrees(doBinarize, pThreshold, whatWeightMeasure, workFile)
%MOUSENODEDEGREES 
    if nargin < 1 || isempty(doBinarize)
        doBinarize = true;
    end
    if nargin < 2 || isempty(pThreshold)
        pThreshold = 0.05;
    end
    if nargin < 3 || isempty(whatWeightMeasure)
        whatWeightMeasure = 'NCD';
    end
    if nargin < 4
        workFile = [];
    end
    whatHemispheres = 'right';
    whatData = 'Oh';
    
    [Adj,regionAcronyms,adjPVals] = GiveMeAdj(whatData,pThreshold,doBinarize,...
    whatWeightMeasure,whatHemispheres);

    kin = sum(Adj, 1)';
    kout = sum(Adj, 2);
    ktot = kin + kout;
    
    if ~isempty(workFile)
        data = autoLoad(workFile);
        data = data(~strcmp(data.RegionAcronym, 'SSp-un'), :); % Get rid of the unnassigned primary somatosensory area
        [~, ia] = ismember(data.RegionAcronym, regionAcronyms);
        ia = ia(ia > 0);
        data.kin = kin(ia);
        data.kout = kout(ia);
        data.ktot = ktot(ia); 
        save(workFile, 'data');
    end
end

