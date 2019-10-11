function [outlossmat, outfmat, outtrainlossmat] = combineAnalysis2(filestem)
%COMBINEANALYSIS2 
    outlossmat = [];
    outfmat = [];
    outtrainlossmat = [];
    files = dir([filestem, '*.mat']);
    for i = 1:length(files)
        load(files(i).name, 'lossmat', 'fmat', 'trainlossmat')
        outlossmat = [outlossmat, lossmat];
        outfmat = [outfmat, fmat];
        outtrainlossmat = [outtrainlossmat, trainlossmat];
    end
    lossmat = outlossmat;
    fmat = outfmat;
    trainlossmat = outtrainlossmat;
    if ~ismember({files.name}, [filestem, '.mat'])
        save([filestem, '.mat'], 'lossmat', 'fmat', 'trainlossmat')
    else
        error([filestem, '.mat already exists'])
    end
end

