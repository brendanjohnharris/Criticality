function test_CO_Embed(x)
    figure, hold on
    xt = x(1:end
    for i = 1:size(x, 1)
        u = [];
        for t = 1:10
            u(t) = sum(
        u = [res.incircle_01, res.incircle_02, res.incircle_05, res.incircle_1, res.incircle_2, res.incircle_3];
        v = [0.1, 0.2, 0.5, 1, 2, 3];
        plot(v, u, '-o')
    end
end

