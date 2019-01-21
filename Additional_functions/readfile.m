function data=readfile(filename)
%Read a UTF8 or ANSI (US-ASCII) file
%
% Syntax:
%    data=readfile(filename)
%    filename: char array with either relative or absolute path
%    data: n-by-1 cell (1 cell per line in the file, even empty lines)
%
% This function is aimed at providing a reliable method of reading a file.
% The backbone of this function is the fileread function. Further
% processing is done to attempt to detect if the file is UTF8 or not, apply
% the transcoding and returning the file as an 1-by-n cell array for files
% with n lines.
%
% On ML6.5, this function can't read ANSI file with chars greater than 255.
% Octave can't handle those characters for ANSI or UTF8. In the case of
% Octave they are likely converted to 0, while on ML6.5 the output is
% impracticable.
%
% The test for being UTF8 can fail. For files with chars in the 128:255
% range, the test will often determine the encoding correctly, but it might
% fail.
%
% Compatibility:
% Matlab: should work on most releases (tested on R2018a(x64), R2015b(x32),
%         R2012b(x64), and R6.5)
% Octave: tested on 4.2.1
% OS:     Matlab tested on Windows 10 (32bit and 64bit).
%         Octave tested  on Windows 10 (32bit and 64bit) and on a virtual
%         Ubuntu 16.04 LTS (32bit).
%         Should work for Mac.
%
% Version: 1.0
% Date:    2018-09-11
% Author:  H.J. Wisselink
% Email=  'h_j_wisselink*alumnus_utwente_nl';
% Real_email = regexprep(Email,{'*','_'},{'@','.'})

% Tested with 2 files with the following chars:
% list_of_chars_file1=[...
%     0032 0033 0034 0035 0037 0039 0040 0041 0042 0044 0045 0046 0047 ...
%     0048 0049 0050 0051 0052 0053 0054 0055 0056 0057 0058 0059 0061 ...
%     0063 0065 0066 0067 0068 0069 0070 0071 0072 0073 0074 0075 0076 ...
%     0077 0078 0079 0080 0081 0082 0083 0084 0085 0086 0087 0088 0089 ...
%     0090 0091 0093 0096 0097 0098 0099 0100 0101 0102 0103 0104 0105 ...
%     0106 0107 0108 0109 0110 0111 0112 0113 0114 0115 0116 0117 0118 ...
%     0119 0120 0121 0122 0160 0171 0173 0183 0187 0188 0189 0191 0192 ...
%     0193 0196 0200 0201 0202 0203 0205 0207 0209 0211 0212 0218 0224 ...
%     0225 0226 0228 0230 0231 0232 0233 0234 0235 0237 0238 0239 0241 ...
%     0242 0243 0244 0246 0249 0250 0251 0252 0253 8211 8212 8216 8217 ...
%     8218 8220 8221 8222 8226 8230];
% list_of_chars_file2=[32:126 160:255 32 32 32];

%#dependencies{UTF8_to_str,ThrowErrorIfNotUTF8file}

persistent CPwin2UTF8 origin target legacy isOctave v
if isempty(CPwin2UTF8)
    CPwin2UTF8=[338 140;339 156;352 138;353 154;376 159;381 142;382 158;...
        402 131;710 136;732 152;8211 150;8212 151;8216 145;8217 146;...
        8218 130;8220 147;8221 148;8222 132;8224 134;8225 135;8226 149;...
        8230 133;8240 137;8249 139;8250 155;8364 128;8482 153];
    origin=char(CPwin2UTF8(:,1));
    target=char(CPwin2UTF8(:,2));
    
    %The regexp split option was introduced in R2007b.
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
    v=version;v=str2double(v(1:3));%release version
    legacy.split = ...
        (v<4.0 &&  isOctave) ||...
        (v<7.5 && ~isOctave);
end
if ~isOctave
    str=fileread(filename);
    if ispc
        str_original=str;%make a backup
        %Convert from Windows-1252 (the default on a Windows machine) to UTF8
        try
            [a,b]=ismember(str,origin);
            str(a)=target(b(a));
        catch
            %in case of an ismember memory error on ML6.5
            for n=1:numel(origin)
                str=strrep(str,origin(n),target(n));
            end
        end
        try
            if v>=7.0
                ThrowErrorIfNotUTF8file(str)
                %Probably introduced in R14 (v7.0)
                str=native2unicode(uint8(str),'UTF8');
                str=char(str);
            else
                str=UTF8_to_str(str);
            end
        catch
            %ML6.5 doesn't support the "catch ME" syntax
            ME=lasterror;%#ok<LERR>
            if strcmp(ME.identifier,'HJW:UTF8_to_str:notUTF8')
                %Apparently it is not a UTF8 file, as the converter failed, so
                %undo the Windows-1252 codepage re-mapping.
                str=str_original;
            else
                rethrow(ME)
            end
        end
    end
    str(str==13)='';
    if legacy.split
        s1=strfind(str,char(10));s2=s1;%#ok<CHARTEN>
        data=cell(1,numel(s1)+1);
        start_index=[s1 numel(str)+1];
        stop_index=[0 s2];
        for n=1:numel(start_index)
            data{n}=str((stop_index(n)+1):(start_index(n)-1));
        end
    else
        data=regexp(str,char(10),'split'); %#ok<CHARTEN>
    end
else
    data = cell(0);
    fid = fopen (filename, 'r');
    i=0;
    while i==0 || ischar(data{i})
        i=i+1;
        data{i} = fgetl (fid);
    end
    fclose (fid);
    data = data(1:end-1);  % No EOL
    try
        data_original=data;
        for n=1:numel(data)
            data{n}=UTF8_to_str(data{n});
        end
    catch ME
        if strcmp(ME.identifier,'HJW:UTF8_to_str:notUTF8')
            %Apparently it is not a UTF8 file, as the converter failed, so
            %undo the Windows-1252 codepage re-mapping.
            data=data_original;
        else
            rethrow(ME)
        end
    end
end
end
function unicode=UTF8_to_str(UTF8)
%Convert UTF8 to actual char values
%
%This function replaces the syntax str=native2unicode(uint8(UTF8),'UTF8');
%This function throws an error if the input is not possibly UTF8.
%
%In Octave there is poor to no support for chars above 255. This has to do
%with the way Octave runs: as a wrapper around a CLI. This limits what
%Octave can do both on Windows and Linux machines (and presumably mac as
%well).
%
%In your function you can set a preference for what should happen with the
%setpref function, use the OCTAVE___UTF8_to_str group. You can set the
%behavior__char_geq256 to 4 levels: 
%0 (ignore), 1 (reported in setpref), 2 (throw warning), 3 (throw error)
%
%With the level set to 1, you can use
%getpref('OCTAVE___UTF8_to_str','error_was_triggered') to see if there is
%a char>255. If that was the case, it is set to 1.

% %test case:
% c=[char(hex2dec('0024')) char(hex2dec('00A2')) char(hex2dec('20AC'))];
% c=[c c+1 c];
% UTF8=unicode2native(c,'UTF8');
% native=UTF8_to_str(UTF8);
% disp(c)
% disp(native)

if any(UTF8>255)
    error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
end
UTF8=char(UTF8);

persistent isOctave
if isempty(isOctave)
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end
if isOctave
    behavior__char_geq256=getpref(...
        'OCTAVE___UTF8_to_str','behavior__char_geq256',1);
    setpref('OCTAVE___UTF8_to_str','error_was_triggered',0);
    ID='HJW:UTF8_to_str:charnosupport';
    msg='Chars greater than 255 are not supported on Octave.';
end

%Matlab doesn't support 4-byte chars in the same way as 1-3 byte chars. So
%we ignore them and start with the 3-byte chars (starting with 1110xxxx).
val=bin2dec('11100000');
byte3=UTF8>=val;
if any(byte3)
    byte3=find(byte3)';
    try
        byte3=UTF8([byte3 (byte3+1) (byte3+2)]);
    catch
        if numel(UTF8)<(max(byte3)+2)
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        else
            rethrow(lasterror) %#ok<LERR> no "catch ME" syntax in ML6.5
        end
    end
    byte3=unique(byte3,'rows');
    S2=mat2cell(char(byte3),ones(size(byte3,1),1),3);
    for n=1:numel(S2)
        bin=dec2bin(double(S2{n}))';
        %To view the binary data, you can use this: bin=bin(:)';
        %Remove binary header:
        %1110xxxx10xxxxxx10xxxxxx
        %    xxxx  xxxxxx  xxxxxx
        if ~strcmp('11101010',bin([1 2 3 4 8+1 8+2 16+1 16+2]))
            %Check if the byte headers match the UTF8 standard
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        end
        bin([1 2 3 4 8+1 8+2 16+1 16+2])='';
        if ~isOctave
            S3=char(bin2dec(bin));
        else
            val=bin2dec(bin');
            if behavior__char_geq256~=0 && val>255
                if behavior__char_geq256==1
                    warning(ID,msg)
                else
                    error(ID,msg)
                end
            end
            w=warning('off','all');
            S3=char(bin2dec(bin'));
            warning(w)
        end
        %Perform replacement
        UTF8=strrep(UTF8,S2{n},S3);
    end
end
%Next, the 2-byte chars (starting with 110xxxxx)
val=bin2dec('11000000');
byte2=UTF8>=val & UTF8<256;%Exclude the already converted chars
if any(byte2)
    byte2=find(byte2)';
    try
        byte2=UTF8([byte2 (byte2+1)]);
    catch
        if numel(UTF8)<(max(byte2)+1)
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        else
            rethrow(lasterror) %#ok<LERR> no "catch ME" syntax in ML6.5
        end
    end
    byte2=unique(byte2,'rows');
    S2=mat2cell(byte2,ones(size(byte2,1),1),2);
    for n=1:numel(S2)
        bin=dec2bin(double(S2{n}))';
        %To view the binary data, you can use this: bin=bin(:)';
        %Remove binary header:
        %110xxxxx10xxxxxx
        %   xxxxx  xxxxxx
        if ~strcmp('11010',bin([1 2 3 8+1 8+2]))
            %Check if the byte headers match the UTF8 standard
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        end
        bin([1 2 3 8+1 8+2])='';
        if ~isOctave
            S3=char(bin2dec(bin));
        else
            val=bin2dec(bin');%Octave needs an extra transpose
            if behavior__char_geq256~=0 && val>255
                %See explanation above for the reason behind this code.
                if behavior__char_geq256==1
                    setpref('OCTAVE___UTF8_to_str',...
                        'error_was_triggered',1)
                elseif behavior__char_geq256==2
                    warning(ID,msg)
                else
                    error(ID,msg)
                end
            end
            S3=char(val);
        end
        %Perform replacement
        UTF8=strrep(UTF8,S2{n},S3);
    end
end
unicode=UTF8;
end
function ThrowErrorIfNotUTF8file(str)
%Test if the char input is likely to be UTF8
%
%This uses the same tests as the UTF8_to_str function.
%Octave has poor support for chars >255, but that is ignored in this
%function.

if any(str>255)
    error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
end
str=char(str);

persistent isOctave
if isempty(isOctave)
    isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
end

%Matlab doesn't support 4-byte chars in the same way as 1-3 byte chars. So
%we ignore them and start with the 3-byte chars (starting with 1110xxxx).
val_byte3=bin2dec('11100000');
byte3=str>=val_byte3;
if any(byte3)
    byte3=find(byte3)';
    try
        byte3=str([byte3 (byte3+1) (byte3+2)]);
    catch
        if numel(str)<(max(byte3)+2)
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        else
            rethrow(lasterror) %#ok<LERR> no "catch ME" syntax in ML6.5
        end
    end
    byte3=unique(byte3,'rows');
    S2=mat2cell(char(byte3),ones(size(byte3,1),1),3);
    for n=1:numel(S2)
        bin=dec2bin(double(S2{n}))';
        %To view the binary data, you can use this: bin=bin(:)';
        %Remove binary header:
        %1110xxxx10xxxxxx10xxxxxx
        %    xxxx  xxxxxx  xxxxxx
        if ~strcmp('11101010',bin([1 2 3 4 8+1 8+2 16+1 16+2]))
            %Check if the byte headers match the UTF8 standard
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        end
    end
end
%Next, the 2-byte chars (starting with 110xxxxx)
val_byte2=bin2dec('11000000');
byte2=str>=val_byte2 & str<val_byte3;%Exclude the already checked chars
if any(byte2)
    byte2=find(byte2)';
    try
        byte2=str([byte2 (byte2+1)]);
    catch
        if numel(str)<(max(byte2)+1)
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        else
            rethrow(lasterror) %#ok<LERR> no "catch ME" syntax in ML6.5
        end
    end
    byte2=unique(byte2,'rows');
    S2=mat2cell(byte2,ones(size(byte2,1),1),2);
    for n=1:numel(S2)
        bin=dec2bin(double(S2{n}))';
        %To view the binary data, you can use this: bin=bin(:)';
        %Remove binary header:
        %110xxxxx10xxxxxx
        %   xxxxx  xxxxxx
        if ~strcmp('11010',bin([1 2 3 8+1 8+2]))
            %Check if the byte headers match the UTF8 standard
            error('HJW:UTF8_to_str:notUTF8','Input is not UTF8')
        end
    end
end
end
