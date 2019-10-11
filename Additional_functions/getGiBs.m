function gibs = getGiBs(varargin)
    if ~all(cellfun(@ischar, varargin))
        varargin = horzcat(varargin{:});
    end
    gibs = zeros(1, length(varargin));
    for i = 1:length(varargin)
        bs = evalin('caller', sprintf('whos(''%s'')', varargin{i}));
        gibs(i) = bs.bytes;
    end
    gibs = sum(gibs)./2^30;
end
