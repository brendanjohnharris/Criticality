function disp(X)
    builtin('disp', X)
    whichOne = reWriter.setgetWhichOne;
    whichOne(1) = 0; % None
    reWriter.setgetWhichOne(whichOne);
end