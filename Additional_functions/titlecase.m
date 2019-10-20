function str = titlecase(str, unpack)
%https://au.mathworks.com/matlabcentral/answers/107307-function-to-capitalize-first-letter-in-each-word-in-string-but-forces-all-other-letters-to-be-lowerc
    if nargin < 2 || isempty(unpack)
        unpack = 0;
    end
    if isstring(str) || ischar(str)
        str = {str};
        unpack = 1;
    end
    for i = 1:length(str)
        substr = str{i};
        idx = regexp([' ' substr],'(?<=\s+)\S','start')-1;
        substr(idx) = upper(substr(idx));
        str{i} = substr;
    end
    if unpack
        str = [str{:}];
    end
end