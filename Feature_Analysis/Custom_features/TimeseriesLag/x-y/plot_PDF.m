function plot_PDF(x)
    samplepoints = linspace(0, max(x), 1000);
    dist = fitdist(x', 'Kernel', 'Kernel', 'Normal');
    f = pdf(dist, samplepoints)';
    
    x1 = x(2:end);
    x0 = x(1:end-1);
    
    plot(samplepoints./std(x1 - x0), f./max(f))
end

