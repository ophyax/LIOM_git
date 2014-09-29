function varargout = GUI_LCModel(varargin)
% GUI_LCMODEL M-file for GUI_LCModel.fig
%      GUI_LCMODEL, by itself, creates a new GUI_LCMODEL or raises the existing
%      singleton*.
%
%      H = GUI_LCMODEL returns the handle to a new GUI_LCMODEL or the handle to
%      the existing singleton*.
%
%      GUI_LCMODEL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_LCMODEL.M with the given input arguments.
%
%      GUI_LCMODEL('Property','Value',...) creates a new GUI_LCMODEL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_LCModel_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_LCModel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_LCModel

% Last Modified by GUIDE v2.5 08-Apr-2010 18:19:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_LCModel_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_LCModel_OutputFcn, ...
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


% --- Executes just before GUI_LCModel is made visible.
function GUI_LCModel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_LCModel (see VARARGIN)

% Choose default command line output for GUI_LCModel
handles.output = hObject;
handles.called=varargin{1};
% Update handles structure
guidata(hObject, handles);

initialize_lcmodelfig(hObject)



% UIWAIT makes GUI_LCModel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_LCModel_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Controlfile ------------------------------------------------------
% --- Executes on button press in lcmodelfig_pushbutton_SelectControlfile.
function lcmodelfig_pushbutton_SelectControlfile_Callback(hObject, eventdata, handles)
controlfilelist = get(handles.lcmodelfig_edit_Controlfile,'String');
mainhandles=guidata(findobj('Tag','mainmenu'));

cd([mainhandles.homedir filesep 'private' filesep 'controlfile']);
[filename,filepath] = uigetfile(...
    {'*.CONTROL',  'CONTROL Files (*.CONTROL)';...
    '*.txt',  'Text Files (*.txt)';...
    '*.asc',  'ASCII Files (*.txt)';...
    '*.*',  'All Files (*.*)'},'Open CONTROL file for LC Model!','Get files for LC Model');
cd(mainhandles.homedir)


if isempty(filepath)==0 && ischar(filepath)==1
    mainhandles.lcmodel.orig_controlfile=[filepath, filename];
    set(handles.lcmodelfig_edit_Controlfile,'Style','edit','String',mainhandles.lcmodel.orig_controlfile)
    guidata(findobj('Tag','mainmenu'),mainhandles);
    lcmodelfig_pushbutton_CreateControlfile_Callback(hObject, eventdata, handles, 1)
else
    mainhandles.lcmodel.orig_controlfile='Control file';
    if length(controlfilelist)==1
        set(handles.lcmodelfig_edit_Controlfile,'Style','edit','String',controlfilelist)
    elseif length(controlfilelist)>1
        set(handles.lcmodelfig_edit_Controlfile,'Style','popupmenu','String',controlfilelist)
    end
    guidata(findobj('Tag','mainmenu'),mainhandles);
    %     lcmodelfig_pushbutton_CreateControlfile_Callback(hObject, eventdata, handles, 1)
    %     return
end



% --- Executes on button press in lcmodelfig_pushbutton_CreateControlfile.
function lcmodelfig_pushbutton_CreateControlfile_Callback(hObject, eventdata, handles, flag)

if nargin==4
    guicall=0;
else
    guicall=1;
end

mainhandles=guidata(findobj('Tag','mainmenu'));



data_idx = mainhandles.lcmodel.dataidx;




if length(data_idx)>1
    answer=questdlg({'There is more than one file selected.'; ...
        'Should all off them be processed with the LC Model?'},'Batch Processing','Yes','No','Yes');
    if strcmp(answer,'No')
        disp('not implemented yet')
        return
    end
end
% if ~isfield(mainhandles.lcmodel,'controlfile')
%      mainhandles.lcmodel.controlfile.yesall=''; 
% else
%     if ~isfield(mainhandles.lcmodel.controlfile,'yesall')
%         mainhandles.lcmodel.controlfile.yesall='';
%     end
% end
mainhandles.lcmodel=rmfield(mainhandles.lcmodel,'cur_controlfile');
for i=1:length(data_idx)
    array_idx = mainhandles.lcmodel.arrayidx{i};
    curfidpath=mainhandles.datalist(data_idx(i)).path;
    %     lcmdir=[curfidpath(1:max(findstr(curfidpath,'.'))) 'lcm'];
    [pathstr, name, ext]= fileparts(curfidpath);
    %     ext = strrep(ext,'.fid','');
    if isempty(ext)
        curfidpath=mainhandles.datalist(data_idx(i)).liststring;
        [pathstr, name, ext]= fileparts(curfidpath);
        lcmdir = [pathstr filesep name '.lcm'];
    else
        lcmdir = [pathstr filesep name '.lcm'];
    end
    
    %     lcmdir=[curfidpath '.lcm'];
    if exist(lcmdir,'dir')==0
        mkdir(lcmdir)
    end
    if isempty(array_idx)
        if mainhandles.datalist(data_idx(i)).multiplicity>1
            for j=1:mainhandles.datalist(data_idx(i)).multiplicity
                if strcmp(mainhandles.datalist(data_idx(i)).filename,'fid')
                    path = mainhandles.datalist(data_idx(i)).path;
                    separator = find(path==filesep);
                    filename{j}=[path((separator(length(separator))+1):length(path)) '_' num2str(j)];
                else
                    [pathstra, namea, exta]= fileparts(mainhandles.datalist(data_idx(j)).filename)
                    filename{j} = [namea '_' num2str(j)];;
                end
            end
        else
            if strcmp(mainhandles.datalist(data_idx(i)).filename,'fid')
                path = mainhandles.datalist(data_idx(i)).path;
                separator = find(path==filesep);
                filename{i}=path((separator(length(separator))+1):length(path));
            else
                [pathstra, namea, exta]= fileparts(mainhandles.datalist(data_idx(i)).filename);
                filename{i} = namea;
            end
        end
    else
        path = mainhandles.datalist(data_idx(i)).path;
        separator = find(path==filesep);
        if length(array_idx)>1
            for j=1:length(array_idx)
                if strcmp(mainhandles.datalist(data_idx(i)).filename,'fid')
                    filename{j}=[path((separator(length(separator))+1):length(path)) '_' num2str(array_idx(j))];
                else
                    [pathstra, namea, exta]= fileparts(mainhandles.datalist(data_idx(i)).filename);
                    filename{j} = [namea '_' num2str(array_idx(j))];
                end
            end
        else
            if strcmp(mainhandles.datalist(data_idx(i)).filename,'fid')
                filename{1}=path((separator(length(separator))+1):length(path));
            else
                [pathstra, namea, exta]= fileparts(mainhandles.datalist(data_idx(i)).filename);
                filename{1} = namea;
            end
        end
    end
    
    for j=1:length(filename)
        filename_tot=[lcmdir filesep char(filename{j}) '.CONTROL'];
        d=dir(filename_tot);
        if isempty(d)==0 && isempty(handles.yesall.overwrite.controlfile)
            answer=questdlg({'Overwrite existing file:'; filename_tot},'Overwrite File','Yes','Yes to All','No','Yes');
            if strcmp(answer,'No')
                handles.yesall.overwrite.controlfile = '';
                return
            elseif strcmp(answer,'Yes to All')
                handles.yesall.overwrite.controlfile='Yes to All';
            else
                handles.yesall.overwrite.controlfile = '';
            end
        else
            answer = handles.yesall.overwrite.controlfile;
        end
        
        
        
        if exist(mainhandles.lcmodel.orig_controlfile,'file') && guicall==0
            %% too early need target folder / reference file /
            status = 1;
            if isfield(mainhandles.lcmodel,'cur_controlfile')==0
                mainhandles.lcmodel.cur_controlfile{i}=filename_tot;
            else
                mainhandles.lcmodel.cur_controlfile{length(mainhandles.lcmodel.cur_controlfile)+1}=filename_tot;
            end
            
            %             status=createlcmcontrolfile(filename_tot);
%             mainhandles.lcmodel.orig_controlfile
%             filename_tot
            copyfile(mainhandles.lcmodel.orig_controlfile,filename_tot);
        else
            status=createlcmcontrolfile(filename_tot,mainhandles.datalist(data_idx(i)).nucleus);
        end
        if status==0
            return
        end
        % % %          REMOVED.... SEEMS WRONG
        % %         if isfield(mainhandles.lcmodel,'cur_controlfile')==0
        % %             mainhandles.lcmodel.cur_controlfile{1}=filename_tot;
        % %         else
        % %             mainhandles.lcmodel.cur_controlfile{length(mainhandles.lcmodel.cur_controlfile)+1}=filename_tot;
        % %         end
    end
    clear filename
end

if length(mainhandles.lcmodel.cur_controlfile)>1
    set(handles.lcmodelfig_edit_Controlfile,'Style','popupmenu',...
        'String',mainhandles.lcmodel.cur_controlfile,'Value',1)%,'HorizontalAlignment','right')
    mainhandles.lcmodel.sel_controlfile=char(mainhandles.lcmodel.cur_controlfile{1});
else
    set(handles.lcmodelfig_edit_Controlfile,'Style','edit',...
        'String',mainhandles.lcmodel.cur_controlfile)
    mainhandles.lcmodel.sel_controlfile=char(mainhandles.lcmodel.cur_controlfile);
end

set(get(handles.lcmodelfig_uipanel_options,'Children'),'Visible','on','Enable','on')

guidata(findobj('Tag','lcmodelfig'),handles);
guidata(findobj('Tag','mainmenu'),mainhandles);

% --- Executes on button press in lcmodelfig_pushbutton_EditControlfile.
function lcmodelfig_pushbutton_EditControlfile_Callback(hObject, eventdata, handles)
% this is to edit the CONTROL file itself, not to change the path to it
mainhandles=guidata(findobj('Tag','mainmenu'));
edit(mainhandles.lcmodel.sel_controlfile)
% also very elegant with a "inputdlg"

% --- Executes on button press in lcmodelfig_pushbutton_lcmodelfig_edit_Controlfile.
function lcmodelfig_edit_Controlfile_Callback(hObject, eventdata, handles)
% this edit field shows the path to the control file
mainhandles=guidata(findobj('Tag','mainmenu'));

if strcmp(get(hObject,'Style'),'edit')
    curfile=get(hObject,'String');
else
    liststring=get(hObject,'String');
    listidx=get(hObject,'Value');
    curfile=char(liststring(listidx));
end

if exist(curfile,'file')~=2
    errordlg('This CONTROL file can not be found or does not exist!')
    set(hObject,'String',mainhandles.lcmodel.sel_controlfile)
else
    mainhandles.lcmodel.sel_controlfile=curfile;
    guidata(findobj('Tag','mainmenu'),mainhandles);
end

%% Basisfile ------------------------------------------------------
% --- Executes on button press in lcmodelfig_pushbutton_SelectBasisfile.
function lcmodelfig_pushbutton_SelectBasisfile_Callback(hObject, eventdata, handles)

homedir=pwd;
mainhandles=guidata(findobj('Tag','mainmenu'));
[path name ext] = fileparts(mainhandles.lcmodel.basisfile)
if exist(path,'dir')
    cd(path);
end
if exist(mainhandles.lcmodel.basisfile,'file')
    defaultfile = [name ext];
else
    defaultfile = '';
end

[filename,filepath] = uigetfile(...
    {'*.BASIS',  'BASIS Files (*.BASIS)';...
    '*.txt',  'Text Files (*.txt)';...
    '*.asc',  'ASCII Files (*.txt)';...
    '*.*',  'All Files (*.*)'},'Open BASIS file for LC Model!',defaultfile);
cd(homedir)

if filename~=0
    mainhandles.lcmodel.basisfile=[filepath filename];
    set(handles.lcmodelfig_edit_Basisfile,'String',mainhandles.lcmodel.basisfile)
    guidata(findobj('Tag','mainmenu'),mainhandles);
end

% --- Executes on button press in lcmodelfig_edit_Basisfile_Callback.
function lcmodelfig_edit_Basisfile_Callback(hObject, eventdata, handles)

newstring = get(hObject,'String');
if find(newstring,'/') % unix file separator = unix path
    mainhandles.lcmodel.basisfile=newstring;
else % windows path
    if exist(newstring,'file')
        mainhandles.lcmodel.basisfile=newstring;
    end
end
guidata(findobj('Tag','mainmenu'),mainhandles);

%% Referencefile ------------------------------------------------------
% --- Executes on button press in lcmodelfig_pushbutton_reffile.
function lcmodelfig_pushbutton_reffile_Callback(hObject, eventdata, handles)
%open GUI_filelist and enable the button

try
    filelisthandles=guidata(findobj('Tag','filelistfig'));
catch
    GUI_Filelist
    filelisthandles=guidata(findobj('Tag','filelistfig'));
end
mainhandles=guidata(findobj('Tag','mainmenu'));
set(filelisthandles.filelistfig_pushbutton_LCModelRef,'Visible','On')
mainhandles.reffile_counter = 0;
mainhandles.lcmodel.same_reffile = '';
mainhandles.lcmodel.ECC = '';
mainhandles.lcmodel.dataidx_ref = [];
mainhandles.lcmodel.arrayidx_ref = [];

disp('Select the reference file for:')
disp(['Control File: ' mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter+1}])
set(filelisthandles.filelistfig,'Visible','on' );
mainhandles.lcmodel.disp_control_file = msgbox(['Control File: ' mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter+1}],'Select the reference file for:');


sum_idx = mainhandles.lcmodel.dataidx(mainhandles.reffile_counter+1);
filelist = get(filelisthandles.filelistfig_listbox,'String');
file = mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter+1};
[pathstr, name, ext] = fileparts(file);
pathstr = strrep(pathstr,'lcm',['fid' filesep 'fid']);
met_idx = strmatch(pathstr,filelist,'exact');

try
    rule = char(mainhandles.lcmodel.rule);
    dataidx_next = eval(rule);

    if isempty(dataidx_next) || dataidx_next<1 || dataidx_next>length(mainhandles.datalist)

        dataidx_next = sum_idx; 
    end
catch
    dataidx_next = sum_idx;
end
handles.yesall.ECC = '';

set(filelisthandles.filelistfig_listbox,'Value',dataidx_next);
guidata(findobj('Tag','lcmodelfig'),handles);
guidata(findobj('Tag','mainmenu'),mainhandles);
guidata(findobj('Tag','filelistfig'),filelisthandles);


% % Multiple ref file
% % if length(mainhandles.lcmodel.cur_controlfile)>1
% %     set(handles.lcmodelfig_edit_Controlfile,'Style','popupmenu',...
% %         'String',mainhandles.lcmodel.cur_controlfile,'Value',1)%,'HorizontalAlignment','right')
% %     mainhandles.lcmodel.sel_controlfile=char(mainhandles.lcmodel.cur_controlfile{1});
% % else
% %     set(handles.lcmodelfig_edit_Controlfile,'Style','edit',...
% %         'String',mainhandles.lcmodel.cur_controlfile)
% %     mainhandles.lcmodel.sel_controlfile=char(mainhandles.lcmodel.cur_controlfile);
% % end


function lcmodelfig_edit_reffile_Callback(hObject, eventdata, handles)

% mainhandles=guidata(findobj('Tag','mainmenu'));
% if exist(get(hObject,'String'),'file')
%     mainhandles.lcmodel.reffile=get(hObject,'String');
% elseif exist(get(hObject,'String'),'dir')
% else
%     set(hObject,'String',mainhandles.lcmodel.reffile)
% end
% guidata(findobj('Tag','mainmenu'),mainhandles)

%% Create .RAW & .PLOTIN & .CONTROL and transfer files------------------------
% --- Executes on button press in lcmodelfig_pushbutton_CreateLCMInput.
function lcmodelfig_pushbutton_CreateLCMInput_Callback(hObject, eventdata, handles)

global yesall_plotin yesall_raw

mainhandles=guidata(findobj('Tag','mainmenu'));

if length(mainhandles.lcmodel.cur_controlfile)>1
    answer=questdlg({'There is more than one CONTROL file in the list.'; ...
        'Should all or just the current file be processed with the LC Model?'},'Batch Processing','All','Current','All');
else
    answer='Current';
end

switch char(answer)
    case 'Current'
        filelist=mainhandles.lcmodel.sel_controlfile;
    case 'All'
        filelist=get(handles.lcmodelfig_edit_Controlfile,'String');
    otherwise
end

extensionlist={'.fid'; '.sum'; ''};
yesall_plotin=0;
yesall_raw=0;
    ldata_idx = length(mainhandles.lcmodel.dataidx);
%     larray_idx = length(mainhandles.lcmodel.arrayidx);

% mainhandles.lcmodel.fid2raw.zerofill
% for i=1:size(filelist,1)

%% slect postprocessing options
mainhandles.switch_bkp = mainhandles.switch;
guidata(findobj('Tag','mainmenu'),mainhandles);
a=gui_dataselect('fid2RAW',mainhandles.datalist(ldata_idx(1)).multiplicity);
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



control_idx=0;
for i = 1:ldata_idx
    larray_idx = length(mainhandles.lcmodel.arrayidx{i});
    for k = 1:larray_idx
    control_idx = control_idx+1;
    %     'mainhandles.lcmodel.arrayidx'
    %     mainhandles.lcmodel.arrayidx
    %     fid2RAW(mainhandles.lcmodel.dataidx(i),mainhandles.lcmodel.arrayidx(i),'lcmodelfig')
    %     fid2RAW(mainhandles.lcmodel.dataidx_ref(i),mainhandles.lcmodel.arrayidx_ref(i),'lcmodelfig_reffile')
    
    
    if strcmp(mainhandles.lcmodel.reffile{1},'')==0
        fid2RAW(mainhandles.lcmodel.dataidx(i),mainhandles.lcmodel.arrayidx{i}(k),'lcmodelfig_reffile');
    end
    fid2RAW(mainhandles.lcmodel.dataidx(i),mainhandles.lcmodel.arrayidx{i}(k),'lcmodelfig');
    
    
    params=mainhandles.datalist(mainhandles.lcmodel.dataidx(i)).params;
    
    status=createlcmodelinput(filelist(control_idx,:),params,control_idx,0);
   disp('%%%%%%%%%%%%%% TOTAL LCMODEL FILE %%%%%%%%%%%')
    disp([control_idx size(filelist,1)])
    if status==0;
        errordlg({'Input files for LC Model could not be written for :';filename})
        return
    end   
    end
end
% end
% if isfield(mainhandles.lcmodel,'fid2raw');
%     if isfield(mainhandles.lcmodel.fid2raw,'zerofill');
%         mainhandles.lcmodel.fid2raw = rmfield(mainhandles.lcmodel.fid2raw,'zerofill');
%     end
% end
% if isfield(mainhandles.lcmodel,'ECC')
%     mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'ECC');
% end
guidata(findobj('Tag','mainmenu'),mainhandles);
set(handles.lcmodelfig_pushbutton_readcoord,'Visible','on');
set(handles.lcmodelfig_pushbutton_openpdf,'Visible','on');
set(handles.lcmodelfig,'Visible','on');
%% Settings on LC Model server ---------------------------------
function lcmodelfig_edit_server_Callback(hObject, eventdata, handles)

serverstr=get(hObject,'String');
[status,result] = dos(['ping ' serverstr]);
disp(result)
if status~=0
    errordlg(['Connection to ' serverstr ' could not be established'])
    return
else
    mainhandles=guidata(findobj('Tag','mainmenu'));
    mainhandles.lcmodel.server=serverstr;
    set(hObject,'String',serverstr)
    guidata(findobj('Tag','mainmenu'),mainhandles);
end

function lcmodelfig_edit_targetfolder_Callback(hObject, eventdata, handles)

targetfolder=get(hObject,'String');
mainhandles=guidata(findobj('Tag','mainmenu'));
mainhandles.lcmodel.targetfolder=targetfolder;
guidata(findobj('Tag','mainmenu'),mainhandles);






% --- Check Results ------------------------------------------------------
% --- Executes on button press in lcmodelfig_pushbutton_openpdf.
function lcmodelfig_pushbutton_openpdf_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));

filelist = mainhandles.lcmodel.cur_controlfile;

for i =1:length(filelist);
    [pathname, file, ext] = fileparts(filelist{1,i});
    
    % cd('D:\Program Files\MATLAB704\work\lcmodel\NewFolder1')
    open(fullfile(pathname,[file '.pdf']));

end


% --- Executes on button press in lcmodelfig_pushbutton_readcoord.
function lcmodelfig_pushbutton_readcoord_Callback(hObject, eventdata, handles)

coord


%--------------------------------------------------------------------------


% --- Executes on button press in lcmodelfig_pushbutton_summary.
function lcmodelfig_pushbutton_summary_Callback(hObject, eventdata, handles)
% hObject    handle to lcmodelfig_pushbutton_summary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainhandles=guidata(findobj('Tag','mainmenu'));

filelist = mainhandles.lcmodel.cur_controlfile;

for i =1:length(filelist);
    [pathname, file, ext] = fileparts(filelist{1,i});
    
    % cd('D:\Program Files\MATLAB704\work\lcmodel\NewFolder1')
    open(fullfile(pathname,[file '.pdf']));

end


% --- Executes during object creation, after setting all properties.
function lcmodelfig_edit_Controlfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodelfig_edit_Controlfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function lcmodelfig_edit_targetfolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodelfig_edit_targetfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lcmodelfig_edit_server_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodelfig_edit_server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lcmodelfig_edit_reffile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lcmodelfig_edit_reffile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end









