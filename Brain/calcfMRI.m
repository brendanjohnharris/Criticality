function data = calcfMRI(feature, subfeature, workFile, params)
%CALCFMRI Evaluate a feature on resting state mice fMRI scans
% Give one or more 'feature's (referring to a timeseries 'x') and (if
% required) any 'subfeature's as strings in cell arrays.
    if nargin < 2
        subfeature = [];
    end
    if nargin < 3
        workFile = [];
    end
    if nargin < 4
        params = [];
    end
    
    if isempty(workFile)
        data = autoLoad('../test/Data/100SubjfMRI/');
    else
        data = autoLoad(workFile);
    end
    
    fvals = nan(height(data), 1);
    
    vWriter = reWriter();
    start = tic;
    
    if ~isempty(params)
        newfs = {};
        newsubfs = {};
        for f = 1:length(feature)
            slra = arrayfun(@(x) strrep(feature{f}, 'params', num2str(x)), params, 'un', 0);;
            newfs(end+1:end+length(params)) = slra;
            newsubfs(end+1:end+length(params)) = repmat(subfeature(f), 1, length(slra));
        end
        feature = newfs;
        subfeature = newsubfs;
    end
    
    for v = 1:height(data)
        for f = 1:length(feature)
            x = data(v, :).timeSeriesData; % feature should look like 'mean(x)'
            res = eval(feature{f});
            if ~isempty(subfeature) && ~isempty(subfeature{f})
                fvals(v, f) = res.(subfeature{f});
            else
                fvals(v, f) = res;
            end
        end
        reWrite(vWriter, '--------------- %g%% complete, %gs elapsed ---------------\n',...
            round(100*(v)./height(data)), round(toc(start)));
    end
    
    for f = 1:length(feature)
        feature = regexprep(feature, '\(', '');
        feature = regexprep(feature, '\)', '');
        feature = regexprep(feature, ',', '');
        feature = regexprep(feature, '\s', '');
        feature = regexprep(feature, "\'", '');
        feature = regexprep(feature, '\"', '');
        if ~isempty(subfeature) && ~isempty(subfeature{f})
            data.(genvarname([feature{f}, subfeature{f}])) = fvals(:, f);
        else
            data.(genvarname(feature{f})) = fvals(:, f);
        end
    end
    if ~isempty(workFile)
        data = removevars(data, 'timeSeriesData');
        save(workFile, 'data')
    end
end