function illustrateNaiveBayes()
    f = figure('Color', 'w');
    ax = gca;
    s = 1.5;
    m = 3;
    x1 = [-4:0.01:8];
    x2 = x1;
    y1 = normpdf(x1,0,1);
    y2 = normpdf(x2,m,s);
    p1 = plot(x1, y1);
    hold on
    xl = x2(find(y2 > y1, 1, 'first'));
    xline(xl, '--k')
    p2 = plot(x2, y2);
    scatter1 = randn(20, 1);
    scatter2 = (randn(20, 1).*s)+m;
    xs = zeros(20, 1);
    plot(scatter1, xs, 'ko', 'markerfacecolor', p1.Color)
     plot(scatter2, xs, 'ko', 'markerfacecolor', p2.Color)
end

