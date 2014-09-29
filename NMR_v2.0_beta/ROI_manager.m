function varargout = ROI_manager(varargin)
% ROI_MANAGER M-file for ROI_manager.fig
%      ROI_MANAGER, by itself, creates a new ROI_MANAGER or raises the existing
%      singleton*.
%
%      H = ROI_MANAGER returns the handle to a new ROI_MANAGER or the handle to
%      the existing singleton*.
%
%      ROI_MANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_MANAGER.M with the given input
%      arguments.
%
%      ROI_MANAGER('Property','Value',...) creates a new ROI_MANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_manager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_manager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_manager

% Last Modified by GUIDE v2.5 29-Sep-2010 11:26:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_manager_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_manager_OutputFcn, ...
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


% --- Executes just before ROI_manager is made visible.
function ROI_manager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_manager (see VARARGIN)

% Choose default command line output for ROI_manager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_ROI_manager(handles);


% UIWAIT makes ROI_manager wait for user response (see UIRESUME)
% uiwait(handles.ROI_manager);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_manager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in roi_listbox.
function roi_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to roi_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns roi_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from roi_listbox
roi_idx = get(hObject,'Value')
handles.roi_idx = get(hObject,'Value');
roi_list = cellstr(get(hObject,'String'));
handles.roi_list = roi_list;
roi_name = roi_list{roi_idx};
handles.roi_name = roi_name;
set(handles.info_edit_name,'String',roi_name);
set(handles.info_slider_transp,'Value',handles.roilist.(roi_name).transp);
set(handles.info_pushbutton_color,'BackgroundColor',handles.roilist.(roi_name).color);
guidata(handles.ROI_manager,handles);

% handles.roi_list
% roi_name
% handles.roilist.(roi_name)

% --- Executes during object creation, after setting all properties.
function roi_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roi_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in roi_pushbutton_new.
function roi_pushbutton_new_Callback(hObject, eventdata, handles)
% hObject    handle to roi_pushbutton_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
name =['ROI' num2str(length(roi_list)+1)];
handles.roilist.(name).roi = zeros(handles.size);
handles.roilist.(name).color = [1 0 0];
handles.roilist.(name).transp = 1;

set(handles.info_edit_name,'String',name);
set(handles.info_pushbutton_color,'BackgroundColor',handles.roilist.(name).color);
roi_list{length(roi_list)+1} =  name;
set(handles.roi_listbox,'String',roi_list);
set(handles.roi_listbox,'Max',length(roi_list));
set(handles.roi_listbox,'Value',length(roi_list));

guidata(handles.ROI_manager,handles);

% --- Executes on button press in roi_pushbutton_delete.
function roi_pushbutton_delete_Callback(hObject, eventdata, handles)
% hObject    handle to roi_pushbutton_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};
all_idx = 1:length(roi_list);
roi_list = roi_list(setxor(all_idx,roi_idx));
if roi_idx > length(roi_list)
    set(handles.roi_listbox,'Value',length(roi_list))
end
set(handles.roi_listbox,'String',roi_list)
handles.roilist = rmfield(handles.roilist,roi_name);
guidata(handles.ROI_manager,handles);

% --- Executes on button press in roi_pushbutton_load.
function roi_pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to roi_pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in output_pushbutton_excel.
function output_pushbutton_excel_Callback(hObject, eventdata, handles)
% hObject    handle to output_pushbutton_excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function info_edit_name_Callback(hObject, eventdata, handles)
% hObject    handle to info_edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of info_edit_name as text
%        str2double(get(hObject,'String')) returns contents of info_edit_name as a double
new_name=get(hObject,'String');
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx= get(handles.roi_listbox,'Value');
old_name =roi_list{roi_idx};

handles.roilist.(new_name) = handles.roilist.(old_name);
handles.roilist = rmfield(handles.roilist,old_name);
roi_list{roi_idx} = new_name;
set(handles.roi_listbox,'String',roi_list);
guidata(handles.ROI_manager,handles)


% --- Executes during object creation, after setting all properties.
function info_edit_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_edit_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in info_pushbutton_color.
function info_pushbutton_color_Callback(hObject, eventdata, handles)
% hObject    handle to info_pushbutton_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
color = uisetcolor(get(hObject,'BackgroundColor'));
set(hObject,'BackgroundColor',color);

roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

handles.roilist.(roi_name).color=color;

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in info_pushbutton_export.
function info_pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to info_pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in option_checkbox_thres.
function option_checkbox_thres_Callback(hObject, eventdata, handles)
% hObject    handle to option_checkbox_thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of option_checkbox_thres




% --- Executes during object deletion, before destroying properties.
function ROI_manager_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to ROI_manager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject,'Visible','off')


% --- Executes on slider movement.
function info_slider_transp_Callback(hObject, eventdata, handles)
% hObject    handle to info_slider_transp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
transp = get(hObject,'Value');

roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

handles.roilist.(roi_name).transp=transp;

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes during object creation, after setting all properties.
function info_slider_transp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to info_slider_transp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes on button press in tool_pushbutton_paint.
function tool_pushbutton_paint_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_paint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);
thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_draw.
function tool_pushbutton_draw_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_draw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);


if get(handles.options_checkbox_thres,'Value')==1
    thres(1)=get(handles.options_slider_thresmin,'Value');
    thres(2)=get(handles.options_slider_thresmax,'Value');
else
    thres=[];
end

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_poly.
function tool_pushbutton_poly_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_poly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_rect.
function tool_pushbutton_rect_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_rect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_thres.
function tool_pushbutton_thres_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_erode.
function tool_pushbutton_erode_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_erode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');
d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_exp.
function tool_pushbutton_exp_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;

% --- Executes on button press in tool_pushbutton_circ.
function tool_pushbutton_circ_Callback(hObject, eventdata, handles)
% hObject    handle to tool_pushbutton_circ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = get(hObject,'String');

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

thres = get(handles.options_checkbox_thres,'Value');

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e,thres);

guidata(handles.ROI_manager,handles);
ImageOrient_display;


function options_edit_thresmax_Callback(hObject, eventdata, handles)
% hObject    handle to options_edit_thresmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of options_edit_thresmax as text
%        str2double(get(hObject,'String')) returns contents of options_edit_thresmax as a double


% --- Executes during object creation, after setting all properties.
function options_edit_thresmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to options_edit_thresmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function options_edit_thresmin_Callback(hObject, eventdata, handles)
% hObject    handle to options_edit_thresmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of options_edit_thresmin as text
%        str2double(get(hObject,'String')) returns contents of options_edit_thresmin as a double


% --- Executes during object creation, after setting all properties.
function options_edit_thresmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to options_edit_thresmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function options_slider_thresmax_Callback(hObject, eventdata, handles)
% hObject    handle to options_slider_thresmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function options_slider_thresmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to options_slider_thresmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function options_slider_thresmin_Callback(hObject, eventdata, handles)
% hObject    handle to options_slider_thresmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function options_slider_thresmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to options_slider_thresmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in options_checkbox_thres.
function options_checkbox_thres_Callback(hObject, eventdata, handles)
% hObject    handle to options_checkbox_thres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of options_checkbox_thres


% --- Executes on button press in output_pushbutton_refresh.
function output_pushbutton_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to output_pushbutton_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImageOrient_display;


% --- Executes on button press in info_pushbutton_copynext.
function info_pushbutton_copynext_Callback(hObject, eventdata, handles)
% hObject    handle to info_pushbutton_copynext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = 'copy_next';

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e);

guidata(handles.ROI_manager,handles);

% --- Executes on button press in info_pushbutton_copyprev.
function info_pushbutton_copyprev_Callback(hObject, eventdata, handles)
% hObject    handle to info_pushbutton_copyprev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
roi_list = cellstr(get(handles.roi_listbox,'String'));
roi_idx = get(handles.roi_listbox,'Value');
roi_name =roi_list{roi_idx};

roi = handles.roilist.(roi_name).roi;
tool = 'copy_prev';

d_e = abs(get(handles.options_checkbox_erase,'Value')-1);

handles.roilist.(roi_name).roi = ROI_create(roi,tool,d_e);

guidata(handles.ROI_manager,handles);

% --- Executes on button press in options_checkbox_erase.
function options_checkbox_erase_Callback(hObject, eventdata, handles)
% hObject    handle to options_checkbox_erase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of options_checkbox_erase


% --- Executes on button press in output_pushbutton_crop.
function output_pushbutton_crop_Callback(hObject, eventdata, handles)
% hObject    handle to output_pushbutton_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
