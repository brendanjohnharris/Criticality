function wid = NormalWidth(x, y, nrm)
    if size(x, 1) > 2
        x = x';
    end
    if nargin < 2 || isempty(y)
        y = x(2, :);
        x = x(1, :);
    end
    if nargin < 3 || isempty(nrm)
        nrm = 1;
    end
    if size(y, 1) > 2
        y = y';
    end
    themeans = mean([x; y], 1); 
    %wid = std(sign(x - themeans).*sqrt((x - themeans).^2 + (y - themeans).^2));
    %wid = kurtosis(sign(x - themeans).*sqrt((x - themeans).^2 + (y - themeans).^2));
    %wid = 1 - sum((y - x).^2)./sum((y - mean(y)).^2);
    %wid = sum((y - x).^2)./length(x);
    %wid = mean(sqrt((x - themeans).^2 + (y - themeans).^2)./themeans);
    %wid = corr(x', y');

    %wid = std(sign(x - themeans).*sqrt((x - themeans).^2 + (y - themeans).^2))./nrm; % In this case nrm is the std of all residuals
    %wid = sum(abs((x - mean(x)).*(y - mean(y))));
    wid = sum(abs((y - themeans)))./(length(y).*std(y));%corr(x', y');%%

   % p = fitdist((sign(x - themeans).*sqrt((x - themeans).^2 + (y - themeans).^2))', 'Normal');
    %wid = pdf(p, 0);
end

