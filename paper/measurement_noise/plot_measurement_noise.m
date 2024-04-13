% metas = 0.1:0.1:3;
% system = 'supercritical_hopf_radius_(snr)';

metas = 0:0.01:0.3;
system = 'supercritical_hopf_radius_(dnm)';

%% First load the data for each measurement noise, meta
D = {};

for m = metas
    load(fullfile("./Data/", system, string(m), "time_series_data.mat"), '')
    D{end+1} = cat(3, time_series_data.TS_DataMat);
end
mus = time_series_data(1, :).Inputs.cp_range;
etas = arrayfun(@(x) x.Inputs.eta, time_series_data)';
fs = time_series_data(1, :).Operations;
D = cat(4, D{:});
D = permute(D, [2, 1, 3, 4]);
dims = ["f", "mu", "eta", "meta"];

%% Plot mu-F scatters for different values of meta
mm = [metas(1), metas(3), metas(6), metas(9)];
eis = 1:5:size(D, 3);
cmp = inferno(length(eis));
for mi = 1:length(mm)
    m = mm(mi);
    f = figure();
    ft = 3; % AC1
  
    ax = axes(f);
    hold on
    setas = etas(eis);
    for ei = 1:length(setas)
        e = setas(ei);
        plot(mus, squeeze(D(ft, :, etas==e, metas==m)), 'Color', cmp(ei, :))
    end
    ax.Title.String=string(m);
end

%%
i = 22;
eidxs = 20:length(etas);
dd = squeeze(D(3, :, eidxs, i));
% [xk,yk] = meshgrid(-3:3);
% K = exp(-(xk.^2 + yk.^2)/10); K = K/sum(K(:));
% dd = conv2(dd,K,'same');
[y, x] = meshgrid(etas(eidxs), mus);
surf(x, y, dd, 'EdgeAlpha', 0.5)
hold on
light 
light('position', [-1 -1 0])
lighting gouraud 
material shiny 
xlabel mu
ylabel eta
zlabel AC
title(metas(i))
% zlim([0, 1])
% set(gca,'Ydir','reverse')
hold off
% contour(dd)


%% Plot a mu-F scatter with variable measurement noise and variable dynamical noise
if false
    ff = 4;
    mmetas = [5, 5, 1, 1];
    eetas = [0.01, 1, 0.01, 1];
    
    
    f = figure();
    ax = axes(f);
    cmap = inferno();
    cmap = cmap([1, 100, 150, 200], :);
    hold on
    X = D(ff, :, arrayfun(@(x) find(etas == x), eetas), arrayfun(@(x) find(metas == x), mmetas));
    ax.YLabel.String = strrep(fs(ff, :).Name, "_", "\_");
    
    for i = 1:length(mmetas)
        cc = cmap(i, :)';
        mm = mmetas(i);
        ee = eetas(i);
        plot(mus, squeeze(X(1, :,i, i)), '.-', color=cc, markersize=10, linewidth=1)
    end
    
    X = D(ff, :, :, :);
    Y = squeeze(reshape(X, 1, 101, [], 1));
    cmus = repmat(mus', length(metas)*length(etas), 1);
    c = corr(cmus, Y(:), 'Type', 'Spearman');
    ax.Title.String = sprintf("$$\\rho = %.3g$$", c);
    ax.Title.Interpreter = "LaTeX";
    f.Color = 'w';
    
    colormap(cmap);
    imagesc([1, 100, 150, 200], 'Visible', 0);
    C = colorbar(ax);
    C.Ticks = 0.125:0.25:1;
    C.TickLabels = arrayfun(@(i) sprintf("$$\\eta=%.2g\\quad \\xi=%.2g$$", ...
        eetas(i), mmetas(i)), 1:length(mmetas));
    C.TickLabelInterpreter = "LaTeX";
    ax.XLabel.String = "$$\mu$$";
    ax.XLabel.Interpreter = "LaTeX";
    f.PaperPosition = [0 0 15 10];
    ax.Box = 1;
    
    saveas(f, sprintf("%s.svg", fs(ff, :).Name{1}))
end

%%
eidxs = 20:length(etas);
features = [1, 3, 4];
for fi = 1:length(features)
    f = features(fi);
    rho = [];
    for mi = 1:length(metas)
        d = squeeze(D(f, :, eidxs, mi));
        cmus = repmat(mus', 1, size(d, 2));
        rho(end+1) = corr(d(:), cmus(:), 'Type', 'Spearman');
    end
    rhos{fi} = rho;
end
f = figure('color', 'w');
ax = axes(f);
hold on
plot(ax, metas, rhos{3}, 'linewidth', 2)
plot(ax, metas, rhos{2}, 'linewidth', 2)
plot(ax, metas, rhos{1}, 'color', 'k', 'linewidth', 2)
ax.XLabel.String = "$$\chi$$";
ax.XLabel.Interpreter = "LaTeX";
ax.YLabel.String = "$$\rho^\textrm{var}_\mu$$";
ax.YLabel.Interpreter = "LaTeX";
f.PaperPosition = [0 0 10 8];
ax.Box = 1;
ax.YLim = [0, 1];
L = legend(ax, {'Standard deviation', 'AC\_1', 'RAD'}, 'Location', 'northwest');
L.ItemTokenSize = [15, 18];

saveas(f, "noisecomparison.svg")

