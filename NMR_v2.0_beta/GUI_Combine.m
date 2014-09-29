function varargout = GUI_Combine(varargin)
% GUI_COMBINE M-file for gui_combine.fig
%      GUI_COMBINE, by itself, creates a new GUI_COMBINE or raises the existing
%      singleton*.
%
%      H = GUI_COMBINE returns the handle to a new GUI_COMBINE or the handle to
%      the existing singleton*.
%
%      GUI_COMBINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_COMBINE.M with the given input arguments.
%
%      GUI_COMBINE('Property','Value',...) creates a new GUI_COMBINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Combine_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Combine_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_combine

% Last Modified by GUIDE v2.5 14-Aug-2009 13:35:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_Combine_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_Combine_OutputFcn, ...
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


% --- Executes just before gui_combine is made visible.
function GUI_Combine_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_combine (see VARARGIN)

% Choose default command line output for gui_combine
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_GUI_Combine(hObject)

% UIWAIT makes gui_combine wait for user response (see UIRESUME)
% uiwait(handles.GUI_Combine);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Combine_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in comb_pushbutton_combine.
function comb_pushbutton_combine_Callback(hObject, eventdata, handles)
% hObject    handle to comb_pushbutton_combine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filelisthandles = guidata(findobj('Tag','filelistfig'));
filelisthandles.combine = handles.filename;
guidata(findobj('Tag','filelistfig'),filelisthandles);
if get(handles.comb_radiobutton_selection,'Value')==1
    handles.comb_idx = get(filelisthandles.filelistfig_listbox,'Value');
    handles.filename_cur = handles.filename;
    combine_experiment(handles)
else
    if get(handles.array_togglebutton_row_interl,'Value')==0 %in Row
        idx=[handles.array.start:1:handles.array.end];
        if mod(length(idx),handles.array.step)~=0
            idx=[idx zeros(([1 (handles.array.step-mod(length(idx),handles.array.step))]))]
        end
        idx = reshape(idx,handles.array.step,length(idx)/handles.array.step);
        for j=1:1:size(idx,2)
        handles.filename_cur = [handles.filename '_' num2str(j)];
        handles.comb_idx = squeeze(idx(:,j));
        combine_experiment(handles)
        end
    else %Interleaved
        idx=[handles.array.start:1:handles.array.end];
        for j=1:1:handles.array.step
        handles.filename_cur = [handles.filename '_' num2str(j)];
        handles.comb_idx = (handles.array.start+j):handles.array.step:handles.array.end;
        combine_experiment(handles)
        end
        
    end
end
% pause


delete(findobj('Tag','GUI_Combine'))
%     get(findobj(


% --- Executes during object creation, after setting all properties.
function comb_edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to comb_edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

handles.filename = get(hObject,'String');
guidata(hObject,handles)


% --- Executes on button press in comb_radiobutton_selection.
function comb_radiobutton_selection_Callback(hObject, eventdata, handles)
% hObject    handle to comb_radiobutton_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of comb_radiobutton_selection
if get(hObject,'Value')==1
set(handles.comb_radiobutton_selection,'Value',1);
set(get(handles.comb_uipanel_array,'Childre'),'Enable','off')
else
    set(handles.comb_radiobutton_array,'Value',1);
    set(get(handles.comb_uipanel_array,'Children'),'Enable','on')

    try
        set(handles.array_edit_start,'String',num2str(handles.array.start));
        set(handles.array_edit_step,'String',num2str(handles.array.step));
        set(handles.array_edit_end,'String',num2str(handles.array.start));
    catch
        set(handles.array_edit_start,'String','1');
        set(handles.array_edit_step,'String','1');
        set(handles.array_edit_end,'String','1');
    end
    handles.array.start = str2num(get(handles.array_edit_start,'String'));
    handles.array.step = str2num(get(handles.array_edit_step,'String'));  
    handles.array.end = str2num(get(handles.array_edit_end,'String'));
end
guidata(hObject,handles)

% --- Executes on button press in comb_radiobutton_array.
function comb_radiobutton_array_Callback(hObject, eventdata, handles)
% hObject    handle to comb_radiobutton_array (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of comb_radiobutton_array
if get(hObject,'Value')==1
    set(handles.comb_radiobutton_array,'Value',1);
    set(get(handles.comb_uipanel_array,'Children'),'Enable','on')

    try
        set(handles.array_edit_start,'String',num2str(handles.array.start));
        set(handles.array_edit_step,'String',num2str(handles.array.step));
        set(handles.array_edit_end,'String',num2str(handles.array.start));
    catch
        set(handles.array_edit_start,'String','1');
        set(handles.array_edit_step,'String','1');
        set(handles.array_edit_end,'String','1');
    end
    handles.array.start = str2num(get(handles.array_edit_start,'String'));
    handles.array.step = str2num(get(handles.array_edit_step,'String'));  
    handles.array.end = str2num(get(handles.array_edit_end,'String'));

else
    set(handles.comb_radiobutton_selection,'Value',1);
    set(get(handles.comb_uipanel_array,'Childre'),'Enable','off')

end
guidata(hObject,handles)

% --- Executes on button press in array_togglebutton_row_interl.
function array_togglebutton_row_interl_Callback(hObject, eventdata, handles)
% hObject    handle to array_togglebutton_row_interl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of array_togglebutton_row_interl
if get(hObject,'Value')==1 %interleaved
    ex_string{1,1}='e,g: 1 / 5 / 30';
    ex_string{2,1}='<1,6,11,...>; <2,7,12,...>; ...';
    a=get(handles.array_text_exemple,'String');
    set(handles.array_text_exemple,'String',ex_string);
    set(handles.array_text_exemple,'String',ex_string);
    set(handles.array_togglebutton_row_interl,'String','Interleaved');
else %inrow
    ex_string{1,1}='e,g: 1 / 5 / 30';
    ex_string{2,1}='<1-5>; <6-11>; ...';
    a=get(handles.array_text_exemple,'String');
    set(handles.array_text_exemple,'String',ex_string);
    set(handles.array_text_exemple,'String',ex_string);
    set(handles.array_togglebutton_row_interl,'String','In Row');
end
guidata(hObject,handles)



function array_edit_start_Callback(hObject, eventdata, handles)
% hObject    handle to array_edit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of array_edit_start as text
%        str2double(get(hObject,'String')) returns contents of array_edit_start as a double
handles.array.start=str2double(get(hObject,'String'));
guidata(hObject,handles)

function array_edit_step_Callback(hObject, eventdata, handles)
% hObject    handle to array_edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of array_edit_step as text
%        str2double(get(hObject,'String')) returns contents of array_edit_step as a double
handles.array.step=str2double(get(hObject,'String'));
guidata(hObject,handles)


function array_edit_end_Callback(hObject, eventdata, handles)
% hObject    handle to array_edit_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of array_edit_end as text
%        str2double(get(hObject,'String')) returns contents of array_edit_end as a double
handles.array.end=str2double(get(hObject,'String'));
guidata(hObject,handles)

%%
% --- Executes during object creation, after setting all properties.
function array_edit_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_edit_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function array_edit_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_edit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function array_edit_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to array_edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function comb_edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comb_edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


