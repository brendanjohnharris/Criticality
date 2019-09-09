function y = updowns(x)
    y =  BF_Binarize(x, 'diff');
    y(y == 0) = -1;
    y = cumsum(y);
end

