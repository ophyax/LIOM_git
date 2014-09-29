function varargout = GUI_Process(varargin)
% GUI_PROCESS M-file for GUI_Process.fig
%      GUI_PROCESS, by itself, creates a new GUI_PROCESS or raises the existing
%      singleton*.
%
%      H = GUI_PROCESS returns the handle to a new GUI_PROCESS or the handle to
%      the existing singleton*.
%
%      GUI_PROCESS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_PROCESS.M with the given input arguments.
%
%      GUI_PROCESS('Property','Value',...) creates a new GUI_PROCESS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Process_OpeningFunction gets called.
%      An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Process_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Process

% Last Modified by GUIDE v2.5 16-Aug-2010 17:23:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_Process_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_Process_OutputFcn, ...
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


% --- Executes just before GUI_Process is made visible.
function GUI_Process_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Process (see VARARGIN)

% Choose default command line output for GUI_Process
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_processfig(hObject)

% UIWAIT makes GUI_Process wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Process_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

mainhandles=guidata(findobj('Tag','mainmenu'));
set(handles.processfig_text_np,'String',...
    ['transform size of FID ' num2str(mainhandles.datalist(mainhandles.dispopts.dataidx).np/2) ' points to'])


%--- Phasecorrection ------------------------------------------------
%----------------------------------------------------------------
function processfig_edit_phasecorr0_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.process.phasecorr0 = round(str2double(get(hObject,'String'))*100)/100;
if mainhandles.process.phasecorr0 > get(handles.processfig_slider_phasecorr0,'Max') || ...
        mainhandles.process.phasecorr0 < get(handles.processfig_slider_phasecorr0,'Min')
    mainhandles.process.phasecorr0=get(handles.processfig_slider_phasecorr0,'Value');
    set(handles.processfig_edit_phasecorr0,'String',mainhandles.process.phasecorr0);
else
    set(handles.processfig_slider_phasecorr0,'Value',mainhandles.process.phasecorr0);
end
if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
        mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(mainhandles.dispopts.arrayidx)=...
        mainhandles.process.phasecorr0;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0=...
        mainhandles.process.phasecorr0;
end
set(handles.processfig_slider_phasecorr0,'Value',mainhandles.process.phasecorr0)
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
guidata(findobj('Tag','processfig'),handles);
processfig_togglebutton_appltoarray1_Callback(hObject, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );
% --- Executes on slider movement.
function processfig_slider_phasecorr0_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.process.phasecorr0 = round(get(hObject,'Value')*100)/100;
set(handles.processfig_slider_phasecorr0,'Value',mainhandles.process.phasecorr0);
set(handles.processfig_edit_phasecorr0,'String',num2str(mainhandles.process.phasecorr0))
if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
        mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(mainhandles.dispopts.arrayidx)=...
        mainhandles.process.phasecorr0;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0=...
        mainhandles.process.phasecorr0;
end
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles)
guidata(findobj('Tag','processfig'),handles);
processfig_togglebutton_appltoarray1_Callback(hObject, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );

%----------------------------------------------------------------
function processfig_edit_phasecorr1_Callback(hObject, eventdata, handles)
mainhandles= guidata(findobj('Tag','mainmenu'));
mainhandles.process.phasecorr1 = round(str2double(get(hObject,'String'))*100)/100;
if mainhandles.process.phasecorr1 > get(handles.processfig_slider_phasecorr1,'Max') || ...
        mainhandles.process.phasecorr1 < get(handles.processfig_slider_phasecorr1,'Min')
    mainhandles.process.phasecorr1=get(handles.processfig_slider_phasecorr1,'Value');
    set(handles.processfig_edit_phasecorr1,'String',mainhandles.process.phasecorr1);
else
    set(handles.processfig_slider_phasecorr1,'Value',mainhandles.process.phasecorr1);
end
if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
        mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(mainhandles.dispopts.arrayidx)=...
        mainhandles.process.phasecorr1;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1=...
        mainhandles.process.phasecorr1;
end
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
guidata(findobj('Tag','processfig'),handles);
processfig_togglebutton_appltoarray1_Callback(hObject, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );
% --- Executes on slider movement.
function processfig_slider_phasecorr1_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.process.phasecorr1 = round(get(hObject,'Value')*100)/100;
set(handles.processfig_slider_phasecorr1,'Value',mainhandles.process.phasecorr1);
set(handles.processfig_edit_phasecorr1,'String',num2str(mainhandles.process.phasecorr1))
if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
        mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(mainhandles.dispopts.arrayidx)=...
        mainhandles.process.phasecorr1;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1=...
        mainhandles.process.phasecorr1;
end
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
displaycontrol
set(handles.processfig,'Visible','on' );
guidata(findobj('Tag','processfig'),handles);
processfig_togglebutton_appltoarray1_Callback(hObject, eventdata, handles)
% --- Executes on button press in processfig_togglebutton_appltoarray1.
function processfig_togglebutton_appltoarray1_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
if get(handles.processfig_togglebutton_appltoarray1,'Value')
    if mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity > 1
        for i=1:mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity
            mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(i)=...
                mainhandles.process.phasecorr0;
            %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(mainhandles.dispopts.arrayidx);
            mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(i)=...
                mainhandles.process.phasecorr1;
            %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(mainhandles.dispopts.arrayidx);
        end
    end
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1=1;
    mainhandles.switch.phasecorrection=1;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1=0;
end
guidata(findobj('Tag','mainmenu'),mainhandles);
% --- Executes on button press in processfig_pushbutton_appltoall1.
function processfig_pushbutton_appltoall1_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
for j=1:length(mainhandles.datalist)
    multiplicity = mainhandles.datalist(j).multiplicity;
    %     for i=1:mainhandles.datalist(j).multiplicity
    mainhandles.datalist(j).process.phasecorr0(1:multiplicity)=...
        mainhandles.process.phasecorr0;
    %             mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(mainhandles.dispopts.arrayidx);
    mainhandles.datalist(j).process.phasecorr1(1:multiplicity)=...
        mainhandles.process.phasecorr1;
    %             mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(mainhandles.dispopts.arrayidx);
    %     end
end
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);

% % --- Executes on button press in processfig_pushbutton_appltoarray2.
% function processfig_pushbutton_appltoarray2_Callback(hObject, eventdata, handles)
% mainhandles=guidata(findobj('Tag','mainmenu'));
% if mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity > 1
%     %     for i=1:mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1=...
%         mainhandles.process.apodparam1;
%         mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1;
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2=...
%         mainhandles.process.apodparam2;
%         mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2;
%     %     end
% end
% guidata(findobj('Tag','mainmenu'),mainhandles);
% --- Executes on button press in processfig_pushbutton_appltoall2.
function processfig_pushbutton_appltoall2_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
for j=1:length(mainhandles.datalist)
    multiplicity=mainhandles.datalist(j).multiplicity;
    %     for i=1:mainhandles.datalist(j).multiplicity
    mainhandles.datalist(j).process.apodizefct=...
        mainhandles.process.apodizefct;
    mainhandles.datalist(j).process.apodparam1(1:multiplicity)=...
        mainhandles.process.apodparam1(mainhandles.dispopts.arrayidx);
    %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1;
    mainhandles.datalist(j).process.apodparam2(1:multiplicity)=...
        mainhandles.process.apodparam2(mainhandles.dispopts.arrayidx);
    %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2;
    %     end
    
end
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);


% % --- Executes on button press in processfig_pushbutton_appltoarray3.
% function processfig_pushbutton_appltoarray3_Callback(hObject, eventdata, handles)
% mainhandles=guidata(findobj('Tag','mainmenu'));
% if mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity > 1
%     %     for i=1:mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process.transfsize=...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).process.transfsize;
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process.lsfid=...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).process.lsfid;
%     %     end
% end
% guidata(findobj('Tag','mainmenu'),mainhandles);
% --- Executes on button press in processfig_pushbutton_appltoall3.
function processfig_pushbutton_appltoall3_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
for j=1:length(mainhandles.datalist)
    %     for i=1:mainhandles.datalist(j).multiplicity
    mainhandles.datalist(j).process.transfsize=...
        mainhandles.process.transfsize;
    %             mainhandles.datalist(mainhandles.dispopts.dataidx).process.transfsize;
    mainhandles.datalist(j).process.lsfid=...
        mainhandles.process.lsfid;
    %             mainhandles.datalist(mainhandles.dispopts.dataidx).process.lsfid;
    %     end
end
mainhandles.switch.transformsize=1;
mainhandles.switch.lsfid=1;
guidata(findobj('Tag','mainmenu'),mainhandles);

%--- Apodization -----------------------------------------------------
% --- Executes on selection change in processfig_popupmenu_apodfunction.
function processfig_popupmenu_apodfunction_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
liststr=get(hObject,'String');
mainhandles.process.apodizefct = char(liststr(get(hObject,'Value')));
if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
        mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodizefct=...
        mainhandles.process.apodizefct;
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodizefct=...
        mainhandles.process.apodizefct;
end

switch char(mainhandles.process.apodizefct)
    case {'doubleexp','lorentzian','gaussian'}
        set(handles.processfig_slider_apodparam2,'Enable','on')
        set(handles.processfig_edit_apodparam2,'Enable','on')
    otherwise
        set(handles.processfig_slider_apodparam2,'Enable','off')
        set(handles.processfig_edit_apodparam2,'Enable','off')
end
mainhandles.switch.apodization=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
displaycontrol
set(handles.processfig,'Visible','on' );

%----------------------------------------------------------------
function processfig_edit_apodparam1_Callback(hObject, eventdata, handles)
mainhandles= guidata(findobj('Tag','mainmenu'));
mainhandles.process.apodparam1 = round(str2double(get(hObject,'String'))*100)/100; % Hz = LB = first Parameter of apodzing function
if mainhandles.process.apodparam1 > get(handles.processfig_slider_apodparam1,'Max') || ...
        mainhandles.process.apodparam1 < get(handles.processfig_slider_apodparam1,'Min')
    mainhandles.process.apodparam1=get(handles.processfig_slider_apodparam1,'Value');
    set(handles.processfig_edit_apodparam1,'String',mainhandles.process.apodparam1(mainhandles.dispopts.arrayidx));
else
    set(handles.processfig_slider_apodparam1,'Value',mainhandles.process.apodparam1(mainhandles.dispopts.arrayidx));
end
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1=...
%         mainhandles.process.apodparam1;
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1(mainhandles.dispopts.arrayidx)=...
    mainhandles.process.apodparam1;
% end
mainhandles.switch.apodization=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
processfig_togglebutton_appltoarray2_Callback(handles.processfig_togglebutton_appltoarray2, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );
% --- Executes on slider movement.
function processfig_slider_apodparam1_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.process.apodparam1 = round(get(hObject,'Value')*100)/100; % Hz = LB = first Parameter of apodzing function
set(handles.processfig_slider_apodparam1,'Value',mainhandles.process.apodparam1);
set(handles.processfig_edit_apodparam1,'String',num2str(mainhandles.process.apodparam1))
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process(mainhandles.dispopts.arrayidx).apodparam1=...
%         mainhandles.process.apodparam1;
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1(mainhandles.dispopts.arrayidx)=...
    mainhandles.process.apodparam1;
% end
mainhandles.switch.apodization=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
processfig_togglebutton_appltoarray2_Callback(handles.processfig_togglebutton_appltoarray2, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );

%----------------------------------------------------------------
function processfig_edit_apodparam2_Callback(hObject, eventdata, handles)
mainhandles= guidata(findobj('Tag','mainmenu'));
mainhandles.process.apodparam2 = round(str2double(get(hObject,'String'))*100)/100; % Hz = second Parameter of apodzing function
if mainhandles.process.apodparam2 > get(handles.processfig_slider_apodparam1,'Max') || ...
        mainhandles.process.apodparam2 < get(handles.processfig_slider_apodparam2,'Min')
    mainhandles.process.apodparam2=get(handles.processfig_slider_apodparam2,'Value');
    set(handles.processfig_edit_apodparam2,'String',mainhandles.process.apodparam2);
else
    set(handles.processfig_slider_apodparam2,'Value',mainhandles.process.apodparam2);
end
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process(mainhandles.dispopts.arrayidx).apodparam1=...
%         mainhandles.process.apodparam2;
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2(mainhandles.dispopts.arrayidx)=...
    mainhandles.process.apodparam2;
% end
mainhandles.switch.apodization=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
processfig_togglebutton_appltoarray2_Callback(handles.processfig_togglebutton_appltoarray2, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );
% --- Executes on slider movement.
function processfig_slider_apodparam2_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.process.apodparam2 = round(get(hObject,'Value')*100)/100; % Hz = second Parameter of apodzing function
set(handles.processfig_slider_apodparam2,'Value',mainhandles.process.apodparam2);
set(handles.processfig_edit_apodparam2,'String',num2str(mainhandles.process.apodparam2))
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process(mainhandles.dispopts.arrayidx).apodparam2=...
%         mainhandles.process.apodparam2;
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2(mainhandles.dispopts.arrayidx)=...
    mainhandles.process.apodparam2;
% end
mainhandles.switch.apodization=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
processfig_togglebutton_appltoarray2_Callback(handles.processfig_togglebutton_appltoarray2, eventdata, handles)
displaycontrol
set(handles.processfig,'Visible','on' );

% --- Transform Size --------------------------------------------------
% --- Executes on selection change in processfig_popupmenu_transfsize.
function processfig_popupmenu_transfsize_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
liststr=get(hObject,'String');
if strcmp(liststr(get(hObject,'Value')),'none')==1
    mainhandles.process.transfsize = 0;
else
    transform_str = char(liststr(get(hObject,'Value')));
    if isempty(strfind(transform_str,'k'))
        mainhandles.process.transfsize = str2double(transform_str);
    else
        mainhandles.process.transfsize = str2double(transform_str(1:length(transform_str)-1))*1024;
    end
end
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process(mainhandles.dispopts.arrayidx).transfsize=...
%         mainhandles.process.transfsize;
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.transfsize=...
    mainhandles.process.transfsize;
% end
mainhandles.switch.transformsize=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
displaycontrol
set(handles.processfig,'Visible','on' );

function processfig_edit_lsfid_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
try
    round(str2double(get(hObject,'String')));
catch
    errordlg('Please enter an integer value for lsfid!')
end
% if mainhandles.datalist(mainhandles.dispopts.dataidx).params.arraydim>1 || ...
%         mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity>1
%     mainhandles.datalist(mainhandles.dispopts.dataidx).process(mainhandles.dispopts.arrayidx).lsfid=...
%         round(str2double(get(hObject,'String')));
% else
mainhandles.datalist(mainhandles.dispopts.dataidx).process.lsfid=...
    round(str2double(get(hObject,'String')));
% end
mainhandles.switch.lsfid=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
displaycontrol
set(handles.processfig,'Visible','on' );

% --- Divers -------------------------------------------------------------
% --- Executes on button press in processfig_pushbutton_nearestline.
function processfig_pushbutton_nearestline_Callback(hObject, eventdata, handles)

% --- Executes on button press in processfig_pushbutton_displinewidth.
function processfig_pushbutton_displinewidth_Callback(hObject, eventdata, handles)

% --- Executes on button press in processfig_togglebutton_DCoffsetcorr.
function processfig_togglebutton_DCoffsetcorr_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx = mainhandles.dispopts.dataidx;
% if mainhandles.datalist(dataidx).process.DCoffset==0
% mainhandles.datalist(dataidx).process.DCoffset=1;
% else
%   mainhandles.datalist(dataidx).process.DCoffset=0;
% end
mainhandles.datalist(dataidx).process.DCoffset=1;
mainhandles.switch.dcoffset=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
displaycontrol
set(handles.processfig,'Visible','on' );

% --- Executes on button press in processfig_pushbutton_B0driftcorr.
function processfig_pushbutton_B0driftcorr_Callback(hObject, eventdata, handles)
B0_calc
% swicth set on inside the function
displaycontrol
set(handles.processfig,'Visible','on' );

% --- Executes on button press in processfig_pushbutton_autophase.
function processfig_pushbutton_autophase_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx = mainhandles.dispopts.dataidx;
mainhandles.datalist(dataidx).process.DCoffset=1;
mainhandles.switch.phasecorrection=1;
guidata(findobj('Tag','mainmenu'),mainhandles);
Autophase
displaycontrol
set(findobj('Tag','processfig'),'Visible','on' );


% --- Executes on button press in processfig_pushbutton_addfid.
function processfig_pushbutton_addfid_Callback(hObject, eventdata, handles)
add_fid

% --- Executes on button press in processfig_pushbutton_fid2RAW.
function processfig_pushbutton_fid2RAW_Callback(hObject, eventdata, handles)
% mainhandles=guidata(findobj('Tag','mainmenu'));
% fid2RAW(mainhandles.dispopts.dataidx,mainhandles.dispopts.arrayidx,'processfig')
% % fid2RAW(mainhandles.datalist(mainhandles.dipsopts.dataidx).data
% autophase
%-----------------------------------------------------------------------
%--- CreateFcn ---------------------------------------------------------
mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx;


mainhandles.switch_bkp = mainhandles.switch;

mainhandles.switch.phasecorrection=1;
mainhandles.switch.apodization=0;
mainhandles.switch.transformsize=0;
mainhandles.switch.lsfid=1;
mainhandles.switch.dcoffset=1;
mainhandles.switch.b0=1;
mainhandles.switch.ECC=0;
mainhandles.switch.normalization = 1;
guidata(findobj('Tag','mainmenu'),mainhandles);
a=gui_dataselect('fid2RAW',mainhandles.datalist(dataidx).multiplicity);
uiwait(a);
if ~isempty(findobj('Tag','dataselect'))
    h=guidata(a);
    sel_idx = get(h.listbox,'Value');
    
    
    mainhandles.switch.phasecorrection=h.switch.phasecorrection;
    mainhandles.switch.apodization=h.switch.apodization;
    mainhandles.switch.transformsize=h.switch.transformsize;
    mainhandles.switch.lsfid=h.switch.lsfid;
    mainhandles.switch.dcoffset=h.switch.dcoffset;
    mainhandles.switch.b0=h.switch.b0;
    mainhandles.switch.normalization=h.switch.b0;
    mainhandles.switch.normalization = h.switch.normalization;
    delete(a)
    clear h
    guidata(findobj('Tag','mainmenu'),mainhandles);
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end
h=waitbar(0,'Wait, wirting RAW files...');
for i=1:length(sel_idx)
    waitbar(i/length(sel_idx))
    fid2RAW(dataidx,sel_idx(i),'processfig')
end
close(h)




% --- Executes during object creation, after setting all properties.
function processfig_edit_phasecorr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_edit_phasecorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function processfig_slider_phasecorr0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_slider_phasecorr0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function processfig_slider_phasecorr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_slider_phasecorr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function processfig_edit_phasecorr0_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function processfig_popupmenu_apodfunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_popupmenu_apodfunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function processfig_edit_apodparam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_edit_apodparam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function processfig_edit_apodparam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_edit_apodparam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function processfig_slider_apodparam1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_slider_apodparam1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function processfig_slider_apodparam2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_slider_apodparam2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function processfig_popupmenu_transfsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_popupmenu_transfsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function processfig_edit_lsfid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_edit_lsfid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in processfig_pushbutton_LCModel.
function processfig_pushbutton_LCModel_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_LCModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
GUI_LCModel('processfig')




% --- Executes on button press in processfig_pushbutton_varian.
function processfig_pushbutton_varian_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_varian (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainhandles=guidata(findobj('Tag','mainmenu'));

save_fid

guidata(findobj('Tag','mainmenu'),mainhandles)



% --- Executes on button press in processfig_pushbutton_jmrui.
function processfig_pushbutton_jmrui_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_jmrui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx;


mainhandles.switch_bkp = mainhandles.switch;

mainhandles.switch.phasecorrection=1;
mainhandles.switch.apodization=0;
mainhandles.switch.transformsize=0;
mainhandles.switch.lsfid=1;
mainhandles.switch.dcoffset=1;
mainhandles.switch.b0=1;
mainhandles.switch.ECC=0;
mainhandles.switch.normalization = 0;
guidata(findobj('Tag','mainmenu'),mainhandles);
a=gui_dataselect('fid2RAW',mainhandles.datalist(dataidx).multiplicity);
uiwait(a);
if ~isempty(findobj('Tag','dataselect'))
    h=guidata(a);
    sel_idx = get(h.listbox,'Value');
    
    
    mainhandles.switch.phasecorrection=h.switch.phasecorrection;
    mainhandles.switch.apodization=h.switch.apodization;
    mainhandles.switch.transformsize=h.switch.transformsize;
    mainhandles.switch.lsfid=h.switch.lsfid;
    mainhandles.switch.dcoffset=h.switch.dcoffset;
    mainhandles.switch.b0=h.switch.b0;
    mainhandles.switch.normalization=h.switch.b0;
    mainhandles.switch.normalization = h.switch.normalization;
    delete(a)
    clear h
    guidata(findobj('Tag','mainmenu'),mainhandles);
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end
h=waitbar(0,'Wait, wirting jMRui text files...');
for i=1:length(sel_idx)
    waitbar(i/length(sel_idx))
    jmrui(dataidx,sel_idx(i),'processfig')
end
close(h)


% --- Executes on button press in processfig_pushbutton_savefig.
function processfig_pushbutton_savefig_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_savefig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mainhandles=guidata(findobj('Tag','mainmenu'));
[path folder]=fileparts(mainhandles.datalist(mainhandles.dispopts.dataidx).path);

data=get(mainhandles.currentplot,'UserData');
size(data)
xdata=get(mainhandles.currentplot,'XData');
xlim1=get(mainhandles.axes1,'Xlim');
ylim1=get(mainhandles.axes1,'Ylim');
try
    labelx=get(get(get(mainhandles.currentplot,'Parent'),'XLabel'),'String');
    xformat=labelx(find(labelx=='[',1,'last')+1:find(labelx==']',1,'last')-1);
catch
    xformat='xdata';
end
if isempty(xformat)
    xformat='xdata';
end
if ischar(folder(1))
    folder=['s_' folder];
end
folder =strrep(folder,' ','_');
eval([folder '.' xformat ' = xdata;']);
eval([folder '.data = data;']);
assignin('base',folder,eval(folder))
figure('Name',folder)
plot(xdata,data,'k');
xlim(xlim1)
ylim(ylim1)
if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
    set(gca,'XDir','reverse')
end




% --- Executes on button press in processfig_pushbutton_BISEP.
function processfig_pushbutton_BISEP_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_BISEP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BISEP;





% --- Executes on button press in processfig_pushbutton_dss.
function processfig_pushbutton_dss_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_dss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% mainhandles=guidata(findobj('Tag','mainmenu'));
%
% dataidx = mainhandles.dispopts.dataidx;
% mult = mainhandles.datalist(dataidx).multiplicity;
%
% for k =1:mult
%     mainhandles.dispopts.arrayidx = k;
%     guidata(findobj('Tag','mainmenu'),mainhandles);
%     displaycontrol
%     spect{k} = get(mainhandles.currentplot,'UserData');
% end
% set(0,'CurrentFigure',mainhandles.mainmenu)
% gca
% cla
% figure
% hold on
% for k =1:mult
%     plot(spect{k},'r')
% end
% hold off




% --- Executes on button press in processfig_pushbutton_ApplyTOraw.
function processfig_pushbutton_ApplyTOraw_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_ApplyTOraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx;


mainhandles.switch_bkp = mainhandles.switch;

mainhandles.switch.phasecorrection=1;
mainhandles.switch.apodization=1;
mainhandles.switch.transformsize=1;
mainhandles.switch.lsfid=1;
mainhandles.switch.dcoffset=1;
mainhandles.switch.b0=1;
mainhandles.switch.ECC=1;
mainhandles.switch.normalization = 0;
guidata(findobj('Tag','mainmenu'),mainhandles);
a=gui_dataselect('raw',mainhandles.datalist(dataidx).multiplicity);
uiwait(a);
if ~isempty(findobj('Tag','dataselect'))
    h=guidata(a);
    sel_idx = get(h.listbox,'Value');
    
    
    mainhandles.switch.phasecorrection=h.switch.phasecorrection;
    mainhandles.switch.apodization=h.switch.apodization;
    mainhandles.switch.transformsize=h.switch.transformsize;
    mainhandles.switch.lsfid=h.switch.lsfid;
    mainhandles.switch.dcoffset=h.switch.dcoffset;
    mainhandles.switch.b0=h.switch.b0;
    mainhandles.switch.normalization=h.switch.b0;
    mainhandles.switch.normalization = h.switch.normalization;
    delete(a)
    clear h
    guidata(findobj('Tag','mainmenu'),mainhandles);
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end

    try
        lsfid = mainhandles.datalist(dataidx).process.lsfid;
    catch
        lsfid=0;
    end
h=waitbar(0,'Wait, Apply postprocessing to RAW files...');
for i=1:length(sel_idx)
    waitbar(i/length(sel_idx))
    

    
    %         for k=1:mainhandles.datalist(data_idx(i)).multiplicity
  
        k=sel_idx(i);
        try
            phasecorr0(i,k) = mainhandles.datalist(dataidx).process.phasecorr0(k);
            phasecorr1(i,k) = mainhandles.datalist(dataidx).process.phasecorr1(k);
        catch
            phasecorr0(i,k) = 0;
            phasecorr1(i,k) = 0;
        end
        
                
%                 guidata(findobj('Tag','mainmenu'),mainhandles)
                
                temp(i).real =  squeeze(mainhandles.datalist(dataidx).data.real(k,:,:));
                temp(i).imag =  squeeze(mainhandles.datalist(dataidx).data.imag(k,:,:));
                
                if mainhandles.switch.phasecorrection==1
                    fid_length=length(temp(i).real); %=mainhandles.datalist(dataidx).np/2;
                    t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx).spectralwidth;
%                     t=t_vec;
                    % calculation of x-axis for frequency-space
                    cut = round(fid_length/2);
                    df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                    f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

                    temp(i) = phasing(squeeze(temp(i)), f_vec_shifted, phasecorr0(i,k), phasecorr1(i,k));
                    mainhandles.datalist(dataidx).process.phasecorr0(k)=0;
                    mainhandles.datalist(dataidx).process.phasecorr1(k)=0;
                    guidata(findobj('Tag','mainmenu'),mainhandles);
                end

                
                data(i) = postprocessing(squeeze(temp(i)),dataidx,k);
                
                if mainhandles.switch.apodization ==1
                    mainhandles.datalist(dataidx).process.apodparam1(k)=0;
                    mainhandles.datalist(dataidx).process.apodparam2(k)=0;
                end
                
                 if mainhandles.switch.lsfid ==1
                    mainhandles.datalist(dataidx).process.lsfid=0;
                 end
                
                if mainhandles.switch.b0 ==1
                    if isfield(mainhandles.datalist(dataidx).process,'b0')
                        mainhandles.datalist(dataidx).process = rmfield(mainhandles.datalist(dataidx).process,'b0');
                    end            
                end
                if mainhandles.switch.transformsize ==1
                    mainhandles.datalist(dataidx).params.np = 2*size(temp(i).real,3);
                end
        mainhandles.datalist(dataidx).data.real(k,:,:)=data(i).real;
        mainhandles.datalist(dataidx).data.imag(k,:,:)=data(i).imag;
        guidata(findobj('Tag','mainmenu'),mainhandles);
    
end
close(h)
displaycontrol


% --- Executes on selection change in processfig_popupmenu_myfunc.
function processfig_popupmenu_myfunc_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_popupmenu_myfunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns processfig_popupmenu_myfunc contents as cell array
%        contents{get(hObject,'Value')} returns selected item from processfig_popupmenu_myfunc


% --- Executes during object creation, after setting all properties.
function processfig_popupmenu_myfunc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to processfig_popupmenu_myfunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processfig_pushbutton_myfunc.
function processfig_pushbutton_myfunc_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_myfunc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainhandles=guidata(findobj('Tag','mainmenu'));
func_list = get(handles.processfig_popupmenu_myfunc,'String');
func_idx = get(handles.processfig_popupmenu_myfunc,'Value');

run([mainhandles.homedir filesep 'myfunc' filesep 'MRS' filesep func_list{func_idx} '.m'])


% --- Executes on button press in processfig_togglebutton_appltoarray2.
function processfig_togglebutton_appltoarray2_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_togglebutton_appltoarray2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of processfig_togglebutton_appltoarray2

mainhandles=guidata(findobj('Tag','mainmenu'));
multiplicity =mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity;
if get(handles.processfig_togglebutton_appltoarray2,'Value')
    if multiplicity > 1
        %         for i=1:mainhandles.datalist(mainhandles.dispopts.dataidx).multiplicity
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam1(1:multiplicity)=...
            mainhandles.process.apodparam1;
        %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr0(mainhandles.dispopts.arrayidx);
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.apodparam2(1:multiplicity)=...
            mainhandles.process.apodparam2;
        %         mainhandles.datalist(mainhandles.dispopts.dataidx).process.phasecorr1(mainhandles.dispopts.arrayidx);
        %         end
    end
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2=1;
    
else
    mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2=0;
end
guidata(findobj('Tag','mainmenu'),mainhandles);



% --- Executes on button press in processfig_pushbutton_matlab.
function processfig_pushbutton_matlab_Callback(hObject, eventdata, handles)
% hObject    handle to processfig_pushbutton_matlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainhandles=guidata(findobj('Tag','mainmenu'));
dataidx=mainhandles.dispopts.dataidx;
study = mainhandles.datalist(dataidx);
cd(mainhandles.datalist(dataidx).path)

uisave('study',mainhandles.datalist(dataidx).filename)
cd(mainhandles.homedir);



