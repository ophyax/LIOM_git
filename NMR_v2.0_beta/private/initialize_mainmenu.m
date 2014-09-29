function initialize_mainmenu(hObject)


handles = guidata(hObject);


%% --- 'load session_log.mat'
% initialize and overwrite later


privatepath=fileparts(which('initialize_mainmenu.m'));
handles.homedir=privatepath(1:length(privatepath)-8);

% handles.homedir=pwd;
% strrep(handles.homedir,'private','');
% strrep(handles.homedir,'\\','\');
disp(handles.homedir)
handles.startpath='';
if isfield(handles,'sessionlog')
    handles.startpath=handles.sessionlog.startpath;
    lcmodel=handles.sessionlog.lcmodel;
    handles.studyreport=handles.sessionlog.studyreport;
elseif exist('session_log.mat','file')
    load(which('session_log.mat'))
    handles.sessionlog=sessionlog;
    handles.startpath=sessionlog.startpath;
    if isfield(sessionlog,'lcmodel')
        handles.lcmodel=sessionlog.lcmodel;
    end
    if isfield(sessionlog,'studyreport')
        handles.studyreport=sessionlog.studyreport;
    end
else  %first use
    handles.startpath=handles.homedir;
    handles.sessionlog = [];
end
% if isfield(handles,'lcmodel')==1
% fields=fieldnames(handles.lcmodel);
% for i=1:length(fields)
%     if isfield(lcmodel,fields(i))
%         handles.lcmodel.(char(fields(i)))=lcmodel.(char(fields(i)));
%     end
% end
% end

%% --- prepare default options ---------------------------------------------
handles.dispopts.dataidx=1;
handles.dispopts.arrayidx=1;

set(handles.dispopts_togglebutton_format_rawfft,'Value',0, ... 
    'Enable','off') %'Parent',handles.mainmenu_uipanel_curdispopts,
set(handles.dispopts_radiobutton_format_absval,'Value',1)
set(handles.dispopts_radiobutton_format_fdf,'Visible','on','Enable','off')
set(handles.dispopts_togglebutton_format_ppmhz,'Visible','on',...
    'Enable','off') %'Parent',handles.mainmenu_uipanel_curdispopts
set(get(handles.dispopts_uipanel_dataformat,'Children'),'Enable','off')
% set(handles.dispopts_pushbutton_orient,'Visible','off')

    set(handles.dispopt_uipanel_DWI,'Visible','off');
    set(handles.dispopt_popupmenu_DWI,'Enable','off');

handles.dispopts.axesscaling.x=zeros(2,2);
handles.dispopts.axesscaling.y=zeros(2,5,2);

% set(handles.dispopt_radiobutton_grid,'Value',0,'Enable','off')
% set(handles.dispopt_radiobutton_datacursor,'Enable','off')
% set(handles.dispopt_pushbutton_resetdisp,'Enable','off')
% set(handles.dispopt_radiobutton_cbar,'Enable','off')

% cmap_idx=2;
% strlist = get(handles.dispopt_popupmenu_cmap,'String');
% set(handles.dispopt_popupmenu_cmap,'Value',cmap_idx,'Enable','off');
% handles.dispopts.cmap=strlist(cmap_idx);

%% --- set switches ---------------------------------------------------------
handles.switch.phasecorrection=0;
handles.switch.apodization=0;
handles.switch.transformsize=0;
handles.switch.lsfid=0;
handles.switch.dcoffset=0;
handles.switch.b0=0;
handles.switch.ECC=0;
handles.dispopts.resetdisp=1;
handles.switch.normalization=0;






%% ---- set options -------------------------------------
if isfield(handles.sessionlog,'options')
    handles.options = handles.sessionlog.options;
else
    handles.options.debug.display =0; %display information while running
end

if ~isfield(handles.options,'load')
        handles.options.load.fid =1;
        handles.options.load.fdf = 0;
        handles.options.load.matlab = 1;
        handles.options.load.analyse = 1;
        handles.options.load.siemens = 1;
        handles.options.load.dicom = 1;
        handles.options.load.raw = 1;
 end



%% --- initialize uicontrols ------------------------------------------------
set(handles.dispopt_edit_datanum,'String',...
    [num2str(handles.dispopts.dataidx) '|' num2str(handles.dispopts.arrayidx)])
% 
set(findobj('Parent',handles.mainmenu_uipanel_axes,'Type','uicontrol','Style','edit'),...
    'Visible','off')

%% --- required information of uicontrols --------------------------------
tmp = get(findobj('Parent',handles.mainmenu_uipanel_axes,...
    'Type','uicontrol','Style','edit'),'Position');
if ~isempty(tmp)
handles.edit_pos = cell2mat(tmp);
else
    handles.edit_pos = [];
end

handles.process = [];
%% --- save handles ---------------------------------------------------------
guidata(hObject,handles);



