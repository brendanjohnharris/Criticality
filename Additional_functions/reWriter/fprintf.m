function fprintf(varargin)
    builtin('fprintf', varargin{:});
    whichOne = reWriter.setgetWhichOne;
    whichOne(1) = 0; % None
    reWriter.setgetWhichOne(whichOne);
end