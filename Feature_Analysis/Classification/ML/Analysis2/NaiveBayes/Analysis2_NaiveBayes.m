function Analysis2_NaiveBayes(arrayid)
    rng(arrayid)
    home_dir = pwd; 
    cd('~/hctsa_v098')
    startup()
    cd('~/Criticality')
    add_all_subfolders
    cd(home_dir)
    load('../time_series_data.mat')
    template = templateNaiveBayes('DistributionNames', 'normal');
    [lossmat, fmat, trainlossmat] = sequentialFeaturePerformance(template, time_series_data, 1, 0.9, 4, 0);
    lossvec = allFeaturePerformance(template, time_series_data, 1, 0.9);
    save(sprintf('Analysis2_NaiveBayes%i.mat', arrayid), 'lossmat', 'fmat', 'trainlossmat', 'lossvec')
end