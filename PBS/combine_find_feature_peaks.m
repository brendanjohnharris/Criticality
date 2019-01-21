function combine_feature_peak_results(file_prefix)
    if nargin < 1 || isempty(file_prefix)
        file_prefix = 'res';
    end
    files = dir;
    matching_files = regexp({files.name}, [file_prefix, '\d+[.]mat'], 'match');
    matching_files = matching_files(~cellfun(@isempty,matching_files));
    matching_files = cellfun(@(x) x{1}, matching_files, 'UniformOutput', false);
    matching_file_nums = cellfun(@str2num, cellfun(@(x) x{1}, regexp(matching_files, ...
        ['(?<=', file_prefix, ')\d+(?=[.]mat)'], 'match'), 'UniformOutput', false));
    [matching_file_nums, idxs] = sort(matching_file_nums);
    matching_files = matching_files(idxs); % Files now sorted by their number
    c = struct('etarange', [], 'peakparameters', [], 'peakvals', [], 'time', 0, 'op_table', []);
    for i = 1:length(matching_file_nums)
        ind = matching_file_nums(i);
        load([file_prefix, num2str(ind), '.mat'])
        c.etarange = [c.etarange, etarange];
        c.peakparameters = [c.peakparameters; peakparameters];
        c.peakvals = [c.peakvals; peakvals];
        c.time = c.time + time;
    end
    c.op_table = op_table; % Should be the same in all parts
    save('combined_results.mat', '-struct', 'c')
end

