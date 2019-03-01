function exsect_file(lines, file_in, file_out)
    if nargin < 3 || isempty(file_out)
        response = input('No output file is provided, so the input file will be overwritten. Press [y] to continue:');
        if ~strcmp('y', response)
            return
        else
            file_out = file_in;
        end
    end
    f = fopen(file_in);
    line_cell = textscan(f,'%s','Delimiter','\n');
    line_cell = line_cell{1};
    line_cell = line_cell(lines);
    out_f = fopen(file_out, 'w');
    fprintf(out_f,'%s\n',line_cell{:});
    fclose('all');
end

