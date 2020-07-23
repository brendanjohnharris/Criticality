function varargout = autoLoad(filePath)
%AUTOLOAD Sick of organising load functions in the main project code. So,
% every new dataset can get its own adjacent load file, and this one
% function will recognise and run such load files (given a path). Don't
% have conflicting load functions in the same directory (if you do then only one
% will be used). This should also help make datasets more portable.
    if nargin < 1 || isempty(filePath)
        filePath = pwd;
    end
    if strcmp(filePath(end-3:end), '.mat') % You just want to load all variables from a file
        fout = load(filePath);
        outNames = fieldnames(fout);
        fout = cellfun(@(x) fout.(x), outNames, 'UniformOutput', 0);
    else
        funcs = dir(filePath);
        funcs = {funcs(~cellfun(@isempty, regexp({funcs.name}, '.*\.m$', 'match'))).name};
        fout = [];
        notPath = 0;
        % Check if filePath is on matlab path
        if ~sum(~cellfun(@isempty, regexp(strsplit(path(), ';'), strrep(['^(', filePath, ')$'], '\', '\\'), 'match')))
            notPath = 1;
            p = what(filePath);
            addpath(p.path); 
            % This is now at the top of the search path, so it supercedes any other functions with the same name
        end
        for fi = 1:length(funcs)
            f = funcs{fi};
            f = strrep(f, '.m', '');
            try
                [fout{1:nargout(f)}] = feval(f);
                % For when the load function doesn't take a file path as an input
                break
            catch
                try
                    [fout{1:nargout(f)}] = feval(f, filePath);
                    % And for when it does
                    break
                catch
                end
            end
        end
        if notPath
            rmpath(p.path);
        end
        if isempty(fout)
            error('No valid, or functional, load file found')
        end
    end
    varargout = fout;
    if nargout <= 1 && length(fout) > 1 % You don't know how many arguments to expect, so give them all as a cell
        if ~strcmp(filePath(end-3:end), '.mat')
            fid = fopen([f, '.m']);
            outNames = fgetl(fid);
            fclose(fid);
            outNames = regexp(outNames, '(?<=\[).*(?=\])', 'match');
            outNames = regexprep(outNames, '\s', '');
            outNames = strsplit(outNames{1}, ',');
        end
        varargout = {cell2table(fout', 'VariableNames', outNames)};
    end
end

