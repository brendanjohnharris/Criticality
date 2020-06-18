function [ax, Xv, Yv] = ribbon(data, alpha, color, ax, ser)
%RIBBON 
    if iscell(data) && length(data) == 1
        data = {data{1}, data{1}};
    elseif isvector(data) || isscalar(data)
        data = {data, data};
    elseif length(data) > 2
        error('Cannot plot a three dimensional ribbon!')
    end
    if length(data{1}) ~= length(data{2})
        error('The size of the ribbon data does not match')
    end
    if nargin < 2 || isempty(alpha)
        alpha = 0.3;
    end
    if nargin < 3
        color = [];
    end
    if nargin < 4 || isempty(ax)
        ax = gca;
    end
    if nargin < 5 || isempty(ser)
        nogood = 0;
        if length(data{1}) == 1 
            ser = ax.Children(end);
        else
            nogood = 1;
            for i = length(ax.Children):-1:1
                if length(ax.Children(i).YData) == length(data{1}) 
                    ser = ax.Children(i);
                    nogood = 0;
                end
            end
        end
        if nogood
            error('Could not find a valid series')
        end
    end
    hold on
    if isscalar(data{1})
        data{1} = repmat(data{1}, 1, length(ser.YData));
    end
    if isscalar(data{2})
        data{2} = repmat(data{2}, 1, length(ser.YData));
    end
    Xdata = ser.XData(:);
    Ydata = ser.YData(:);
    Ymin = Ydata - data{1}(:);
    Ymax = Ydata(end:-1:1) + flipud(data{2}(:));
    if isempty(color)
        try 
            color = ser.Color;
        catch
            warning('No colour found; picking grey')
            color = [0.5, 0.5, 0.5];
        end
    end
    Xv = [Xdata; Xdata(end:-1:1); Xdata(1)]';
    Yv = [Ymin; Ymax; Ymin(1)]';
    p = patch(Xv, Yv, color, 'FaceAlpha', alpha, 'EdgeColor', 'none');
    uistack(p, 'down')
end

