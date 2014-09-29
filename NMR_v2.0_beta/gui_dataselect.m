function varargout = gui_dataselect(varargin)
% GUI_DATASELECT M-file for gui_dataselect.fig
%      GUI_DATASELECT, by itself, creates a new GUI_DATASELECT or raises the existing
%      singleton*.
%
%      H = GUI_DATASELECT returns the handle to a new GUI_DATASELECT or the handle to
%      the existing singleton*.
%
%      GUI_DATASELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DATASELECT.M with the given input arguments.
%
%      GUI_DATASELECT('Property','Value',...) creates a new GUI_DATASELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_dataselect_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_dataselect_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_dataselect

% Last Modified by GUIDE v2.5 08-Sep-2010 10:47:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_dataselect_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_dataselect_OutputFcn, ...
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


% --- Executes just before gui_dataselect is made visible.
function gui_dataselect_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_dataselect (see VARARGIN)

% Choose default command line output for gui_dataselect
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_dataselect wait for user response (see UIRESUME)
% uiwait(handles.dataselect);
initialize_dataselect(hObject,varargin);
% uiwait(hObject)
% handles.output{1} = get(handles.listbox,'Value');
% varargout = {get(handles.listbox,'Value')};
% handles.output=get(handles.listbox,'Value')
% guidata(hObject, handles);
% varargout = gui_dataselect_OutputFcn(hObject, eventdata, handles)
% varargout =get(handles.listbox,'Value');
% close(handles.dataselect)
% dataselect_CloseRequestFcn(hObject, eventdata, handles)


% --- Outputs from this function are returned to the command line.
function varargout = gui_dataselect_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure


varargout{1} = handles.output;




% --- Executes on button press in pushbutton_select2.
function pushbutton_select2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
edit1_Callback(handles.edit1,eventdata,handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
array=handles.multiplicity;
user_str = get(hObject,'String');
try
    if ischar(user_str)
    select_user=eval(user_str);
    elseif iscell(user_str)
        select_user=eval(user_str{1});
    end
catch
    display(select_user)
    errordlg('Impossible to evaluate input')
end
if size(select_user,1)==1 || size(select_user,2)==1
    
else
    display(select_user)
   errordlg('Impossible to evaluate input: dimension wrong')
end

if max(select_user)>array
    display(select_user)
    errordlg('Impossible to evaluate input: Max index exceed arrayy size')
end
set(handles.listbox,'Value',select_user)
guidata(handles.dataselect,handles);
    

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


% --- Executes on selection change in listbox.
function listbox_Callback(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox

% if size(get(hObject,'Value'))==1
%     'bb'
%     
% end


% --- Executes during object creation, after setting all properties.
function listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_all.
function pushbutton_all_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.listbox,'Value',1:handles.multiplicity);
guidata(handles.dataselect,handles)


% --- Executes on button press in pushbutton_none.
function pushbutton_none_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.listbox,'Value',1);

% --- Executes on button press in checkbox_dcoffset.
function checkbox_dcoffset_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_dcoffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_dcoffset

    handles.switch.dcoffset=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes on button press in checkbox_transfromize.
function checkbox_transfromize_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_transfromize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_transfromize
handles.switch.transformsize=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes on button press in checkbox_lsfid.
function checkbox_lsfid_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lsfid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lsfid
handles.switch.lsfid=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes on button press in checkbox_apodization.
function checkbox_apodization_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_apodization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_apodization
handles.switch.apodization=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes on button press in checkbox_phase.
function checkbox_phase_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_phase
handles.switch.phasecorrection=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes on button press in pushbutton_apply.
function pushbutton_apply_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% mainhandles = guidata(findobj('Tag','mainmenu'),handles);
handles.selection=get(handles.listbox,'Value');
guidata(handles.dataselect, handles);
uiresume(handles.dataselect);
% varargout{1} =dataselect_CloseRequestFcn(handles.dataselect, eventdata, handles);
% delete(handles.dataselect);


% --- Executes on button press in checkbox_b0.
function checkbox_b0_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_b0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_b0
handles.switch.b0=get(hObject,'Value');
    guidata(handles.dataselect,handles)

% --- Executes when user attempts to close dataselect.
function varargout = dataselect_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to dataselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isfield(handles,'selection')
        varargout{1}=handles.selection;
else
    varargour{1}=[];
 end
delete(hObject);


% --- Executes on button press in checkbox_norm.
function checkbox_norm_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_norm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_norm
handles.switch.normalization=get(hObject,'Value');
    guidata(handles.dataselect,handles)



function edit_timecourse_Callback(hObject, eventdata, handles)
% hObject    handle to edit_timecourse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_timecourse as text
%        str2double(get(hObject,'String')) returns contents of edit_timecourse as a double
handles.switch.timecourse=str2double(get(hObject,'String'));
guidata(handles.dataselect,handles)

% --- Executes during object creation, after setting all properties.
function edit_timecourse_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_timecourse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_default.
function pushbutton_default_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

called=handles.called;
if isfield(handles,'called2')
    called2= handles.called2;
else
    called2 = [];
end
switch called
    case 'b0'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=1;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=0;
        if ~isempty(called2)
            switch called2
                case 'autophase'
                    method=cellstr(get(handles.popupmenu_method,'String'));
                    handles.switch.method=method{1};
                    set(handles.popupmenu_method,'Value',1);
            end
        end
        
    case 'add'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=1;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=handles.multiplicity;
    case 'raw'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=1;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=0;
    case 'fid2raw'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=0;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=0;
    case 'BISEP'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=0;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=2;
    case 'Temp'
        handles.switch.phasecorrection=1;
        handles.switch.apodization=1;
        handles.switch.transformsize=0;
        handles.switch.lsfid=1;
        handles.switch.dcoffset=1;
        handles.switch.b0=1;
        handles.switch.timecourse=0;
end

if handles.switch.phasecorrection==1;
        set(handles.checkbox_phase,'Value',1)
else
    set(handles.checkbox_phase,'Value',0);
end

if handles.switch.apodization==1;
        set(handles.checkbox_apodization,'Value',1)
else
    set(handles.checkbox_apodization,'Value',0);
end

if handles.switch.transformsize==1;
    
            set(handles.checkbox_transfromize,'Value',1)
else
    set(handles.checkbox_transfromize,'Value',0);
end

if handles.switch.lsfid==1;
        set(handles.checkbox_lsfid,'Value',1)
else
    set(handles.checkbox_lsfid,'Value',0);
end

if handles.switch.dcoffset==1;
        set(handles.checkbox_dcoffset,'Value',1)
else
    set(handles.checkbox_dcoffset,'Value',0);
end

if handles.switch.b0==1;
        set(handles.checkbox_b0,'Value',1)
else
    set(handles.checkbox_b0,'Value',0);
end

if isfield(handles.switch,'timecourse')
    set(handles.edit_timecourse,'String',num2str(handles.switch.timecourse))
end


% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_method
method=cellstr(get(hObject,'String'));
handles.switch.method=method{get(hObject,'Value')};
guidata(handles.dataselect,handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
