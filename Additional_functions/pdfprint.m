function pdfprint(varargin)
% PDFPRINT Save a figure. Intended to fix issues with 'print' and pdf files. 
% Same arguments as print. Of course, it works with other file formats as well.
    warning('off', 'MATLAB:print:FigureTooLargeForPage')
    h = gcf;
    set(h,'Units','Centimeters');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Centimeters','PaperSize',[pos(3), pos(4)])
    print(varargin{:})
    warning('on', 'MATLAB:print:FigureTooLargeForPage')
end

