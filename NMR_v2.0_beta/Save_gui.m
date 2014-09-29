function varargout = Save_gui(varargin)
% SAVE_GUI M-file for Save_gui.fig
%      SAVE_GUI, by itself, creates a new SAVE_GUI or raises the existing
%      singleton*.
%
%      H = SAVE_GUI returns the handle to a new SAVE_GUI or the handle to
%      the existing singleton*.
%
%      SAVE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAVE_GUI.M with the given input arguments.
%
%      SAVE_GUI('Property','Value',...) creates a new SAVE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Save_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Save_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Save_gui

% Last Modified by GUIDE v2.5 11-Oct-2009 11:29:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Save_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @Save_gui_OutputFcn, ...
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


% --- Executes just before Save_gui is made visible.
function Save_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Save_gui (see VARARGIN)

% Choose default command line output for Save_gui
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);
initialize_Save_gui(hObject);
% UIWAIT makes Save_gui wait for user response (see UIRESUME)
% uiwait(handles.Save_gui);


% --- Outputs from this function are returned to the command line.
function varargout = Save_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in save_pushbutton_save.
function save_pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_image;
delete(findobj('Tag','Save_gui'));


function save_edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to save_edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_edit_filename as text
%        str2double(get(hObject,'String')) returns contents of save_edit_filename as a double
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).filename=get(hObject,'String');
guidata(findobj('Tag','Save_gui'), handles);

% --- Executes during object creation, after setting all properties.
function save_edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in format_pushbutton_set.
% -- new save
function format_pushbutton_set_Callback(hObject, eventdata, handles)
% hObject    handle to format_pushbutton_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

tot_idx=tot_idx+1;
idx=tot_idx;


idx_str = [num2str(idx) '/' num2str(tot_idx)];
set(handles.save_edit_idx,'String',idx_str);

guidata(findobj('Tag','Save_gui'), handles);
save_edit_idx_Callback(hObject, eventdata, handles);

% --- Executes on button press in format_pushbutton_reset.
function format_pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to format_pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

tot_idx=tot_idx-1;
if tot_idx<1
    tot_idx=1;
    idx=1;
else
    handles.options=handles.options([1:(idx-1) idx:length(handles.options)]);
    idx=idx-1;
    if idx<1
        idx=1;
    end
end
idx_str = [num2str(idx) '/' num2str(tot_idx)];
set(handles.save_edit_idx,'String',idx_str);


guidata(findobj('Tag','Save_gui'), handles);
save_edit_idx_Callback(hObject, eventdata, handles);


% --- Executes on selection change in save_popupmenu_fileformat.
function save_popupmenu_fileformat_Callback(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_fileformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns save_popupmenu_fileformat contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_popupmenu_fileformat
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).fileformat=get(hObject,'Value');
guidata(findobj('Tag','Save_gui'), handles);

% --- Executes during object creation, after setting all properties.
function save_popupmenu_fileformat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_fileformat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in save_popupmenu_bitetype.
function save_popupmenu_bitetype_Callback(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_bitetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns save_popupmenu_bitetype contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_popupmenu_bitetype
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).bitetype=get(hObject,'Value');
guidata(findobj('Tag','Save_gui'), handles);

% --- Executes during object creation, after setting all properties.
function save_popupmenu_bitetype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_bitetype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in save_checkbox_sepfolder.
function save_checkbox_sepfolder_Callback(hObject, eventdata, handles)
% hObject    handle to save_checkbox_sepfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of save_checkbox_sepfolder
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).sepfolder=get(hObject,'Value');

content = get(handles.save_popupmenu_fileformat,'String');
ext = content{handles.options(idx).fileformat};
if get(hObject,'Value')==1;
    handles.options(idx).outputpath=[handles.options(idx).outputpath filesep ext];
else
    try,

        handles.options(idx).outputpath=strrep(handles.options(idx).outputpath,[filesep ext],'');
    catch,
        disp('Output pth changed previously manually');
        set(hObject,'Value',1);
    end
end
set(handles.save_edit_outputdir,'String',handles.options(idx).outputpath);
guidata(findobj('Tag','Save_gui'), handles);

% --- Executes on button press in save_pushbutton_idx_prev.
function save_pushbutton_idx_prev_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton_idx_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/' );
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

idx=idx-1;
if idx<1
    idx=tot_idx;
end

idx_str = [num2str(idx) '/' num2str(tot_idx)];
set(handles.save_edit_idx,'String',idx_str);

guidata(findobj('Tag','Save_gui'), handles);
save_edit_idx_Callback(hObject, eventdata, handles);

% --- Executes on button press in save_pushbutton_idx_next.
function save_pushbutton_idx_next_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton_idx_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

idx=idx+1;
if idx>tot_idx
    idx=1;
end

idx_str = [num2str(idx) '/' num2str(tot_idx)];
set(handles.save_edit_idx,'String',idx_str);

guidata(findobj('Tag','Save_gui'), handles);
save_edit_idx_Callback(hObject, eventdata, handles);


function save_edit_idx_Callback(hObject, eventdata, handles)
% hObject    handle to save_edit_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_edit_idx as text
%        str2double(get(hObject,'String')) returns contents of
%        save_edit_idx as a double
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

if tot_idx > length(handles.options) % create new save options
    for k=(length(handles.options)+1):tot_idx
        handles.options(k)=handles.options(1);
    end
end

set(handles.save_popupmenu_soft,'Value',handles.options(idx).soft);
set(handles.save_popupmenu_fileformat,'Value',handles.options(idx).fileformat);
set(handles.save_popupmenu_bitetype,'Value',handles.options(idx).bitetype);
set(handles.save_checkbox_sepfolder,'Value',handles.options(idx).sepfolder);
set(handles.save_edit_outputdir,'String',handles.options(idx).outputpath,'HorizontalAlignment','right');
set(handles.save_edit_filename,'String',handles.options(idx).filename);
if isfield(handles.options(idx),'dim') && isfield(handles.options(idx),'DWdata')
    set(handles.DT_popupmenu_3D4D,'Value',handles.options(idx).dim);
    set(handles.DTI_listbox_DWdata,'Value',[1:length(handles.options(idx).DWdata)]);
end
guidata(findobj('Tag','Save_gui'), handles);


% --- Executes during object creation, after setting all properties.
function save_edit_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_edit_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function save_edit_outputdir_Callback(hObject, eventdata, handles)
% hObject    handle to save_edit_outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_edit_outputdir as text
%        str2double(get(hObject,'String')) returns contents of save_edit_outputdir as a double
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).outputdir=get(hObject,'String');
guidata(findobj('Tag','Save_gui'),handles);

% --- Executes during object creation, after setting all properties.
function save_edit_outputdir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_edit_outputdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_pushbutton_browse.
function save_pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
datadir = uigetdir(handles.options(idx).outputpath,'Select directory containing data');%,x,y)
if ~strcmp(datadir,handles.options(idx).outputpath)
    set(handles.save_checkbox_sepfolder,'Value',1);
end
if datadir~=0
    handles.options(idx).outputpath=datadir;
    set(handles.save_edit_outputdir,'String',datadir);
end
handles.options(idx).outputdir = datadir;
guidata(findobj('Tag','Save_gui'), handles);


% --- Executes on selection change in DT_popupmenu_3D4D.
function DT_popupmenu_3D4D_Callback(hObject, eventdata, handles)
% hObject    handle to DT_popupmenu_3D4D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DT_popupmenu_3D4D contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DT_popupmenu_3D4D
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
handles.options(idx).dim=get(hObject,'Value');

guidata(findobj('Tag','Save_gui'), handles);

% --- Executes during object creation, after setting all properties.
function DT_popupmenu_3D4D_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DT_popupmenu_3D4D (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DTI_listbox_DWdata.
function DTI_listbox_DWdata_Callback(hObject, eventdata, handles)
% hObject    handle to DTI_listbox_DWdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DTI_listbox_DWdata contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DTI_listbox_DWdata
idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
% get(hObject,'Value')
handles.options(idx).DWdata = get(hObject,'Value');
guidata(findobj('Tag','Save_gui'), handles);

% --- Executes during object creation, after setting all properties.
function DTI_listbox_DWdata_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DTI_listbox_DWdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in save_popupmenu_soft.
function save_popupmenu_soft_Callback(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_soft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns save_popupmenu_soft contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_popupmenu_soft
clc
softlist = get(hObject,'String');
softidx = get(hObject,'Value');
soft = char(softlist{softidx});
switch soft
    case {'Default'}
        fileformat = {'Analyse'};
        bitetype = {'int16'};
        dim3D4D = {'3D'};
    case {'ImageJ'}
        fileformat = {'Analyse'};
        bitetype = {'int16'};
        dim3D4D = {'3D'};
    case {'MedINRIA'}
        fileformat = {'Analyse'};
        bitetype = {'int16'};
        dim3D4D = {'3D'};
    case {'MRIcro'}
        fileformat = {'Analyse'};
        bitetype = {'int16'};
        dim3D4D = {'3D'};
    case {'Slicer'}
        fileformat = {'Analyse'};
        bitetype = {'int16'};
        dim3D4D = {'3D'};
    case {'DTIStudio'}
       fileformat = {'Analyse'};
       bitetype = {'int16'};
       dim3D4D = {'3D'};
    case {'Matlab'}
       fileformat = {'Matlab'};
       bitetype = {'double'};
       dim3D4D = {'3D'};
end
fileformat_idx = find(ismember(handles.fileformat,fileformat)==1);
bitetype_idx = find(ismember(handles.bitetype,bitetype)==1);
dim3D4D_idx = find(ismember(handles.dim3D4D,dim3D4D)==1);

set(handles.save_popupmenu_fileformat,'Value',fileformat_idx);
% if isempty(bitetype_idx)
%     set(handles.save_popupmenu_bitetype,'Enable','off');
% else
    set(handles.save_popupmenu_bitetype,'Enable','on');
    set(handles.save_popupmenu_bitetype,'Value',bitetype_idx);
% end
% if isempty(dim3D4D_idx)
%     set(handles.DT_popupmenu_3D4D,'Enable','off');
% else
%     set(handles.DT_popupmenu_3D4D,'Enable','on');
    set(handles.DT_popupmenu_3D4D,'Value',dim3D4D_idx);
% end

idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));

handles.options(idx).soft = get(hObject,'Value');
handles.options(idx).fileformat = fileformat_idx;
handles.options(idx).bitetype = bitetype_idx;
handles.options(idx).dim = dim3D4D_idx;
handles.options(idx).sepfolder = 0;
guidata(findobj('Tag','Save_gui'), handles);


% --- Executes during object creation, after setting all properties.
function save_popupmenu_soft_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_popupmenu_soft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end