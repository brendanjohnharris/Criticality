function varargout = design_input_struct(varargin)
% DESIGN_INPUT_STRUCT MATLAB code for design_input_struct.fig
%      DESIGN_INPUT_STRUCT, by itself, creates a new DESIGN_INPUT_STRUCT or raises the existing
%      singleton*.
%
%      H = DESIGN_INPUT_STRUCT returns the handle to a new DESIGN_INPUT_STRUCT or the handle to
%      the existing singleton*.
%
%      DESIGN_INPUT_STRUCT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESIGN_INPUT_STRUCT.M with the given input arguments.
%
%      DESIGN_INPUT_STRUCT('Property','Value',...) creates a new DESIGN_INPUT_STRUCT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before design_input_struct_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to design_input_struct_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help design_input_struct

% Last Modified by GUIDE v2.5 12-Sep-2019 15:45:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @design_input_struct_OpeningFcn, ...
                   'gui_OutputFcn',  @design_input_struct_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before design_input_struct is made visible.
function design_input_struct_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to design_input_struct (see VARARGIN)

% Choose default command line output for design_input_struct
handles.output = struct('cp_range', [], 'system_type', [], 'tmax', [], 'initial_conditions', [],...
    'parameters', [], 'bifurcation_point', [], 'etarange', [], 'numpoints', [], 'savelength', [],...
    'dt', [], 'T', [], 'sampling_period', [], 'foldername', [], 'rngseed', [],...
    'randomise', [], 'vocal', [], 'save_cp_split', [], 'input_file', [], 'input_struct', [],...
    'integrated_hctsa', struct('beVocal', [], 'INP_ops', [],...
                        'INP_mops', [], 'customFile', [], 'doParallel', []), ...
    'criteria', [], 'maxAttempts', []);
%handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


set(handles.dynamical_system,'String',[{''}, varargin{1}])
set(handles.dynamical_system, 'FontUnits', 'Normalized')
set(handles.figure1, 'Units', 'centimeters')
set(handles.figure1, 'OuterPosition', [0 0 30 20])
set(handles.figure1, 'Color', 'w')
movegui(handles.figure1, 'center')
%% Add tooltips
tm = javax.swing.ToolTipManager.sharedInstance;
javaMethodEDT('setInitialDelay',tm,0);


set(handles.text2, 'Tooltip', 'A character array specifying the dynamical system to be used for integration')
set(handles.controlparameters, 'Tooltip', ['A row vector containing the values of the control ', ...
                                   'parameter for which time series will be generated'])
set(handles.text4, 'Tooltip', ['A row vector containing the values of the noise ', ...
                                'parameter for which time series will be generated'])
set(handles.text5, 'Tooltip', ['A number containing the initial conditions of ', ...
                               'the simulation'])
set(handles.text7, 'Tooltip', ['A number specifying the value of the control ', ...
                              'parameter at which bifurcation occurs (Note: ', ...
                              'This does NOT set the bifurcation point, ', ...
                              'but is used to label the time series)'])
set(handles.text6, 'Tooltip', ['A vector containing the value of any parameters ', ...
                               'other than the control and noise parameters'])
set(handles.text15, 'Tooltip', ['A number giving the time over which values will be generated'])
set(handles.text17, 'Tooltip', ['The number of points to be generated during ', ...
                               'integration (before transient removal)'])
set(handles.text18, 'Tooltip', ['A number specifying the timestep of integration'])
set(handles.text19, 'Tooltip', ['A number giving the length, in seconds, of the ', ...
                               'output time series. This function always ', ...
                               'returns/saves the LAST T seconds of the ', ...
                               'generated time series. Use this option to ', ...
                               'remove transients.'])
set(handles.text21, 'Tooltip', ['The number of points to be saved and returned ', ...
                               '(following transient removal and downsampling)'])
set(handles.text22, 'Tooltip', 'The time between points of the output time series')
set(handles.text23, 'Tooltip', ['A character array containing the name of the ', ...
                               'folder into which the results are saved; if ',...
                               'empty, no results will be saved'])
set(handles.text24, 'Tooltip', ['A positive integer specifying the (approximate) ',...
                              'number of subdirectories into which the results ', ...
                              'will be saved (split by control parameter). ', ...
                              'Useful for distributed computation.'])
set(handles.text25, 'Tooltip', ['A number used as the seed of the random number ', ...
                              'generator; set this and disable ''randomise'' to ', ...
                              'duplicate previous results'])
set(handles.text26, 'Tooltip', ['A binary; if true, the ''rngseed'' will be ignored ', ...
                               'and the random number generator shuffled'])
set(handles.text27, 'Tooltip', 'A binary; true limits command line outputs')
set(handles.text28, 'Tooltip', ['A structure containing options for ', ...
                              'integrating hctsa calcualtions with time series ', ...
                              'generation. If all fields are empty, time series ', ...
                              'will be generated as normal. If not, a hctsa ', ...
                              'file will be saved in place of a timeseries file.'])
set(handles.text30, 'Tooltip', sprintf(['A string containing the criteria for ',...
                               'accepting timeseries, referring to the timeseries', ...
                               '''rout'' (make sure it is a vectorised expression).\n', ...
                               'E.g. ''mean(rout, 2) > 0''])']))
set(handles.text31, 'Tooltip', 'A number specifying how many times to try simulating each timeseries.')
set(handles.dynamical_system, 'Value', 1);


% UIWAIT makes design_input_struct wait for user response (see UIRESUME)
uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = design_input_struct_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;
    delete(handles.figure1)




%% Create elements

%% Dynamical System Options
    % --- Executes on selection change in dynamical_system.
    function dynamical_system_Callback(hObject, eventdata, handles)
    % hObject    handle to dynamical_system (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns dynamical_system contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from dynamical_system
    dynamical_systems_list = get(hObject, 'String');
    what_system = dynamical_systems_list(get(hObject, 'Value'));
    handles.output.system_type = what_system{1};
    if get(hObject, 'Value') > 1
        set(handles.text2, 'ForegroundColor', 'k')
    else
        set(handles.text2, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


    % --- Executes during object creation, after setting all properties.
    function dynamical_system_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to dynamical_system (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
uiresume(handles.figure1)


function edit1_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        cp_range = str2num(strng);
        handles.output.cp_range = cp_range;
        if ~isempty(cp_range)
            set(handles.controlparameters, 'ForegroundColor', 'k')
        else
            set(handles.controlparameters, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.controlparameters, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        etarange = str2num(strng);
        handles.output.etarange = etarange;
        if ~isempty(etarange)
            set(handles.text4, 'ForegroundColor', 'k')
        else
            set(handles.text4, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text4, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        initial_conditions = str2num(strng);
        handles.output.initial_conditions = initial_conditions;
        if ~isempty(initial_conditions)
            set(handles.text5, 'ForegroundColor', 'k')
        else
            set(handles.text5, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text5, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        parameters = str2num(strng);
        handles.output.parameters = parameters;
        set(handles.text6, 'ForegroundColor', 'k')
    catch
        set(handles.text6, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        bifurcation_point = str2num(strng);
        handles.output.bifurcation_point = bifurcation_point;
        if ~isempty(bifurcation_point)
            set(handles.text7, 'ForegroundColor', 'k')
        else
            set(handles.text7, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text7, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        tmax = str2num(strng);
        handles.output.tmax = tmax;
        if ~isempty(tmax)
            set(handles.text15, 'ForegroundColor', 'k')
        else
            set(handles.text15, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text15, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_time_options(handles)

% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit13_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        numpoints = str2num(strng);
        handles.output.numpoints = numpoints;
        if ~isempty(numpoints)
            set(handles.text17, 'ForegroundColor', 'k')
        else
            set(handles.text17, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text17, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_time_options(handles)

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit14_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        dt = str2num(strng);
        handles.output.dt = dt;
        if ~isempty(dt)
            set(handles.text18, 'ForegroundColor', 'k')
        else
            set(handles.text18, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text18, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_time_options(handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function check_time_options(handles)
    if ~isempty(handles.output.dt) && isempty(handles.output.tmax) && isempty(handles.output.numpoints)
        set(handles.text18, 'ForegroundColor', 'k')
        set(handles.text17, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text15, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.numpoints) && isempty(handles.output.dt) && isempty(handles.output.tmax)
        set(handles.text17, 'ForegroundColor', 'k')
        set(handles.text15, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text18, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.tmax) && isempty(handles.output.dt) && isempty(handles.output.numpoints)
        set(handles.text15, 'ForegroundColor', 'k')
        set(handles.text17, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text18, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.tmax) && ~isempty(handles.output.dt) && ~isempty(handles.output.numpoints)
        set(handles.text15, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text17, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text18, 'ForegroundColor', [1.0000    0.2549    0.2118])
    else
        set(handles.text15, 'ForegroundColor', 'k')
        set(handles.text17, 'ForegroundColor', 'k')
        set(handles.text18, 'ForegroundColor', 'k')
    end





function edit17_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        sampling_period = str2num(strng);
        handles.output.sampling_period = sampling_period;
        if ~isempty(sampling_period)
            set(handles.text22, 'ForegroundColor', 'k')
        else
            set(handles.text22, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text22, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_timeseries_options(handles)


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        savelength = str2num(strng);
        handles.output.savelength = savelength;
        if ~isempty(savelength)
            set(handles.text21, 'ForegroundColor', 'k')
        else
            set(handles.text21, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text21, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_timeseries_options(handles)


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        T = str2num(strng);
        handles.output.T = T;
        if ~isempty(T)
            set(handles.text19, 'ForegroundColor', 'k')
        else
            set(handles.text19, 'ForegroundColor', [1.0000    0.2549    0.2118])
        end
    catch
        set(handles.text19, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)
    check_timeseries_options(handles)


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function check_timeseries_options(handles)
    if ~isempty(handles.output.sampling_period) && isempty(handles.output.savelength) && isempty(handles.output.T)
        set(handles.text22, 'ForegroundColor', 'k')
        set(handles.text21, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text19, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.savelength) && isempty(handles.output.sampling_period) && isempty(handles.output.T)
        set(handles.text21, 'ForegroundColor', 'k')
        set(handles.text22, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text19, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.T) && isempty(handles.output.sampling_period) && isempty(handles.output.savelength)
        set(handles.text19, 'ForegroundColor', 'k')
        set(handles.text22, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text21, 'ForegroundColor', [1.0000    0.2549    0.2118])
    elseif ~isempty(handles.output.sampling_period) && ~isempty(handles.output.savelength) && ~isempty(handles.output.T)
        set(handles.text21, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text22, 'ForegroundColor', [1.0000    0.2549    0.2118])
        set(handles.text19, 'ForegroundColor', [1.0000    0.2549    0.2118])
    else
        set(handles.text21, 'ForegroundColor', 'k')
        set(handles.text22, 'ForegroundColor', 'k')
        set(handles.text19, 'ForegroundColor', 'k')
    end




function edit18_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        save_cp_split = str2num(strng);
        handles.output.save_cp_split = save_cp_split;
        set(handles.text24, 'ForegroundColor', 'k')
    catch
        set(handles.text24, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        foldername = strng;
        if strcmp(foldername, '[]')
            foldername = [];
        end
        handles.output.foldername = foldername;
        set(handles.text23, 'ForegroundColor', 'k')
    catch
        set(handles.text23, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    hctsa_ops = integrated_hctsa_options;
    handles.output.integrated_hctsa = hctsa_ops;
    guidata(hObject, handles)

% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'Value');
    try
        randomise = strng;
        handles.output.randomise = randomise;
        set(handles.text26, 'ForegroundColor', 'k')
    catch
        set(handles.text26, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)



function edit19_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        rngseed = str2num(strng);
        handles.output.rngseed = rngseed;
        set(handles.text25, 'ForegroundColor', 'k')
    catch
        set(handles.text25, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'Value');
    try
        vocal = strng;
        handles.output.vocal = vocal;
        set(handles.text27, 'ForegroundColor', 'k')
    catch
        set(handles.text27, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    hctsa_ops = critetia_option;
    handles.output.criteria = criteria;
    guidata(hObject, handles)



function edit24_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        criteria = strng;
        if strcmp(criteria, '[]')
            criteria = 1;
        end
        handles.output.criteria = criteria;
        set(handles.text30, 'ForegroundColor', 'k')
    catch
        set(handles.text30, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit25_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    try
        maxAttempts = str2double(strng);
        if isnan(maxAttempts)
            maxAttempts = 100;
        end
        handles.output.maxAttempts = maxAttempts;
        set(handles.text31, 'ForegroundColor', 'k')
    catch
        set(handles.text31, 'ForegroundColor', [1.0000    0.2549    0.2118])
    end
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit25_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
