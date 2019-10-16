function Analysis1_LinearSVM(arrayid)
    rng(arrayid)
    home_dir = pwd; 
    cd('~/hctsa_v098')
    startup()
    cd('~/Criticality')
    add_all_subfolders
    cd(home_dir)
    load('../time_series_data.mat')
    template = templateSVM('KernelFunction', 'linear');
    [operations, lossmat] = FeatureWisePerformance(template, time_series_data, 1, 0.9, 1); 
    
    load('../shuffled_time_series_data.mat')
    [shuffleoperations, shufflelossmat] = FeatureWisePerformance(template, time_series_data, 1, 0.9, 1); 
    
    save('Analysis1_LinearSVM.mat', 'operations', 'lossmat', 'shuffleoperations', 'shufflelossmat')
    save(sprintf('Analysis2_LinearSVM%i.mat', arrayid), 'lossmat', 'fmat', 'trainlossmat', 'lossvec')
end