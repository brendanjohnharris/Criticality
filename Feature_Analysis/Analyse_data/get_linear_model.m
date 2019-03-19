function [allb, allRMSE, CP, NOISE, f] = get_linear_model(data, op_id, fixed_noise_gradient)
    if nargin < 2
        op_id = [];
    end
    if nargin < 3
        fixed_noise_gradient = [];
    end
    % Coefficients are returned in the order following:
    %   cp = b_0 + f*b_1 + noise*b_2
    % To plot, use surf(CP, NOISE, (CP - b(1) - NOISE.*b(3))./b(2), 'EdgeColor', 'None'), hold on, surf(CP, NOISE, f)
    idxs = (data(1).Inputs.cp_range >= data(1).Correlation_Range(1) & data(1).Inputs.cp_range <= data(1).Correlation_Range(2))';
    datamat = cat(3, data.TS_DataMat); % Slowest part
    datamat = datamat(idxs, :, :);
    if ~isempty(op_id)
        datamat = datamat(:, op_id, :);
    end
    allb = cell(size(datamat,2), 1);
    allRMSE = allb;
    for n = 1:size(datamat,2)
        f = permute(datamat(:, n, :), [1 3 2]);
        cp = data(1).Inputs.cp_range(idxs); % Assumes control parameter range is constant
        noise = arrayfun(@(x) x.Inputs.eta, data)';
        [CP, NOISE] = ndgrid(cp, noise);
        if ~isempty(fixed_noise_gradient)
            points = [f(:), CP(:) - fixed_noise_gradient.*NOISE(:)];
            X = [ones(size(points, 1), 1), points(:, [1:end-1])];
            b = (X'*X)\X'*points(:, end);
            p = X*b;
            b = [b; fixed_noise_gradient];
        else
            points = [f(:), NOISE(:), CP(:)];
            X = [ones(size(points, 1), 1), points(:, [1:end-1])];
            b = (X'*X)\X'*points(:, end);
            p = X*b;
        end     
        e = p - points(:, end);
        allb{n} = b;
        allRMSE{n} = sqrt(sum(e.^2)./length(e));
    end
    if ~isempty(op_id)
        allb = cell2mat(allb);
        allRMSE = cell2mat(allRMSE);
    else
        CP = [];
        NOISE = [];
        f = [];
    end
end

