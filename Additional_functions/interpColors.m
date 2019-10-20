function colormap = interpColors(color1, color2, N)
%INTERPCOLORS Give two colours, and this function will produce a colourmap
%by linearly interpolating between them.
colormap = interp1([1, N], [color1(:)'; color2(:)'], 1:N, 'linear');
end

