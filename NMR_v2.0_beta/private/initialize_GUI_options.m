function initialize_GUI_options(hObject,called)
% clc;
%% get figure handles
handles = guidata(hObject);
mainhandles = guidata(findobj('Tag','mainmenu'));

%% get options value from mainhandles
%%startpath
if isfield(mainhandles,'startpath')==0 || strcmp(called,'reset')==1
    startpath = matlabroot;
else
    startpath = mainhandles.startpath;
end


%%load
if ~isfield(mainhandles,'options')
if ~isfield(mainhandles.options,'load')
        mainhandles.options.load.fid =1;
        mainhandles.options.load.fdf = 0;
        mainhandles.options.load.matlab = 1;
        mainhandles.options.load.analyse = 1;
        mainhandles.options.load.siemens = 1;
        mainhandles.options.load.dicom = 1;
        mainhandles.options.load.raw = 1;
end
else
    if ~isfield(mainhandles.options,'load')
        mainhandles.options.load.fid =1;
        mainhandles.options.load.fdf = 0;
        mainhandles.options.load.matlab = 1;
        mainhandles.options.load.analyse = 1;
        mainhandles.options.load.siemens = 1;
        mainhandles.options.load.dicom = 1;
        mainhandles.options.load.raw = 1;
    end   
end

%%Lcmodel
if isfield(mainhandles,'lcmodel')==0 || strcmp(called,'reset')==1
    server = 'Input server name';
    targetfolder = 'Input destination on server';
    login = 'Input login name';
    pwd = 'Input password';
    handles.pwd = pwd;
    rule = 'Input rule';
    winscp ='Input winscp.com path';
else
    server = mainhandles.lcmodel.server.name;
    login = mainhandles.lcmodel.server.login;
    pwd = mainhandles.lcmodel.server.pwd;
    winscp='C:\Program Files (x86)\WinSCP\WinSCP.exe';
    %mainhandles.lcmodel.winscp=winscp;
    handles.pwd = pwd;
    pwd = char(repmat('#',[1 length(pwd)]));
    targetfolder = mainhandles.lcmodel.targetfolder;
    try
    rule = mainhandles.lcmodel.rule;
    catch
        rule = '';
    end
end

% set(handles.lcmodel_text_server,'Parent',handles.GUI_options_fig);
% set(handles.lcmodel_text_targetfolder,'Parent',handles.GUI_options_fig);
% set(handles.lcmodel_text_login,'Parent',handles.GUI_options_fig);
% set(handles.lcmodel_text_pwd,'Parent',handles.GUI_options_fig);
% set(handles.lcmodel_text_rule,'Parent',handles.GUI_options_fig);
% set(handles.lcmodel_text_rule_eg,'Parent',handles.GUI_options_fig);


%% set GUI obejcts values
%%startpath
set(handles.main_edit_startpath,'String',startpath);
%%load
set(handles.load_checkbox_fid,'Value',mainhandles.options.load.fid);
set(handles.load_checkbox_fdf,'Value',mainhandles.options.load.fdf);
set(handles.load_checkbox_matlab,'Value',mainhandles.options.load.matlab);
set(handles.load_checkbox_analyse,'Value',mainhandles.options.load.analyse);
set(handles.load_checkbox_siemens,'Value',mainhandles.options.load.siemens);
set(handles.load_checkbox_dicom,'Value',mainhandles.options.load.dicom);
set(handles.load_checkbox_raw,'Value',mainhandles.options.load.raw);

%%lcmodel
set(handles.lcmodel_edit_server,'String',server);
set(handles.lcmodel_edit_login,'String',login);
set(handles.lcmodel_edit_pwd,'String',pwd);
set(handles.lcmodel_edit_targetfolder,'String',targetfolder);
set(handles.lcmodel_edit_rule,'String',rule);
set(handles.lcmodel_edit_winscp,'String',winscp);

%% save handles
guidata(hObject,handles);