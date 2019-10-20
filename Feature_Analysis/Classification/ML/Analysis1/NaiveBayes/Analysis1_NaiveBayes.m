function Analysis1_NaiveBayes(arrayid)
    rng(arrayid)
    home_dir = pwd; 
    cd('~/hctsa_v098')
    startup()
    cd('~/Criticality')
    add_all_subfolders
    cd(home_dir)
    load('../time_series_data.mat')
    template = templateNaiveBayes('DistributionNames', 'normal');
    [operations, lossmat] = FeatureWisePerformance(template, time_series_data, 1, 0.9, 0); 
    
    load('../shuffled_time_series_data.mat')
    [shuffleoperations, shufflelossmat] = FeatureWisePerformance(template, time_series_data, 1, 0.9, 0); 
    
    save(sprintf('Analysis1_NaiveBayes%i.mat', arrayid), 'operations', 'lossmat', 'shuffleoperations', 'shufflelossmat')
end