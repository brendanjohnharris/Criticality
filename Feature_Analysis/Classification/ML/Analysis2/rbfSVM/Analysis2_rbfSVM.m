function Analysis2_rbfSVM(arrayid)
    rng(arrayid)
    home_dir = pwd; 
    cd('~/hctsa_v098')
    startup()
    cd('~/Criticality')
    add_all_subfolders
    cd(home_dir)
    load('../time_series_data.mat')
    template = templateSVM('KernelFunction', 'rbf', 'KernelScale', 'auto');
    [lossmat, fmat, trainlossmat] = sequentialFeaturePerformance(template, time_series_data, 1, 0.9, 10, 0);
    lossvec = allFeaturePerformance(template, time_series_data, 1, 0.9);
    save(sprintf('Analysis2_LinearSVM%i.mat', arrayid), 'lossmat', 'fmat', 'trainlossmat', 'lossvec')
end