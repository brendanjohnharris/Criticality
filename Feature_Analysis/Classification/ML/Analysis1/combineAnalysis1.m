function [outlossmat, outfmat, outtrainlossmat, outlossvec] = combineAnalysis1(filestem)
%COMBINEANALYSIS2 
    outoperations = [];
    outlossmat = [];
    outshuffleoperations = [];
    outshufflelossmat = [];
    files = dir([filestem, '*.mat']);
    for i = 1:length(files)
        load(files(i).name, 'operations', 'lossmat', 'shuffleoperations', 'shufflelossmat')
        outoperations = [outoperations, operations.Mean_Loss]; % Assume the IDs are all in the same order, which they should be
        outlossmat = [outlossmat, lossmat];
        outshuffleoperations = [outshuffleoperations, shuffleoperations.Mean_Loss];
        outshufflelossmat = [outshufflelossmat, shufflelossmat];
    end
    operations.Mean_Loss = nanmean(outoperations, 2);
    lossmat = outlossmat;
    shuffleoperations.Mean_Loss = nanmean(outshuffleoperations, 2);
    shufflelossmat = outshufflelossmat;
    if ~ismember({files.name}, [filestem, '.mat'])
        save([filestem, '.mat'], 'operations', 'lossmat', 'shuffleoperations', 'shufflelossmat')
    else
        error([filestem, '.mat already exists'])
    end
end

