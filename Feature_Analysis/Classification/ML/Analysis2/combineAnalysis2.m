function [outlossmat, outfmat, outtrainlossmat, outlossvec] = combineAnalysis2(filestem)
%COMBINEANALYSIS2 
    outlossmat = [];
    outfmat = [];
    outtrainlossmat = [];
    outlossvec = [];
    files = dir([filestem, '*.mat']);
    for i = 1:length(files)
        load(files(i).name, 'lossmat', 'fmat', 'trainlossmat', 'lossvec')
        outlossmat = [outlossmat, lossmat];
        outfmat = [outfmat, fmat];
        outtrainlossmat = [outtrainlossmat, trainlossmat];
        outlossvec = [outlossvec, lossvec];
    end
    lossmat = outlossmat;
    fmat = outfmat;
    trainlossmat = outtrainlossmat;
    lossvec = outlossvec;
    if ~ismember({files.name}, [filestem, '.mat'])
        save([filestem, '.mat'], 'lossmat', 'fmat', 'trainlossmat', 'lossvec')
    else
        error([filestem, '.mat already exists'])
    end
end

