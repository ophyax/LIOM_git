function varargout = mainmenu(varargin)
% mainmenu M-file for mainmenu.fig
%      mainmenu, by itself, creates a new mainmenu or raises the existing
%      singleton*.
%
%      H = mainmenu returns the handle to a new mainmenu or the handle to
%      the existing singleton*.
%
%      mainmenu('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in mainmenu.M with the given input arguments.
%
%      mainmenu('Property','Value',...) creates a new mainmenu or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mainmenu_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mainmenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mainmenu

% Last Modified by GUIDE v2.5 09-Sep-2010 11:24:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @mainmenu_OpeningFcn, ...
    'gui_OutputFcn',  @mainmenu_OutputFcn, ...
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


% --- Executes just before mainmenu is made visible.
function mainmenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mainmenu (see VARARGIN)

% Choose default command line output for mainmenu
handles.output = hObject;
handles.fct_acqtype_adaptation=@acqtype_adaption;
% Update handles structure
guidata(hObject, handles);
initialize_mainmenu(hObject)

% UIWAIT makes mainmenu wait for user response (see UIRESUME)
% uiwait(handles.mainmenu);


% --- Outputs from this function are returned to the command line.
function varargout = mainmenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in mainmeu_pushbutton_filelist.
function mainmeu_pushbutton_filelist_Callback(hObject, eventdata, handles)
% hObject    handle to mainmeu_pushbutton_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_Filelist

% --------------------------------------------------------------------
function mainmenu_menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function main_menu_filelist_Callback(hObject, eventdata, handles)
% hObject    handle to main_menu_filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_Filelist

% --------------------------------------------------------------------
function mainmenu_menu_close_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_menu_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close_exit(handles)

% --------------------------------------------------------------------
%    structure with handles and user data (see GUIDATA)



function dispopt_edit_datanum_Callback(hObject, eventdata, handles, displayctrl)
% hObject    handle to dispopt_edit_datanum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispopt_edit_datanum as text
%        str2double(get(hObject,'String')) returns contents of dispopt_edit_datanum as a double
if nargin>3
    %     displayctrl = displayctrl;
else
    displayctrl=1;
end


datenum_str = get(handles.dispopt_edit_datanum,'String');
sepidx = findstr(datenum_str,'|');
if hObject==handles.dispopt_edit_datanum || displayctrl==1
    if length(sepidx)==1 || length(sepidx)==2
        try
            dataidx=str2double(datenum_str(1:sepidx(1)-1));
            if isfield(handles.datalist(handles.dispopts.dataidx).data,'real')
                dime = size(handles.datalist(handles.dispopts.dataidx).data.real);
            elseif isfield(handles.datalist(handles.dispopts.dataidx).data,'fdf')
                dime = size(handles.datalist(handles.dispopts.dataidx).data.fdf);
            end
            if isnumeric(dataidx)==0 || round(dataidx)/dataidx~=1 || ...
                    dataidx<1 || dataidx>length(handles.datalist)
                error('dataidx has the wrong format')
            end
            if length(sepidx)==1
                arrayidx=str2double(datenum_str((sepidx(1)+1):length(datenum_str)));
            elseif length(sepidx)==2
                nv1_idx=str2double(datenum_str((sepidx(1)+1):sepidx(2)-1));
                nv2_idx=str2double(datenum_str((sepidx(2)+1):length(datenum_str)));
                arrayidx=...
                    (nv1_idx-1)*dime(2)+nv2_idx;
            end
            if isnumeric(arrayidx)==0 || round(arrayidx)/arrayidx~=1 || ...
                    arrayidx>dime(1)*dime(2) || ...
                    arrayidx<1
                error('arrayidx has the wrong format')
            end
            handles.dispopts.dataidx=dataidx;
            handles.dispopts.arrayidx=arrayidx;
            guidata(handles.mainmenu,handles)
        catch
            disp('1 data index has not the right format!')
        end
    else
        disp('2 data index has not the right format!')
    end
end
if isfield(handles.datalist(handles.dispopts.dataidx).data,'real')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.real);
elseif isfield(handles.datalist(handles.dispopts.dataidx).data,'fdf')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.fdf);
end

if dime(2)==1
    datenum_str=[num2str(handles.dispopts.dataidx) '|' num2str(handles.dispopts.arrayidx)];
else
    nv1_idx=floor((handles.dispopts.arrayidx-1)/dime(1))+1;
    nv2_idx=mod(handles.dispopts.arrayidx,dime(1));
    if nv2_idx==0
        nv2_idx=dime(1);
    end
    datenum_str=[num2str(handles.dispopts.dataidx) '|' num2str(nv1_idx) '|' num2str(nv2_idx)];
end
set(handles.dispopt_edit_datanum,'String',datenum_str)
if findobj('Tag','filelistfig')
    filelisthandle=guidata(findobj('Tag','filelistfig'));
    
    set(filelisthandle.filelistfig_listbox,'Value',handles.dispopts.dataidx);
    guidata(findobj('Tag','filelistfig'),filelisthandle);
end
if displayctrl~=0
    displaycontrol
end


% --- Executes during object creation, after setting all properties.
function dispopt_edit_datanum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispopt_edit_datanum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispopt_pushbutton_dispMRS.
function dispopt_pushbutton_dispMRS_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_dispMRS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.dispopt_togglebutton_dispMRS =  get(hObject,'Value');
% guidata(handles.mainmenu,handles)
displaycontrol

% --- Executes on button press in dispopt_pushbutton_dispMRI.
function dispopt_pushbutton_dispMRI_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_dispMRI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% handles.dispopt_togglebutton_dispMRI =  get(hObject,'Value');
% guidata(handles.mainmenu,handles)
displaycontrol

% --- Executes on button press in dispopt_togglebutton_dispCSI.
function dispopt_togglebutton_dispCSI_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_togglebutton_dispCSI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_togglebutton_dispCSI
% handles.dispopt_togglebutton_dispCSI =  get(hObject,'Value');
% guidata(handles.mainmenu,handles)
displaycontrol

% --- Executes on button press in dispopt_pushbutton_dispbefore.
function dispopt_pushbutton_dispbefore_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_dispbefore (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datenum_str=get(handles.dispopt_edit_datanum,'String');
sepidx=findstr('|',datenum_str);
dataidx = str2double(datenum_str(1:sepidx(1)-1));

if isfield(handles.datalist(handles.dispopts.dataidx).data,'real')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.real);
elseif isfield(handles.datalist(handles.dispopts.dataidx).data,'fdf')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.fdf);
end
if length(sepidx)==1
    arrayidx=str2double(datenum_str((sepidx(1)+1):length(datenum_str)));
elseif length(sepidx)==2
    nv1_idx=str2double(datenum_str((sepidx(1)+1):sepidx(2)-1));
    nv2_idx=str2double(datenum_str((sepidx(2)+1):length(datenum_str)));
    arrayidx=...
        (nv1_idx-1)*dime(2)+nv2_idx;
end
if dataidx>1
    if handles.datalist(dataidx).multiplicity>1 && arrayidx>1 && ...
            get(handles.dispopt_togglebutton_dispCSI,'Value')==0
        arrayidx=arrayidx-1;
    else
        dataidx=dataidx-1;
        arrayidx=handles.datalist(dataidx).multiplicity;
    end
elseif dataidx==1
    if handles.datalist(dataidx).multiplicity>1 && arrayidx>1 && ...
            get(handles.dispopt_togglebutton_dispCSI,'Value')==0
        arrayidx=arrayidx-1;
    elseif arrayidx==1
        dataidx=length(handles.datalist);
        arrayidx=handles.datalist(length(handles.datalist)).multiplicity;
    end
end
if handles.dispopts.dataidx~=dataidx || handles.dispopts.arrayidx~=arrayidx
    %     acqtype_adaption(handles,dataidx)
    handles.dispopts.dataidx=dataidx;
    handles.dispopts.arrayidx=arrayidx;
    %     handles.switch.phasecorrection=1;
    %     handles.switch.apodization=1;
    %     handles.switch.transformsize=1;
    guidata(handles.mainmenu,handles)
    %     dispopt_edit_datanum_Callback(hObject, eventdata, handles)
    displaycontrol
end

% --- Executes on button press in dispopt_pushbutton_dispnext.
function dispopt_pushbutton_dispnext_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_dispnext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datenum_str=get(handles.dispopt_edit_datanum,'String');
sepidx=findstr('|',datenum_str);
dataidx = str2double(datenum_str(1:sepidx(1)-1));

if isfield(handles.datalist(handles.dispopts.dataidx).data,'real')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.real);
elseif isfield(handles.datalist(handles.dispopts.dataidx).data,'fdf')
    dime = size(handles.datalist(handles.dispopts.dataidx).data.fdf);
else
    disp('mainmenu 303: no dime variable')
end
if length(sepidx)==1
    arrayidx=str2double(datenum_str((sepidx(1)+1):length(datenum_str)));
elseif length(sepidx)==2
    nv1_idx=str2double(datenum_str((sepidx(1)+1):sepidx(2)-1));
    nv2_idx=str2double(datenum_str((sepidx(2)+1):length(datenum_str)));
    arrayidx=...
        (nv1_idx-1)*dime(2)+nv2_idx;
end
if dataidx<length(handles.datalist)
    if handles.datalist(dataidx).multiplicity>1 && ...
            arrayidx<handles.datalist(dataidx).multiplicity && ...
            get(handles.dispopt_togglebutton_dispCSI,'Value')==0
        arrayidx=arrayidx+1;
    else
        dataidx=dataidx+1;
        arrayidx=1;
    end
elseif dataidx==length(handles.datalist)
    if handles.datalist(dataidx).multiplicity>1 && ...
            arrayidx<handles.datalist(dataidx).multiplicity  && ...
            get(handles.dispopt_togglebutton_dispCSI,'Value')==0
        arrayidx=arrayidx+1;
    elseif arrayidx==handles.datalist(dataidx).multiplicity
        dataidx=1;
        arrayidx=1;
    end
end

if handles.dispopts.dataidx~=dataidx || handles.dispopts.arrayidx~=arrayidx
    %     set(handles.text_currentfile,'Visible','on')
    handles.dispopts.dataidx=dataidx;
    handles.dispopts.arrayidx=arrayidx;
    guidata(handles.mainmenu,handles)
    %     handles.switch.phasecorrection=1;
    %     handles.switch.apodization=1;
    %     handles.switch.transformsize=1;
    %     dispopt_edit_datanum_Callback(hObject, eventdata, handles)
    displaycontrol
end

% --- Executes on button press in dispopt_pushbutton_dispinfo.
function dispopt_pushbutton_dispinfo_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_dispinfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
paramstr=handles.datalist(handles.dispopts.dataidx).params;
cellstr_of_struct=struct2cellstr(paramstr);
pos=get(findobj('Tag','filelistfig'),'Position');
if isempty(findobj('Tag','fileinfo'))
    h_fileinfo=figure('Tag','fileinfo','Name','File Info','NumberTitle','off',...
        'Units','normalized','MenuBar','none','Position',pos);
else isempty(findobj('Tag','fileinfo'))
    figure(findobj('Tag','fileinfo'))
end
uicontrol('Style','listbox','Units','normalized','Position',[0.0 0.0 1 1],...
    'String',cellstr_of_struct)

% --- Executes on button press in dispopts_radiobutton_format_real.
function dispopts_radiobutton_format_real_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_radiobutton_format_real (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_radiobutton_format_real
if isempty(find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1,1))
    set(hObject,'Value',1)
    return
end
displaycontrol


% --- Executes on button press in dispopts_radiobutton_format_imag.
function dispopts_radiobutton_format_imag_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_radiobutton_format_imag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_radiobutton_format_imag
if isempty(find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1,1))
    set(hObject,'Value',1)
    return
end
displaycontrol


% --- Executes on button press in dispopts_radiobutton_format_absval.
function dispopts_radiobutton_format_absval_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_radiobutton_format_absval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_radiobutton_format_absval
if isempty(find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1,1))
    set(hObject,'Value',1)
    return
end
displaycontrol


% --- Executes on button press in dispopts_radiobutton_format_phase.
function dispopts_radiobutton_format_phase_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_radiobutton_format_phase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_radiobutton_format_phase
if isempty(find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1,1))
    set(hObject,'Value',1)
    return
end
displaycontrol


% --- Executes on button press in dispopts_radiobutton_format_fdf.
function dispopts_radiobutton_format_fdf_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_radiobutton_format_fdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_radiobutton_format_fdf
if isempty(find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1,1))
    set(hObject,'Value',1)
    return
end
displaycontrol


% --- Executes on button press in dispopts_togglebutton_format_rawfft.
function dispopts_togglebutton_format_rawfft_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_togglebutton_format_rawfft (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_togglebutton_format_rawfft
if get(hObject,'Value')
    set(hObject,'String','FID')
else
    set(hObject,'String','FFT')
    
end
displaycontrol


% --- Executes on button press in dispopts_pushbutton_orient.
function dispopts_pushbutton_orient_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_pushbutton_orient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_pushbutton_orient
GUI_ImageOrientation


% --- Executes on selection change in dispopt_popupmenu_DWI.
function dispopt_popupmenu_DWI_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_popupmenu_DWI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns dispopt_popupmenu_DWI contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dispopt_popupmenu_DWI

% diff_idx = get(hObject,'Value');
% handles.datalist(handles.dispopts.dataidx).data.fdf = squeeze(handles.datalist(handles.dispopts.dataidx).data.diff(:,:,:,diff_idx));
% guidata(hObject, handles);
displaycontrol;


% --- Executes during object creation, after setting all properties.
function dispopt_popupmenu_DWI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispopt_popupmenu_DWI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_pushbutton_process.
function process_pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to process_pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_Process;

% --- Executes on button press in process_pushbutton_orient.
function process_pushbutton_orient_Callback(hObject, eventdata, handles)
% hObject    handle to process_pushbutton_orient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_ImageOrientation;


% --- Executes when user attempts to close mainmenu.
function mainmenu_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
close_exit(handles)
% delete(hObject);


% --- Executes on button press in dispopt_pushbutton_setref.
function dispopt_pushbutton_setref_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_setref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cursor_struct=getCursorInfo(handles.dcm_obj);
if isempty(cursor_struct)==0
    pos = cursor_struct.Position;
    newref = str2double(get(handles.dispopt_edit_refline,'String'));
    if isempty(newref) || isnumeric(newref)==0
        errordlg('Format entry must be numeric')
    end
    refoffset = (newref-pos(1));
    
    if get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ... FFT
            get(handles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
%         disp('1')
        if isfield(handles.dispopts,'refoffset')
            refoffset = (refoffset + handles.dispopts.refoffset./(handles.datalist(handles.dispopts.dataidx).params.sfrq));
        end
        handles.dispopts.refoffset=...
            refoffset.*(handles.datalist(handles.dispopts.dataidx).params.sfrq);
        disp(handles.datalist(handles.dispopts.dataidx).params.sfrq)
        disp(handles.dispopts.refoffset)
    elseif get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ... %FFT
            get(handles.dispopts_togglebutton_format_ppmhz,'Value') % Hz
%         disp('2')
        if isfield(handles.dispopts,'refoffset')
            refoffset = +refoffset + handles.dispopts.refoffset;
        end
        handles.dispopts.refoffset=refoffset;
    elseif get(handles.dispopts_togglebutton_format_rawfft,'Value') % sec
%         disp('3')
        if isfield(handles.dispopts,'refoffset')
            refoffset = +refoffset + handles.dispopts.refoffset;
        end
        handles.dispopts.refoffset=1./refoffset;
    end
    disp(handles.dispopts.refoffset)
    set(handles.dispopt_radiobutton_datacursor,'Value',0);
    datacursormode off
    set(handles.dispopt_pushbutton_setref,'Enable','off');
    set(handles.dispopt_edit_refline,'Enable','off');
    guidata(handles.mainmenu,handles)
    displaycontrol
else
    disp('set data cursor')
end



% --- Executes on button press in dispopts_togglebutton_format_ppmhz.
function dispopts_togglebutton_format_ppmhz_Callback(hObject, eventdata, handles)
% hObject    handle to dispopts_togglebutton_format_ppmhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopts_togglebutton_format_ppmhz
if get(hObject,'Value')
    set(hObject,'String','Hz')
else
    set(hObject,'String','ppm')
    
end
displaycontrol



function dispopt_edit_refline_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_edit_refline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dispopt_edit_refline as text
%        str2double(get(hObject,'String')) returns contents of
%        dispopt_edit_refline as a double

% cursor_struct=getCursorInfo(handles.dcm_obj);
% if isempty(cursor_struct)==0
%     pos = cursor_struct.Position;
%     newref = str2double(get(handles.dispopt_edit_refline,'String'));
%     if isempty(newref) || isnumeric(newref)==0
%         errordlg('Format entry must be numeric')
%     end
%     refoffset = newref-pos(1);
%     if get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ... FFT
%             get(handles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
%         handles.dispopts.refoffset=...
%             refoffset.*(handles.datalist(handles.dispopts.dataidx).params.sfrq);
%     elseif get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ... %FFT
%             get(handles.dispopts_togglebutton_format_ppmhz,'Value') % Hz
%         handles.dispopts.refoffset=refoffset;
%     elseif get(handles.dispopts_togglebutton_format_rawfft,'Value') % sec
%         handles.dispopts.refoffset=1./refoffset;
%     end
%     set(handles.dispopt_radiobutton_datacursor,'Value',0);
%     guidata(handles.mainmenu,handles)
%     displaycontrol
% else
%     disp('set data cursor')
% end



% --- Executes during object creation, after setting all properties.
function dispopt_edit_refline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispopt_edit_refline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispopt_radiobutton_datacursor.
function dispopt_radiobutton_datacursor_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_radiobutton_datacursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_radiobutton_datacursor

if get(gco,'Value')
    datacursormode on
    handles.dcm_obj = datacursormode(handles.mainmenu);
    set(handles.dcm_obj,'DisplayStyle','Datatip','SnapToDataVertex','on',...
        'UpdateFcn',@cursorupdatefcn,'Enable','on')
    %     datacursormode(handles.mainmenu,'Enable','on')
    set(handles.dispopt_pushbutton_setref,'Enable','on')
    set(handles.dispopt_edit_refline,'Enable','on')
    guidata(handles.mainmenu,handles)
else
    if isfield(handles,'dcm_obj')
        set(handles.dcm_obj,'Enable','off')
        datacursormode(handles.mainmenu)%,'Enable','off')
        handles.dcm_obj = datacursormode(handles.mainmenu);
    end
    datacursormode off
    set(handles.dispopt_pushbutton_setref,'Enable','off')
    set(handles.dispopt_edit_refline,'Enable','off')
end

% cursorupdatefcn - Click on line to select data point
function txt = cursorupdatefcn(empt,event_obj)
pos = get(event_obj,'Position');
disp(pos)
objstruct=get(get(event_obj,'Target'));
% txt = {[num2str(pos(1))],[num2str(pos(2))]}
if isfield(objstruct,'UData')
    txt = {[num2str(pos(1))],...
        [num2str(pos(2)) ' +- ' num2str(objstruct.UData(pos(1)))]};
elseif isfield(objstruct,'ZData') && isempty(objstruct.ZData)==0 && isnumeric(objstruct.ZData)
    txt = {[num2str(pos(1))],[num2str(pos(2))],[num2str(pos(3))]};
elseif isfield(objstruct,'CData')
    txt = {[num2str(pos(1))],[num2str(pos(2))],...
        num2str(objstruct.CData(pos(1),pos(2)))};
else
    txt = {[num2str(pos(1))],[num2str(pos(2))]};
end



function display_edit_xlim2_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% all_curaxes=findobj('Type','axes','Parent',handles.mainfig_uipanel_axes);
limvec = sort([str2double(get(gco,'String')) str2double(get(handles.display_edit_xlim1,'String'))]);
set_axis_limits(handles,'x',limvec)
function display_edit_xlim1_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% all_curaxes=findobj('Type','axes','Parent',handles.mainfig_uipanel_axes);
limvec = sort([str2double(get(gco,'String')) str2double(get(handles.display_edit_xlim2,'String'))]);
disp(limvec)
set_axis_limits(handles,'x',limvec)
function display_edit_ylim2_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% all_curaxes=findobj('Type','axes','Parent',handles.mainfig_uipanel_axes);
limvec = sort([str2double(get(gco,'String')) str2double(get(handles.display_edit_ylim1,'String'))]);
set_axis_limits(handles,'y',limvec)
function display_edit_ylim1_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% all_curaxes=findobj('Type','axes','Parent',handles.mainfig_uipanel_axes);
limvec = sort([str2double(get(gco,'String')) str2double(get(handles.display_edit_ylim2,'String'))]);
set_axis_limits(handles,'y',limvec)


function set_axis_limits(handles,axesorient,limvec)
% axesorient=x or y
all_curaxes=findobj('Type','axes','Parent',handles.mainmenu_uipanel_axes);
errmsg = '';
if isnumeric(limvec)==0 || sum(isnan(limvec))>0
    errmsg = 'values have to be numeric';
elseif limvec(1)>=limvec(2)
    errmsg = 'vector values must be increasing';
end
if strcmp(errmsg,'')
    switch axesorient
        case 'x'
            set(all_curaxes,'XLim',limvec);
            if get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ...
                    get(handles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                handles.dispopts.axesscaling.x(...
                            get(handles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                     limvec.*(handles.datalist(handles.dispopts.dataidx).params.sfrq)+...
                     handles.datalist(handles.dispopts.dataidx).ppm_ref;
                
            elseif get(handles.dispopts_togglebutton_format_rawfft,'Value')==0 && ...
                    get(handles.dispopts_togglebutton_format_ppmhz,'Value') % Hz
                handles.dispopts.axesscaling.x(...
                            get(handles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=limvec;
%                          disp(handles.dispopts.axesscaling.x)
            elseif get(handles.dispopts_togglebutton_format_rawfft,'Value') % sec
                handles.dispopts.axesscaling.x(...
                            get(handles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=limvec;
            end
        case 'y'
            set(all_curaxes,'YLim',limvec);
            selidx=find(cell2mat(get(get(handles.dispopts_uipanel_dataformat,'children'),'Value'))==1);
            handles.dispopts.axesscaling.y(get(handles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:)=...
                sort(limvec);
    end
    handles.dispopts.axesscaling.switch=1;
    guidata(handles.mainmenu,handles)
%     set(findobj('Parent',handles.mainfig_uipanel_axes,'Type','uicontrol','Style','edit'),...
%         'Visible','off','Selected','off')
    displaycontrol
else
    h_error=errordlg(errmsg);
    waitfor(h_error)
    return
end

% --- Executes during object creation, after setting all properties.
function display_edit_xlim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_edit_xlim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes during object creation, after setting all properties.
function display_edit_xlim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_edit_xlim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function display_edit_ylim1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_edit_ylim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function display_edit_ylim2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_edit_ylim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dispopt_radiobutton_zoom.
function dispopt_radiobutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_radiobutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_radiobutton_zoom
if get(hObject,'Value')
    if strcmp(handles.datalist(handles.dispopts.dataidx).acqtype,'MRI')
        zoom on
    else
        zoom xon
    end
else
    zoom off
end

% --- Executes on button press in dispopt_radiobutton_axislim.
function dispopt_radiobutton_axislim_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_radiobutton_axislim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_radiobutton_axislim
if get(hObject,'Value')
    set(handles.display_edit_xlim1,'Visible','on');
    set(handles.display_edit_xlim2,'Visible','on');
    set(handles.display_edit_ylim1,'Visible','on');
    set(handles.display_edit_ylim2,'Visible','on');    
    data=get(handles.currentplot,'UserData');
    xdata=get(handles.currentplot,'XData');   
    xlim1=get(handles.display_edit_xlim1,'String');
    if ischar(xlim1)
        xlim1=max(xdata);
        xlim2=min(xdata);
        ylim1=min(data);
        ylim2=max(data);
        set(handles.display_edit_xlim1,'String',num2str(xlim1));
        set(handles.display_edit_xlim2,'String',num2str(xlim2));
        set(handles.display_edit_ylim1,'String',num2str(ylim1));
        set(handles.display_edit_ylim2,'String',num2str(ylim2));
    end

else
    set(handles.display_edit_xlim1,'Visible','off');
    set(handles.display_edit_xlim2,'Visible','off');
    set(handles.display_edit_ylim1,'Visible','off');
    set(handles.display_edit_ylim2,'Visible','off');
end


% --- Executes on button press in dispopt_pushbutton_resetdisp.
function dispopt_pushbutton_resetdisp_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_pushbutton_resetdisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.dispopts.ppmhz=1; % instead of hz
handles.dispopts.mode = 'absval';
set(handles.dispopts_togglebutton_format_ppmhz,'Value',0,'String','ppm');
set(handles.dispopts_togglebutton_format_rawfft,'Value',0,'String','FFT / raw');
set(handles.dispopts_radiobutton_format_absval,'Value',1);
% set(handles.dispopts_togglebutton_format_fdf,'Value',0)
set(handles.dispopt_radiobutton_grid,'Value',0);

handles.dispopts.resetdisp=1;
handles.dispopts.axesscaling.switch = 0;
handles.dispopts.axesscaling.x=zeros(2,2);
handles.dispopts.axesscaling.y=zeros(2,5,2);
% dispopt_radiobutton_axislim_Callback(hObject, eventdata, handles);
guidata(handles.mainmenu,handles)
displaycontrol


% --- Executes on button press in dispopt_radiobutton_grid.
function dispopt_radiobutton_grid_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_radiobutton_grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_radiobutton_grid
displaycontrol


% --------------------------------------------------------------------
function mainmenu_menu_open_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_menu_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(findobj('Tag','filelistfig'))
    GUI_Filelist;
end
create_filelist;
updatedata;
set(findobj('Tag','filelistfig'),'Visible','on');


% --------------------------------------------------------------------
function mainmenu_menu_options_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_menu_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function main_menu_preferences_Callback(hObject, eventdata, handles)
% hObject    handle to main_menu_preferences (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_options


% --- Executes on button press in dispopt_togglebutton_dispDSS.
function dispopt_togglebutton_dispDSS_Callback(hObject, eventdata, handles)
% hObject    handle to dispopt_togglebutton_dispDSS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dispopt_togglebutton_dispDSS
if get(hObject,'Value')==1
    set(handles.mainmenu_uipanel_options,'Visible','on')
else
    set(handles.mainmenu_uipanel_options,'Visible','off')
end
displaycontrol



function mainmenu_options_edit1_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainmenu_options_edit1 as text
%        str2double(get(hObject,'String')) returns contents of mainmenu_options_edit1 as a double
val = str2double(get(hObject,'String'));
if val<1
    set(hObject,'String','1')
elseif val>handles.datalist(handles.dispopts.dataidx).multiplicity
    set(hObject,'String',num2str(handles.datalist(handles.dispopts.dataidx).multiplicity))
end
displaycontrol

% --- Executes during object creation, after setting all properties.
function mainmenu_options_edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mainmenu_options_edit2_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainmenu_options_edit2 as text
%        str2double(get(hObject,'String')) returns contents of mainmenu_options_edit2 as a double
val = str2double(get(hObject,'String'));
if val<1
    set(hObject,'String','1')
elseif val>handles.datalist(handles.dispopts.dataidx).multiplicity
    set(hObject,'String',num2str(handles.datalist(handles.dispopts.dataidx).multiplicity))
end
displaycontrol

% --- Executes during object creation, after setting all properties.
function mainmenu_options_edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mainmenu_options_edit3_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainmenu_options_edit3 as text
%        str2double(get(hObject,'String')) returns contents of mainmenu_options_edit3 as a double
val = str2double(get(hObject,'String'));
if val<1
    set(hObject,'String','1')
elseif val>handles.datalist(handles.dispopts.dataidx).multiplicity
    set(hObject,'String',num2str(handles.datalist(handles.dispopts.dataidx).multiplicity))
end
displaycontrol

% --- Executes during object creation, after setting all properties.
function mainmenu_options_edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mainmenu_options_edit4_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainmenu_options_edit4 as text
%        str2double(get(hObject,'String')) returns contents of mainmenu_options_edit4 as a double
displaycontrol

% --- Executes during object creation, after setting all properties.
function mainmenu_options_edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mainmenu_options_edit5_Callback(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mainmenu_options_edit5 as text
%        str2double(get(hObject,'String')) returns contents of mainmenu_options_edit5 as a double

displaycontrol
% --- Executes during object creation, after setting all properties.
function mainmenu_options_edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainmenu_options_edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function main_menu_load_study_Callback(hObject, eventdata, handles)
% hObject    handle to main_menu_load_study (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_open_mainhandles('load');

% --------------------------------------------------------------------
function main_menu_save_study_Callback(hObject, eventdata, handles)
% hObject    handle to main_menu_save_study (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_open_mainhandles('save');
