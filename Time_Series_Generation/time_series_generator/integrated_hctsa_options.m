function varargout = integrated_hctsa_options(varargin)
% INTEGRATED_HCTSA_OPTIONS MATLAB code for integrated_hctsa_options.fig
%      INTEGRATED_HCTSA_OPTIONS, by itself, creates a new INTEGRATED_HCTSA_OPTIONS or raises the existing
%      singleton*.
%
%      H = INTEGRATED_HCTSA_OPTIONS returns the handle to a new INTEGRATED_HCTSA_OPTIONS or the handle to
%      the existing singleton*.
%
%      INTEGRATED_HCTSA_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTEGRATED_HCTSA_OPTIONS.M with the given input arguments.
%
%      INTEGRATED_HCTSA_OPTIONS('Property','Value',...) creates a new INTEGRATED_HCTSA_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before integrated_hctsa_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to integrated_hctsa_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help integrated_hctsa_options

% Last Modified by GUIDE v2.5 19-Mar-2019 11:14:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @integrated_hctsa_options_OpeningFcn, ...
                   'gui_OutputFcn',  @integrated_hctsa_options_OutputFcn, ...
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


% --- Executes just before integrated_hctsa_options is made visible.
function integrated_hctsa_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to integrated_hctsa_options (see VARARGIN)

% Choose default command line output for integrated_hctsa_options
handles.output = struct('beVocal', [], 'INP_ops', [],...
                        'INP_mops', [], 'customFile', [], 'doParallel', []);

% Update handles structure
guidata(hObject, handles);
set(handles.figure1, 'Units', 'centimeters')
%set(handles.figure1, 'OuterPosition', [0 0 30 20])
set(handles.figure1, 'Color', 'w')

%% Add tooltips
tm = javax.swing.ToolTipManager.sharedInstance;
javaMethodEDT('setInitialDelay',tm,0);
set(handles.text2, 'Tooltip', 'Whether to information on the calculation to the command window')
set(handles.text3, 'Tooltip', 'The name of the file containing the operations to calculate')
set(handles.text4, 'Tooltip', 'The name of the file containing the master operations to calculate')
set(handles.text5, 'Tooltip', 'The name of the file to which the hctsa results will be written')
set(handles.text6, 'Tooltip', 'Whether to perform calculations in parallel')
% UIWAIT makes integrated_hctsa_options wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = integrated_hctsa_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
delete(handles.figure1)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'Value');
    handles.output.beVocal = strng;
    guidata(hObject, handles)
    



function edit1_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    if strcmp(strng, '[]')
        strng = [];
    end
    handles.output.INP_ops = strng;
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    if strcmp(strng, '[]')
        strng = [];
    end
    handles.output.INP_mops = strng;
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'String');
    if strcmp(strng, '[]')
        strng = [];
    end
    handles.output.customFile = strng;
    guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
    strng = get(hObject, 'Value');
    handles.output.doParallel = strng;
    guidata(hObject, handles)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    uiresume(handles.figure1)
