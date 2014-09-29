function varargout = GUI_ImageOrientation(varargin)
% GUI_IMAGEORIENTATION M-file for GUI_ImageOrientation.fig
%      GUI_IMAGEORIENTATION, by itself, creates a new GUI_IMAGEORIENTATION or raises the existing
%      singleton*.
%
%      H = GUI_IMAGEORIENTATION returns the handle to a new GUI_IMAGEORIENTATION or the handle to
%      the existing singleton*.
%
%      GUI_IMAGEORIENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_IMAGEORIENTATION.M with the given input arguments.
%
%      GUI_IMAGEORIENTATION('Property','Value',...) creates a new GUI_IMAGEORIENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_ImageOrientation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_ImageOrientation_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_ImageOrientation

% Last Modified by GUIDE v2.5 23-Sep-2010 10:17:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_ImageOrientation_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_ImageOrientation_OutputFcn, ...
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


% --- Executes just before GUI_ImageOrientation is made visible.
function GUI_ImageOrientation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_ImageOrientation (see VARARGIN)

% Choose default command line output for GUI_ImageOrientation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_GUI_ImageOrientation(hObject);


% UIWAIT makes GUI_ImageOrientation wait for user response (see UIRESUME)
% uiwait(handles.GUI_ImageOrientation);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_ImageOrientation_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




function dims_edit_FOV_RO_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_FOV_RO as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_FOV_RO as a double
handles.data.params.lro =str2double(get(hObject,'String'))/10;
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

ImageOrient_display


% --- Executes during object creation, after setting all properties.
function dims_edit_FOV_RO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dims_edit_FOV_PE_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_PE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_FOV_PE as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_FOV_PE as a double
handles.data.params.lpe =str2double(get(hObject,'String'))/10;
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

ImageOrient_display

% --- Executes during object creation, after setting all properties.
function dims_edit_FOV_PE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_PE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dims_edit_FOV_SS_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_SS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_FOV_SS as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_FOV_SS as a double
handles.data.params.thk =str2double(get(hObject,'String'));
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

ImageOrient_display

% --- Executes during object creation, after setting all properties.
function dims_edit_FOV_SS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_FOV_SS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dims_edit_matrix_RO_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_matrix_RO as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_matrix_RO as a double
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

% --- Executes during object creation, after setting all properties.
function dims_edit_matrix_RO_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_RO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dims_edit_matrix_PE_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_PE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_matrix_PE as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_matrix_PE as a double
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

% --- Executes during object creation, after setting all properties.
function dims_edit_matrix_PE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_PE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dims_edit_matrix_SS_Callback(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_SS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dims_edit_matrix_SS as text
%        str2double(get(hObject,'String')) returns contents of dims_edit_matrix_SS as a double
set(hObject,'Value',str2double(get(hObject,'String')));
guidata(handles.GUI_ImageOrientation,handles);

% --- Executes during object creation, after setting all properties.
function dims_edit_matrix_SS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dims_edit_matrix_SS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dims_pushbutton_interp.
function dims_pushbutton_interp_Callback(hObject, eventdata, handles)
% hObject    handle to dims_pushbutton_interp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageOrient_interp
ImageOrient_AdjustSliders('interp');
ImageOrient_display;


% --- Executes on button press in orient_pushbutton_perm_AS.
function orient_pushbutton_perm_AS_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_perm_AS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'perm_AS');
guidata(handles.GUI_ImageOrientation,handles)

ImageOrient_AdjustSliders('perm_AS');
ImageOrient_display;
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'perm_AS');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_A_rot90CW.
function orient_pushbutton_A_rot90CW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_A_rot90CW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'A_rot90CW');
guidata(handles.GUI_ImageOrientation,handles)

ImageOrient_AdjustSliders('A_rot90CW');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'A_rot90CW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_A_rot90CCW.
function orient_pushbutton_A_rot90CCW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_A_rot90CCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
guidata(handles.GUI_ImageOrientation,handles)

ImageOrient_AdjustSliders('A_rot90CCW');
ImageOrient_display;
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'A_rot90CCW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_A_flipvert.
function orient_pushbutton_A_flipvert_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_A_flipvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'A_flipvert');
guidata(handles.GUI_ImageOrientation,handles)

ImageOrient_AdjustSliders('A_flipvert')
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'A_flipvert');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_A_fliphoriz.
function orient_pushbutton_A_fliphoriz_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_A_fliphoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'A_fliphoriz');
guidata(handles.GUI_ImageOrientation,handles)

ImageOrient_AdjustSliders('A_fliphoriz');
ImageOrient_display;
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'A_fliphoriz');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_perm_SC.
function orient_pushbutton_perm_SC_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_perm_SC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'perm_SC');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('perm_SC');
ImageOrient_display;
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'perm_SC');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_S_rot90CW.
function orient_pushbutton_S_rot90CW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_S_rot90CW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'S_rot90CW');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('S_rot90CW');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'S_rot90CW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_S_rot90CCW.
function orient_pushbutton_S_rot90CCW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_S_rot90CCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'S_rot90CCW');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('S_rot90CCW');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'S_rot90CCW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_S_flipvert.
function orient_pushbutton_S_flipvert_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_S_flipvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'S_flipvert');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('S_flipvert');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'S_flipvert');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_S_fliphoriz.
function orient_pushbutton_S_fliphoriz_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_S_fliphoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'S_fliphoriz');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('S_fliphoriz');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'S_fliphoriz');
    guidata(handles.GUI_ImageOrientation,handles);
end


% --- Executes on button press in orient_pushbutton_perm_CA.
function orient_pushbutton_perm_CA_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_perm_CA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'perm_CA');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('perm_CA');
% orient_pushbutton_C_rot90CW_Callback
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'perm_CA');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_C_rot90CW.
function orient_pushbutton_C_rot90CW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_C_rot90CW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.data.image = orientation(handles.data.data.image,'C_rot90CW');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('C_rot90CW');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'C_rot90CW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_C_rot90CCW.
function orient_pushbutton_C_rot90CCW_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_C_rot90CCW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'C_rot90CCW');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('C_rot90CCW');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'C_rot90CCW');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_C_flipvert.
function orient_pushbutton_C_flipvert_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_C_flipvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.data.data.image = orientation(handles.data.data.image,'C_flipvert');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('C_flipvert');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'C_flipvert');
    guidata(handles.GUI_ImageOrientation,handles);
end

% --- Executes on button press in orient_pushbutton_C_fliphoriz.
function orient_pushbutton_C_fliphoriz_Callback(hObject, eventdata, handles)
% hObject    handle to orient_pushbutton_C_fliphoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.data.data.image = orientation(handles.data.data.image,'C_fliphoriz');
guidata(handles.GUI_ImageOrientation,handles)
ImageOrient_AdjustSliders('C_fliphoriz');
ImageOrient_display
if isfield(handles.data,'diff')
    handles.data.diff = orientation(handles.data.diff,'C_fliphoriz');
    guidata(handles.GUI_ImageOrientation,handles);
end
% pushbutton18_Callback


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
initialize_GUI_ImageOrientation(hObject);
ImageOrient_display


% --- Executes on slider movement.
function slider_Axial_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Axial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ImageOrient_display


% --- Executes during object creation, after setting all properties.
function slider_Axial_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Axial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Coronal_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ImageOrient_display

% --- Executes during object creation, after setting all properties.
function slider_Coronal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_Sagittal_Callback(hObject, eventdata, handles)
% hObject    handle to slider_Sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
ImageOrient_display

% --- Executes during object creation, after setting all properties.
function slider_Sagittal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_Sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function display_slider_Contrast_Callback(hObject, eventdata, handles)
% hObject    handle to display_slider_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
max_img=handles.imglim(2);
min_img=handles.imglim(1);
delta_img=max_img-min_img;

slid_value = get(hObject,'Value');
if slid_value>0
    slope_axis=slid_value+1;
else
    slope_axis=1/(-slid_value+1);
end

slope_axis=slope_axis.*delta_img;

shift_axis=get(handles.contrast_slider_brightness,'Value');
shift_axis=shift_axis*delta_img;

handles.clim(1)=(max_img-min_img)/2-slope_axis/2+shift_axis;
handles.clim(2)=(max_img-min_img)/2+slope_axis/2+shift_axis;
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function display_slider_Contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_slider_Contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function display_slider_Brightness_Callback(hObject, eventdata, handles)
% hObject    handle to display_slider_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
shift_axis=get(hObject,'Value');

max_img=handles.imglim(2);
min_img=handles.imglim(1);
delta_img=max_img-min_img;

max_axis=handles.clim(1);
min_axis=handles.clim(2);
delta_axis=max_axis-min_axis;

shift_axis_old = ((max_axis+min_axis)/2-(max_img+min_img)/2)/delta_img;

shift_axis=(shift_axis-shift_axis_old)*delta_img


handles.clim=handles.clim+shift_axis;

guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function display_slider_Brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_slider_Brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in display_popupmenu_DWI.
function display_popupmenu_DWI_Callback(hObject, eventdata, handles)
% hObject    handle to display_popupmenu_DWI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns display_popupmenu_DWI contents as cell array
%        contents{get(hObject,'Value')} returns selected item from display_popupmenu_DWI

% handles.data.data.image = double(squeeze(handles.data.diff(:,:,:,get(hObject,'Value'))));
% guidata(handles.GUI_ImageOrientation,handles);
contrast_pushbutton_reset_Callback(handles.contrast_pushbutton_reset, eventdata, handles);
ImageOrient_display;



% --- Executes during object creation, after setting all properties.
function display_popupmenu_DWI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_popupmenu_DWI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slider_edit_A_current_Callback(hObject, eventdata, handles)
% hObject    handle to slider_edit_A_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slider_edit_A_current as text
%        str2double(get(hObject,'String')) returns contents of slider_edit_A_current as a double
set(handles.slider_Axial,'Value',str2double(get(hObject,'String')));
ImageOrient_AdjustSliders;
ImageOrient_display;


function slider_edit_C_current_Callback(hObject, eventdata, handles)
% hObject    handle to slider_edit_C_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slider_edit_C_current as text
%        str2double(get(hObject,'String')) returns contents of slider_edit_C_current as a double
set(handles.slider_Coronal,'Value',str2double(get(hObject,'String')));
ImageOrient_AdjustSliders;
ImageOrient_display;


function slider_edit_S_current_Callback(hObject, eventdata, handles)
% hObject    handle to slider_edit_S_current (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slider_edit_S_current as text
%        str2double(get(hObject,'String')) returns contents of slider_edit_S_current as a double
set(handles.slider_Sagittal,'Value',str2double(get(hObject,'String')));
ImageOrient_AdjustSliders;
ImageOrient_display;


% --- Executes on button press in display_radiobutton_cross.
function display_radiobutton_cross_Callback(hObject, eventdata, handles)
% hObject    handle to display_radiobutton_cross (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_radiobutton_cross
ImageOrient_display;


% --- Executes on button press in DWI_pushbutton_ADC.
function DWI_pushbutton_ADC_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_ADC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ADC_gui;


% --- Executes on button press in DWI_pushbutton_Qball.
function DWI_pushbutton_Qball_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_Qball (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
runSHQball;

% --- Executes on button press in DWI_pushbutton_DTI.
function DWI_pushbutton_DTI_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_DTI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DTI_gui;


% --- Executes on button press in ImageOrient_pushbutton_save.
function ImageOrient_pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to ImageOrient_pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Save_gui;


% --- Executes on button press in stat_pushbutton_ROI.
function stat_pushbutton_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to stat_pushbutton_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(0,'CurrentFigure',handles.GUI_ImageOrientation);
all_curaxes=findobj('Type','axes','Parent',handles.ImageOrient_uipanel_axes);
set(gcf,'CurrentAxes',handles.axes_axial);
if length(size(handles.data.data.image))==4
    DWI_idx = get(handles.display_popupmenu_DWI,'Value');
    DWI_str = get(handles.display_popupmenu_DWI,'String');
    if ~isempty(strfind(char(DWI_str(DWI_idx)),'b_'))
        img = squeeze(handles.data.data.image(:,:,:,DWI_idx));
        if length(size(img))==2 %single slice
            tmp=img;
            img=zeros(1,size(tmp,1),size(tmp,2));
            img(1,:,:)=tmp;
        end
    elseif ~isempty(strfind(char(DWI_str(DWI_idx)),'colormap'))
        disp('impossible to make ROI')
        return;
    else
        img = squeeze(handles.data.data.Tens.(char(DWI_str(DWI_idx))));
        if length(size(img))==2 %single slice
            tmp=img;
            img=zeros(1,size(tmp,1),size(tmp,2));
            img(1,:,:)=tmp;
        end
        
    end
else
    img = handles.data.data.image(:,:,:);
end
tmp = squeeze(img(round(get(handles.slider_Axial,'Value')),:,:));
BW= roipoly();
result = tmp.*BW;
disp('MEAN:')
AVG = mean(mean(result,1),2);

disp(AVG)


% --- Executes on button press in display_radiobutton_aspect.
function display_radiobutton_aspect_Callback(hObject, eventdata, handles)
% hObject    handle to display_radiobutton_aspect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_radiobutton_aspect
ImageOrient_display;


% --- Executes on button press in stat_pushbutton_SNR.
function stat_pushbutton_SNR_Callback(hObject, eventdata, handles)
% hObject    handle to stat_pushbutton_SNR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(0,'CurrentFigure',handles.GUI_ImageOrientation);
% all_curaxes=findobj('Type','axes','Parent',handles.ImageOrient_uipanel_axes);
set(gcf,'CurrentAxes',handles.axes_axial);
if length(size(handles.data.data.image))==4
    DWI_idx = get(handles.display_popupmenu_DWI,'Value');
    DWI_str = get(handles.display_popupmenu_DWI,'String');
    if ~isempty(strfind(char(DWI_str(DWI_idx)),'b_'))
        img = squeeze(handles.data.data.image(round(get(handles.slider_Axial,'Value')),:,:,:));
    elseif ~isempty(strfind(char(DWI_str(DWI_idx)),'colormap'))
        disp('impossible to make ROI')
        return;
    else
        img = squeeze(handles.data.data.Tens.(char(DWI_str(DWI_idx)))(round(get(handles.slider_Axial,'Value')),:,:));
        
    end
else
    img = squeeze(handles.data.data.image(round(get(handles.slider_Axial,'Value')),:,:));
end
img_displ = get(handles.axes_axial,'UserData');
img_displ =img_displ./max(max(max(img_displ)));
img_displ = repmat(img_displ,[1 1 3]);
aspectration = get(handles.axes_axial,'DataAspectRatio');
% S.mask=permute(zeros(size(img_displ)),[3 1 2]);
ROI_color =[[1 0 0]; [0 1 0]; [0 0 1];[1 1 0]; [1 0 1]; [0 1 1]];
disp('Select Signal Areas and finish by Nois area')
stop=0;
region=1;
while stop ==0
    answ = input('Region name (return = noise):','s');
    region_name{region}=answ;
    set(gcf,'CurrentAxes',handles.axes_axial);
    if ~isempty(answ) && strcmp(answ,'noise')==0
        fprintf('Select %s Area\n',answ);
        S.mask(region,:,:) =roipoly();
        
        inv_mask = repmat(abs(squeeze(S.mask(region,:,:))-1),[1 1 3]);
        
        ROI = repmat(squeeze(S.mask(region,:,:)),[1 1 3]);
        ROI=ROI.*img_displ;
        img_displ = img_displ.*inv_mask;
        col=permute(repmat(ROI_color(region,:),[size(ROI,1) 1 size(ROI,2)]),[1 3 2]);
        ROI=ROI.*col;
        img_displ = img_displ + ROI;
        imshow(img_displ)
        
        region=region+1;
        stop=0;
        clear ROI col inv_mask
        
    else
        disp('Select Noise Area')
        N.mask = roipoly();
        
        inv_mask = repmat(abs(N.mask-1),[1 1 3]);
        ROI = repmat(N.mask,[1 1 3]);
        ROI=ROI.*img_displ;
        img_displ = img_displ.*inv_mask;
        ROI=ROI.*10;
        img_displ = img_displ + ROI;
        imshow(img_displ)
        stop=1;
    end
    
end

[N.x,N.y] = find(N.mask==1);

if  length(size(S.mask))==2
    N_region = 1;
    S.mask=permute(repmat(S.mask,[1 1 1]),[3 1 2]);
else
    N_region =  size(S.mask,1);
end

for r = 1:N_region
    [S.x,S.y] = find(squeeze(S.mask(r,:,:))==1);
    if length(size(img))==3
        for k=1:size(img,3)
            tmp = squeeze(img(:,:,k));
            for n=1:length(N.x)
                N.value(n) = tmp(N.x(n),N.y(n));
            end
            for s=1:size(S.x)
                S.value(s) = tmp(S.x(s),S.y(s));
            end
            S.mvalue(k) = mean(S.value);
            N.svalue(k) = std(N.value);
            SNR(k) = mean(S.value)/std(N.value);
            CV(k) = std(S.value)/mean(S.value);
            %             xlswrite('E:\Nicolas\MATLAB\SNR.xls', squeeze(handles.data.data.image(round(get(handles.slider_Axial,'Value')),:,:,k)), char(['B_' num2str(k)]));
        end
        clear tmp
        
    else
        tmp = squeeze(img(:,:));
        for n=1:length(N.x)
            N.value(n) = tmp(N.x(n),N.y(n));
        end
        for s=1:length(S.x)
            S.value(s) = tmp(S.x(s),S.y(s));
        end
        S.mvalue = mean(S.value);
        N.svalue = std(N.value);
        SNR = mean(mean(S.value))/std(N.value);
        CV = std(S.value)/mean(mean(S.value));
    end
    
    
    %     name_c = 'epi_20080926';
    
    line = 1+(r-1)*8;
    
    excel_data{line,1} = char(region_name{r});
    excel_data{line+1,1} = ['Size ROI ' char(region_name{r}) ':'];
    excel_data{line+1,2} = sum(sum(squeeze(S.mask(r,:,:))));
    excel_data{line+1,3} = 'Size Noise:';
    excel_data{line+1,4} = sum(sum(squeeze(N.mask(:,:))));
    excel_data{line+1,5} = 'Slice number:';
    excel_data{line+1,6} =  round(get(handles.slider_Axial,'Value'));
    excel_data{line+3,1} = '<S> ';
    excel_data{line+4,1} = 'std(Noise)';
    excel_data{line+5,1} = 'SNR';
    excel_data{line+6,1} = 'Coefficient of varation:';
    for n=1:length(SNR)
        excel_data{line+3,n+1} = S.mvalue(n);
        excel_data{line+4,n+1} = N.svalue(n);
        excel_data{line+5,n+1} = SNR(n);
        excel_data{line+6,n+1} = CV(n);
    end
    
end
disp('Exporting results to excel...')
answ2 = input('Excel sheet name:','s');
sheetname = char(answ2);
% answ = input('Ecel file name:','s');
% filename = 'E:\Nicolas\MATLAB\adiab.xls';
xlswrite(filename,excel_data ,sheetname);
disp(excel_data)


% --- Executes on button press in processing_pushbutton_noise.
function processing_pushbutton_noise_Callback(hObject, eventdata, handles)
% hObject    handle to processing_pushbutton_noise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('not implemented yet')

% --- Executes on button press in processing_pushbutton_bias.
function processing_pushbutton_bias_Callback(hObject, eventdata, handles)
% hObject    handle to processing_pushbutton_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Bias_Corrector(handles);
ImageOrient_display;


% --- Executes on button press in process_checkbox_bias.
function process_checkbox_bias_Callback(hObject, eventdata, handles)
% hObject    handle to process_checkbox_bias (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of process_checkbox_bias
ImageOrient_display;


% --- Executes on button press in display_radiobutton_zoom.
function display_radiobutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to display_radiobutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_radiobutton_zoom
if get(hObject,'Value')
    zoom on
    pan off
    set(handles.display_radiobutton_cross,'Value',0);
    set(handles.display_radiobutton_pan,'Value',0);
    %     set(handles.display_radiobutton_cross,'Enable','off');
else
    zoom off
end



% --- Executes on button press in display_radiobutton_pan.
function display_radiobutton_pan_Callback(hObject, eventdata, handles)
% hObject    handle to display_radiobutton_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_radiobutton_pan
if get(hObject,'Value')
    pan on
    zoom off
    set(handles.display_radiobutton_zoom,'Value',0);
else
    pan off
end


% --- Executes on button press in pushbutton_returntonmr.
function pushbutton_returntonmr_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_returntonmr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
run([handles.homedir filesep 'nmr']);
save_open_mainhandles('load',[handles.homedir filesep 'temp_study.mat'])
hh = findobj('Tag','ROI_manager');
if ~isempty(hh)
    delete(hh)
end
delete(handles.GUI_ImageOrientation)


% --- Executes on button press in stat_pushbutton_ROI_manager.
function stat_pushbutton_ROI_manager_Callback(hObject, eventdata, handles)
% hObject    handle to stat_pushbutton_ROI_manager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% togglebutton !!!!
h = findobj('Tag','ROI_manager');
if get(hObject,'Value')  
   if ~isempty(h)
       ROI_handles = guidata(h);
       dime_img = size(handles.data.data.image);
       dime_img=dime_img(1:3); 
       ROI_name = fieldnames(ROI_handles.roilist);
       dime_ROI = size(ROI_handles.roilist.(ROI_name{1}).roi);
       if sum(dime_img==dime_ROI)~=3
           button = questdlg([{'ROI and image does not have same dimensions'}...
                              {'Do you want to crop the ROI?'}...
                              {['size img: ' num2str(dime_img)]}...
                              {['size ROI: ' num2str(dime_ROI)]}],...
                              'Crop ROI','Yes','Delete ROI','No','Yes');
           if strcmp(button,'Yes') && isfield(handles.data,'crop')
               for k=1:length(ROI_name)
                   roi = ROI_handles.roilist.(ROI_name{k}).roi;
                   for j=1:length(handles.data.crop)
                       crop_dim = handles.data.crop{j};
                       roi = roi(crop_dim(1,1):crop_dim(1,2),...
                                crop_dim(2,1):crop_dim(2,2),...
                                crop_dim(3,1):crop_dim(3,2));
                   end
               end
               handles.data = rmfield(handles.data,'crop');
               guidata(handles.GUI_ImageOrientation,handles);
           elseif strcmp(button,'Delete ROI')
               ROI_manager;
           else
               errordlg('Could not open ROI manager, image and ROI dimensions are different')
               return;
           end
                              
           
       end
       ROI_manager;%%%%%% to be commented
       set(h,'Visible','on')
   else
       ROI_manager;
   end
else
   if ~isempty(h)
       
       set(h,'Visible','off')
       delete(h) %%%%%% to be commented
   else
       display('figure has been deleted')
   end
end


% --- Executes on slider movement.
function contrast_slider_brightness_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_slider_brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

shift_axis=get(hObject,'Value');

max_img=handles.imglim(2);
min_img=handles.imglim(1);
delta_img=max_img-min_img;

max_axis=handles.clim(1);
min_axis=handles.clim(2);
delta_axis=max_axis-min_axis;

shift_axis_old = ((max_axis+min_axis)/2-(max_img+min_img)/2)/delta_img;

shift_axis=(shift_axis-shift_axis_old)*delta_img


handles.clim=handles.clim+shift_axis;

guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function contrast_slider_brightness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_slider_brightness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function contrast_slider_contrast_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_slider_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

max_img=handles.imglim(2);
min_img=handles.imglim(1);
delta_img=max_img-min_img;


slid_value = get(hObject,'Value');
if slid_value>0
    slope_axis=slid_value+1;
else
    slope_axis=1/(-slid_value+1);
end

slope_axis=slope_axis.*delta_img;

shift_axis=get(handles.contrast_slider_brightness,'Value');
shift_axis=shift_axis*delta_img;

handles.clim(1)=(max_img-min_img)/2-slope_axis/2+shift_axis;
handles.clim(2)=(max_img-min_img)/2+slope_axis/2+shift_axis;
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;


% --- Executes during object creation, after setting all properties.
function contrast_slider_contrast_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_slider_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function contrast_slider_min_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.clim(1)=get(hObject,'Value');
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function contrast_slider_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_slider_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function contrast_slider_max_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.clim(2)=get(hObject,'Value');
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function contrast_slider_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_slider_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function contrast_edit_min_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrast_edit_min as text
%        str2double(get(hObject,'String')) returns contents of contrast_edit_min as a double
handles.clim(1)=str2double(get(hObject,'String'));
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function contrast_edit_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_edit_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function contrast_edit_max_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_edit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contrast_edit_max as text
%        str2double(get(hObject,'String')) returns contents of contrast_edit_max as a double
handles.clim(2)=str2double(get(hObject,'String'));
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function contrast_edit_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contrast_edit_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in contrast_pushbutton_reset.
function contrast_pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if length(size(handles.data.data.image))==4
    DWI_idx = get(handles.display_popupmenu_DWI,'Value');
    DWI_str = get(handles.display_popupmenu_DWI,'String');
    if ~isempty(strfind(char(DWI_str(DWI_idx)),'b_'))
        img = handles.data.data.image;
    else
        switch char(DWI_str(DWI_idx))
            case 'colormap'
                img =handles.data.data.Tens.colormap;
            case 'GFA'
                img =handles.data.data.qball.(char(DWI_str(DWI_idx)));
                
            case 'ODF'
                img =squeeze(handles.data.data.qball.(char(DWI_str(DWI_idx)))(:,:,:,q));
            otherwise
                img =handles.data.data.Tens.(char(DWI_str(DWI_idx)));
        end
    end
else
    
    img = handles.data.data.image;
end

min_img = min(min(min(min(img))));
max_img = max(max(max(max(img))));
handles.imglim=[min_img max_img];
handles.clim = handles.imglim;
min_axis=min_img;
max_axis=max_img;
set(handles.contrast_edit_min,'String',num2str(min_axis))
set(handles.contrast_slider_min,'Value',min_axis)
set(handles.contrast_slider_min,'Min',min_axis)
set(handles.contrast_slider_min,'Max',max_axis)

set(handles.contrast_edit_max,'String',num2str(max_axis))
set(handles.contrast_slider_max,'Value',max_axis)
set(handles.contrast_slider_max,'Min',get(handles.contrast_slider_min,'Value'))
set(handles.contrast_slider_max,'Max',max_axis)

set(handles.contrast_slider_contrast,'Value',0);
set(handles.contrast_slider_contrast,'Min',-2);
set(handles.contrast_slider_contrast,'Max',2);

set(handles.contrast_slider_brightness,'Value',0);
set(handles.contrast_slider_brightness,'Min',-0.99);
set(handles.contrast_slider_brightness,'Max',0.99);
guidata(handles.GUI_ImageOrientation,handles);


hh = findobj('Tag','ROI_manager');
if ~isempty(hh)
    set(handles.options_slider_thresmin,'Min',handles.imglim(1))
    set(handles.options_slider_thresmin,'Max',handles.imglim(2))
    set(handles.options_slider_thresmin,'Value',handles.imglim(1))
    set(handles.options_slider_thresmin,'Min',handles.imglim(1))
    set(handles.options_slider_thresmin,'Max',handles.imglim(2))
    set(handles.options_slider_thresmin,'Value',handles.imglim(2))

    set(handles.options_edit_thresmin,'String',num2str(handles.imglim(1)))
    set(handles.options_edit_thresmin,'String',num2str(handles.imglim(2)))
end


contents = cellstr(get(handles.display_popupmenu_colormap,'String'));
map = contents{get(handles.display_popupmenu_colormap,'Value')};
colormap([map '(256)'])

ImageOrient_display;


% --- Executes on button press in contrast_pushbutton_auto.
function contrast_pushbutton_auto_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_pushbutton_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in view_togglebutton_3axes.
function view_togglebutton_3axes_Callback(hObject, eventdata, handles)
% hObject    handle to view_togglebutton_3axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view_togglebutton_3axes
h_view = get(handles.uipanel_view,'Children');
h_view= setxor(h_view,hObject);
set(h_view,'Value',0);
set(hObject,'Value',1);
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_changeView;


% --- Executes on button press in view_togglebutton_axial.
function view_togglebutton_axial_Callback(hObject, eventdata, handles)
% hObject    handle to view_togglebutton_axial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view_togglebutton_axial
h_view = get(handles.uipanel_view,'Children');
h_view= setxor(h_view,hObject);
set(h_view,'Value',0);
set(hObject,'Value',1);
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_changeView;

% --- Executes on button press in view_togglebutton_sagittal.
function view_togglebutton_sagittal_Callback(hObject, eventdata, handles)
% hObject    handle to view_togglebutton_sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view_togglebutton_sagittal
h_view = get(handles.uipanel_view,'Children');
h_view= setxor(h_view,hObject);
set(h_view,'Value',0);
set(hObject,'Value',1);
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_changeView;

% --- Executes on button press in view_togglebutton_coronal.
function view_togglebutton_coronal_Callback(hObject, eventdata, handles)
% hObject    handle to view_togglebutton_coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of view_togglebutton_coronal
h_view = get(handles.uipanel_view,'Children');
h_view= setxor(h_view,hObject);
set(h_view,'Value',0);
set(hObject,'Value',1);
guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_changeView;


% --- Executes on button press in display_radiobutton_grid.
function display_radiobutton_grid_Callback(hObject, eventdata, handles)
% hObject    handle to display_radiobutton_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_radiobutton_grid
ImageOrient_display;

% --- Executes on selection change in display_popupmenu_colormap.
function display_popupmenu_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to display_popupmenu_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns display_popupmenu_colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from display_popupmenu_colormap
contents = cellstr(get(hObject,'String'));
map = contents{get(hObject,'Value')};
colormap(map)


% --- Executes during object creation, after setting all properties.
function display_popupmenu_colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_popupmenu_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DWI_pushbutton_DSI.
function DWI_pushbutton_DSI_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_DSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DWI_pushbutton_charmed.
function DWI_pushbutton_charmed_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_charmed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in DWI_pushbutton_axcaliber.
function DWI_pushbutton_axcaliber_Callback(hObject, eventdata, handles)
% hObject    handle to DWI_pushbutton_axcaliber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in display_togglebutton_px_mm.
function display_togglebutton_px_mm_Callback(hObject, eventdata, handles)
% hObject    handle to display_togglebutton_px_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of display_togglebutton_px_mm
ImageOrient_display

% --- Executes on button press in contrast_radiobutton_ylog.
function contrast_radiobutton_ylog_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_radiobutton_ylog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of contrast_radiobutton_ylog
ImageOrient_display

% --- Executes on button press in contrast_radiobutton_zoom.
function contrast_radiobutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to contrast_radiobutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of contrast_radiobutton_zoom
ImageOrient_display


% --- Executes on mouse press over axes background.
function axes_axial_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_axial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curpos = get(hObject,'CurrentPoint');
set(handles.slider_Sagittal,'Value',round(curpos(1,1)));
set(handles.slider_Coronal,'Value',round(curpos(1,2)));
ImageOrient_display;


% --- Executes on mouse press over axes background.
function axes_coronal_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_coronal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curpos = get(hObject,'CurrentPoint');
set(handles.slider_Axial,'Value',round(curpos(1,2)));
set(handles.slider_Sagittal,'Value',round(curpos(1,1)));
ImageOrient_display;

% --- Executes on mouse press over axes background.
function axes_sagittal_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_sagittal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curpos = get(hObject,'CurrentPoint');
set(handles.slider_Axial,'Value',round(curpos(1,2)));
set(handles.slider_Coronal,'Value',round(curpos(1,1)));
ImageOrient_display;

% --- Executes on mouse press over figure background.
function GUI_ImageOrientation_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to GUI_ImageOrientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get(hObject,'CurrentPoint')
% display('asas')

% --------------------------------------------------------------------
function ImageOrient_uipanel_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ImageOrient_uipanel_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% disp('panel')


% --- Executes on mouse press over axes background.
function axes_contrast_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_contrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% get(hObject,'CurrentPoint')
% display('cotrast')

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function GUI_ImageOrientation_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to GUI_ImageOrientation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% curpoint=get(handles.GUI_ImageOrientation,'CurrentPoint')
% disp('GUI_ImageOrientation')
% mainpanelpos = get(handles.ImageOrient_uipanel_axes,'Position');
% axislpos = get(handles.axes_axial,'Position');
% disp('windows')
% get(hObject,'CurrentPoint')
% get(hObject,'Children')
%
% handles.ImageOrient_uipanel_axes
% get(handles.ImageOrient_uipanel_axes,'Children')
%
% handles.axes_axial
% ImageOrient_curpos(handles)

% position of current point within main panel
% curpoint_panel = [(curpoint(1)-mainpanelpos(1))/mainpanelpos(3) ...
%     (curpoint(2)-mainpanelpos(2))/mainpanelpos(4)] % position within main panel
% curpoint_axis = [(curpoint(1)-axislpos(1))/axislpos(3) ...
%     (curpoint(2)-axislpos(2))/axislpos(4)] % position within main panel


% --- Executes on button press in dims_pushbutton_crop.
function dims_pushbutton_crop_Callback(hObject, eventdata, handles)
% hObject    handle to dims_pushbutton_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
display('crop')

view_togglebutton_3axes_Callback(handles.view_togglebutton_3axes, eventdata, handles);
old_dime = size(handles.data.data.image);

set(handles.dims_text_crop,'Visible','on','String','Crop: ');
[img, crop_dim] = ImageOrient_crop(handles);
set(handles.dims_text_crop,'Visible','off','String','Crop: ');
dime=size(img);

handles.data.data.image = img;
if isfield(handles.data,'crop')  
    handles.data.crop{length(handles.data.crop)+1} = crop_dim;
else
    handles.data.crop{1} = crop_dim;
end
for k = 1:length(handles.data.orientation)
    switch char(handles.data.orientation{k})
        case 'RO'
            handles.data.params.np = 2*dime(k);
            handles.data.params.lro = handles.data.params.lro*dime(k)/old_dime(k);
            set(handles.dims_edit_matrix_RO,'String',num2str(handles.data.params.np/2));
            set(handles.dims_edit_FOV_RO,'String',num2str(handles.data.params.lro*10,2));
        case 'PE'
            handles.data.params.nv = dime(k);
            handles.data.params.lpe = handles.data.params.lpe*dime(k)/old_dime(k);
            set(handles.dims_edit_matrix_PE,'String',num2str(handles.data.params.nv));
            set(handles.dims_edit_FOV_PE,'String',num2str(handles.data.params.lpe*10,2));
        case 'SS'
            handles.data.params.ns = dime(k);
            set(handles.dims_edit_matrix_SS,'String',num2str(handles.data.params.ns));
    end
end


handles.imglim=[min(min(min(min(img)))) max(max(max(max(img))))];

guidata(handles.GUI_ImageOrientation,handles);
ImageOrient_AdjustSliders
% ImageOrient_contrast(img);
contrast_pushbutton_reset_Callback(handles.contrast_pushbutton_reset, eventdata, handles);


% --- Executes on button press in pushbutton_color_cur.
function pushbutton_color_cur_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_cur (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

color = uisetcolor(get(hObject,'BackgroundColor'));
set(hObject,'BackgroundColor',color);
ImageOrient_display;
% --- Executes on button press in pushbutton_color_grid.
function pushbutton_color_grid_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_color_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
color = uisetcolor(get(hObject,'BackgroundColor'));
set(hObject,'BackgroundColor',color);
ImageOrient_display;
