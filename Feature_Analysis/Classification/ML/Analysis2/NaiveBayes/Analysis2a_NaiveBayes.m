function Analysis2a_NaiveBayes(arrayid)
    rng(arrayid)
    home_dir = pwd; 
    cd('~/hctsa_v098')
    startup()
    cd('~/Criticality')
    add_all_subfolders
    cd(home_dir)
    load('../time_series_data.mat')
    [lossmat, fmat, trainlossmat] = sequentialFeaturePerformance(templateNaiveBayes('DistributionNames', 'normal'), time_series_data, 1, 0.9, 4, 0);
    save(sprintf('Analysis2a_NaiveBayes%i.mat', arrayid), 'lossmat', 'fmat', 'trainlossmat')
end