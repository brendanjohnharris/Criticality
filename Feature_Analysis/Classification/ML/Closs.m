function theloss = Closs(templateORmdl, data, testdata, useGPU)
%CLOSS 
    if nargin < 4 || isempty(useGPU)
        useGPU = 0;
    end
    if isa(templateORmdl, 'classreg.learning.FitTemplate') && nargin == 3 && ~isempty(data1) && ~isempty(data2)
        mdl = Ctrain(templateORmdl, data, useGPU);
    elseif nargin == 2 && ~isempty(data)
        % The first argument should be a model, and data is actually the
        % test data
        mdl = templateORmdl;
        testdata = data;
    else
        error('Incorrectly formatted input arguments')
    end
    
    [X, Y] = reconstructDataMat(testdata);
    
    theloss = loss(mdl, X, Y);
end

