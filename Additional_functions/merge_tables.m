function merged_table = merge_tables(tables, table_names)
%MERGE_TABLES Merge tables of the same height column-wise
%
%   If two or more columns have both the same name and the same entries one will be
%   discarded
%   If two or more columns have the same name but different entries, both will
%   remain but will be named individually.
%   Columns that appear once will be tagged witht he name fo the table they
%   originated from
%
%   tables:         A cell array containing all of the tables that will be
%                   joined merged
%
%   table_names:    A cell array of character vectors containing the names
%                   of each table, appended to any duplicated column names.
%                   The names should be in the same order as the tables are
%                   given.
%
    numtables = length(tables);
    if ~isempty(table_names) && length(table_names) ~= numtables
        error('The number of named tables does not match the number of tables given')
    end
    a = tables{1};
    for t = 1:numtables-1
        b = tables{t+1};
        [common_vars, ia, ib] = intersect(a.Properties.VariableNames, b.Properties.VariableNames);
        equal_common_vars = common_vars(arrayfun(@(x) isequal(sortrows(a(:, ia(x))), sortrows(b(:, ib(x)))), 1:length(common_vars)));
        a_idxs = ~ismember(a.Properties.VariableNames, equal_common_vars);
        a.Properties.VariableNames(a_idxs) = strcat([table_names{t}], a.Properties.VariableNames(a_idxs));
        b_idxs = ~ismember(b.Properties.VariableNames, equal_common_vars);
        b.Properties.VariableNames(b_idxs) = strcat([table_names{t+1}], b.Properties.VariableNames(b_idxs));
        %b = b(:, (~ismember(b.Properties.VariableNames, equal_common_vars)|ismember(b.Properties.VariableNames, keyvar)));
        a = join(a, b, 'Keys', equal_common_vars); 
        table_names{t+1} = [];
    end
    merged_table = a;
end

