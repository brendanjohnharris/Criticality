function drawnow(varargin)
    builtin('drawnow', varargin{:})
    %Frame = cameraman.setgetFrame;
    %cameraman.setgetFrame(Frame+1);
    notify(gcf, 'ButtonDown')
end