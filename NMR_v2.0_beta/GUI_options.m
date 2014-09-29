function varargout = GUI_options(varargin)
% GUI_OPTIONS M-file for GUI_options.fig
%      GUI_OPTIONS, by itself, creates a new GUI_OPTIONS or raises the existing
%      singleton*.
%
%      H = GUI_OPTIONS returns the handle to a new GUI_OPTIONS or the handle to
%      the existing singleton*.
%
%      GUI_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_OPTIONS.M with the given input arguments.
%
%      GUI_OPTIONS('Property','Value',...) creates a new GUI_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_options

% Last Modified by GUIDE v2.5 01-Oct-2010 09:26:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_options_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_options_OutputFcn, ...
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


% --- Executes just before GUI_options is made visible.
function GUI_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_options (see VARARGIN)

% Choose default command line output for GUI_options
handles.output = hObject;



% Update handles structure
guidata(hObject, handles);
initialize_GUI_options(hObject,'begin');

% UIWAIT makes GUI_options wait for user response (see UIRESUME)
% uiwait(handles.GUI_options_fig);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_options_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function lcmodel_edit_server_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_server as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_server as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_server_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lcmodel_edit_login_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_login (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_login as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_login as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_login_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_login (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lcmodel_edit_pwd_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_pwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_pwd as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_pwd as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_pwd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_pwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lcmodel_edit_rule_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_rule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_rule as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_rule as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_rule_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_rule (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function main_edit_startpath_Callback(hObject, eventdata, handles)
% hObject    handle to main_edit_startpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of main_edit_startpath as text
%        str2double(get(hObject,'String')) returns contents of main_edit_startpath as a double


% --- Executes during object creation, after setting all properties.
function main_edit_startpath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to main_edit_startpath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lcmodel_edit_targetfolder_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_targetfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_targetfolder as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_targetfolder as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_targetfolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_targetfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in options_pushbutton_reset.
function options_pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to options_pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize_GUI_options(findobj('Tag','GUI_options_fig'),'reset');

% --- Executes on button press in options_pushbutton_apply.
function options_pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to options_pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(findobj('Tag','GUI_options_fig'));
mainhandles = guidata(findobj('Tag','mainmenu'));

%%startpath
mainhandles.startpath = get(handles.main_edit_startpath,'String');

%%load
mainhandles.options.load.fid=get(handles.load_checkbox_fid,'Value');
mainhandles.options.load.fdf=get(handles.load_checkbox_fdf,'Value');
mainhandles.options.load.matlab=get(handles.load_checkbox_matlab,'Value');
mainhandles.options.load.analyse=get(handles.load_checkbox_analyse,'Value');
mainhandles.options.load.siemens=get(handles.load_checkbox_siemens,'Value');
mainhandles.options.load.dicom=get(handles.load_checkbox_dicom,'Value');
mainhandles.options.load.raw=get(handles.load_checkbox_raw,'Value');

%%lcmodel
if isfield(mainhandles,'lcmodel')
    mainhandles.lcmodel.server.name = get(handles.lcmodel_edit_server,'String');
    mainhandles.lcmodel.server.login = get(handles.lcmodel_edit_login,'String');
    mainhandles.lcmodel.server.pwd = handles.pwd;
    mainhandles.lcmodel.winscp = get(handles.lcmodel_edit_winscp,'String');
    mainhandles.lcmodel.targetfolder = get(handles.lcmodel_edit_targetfolder,'String');
    mainhandles.lcmodel.rule = get(handles.lcmodel_edit_rule,'String');
else
    child_box = get(handles.options_uipanel_lcmodel,'Children');
    style_box = get(child_box,'Style');
    edit_box= ismember(style_box,'edit');
    string_box = get(child_box(edit_box),'String');
    no_info = strmatch('Input',string_box);
    input_box = {'Target folder/ ', 'Rule/ ', 'Passowrd/ ' ,'Login name/ ','Server name/ '};
    if isempty(no_info)
            mainhandles.lcmodel.server.name = get(handles.lcmodel_edit_server,'String');
            mainhandles.lcmodel.server.login = get(handles.lcmodel_edit_login,'String');
            mainhandles.lcmodel.server.pwd = handles.pwd;
            mainhandles.lcmodel.winscp = get(handles.lcmodel_edit_winscp,'String'); %PP added
            mainhandles.lcmodel.targetfolder = get(handles.lcmodel_edit_targetfolder,'String');
            mainhandles.lcmodel.rule = get(handles.lcmodel_edit_rule,'String');
    else
        text = 'You must first complete these fields:';
        text2 = [input_box{no_info}];
        answr = questdlg([text text2], ...
        'Incomplete information', ...
         'Ok','No, later','Ok');
     if strcmp(answr,'Ok')==1
         return
     else
         guidata(findobj('Tag','mainmenu'),mainhandles);
         delete(findobj('Tag','GUI_options_fig'));
     end  
    end       
end

guidata(findobj('Tag','mainmenu'),mainhandles);
delete(findobj('Tag','GUI_options_fig'));


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over lcmodel_edit_pwd.
function lcmodel_edit_pwd_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_pwd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on lcmodel_edit_pwd and none of its controls.
function lcmodel_edit_pwd_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_pwd (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(findobj('Tag','GUI_options_fig'));
pwd = handles.pwd;
key = get(findobj('Tag','GUI_options_fig'),'CurrentCharacter');
if isempty(key)
    return
end
switch double(key)
%     case {9} % tab or space
%         set(info.disp(info.current),'BackgroundColor',[0.7 0.7 0.7])
%         info.current = rem(info.current,2) + 1;
%         set(info.disp(info.current),'BackgroundColor','w')
    case {8,127} % delete
        if ~isempty(pwd)
            pwd = [];
        end

            set(hObject,'String',...%pwd)%...
                repmat('#',1,length(pwd)))

    case {3,13} % return or enter (Macintosh)
        handles.pwd=pwd;
        guidata(findobj('Tag','GUI_options_fig'),handles);
    otherwise
        pwd = [pwd,key];
        set(hObject,'String',...%pwd);%...
                repmat('#',1,length(pwd)))
end
handles.pwd=pwd;
guidata(findobj('Tag','GUI_options_fig'),handles);


% --- Executes on button press in debug_checkbox_display.
function debug_checkbox_display_Callback(hObject, eventdata, handles)
% hObject    handle to debug_checkbox_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of debug_checkbox_display
mainhandles = guidata(findobj('Tag','mainmenu'));
mainhandles.options.debug.display= get(hObject,'Value');
guidata(findobj('Tag','mainmenu'),mainhandles);



% --- Executes on button press in load_checkbox_fid.
function load_checkbox_fid_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_fid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_fid


% --- Executes on button press in load_checkbox_fdf.
function load_checkbox_fdf_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_fdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_fdf


% --- Executes on button press in load_checkbox_matlab.
function load_checkbox_matlab_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_matlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_matlab


% --- Executes on button press in load_checkbox_analyse.
function load_checkbox_analyse_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_analyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_analyse


% --- Executes on button press in load_checkbox_dicom.
function load_checkbox_dicom_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_dicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_dicom


% --- Executes on button press in load_checkbox_siemens.
function load_checkbox_siemens_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_siemens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_siemens


% --- Executes on button press in load_pushbutton_all.
function load_pushbutton_all_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(get(handles.options_uipanel_load,'Children'),'Value',1);


% --- Executes on button press in load_pushbutton_none.
function load_pushbutton_none_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(get(handles.options_uipanel_load,'Children'),'Value',0);


% --- Executes on button press in lcmodel_pushbutton_reset.
function lcmodel_pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lcmodel_edit_server,'String','');
set(handles.lcmodel_edit_targetfolder,'String','');
set(handles.lcmodel_edit_login,'String','');
set(handles.lcmodel_edit_pwd,'String','');
set(handles.lcmodel_edit_winscp,'String','');
set(handles.lcmodel_edit_rule,'String','');

mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.lcmodel=rmfield(mainhandles.lcmodel,'server');
mainhandles.lcmodel=rmfield(mainhandles.lcmodel,'winscp');
mainhandles.lcmodel=rmfield(mainhandles.lcmodel,'targetfolder');
mainhandles.lcmodel=rmfield(mainhandles.lcmodel,'rule');

guidata(findobj('Tag','mainmenu'),mainhandles);

function lcmodel_edit_winscp_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_winscp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lcmodel_edit_winscp as text
%        str2double(get(hObject,'String')) returns contents of lcmodel_edit_winscp as a double


% --- Executes during object creation, after setting all properties.
function lcmodel_edit_winscp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodel_edit_winscp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_checkbox_raw.
function load_checkbox_raw_Callback(hObject, eventdata, handles)
% hObject    handle to load_checkbox_raw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of load_checkbox_raw
