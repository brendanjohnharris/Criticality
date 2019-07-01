function fval = SD_scaled_maxmin(x, wn, at0)
%SD_SCALED_MAXMIN Scale by SD (dont centre at mean) and then fin the
%difference between maximum and minimum values. Option to have minimum at 0
    y = x./std(x);
    if at0
        y = y - min(y);
    end
    wl = floor(length(y)/wn);
    yb = buffer(y, wl);
    if yb(end) == 0
        yb = yb(:, 1:end-1);
    end
    maxvec = max(yb, [], 1);
    minvec = min(yb, [], 1);
    fval = mean(maxvec - minvec);
end

