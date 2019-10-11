function [ops, opidxs, mops, mopidxs] = getStandardisedFeatures(ops, mops)
%GETSTANDARDISEDFEATURES Get a list of the standardised features from an
%mop and op table
    if nargin < 2 || isempty(mops)
        mops = SQL_add('mops', 'INP_mops.txt', [], 0);
    end
    if nargin < 1 || isempty(ops)
        ops = SQL_add('ops', 'INP_ops.txt', [], 0);
    end
    %% Look through mops for features that have 'y' as their first input argument
    mopCodestrings = mops.Code;
    mopidxs = ~cellfun(@isempty, regexp(mopCodestrings, '.*(y,.*', 'match'));
    mops = mops(mopidxs, :);
    mopCodestrings = mops.Label;
    
    %% Then match them to operations
    opCodestrings = ops.CodeString;
    opCodestrings = regexprep(opCodestrings, '[.].*', '');
    opidxs = find(ismember(opCodestrings, mopCodestrings));
    ops = ops(opidxs, :);
end

