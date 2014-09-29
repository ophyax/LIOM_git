function varargout = GUI_Filelist(varargin)
% GUI_FILELIST M-file for GUI_Filelist.fig
%      GUI_FILELIST, by itself, creates a new GUI_FILELIST or raises the existing
%      singleton*.
%
%      H = GUI_FILELIST returns the handle to a new GUI_FILELIST or the handle to
%      the existing singleton*.
%
%      GUI_FILELIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_FILELIST.M with the given input arguments.
%
%      GUI_FILELIST('Property','Value',...) creates a new GUI_FILELIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_Filelist_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_Filelist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_Filelist

% Last Modified by GUIDE v2.5 19-Aug-2010 17:27:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_Filelist_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_Filelist_OutputFcn, ...
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


% --- Executes just before GUI_Filelist is made visible.
function GUI_Filelist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_Filelist (see VARARGIN)

% Choose default command line output for GUI_Filelist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_filelistfig(hObject)

% UIWAIT makes GUI_Filelist wait for user response (see UIRESUME)
% uiwait(handles.filelistfig);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_Filelist_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in filelistfig_listbox.
function filelistfig_listbox_Callback(hObject, eventdata, handles)
% mainhandles = guidata(findobj('Type','figure','Tag','mainmenu'));
mainhandles=guidata(findobj('Tag','mainmenu'));
% get(handles.filelistfig,'SelectionType')
if strcmp(get(handles.filelistfig,'SelectionType'),'open') || ... % 'normal'/'open'=single/double click
        strcmp(get(handles.filelistfig,'SelectionType'),'alt') % Ctrl+left or only right
    % double click displays data in mainaxes
    listidx=get(hObject,'Value');
    filelist=get(hObject,'String');
    if length(filelist)>length(mainhandles.datalist) % expanded filelist
        curfile=char(filelist(listidx));
        cutidx=max(findstr(curfile,'_'))-1;
        [tf dataidx]=ismember(curfile(1:cutidx),{mainhandles.datalist.liststring});
        if tf==0
            dataidx=1;
            arrayidx=1;
        else
            arrayidx=str2double(curfile(cutidx+2:length(curfile)));
        end
    else % filelist not expanded
        dataidx=listidx;
        arrayidx=1;
    end
    if mainhandles.dispopts.dataidx~=dataidx || mainhandles.dispopts.arrayidx~=arrayidx
        mainhandles.dispopts.dataidx=dataidx;
        mainhandles.dispopts.arrayidx=arrayidx;
        guidata(mainhandles.mainmenu,mainhandles)
    end
    
    displaycontrol
    
elseif strcmp(get(handles.filelistfig,'SelectionType'),'normal') %single click (selection)
    %     disp('normal')
end

%% add / subtract --------------------------------------------------------
% --- Executes on button press in filelistfig_pushbutton_addfiles.
function filelistfig_pushbutton_addfiles_Callback(hObject, eventdata, handles)
set(handles.filelistfig_pushbutton_updatelist,'ForegroundColor',[0 0 0],...
    'FontAngle','normal','FontWeight','normal')
set(handles.filelistfig_listbox,'Enable','off')

mainhandles = guidata(findobj('Tag','mainmenu'));
if isfield(mainhandles,'datalist')
start_loop = length(mainhandles.datalist)+1;
else
    start_loop=1;
end
create_filelist
mainhandles = guidata(findobj('Tag','mainmenu'));
if isfield(mainhandles,'datalist')
end_loop = length(mainhandles.datalist);
updatedata(start_loop,end_loop)
else
    updatedata
end
set(handles.filelistfig_listbox,'Enable','on')

% --- Executes on button press in filelistfig_pushbutton_subtractfiles.
function filelistfig_pushbutton_subtractfiles_Callback(hObject, eventdata, handles)

sellist = get(handles.filelistfig_listbox,'Value');
selinvert = 1:size(get(handles.filelistfig_listbox,'String'),1);
selnew =setxor(selinvert,selinvert(sellist));
mainhandles = guidata(findobj('Tag','mainmenu'));

if isempty(selnew)
    initialize_filelistfig(handles.filelistfig);
    %     return
end

if length(sellist) <= length(selnew)
    datapath_new = mainhandles.datapath;
    for i=1:length(sellist) % to delete from datapath
        datapath_entry = [pathsep mainhandles.datalist(sellist(i)).path];
        datapath_idx = findstr(datapath_new,datapath_entry);
        datapath_new(findstr(datapath_new,datapath_entry):...
            (findstr(datapath_new,datapath_entry)+length(datapath_entry)))='';
        %         datapath_new = [mainhandles.datapath(1:datapath_idx-1) ...
        %             mainhandles.datapath(datapath_idx+length(datapath_entry):length(mainhandles.datapath))];
    end
else
    datapath_new = '';
    for i=1:length(selnew) % remaining entries for new datapath
        datapath_new = [datapath_new pathsep mainhandles.datalist(selnew(i)).path];
    end
end

mainhandles.datalist=mainhandles.datalist(selnew);
mainhandles.datapath=datapath_new;
mainhandles.dispopts.dataidx = find(selnew<min(sellist),1,'last');
mainhandles.dispopts.arrayidx = 1;

if strcmp(datapath_new,'') && isempty(mainhandles.datalist)==1
    set(handles.filelistfig_popupmenu_selectformat,'Value',1,'String','Format')
    set(handles.filelistfig_popupmenu_selecttype,'Value',1,'String','Acqtype')
    set(handles.filelistfig_listbox,'Value',1,'Max',1,'String','empty');
else
    formatlist = unique(cellstr({mainhandles.datalist.format}));
    set(handles.filelistfig_popupmenu_selectformat,'Value',1,'String',formatlist)
    set(handles.filelistfig_listbox,'Value',1,'String',{mainhandles.datalist.liststring},...
        'Max',length({mainhandles.datalist.liststring}))
    if isfield(mainhandles.datalist,'acqtype')==1
        acqtypelist = unique(cellstr({mainhandles.datalist.acqtype}));
        set(handles.filelistfig_popupmenu_selecttype,'Value',1,'String',acqtypelist)
    else
        set(handles.filelistfig_popupmenu_selecttype,'enable','off')
    end
end
guidata(findobj('Tag','mainmenu'),mainhandles)
% default values:
% set(handles.filelistfig_pushbutton_updatelist,'ForegroundColor',[0 0 0],...
%     'FontAngle','normal','FontWeight','normal') % ForegroundColor, FontAngle
set(handles.filelistfig_pushbutton_updatelist,'BackgroundColor',[1 0 0],...
    'FontAngle','italic','FontWeight','bold') % ForegroundColor, FontAngle
% original colour= [0.9255 0.9137 0.8471]

%% Panel of Selection options ----------------------------------------
% --- Executes on button press in filelistfig_pushbutton_selectall.
function filelistfig_pushbutton_selectall_Callback(hObject, eventdata, handles)
set(handles.filelistfig_listbox,'Value',1:length(get(handles.filelistfig_listbox,'String')));

% --- Executes on button press in filelistfig_pushbutton_selectnone.
function filelistfig_pushbutton_selectnone_Callback(hObject, eventdata, handles)
set(handles.filelistfig_listbox,'Value',1)% ,'Max',1,'String','empty');

% --- Executes on button press in filelistfig_pushbutton_selectcur.
function filelistfig_pushbutton_selectcur_Callback(hObject, eventdata, handles)
mainhandles = guidata(findobj('Tag','mainmenu'));
liststr=get(handles.filelistfig_listbox,'String');
% if get(handles.filelistfig_togglebutton_expandlist,'Value')
%     [tf,idx]=ismember([deblank(mainhandles.datalist(mainhandles.dispopts.dataidx).liststring) '_' num2str(mainhandles.dispopts.arrayidx)],...
%         liststr);
% else
[tf,idx]=ismember(mainhandles.datalist(mainhandles.dispopts.dataidx).liststring,liststr);
% end
set(handles.filelistfig_listbox,'Value',idx);

% --- Executes on button press in filelistfig_pushbutton_selectinvert.
function filelistfig_pushbutton_selectinvert_Callback(hObject, eventdata, handles)
sellist = get(handles.filelistfig_listbox,'Value');
selinvert = 1:get(handles.filelistfig_listbox,'Max');
selnew =setxor(selinvert,selinvert(sellist));
if isempty(selnew)==0
    set(handles.filelistfig_listbox,'Value',selnew);
end

% --- Executes on selection change in filelistfig_popupmenu_selecttype.
function filelistfig_popupmenu_selecttype_Callback(hObject, eventdata, handles)
typestr = get(hObject,'String');
seltype = typestr(get(hObject,'Value'));
mainhandles = guidata(findobj('Tag','mainmenu'));
seltypehits = ismember({mainhandles.datalist.acqtype},seltype);
idx = find(seltypehits);
% if  get(handles.filelistfig_togglebutton_expandlist,'Value')
%     validx=[];
%     for i=1:length(idx)
%         [tf,ix]=ismember([mainhandles.datalist(idx(i)).liststring '_1'],get(handles.filelistfig_listbox,'String'));
%         validx = [validx ix];
%     end
%     set(handles.filelistfig_listbox,'Value',validx)
% %     filelistfig_pushbutton_selectarray_Callback
% else
set(handles.filelistfig_listbox,'Value',idx)
% end

% --- Executes on selection change in filelistfig_popupmenu_selectformat.
function filelistfig_popupmenu_selectformat_Callback(hObject, eventdata, handles)
formatstr = get(hObject,'String');
selformat = formatstr(get(hObject,'Value'));
mainhandles = guidata(findobj('Tag','mainmenu'));
selformathits = ismember({mainhandles.datalist.format},selformat);
set(handles.filelistfig_listbox,'Value',find(selformathits))

% --- Executes on button press in filelistfig_pushbutton_selectarray.
% function filelistfig_pushbutton_selectarray_Callback(hObject, eventdata, handles)
%
% mainhandles = guidata(findobj('Tag','mainmenu'));
% handles = guidata(findobj('Tag','filelistfig'));
% if get(handles.filelistfig_togglebutton_expandlist,'Value')
%     liststr = get(handles.filelistfig_listbox,'String');
%     selidx = get(handles.filelistfig_listbox,'Value');
%     selstr = char(liststr(selidx));
%     validx=[];
%     for i=1:length(selidx)
%         idx=max(findstr(selstr(i,:),'_'));
%         [tf, idx_exp]=ismember([deblank(selstr(i,1:idx)) '1'],mainhandles.liststr_expanded);
%         [tf, idx_raw]=ismember(selstr(i,1:idx-1),{mainhandles.datalist.liststring});
%         idx_range=idx_exp:idx_exp+mainhandles.datalist(idx_raw).multiplicity-1;
%         validx = [validx idx_range];
%     end
%     set(handles.filelistfig_listbox,'Value',validx)
% end

%% Nico
function filelistfig_edit_paramNAME_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_edit_paramNAME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filelistfig_edit_paramNAME as text
%        str2double(get(hObject,'String')) returns contents of filelistfig_edit_paramNAME as a double
handles = guidata(findobj('Tag','filelistfig'));
handles.selection.paramNAME = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function filelistfig_edit_paramNAME_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelistfig_edit_paramNAME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filelistfig_edit_paramVALUE_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_edit_paramVALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filelistfig_edit_paramVALUE as text
%        str2double(get(hObject,'String')) returns contents of filelistfig_edit_paramVALUE as a double
handles = guidata(findobj('Tag','filelistfig'));
handles.selection.paramVALUE = get(hObject,'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function filelistfig_edit_paramVALUE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filelistfig_edit_paramVALUE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filelistfig_pushbutton_paramSELECT.
function filelistfig_pushbutton_paramSELECT_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_paramSELECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% typestr = get(hObject,'String');
% seltype = typestr(get(hObject,'Value'));
handles = guidata(findobj('Tag','filelistfig'));
mainhandles = guidata(findobj('Tag','mainmenu'));
if ((isfield(handles.selection,'paramVALUE')== 1) || (isfield(handles.selction,'paramNAME')== 1))==1
    for j= 1: size(mainhandles.datalist,2)
        clear test
        try
            test=mainhandles.datalist(1,j).params.(char(handles.selection.paramNAME));
        catch
            test = [];
        end
        if iscell(test)==1 && ~isempty(test)
            selparamhits(j) = strcmp(test{1},handles.selection.paramVALUE);
        elseif isnumeric(test)==1 && ~isempty(test)
            selparamhits(j) = (test==str2num(handles.selection.paramVALUE));
        end
        %% need to test if the param name is a valid one....
    end
    idx = find(selparamhits);
    set(handles.filelistfig_listbox,'Value',idx);
    
else
    display('no parameter selected')
end

%%
% % --- Executes on button press in filelistfig_togglebutton_expandlist.
% function filelistfig_togglebutton_expandlist_Callback(hObject, eventdata, handles)
% mainhandles = guidata(findobj('Tag','mainmenu'));
% liststr = get(handles.filelistfig_listbox,'String');
% selidx = get(handles.filelistfig_listbox,'Value');
% if isempty(selidx) || selidx<=0 || isinteger(selidx)==0
%     selidx=1;
% end
% selstr = char(liststr(selidx));
% if get(hObject,'Value') % expand to show arrays
%     validx=[];
%     for i=1:length(selidx)
%         [tf, idx]=ismember([deblank(selstr(i,:)) '_1'],mainhandles.liststr_expanded);
%         validx = [validx idx];
%     end
%     set(handles.filelistfig_listbox,'Value',validx,'String',mainhandles.liststr_expanded,...
%         'Max',length(mainhandles.liststr_expanded));
% else % collapse
%     validx=[];
%     for i=1:length(selidx)
%         idx=max(findstr(selstr(i,:),'_'));
%         [tf, idx]=ismember(selstr(i,1:idx-1),{mainhandles.datalist.liststring});
%         validx = [validx idx];
%     end
%     set(handles.filelistfig_listbox,'Value',validx,'String',{mainhandles.datalist.liststring},...
%         'Max',length({mainhandles.datalist.liststring}));
% end

% --- Executes on button press in filelistfig_pushbutton_combine.
function filelistfig_pushbutton_combine_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_combine (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


get(findobj('Tag','filelistfig_listbox'),'Value')
get(findobj('Tag','filelistfig_listbox'),'Max')
fig = GUI_Combine;
uiwait(fig)
disp('gui_filelist')
get(findobj('Tag','filelistfig_listbox'),'Value')
get(findobj('Tag','filelistfig_listbox'),'Max')

% --- Executes on button press in filelistfig_pushbutton_LCModel.
function filelistfig_pushbutton_LCModel_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_LCModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GUI_LCModel('filelistfig')


% --- Executes on button press in filelistfig_pushbutton_loaddata.
function filelistfig_pushbutton_loaddata_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_loaddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

load_data('filelistfig')


% --- Executes on button press in filelistfig_pushbutton_LCModelRef.
function filelistfig_pushbutton_LCModelRef_Callback(hObject, eventdata, handles)
mainhandles=guidata(findobj('Tag','mainmenu'));
lcmodelhandles=guidata(findobj('Tag','lcmodelfig'));
filelisthandles=guidata(findobj('Tag','filelistfig'));
% mainhandles.reffile_counter=0;
'1'
mainhandles.reffile_counter
mainhandles.reffile_counter = mainhandles.reffile_counter + 1; %initialise in GUI_LCModel
'2'
mainhandles.reffile_counter
try
    close(mainhandles.lcmodel.disp_control_file)
catch
end
%get selected file indexes
filelistidx = get(handles.filelistfig_listbox,'Value');
filelist_tot = get(handles.filelistfig_listbox,'String');
filelist={filelist_tot{filelistidx}};
data_idx=[];
array_idx=[];
% if length(filelist_tot)>max(size(mainhandles.datalist)) % = expanded list
%     for i=1:length(filelist)
%         curfile=filelist{i};
%         cutidx=max(strfind(curfile,'_'));
%         curfilestr=curfile(1:cutidx-1);
%         [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
%         data_idx=[data_idx; idx];
%         array_idx=[array_idx str2double(curfile(cutidx+1:length(curfile)))];
%     end
% else
for i=1:length(filelist)
    curfilestr=filelist{i};
    [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
    data_idx=[data_idx; idx];
end
% end
if length(data_idx)>1 || length(array_idx)>1
    errordlg('More than one reference file selcted for the controlfile: %s',mainhandles.lcmodel.cur_controlfile{1})
    return
end
mainhandles.lcmodel.dataidx_ref = [mainhandles.lcmodel.dataidx_ref;data_idx];
mainhandles.lcmodel.arrayidx_ref = [mainhandles.lcmodel.arrayidx_ref;1];

if ~isfield(mainhandles.datalist(data_idx),'loaded') || isempty(mainhandles.datalist(data_idx).loaded) || mainhandles.datalist(data_idx).loaded ~=1
    %     guidata(findobj('Tag','mainmenu'),mainhandles);
    mainhandles.dispopts.dataidx = data_idx;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    load_data('displaycontrol')
    mainhandles=guidata(findobj('Tag','mainmenu'));
end



path = mainhandles.datalist(data_idx(1)).path;
separator = find(path==filesep);

yesall_sameCONTORL = 0;

mainhandles.lcmodel.reffile{mainhandles.reffile_counter}=path;
set(lcmodelhandles.lcmodelfig_edit_reffile,'String',mainhandles.lcmodel.reffile{mainhandles.reffile_counter});
if length(mainhandles.lcmodel.cur_controlfile)>1
    if isempty(mainhandles.lcmodel.same_reffile)
        button = questdlg('Do you want to use the same refeerence file for all LCModel control files?','Multiple Reference File','Yes','Yes to all','No','Yes');
        mainhandles.lcmodel.same_reffile = button;
    else
        button = mainhandles.lcmodel.same_reffile;
    end
    
        if isempty(lcmodelhandles.yesall.ECC)
            ECCbutton = questdlg4('Do you want to apply ECC corection?','ECC correction','Yes','Yes to all', 'No','No to all','Yes to all');
            if strcmp(ECCbutton,'Yes to all')==1 || strcmp(ECCbutton,'No to all')==1
                lcmodelhandles.yesall.ECC = ECCbutton;
            else
                lcmodelhandles.yesall.ECC = '';
            end
        else
            ECCbutton = lcmodelhandles.yesall.ECC;
        end
        if strcmp(button,'Yes')==1 || strcmp(button,'Yes to all')==1
%         clc
        for k=1:length(mainhandles.lcmodel.cur_controlfile)
            mainhandles.lcmodel.reffile{k}=path;
            mainhandles.lcmodel.dataidx_ref = [mainhandles.lcmodel.dataidx_ref;data_idx];
            mainhandles.lcmodel.arrayidx_ref = [mainhandles.lcmodel.arrayidx_ref;1];
            if strcmp(ECCbutton,'Yes')==1 || strcmp(ECCbutton,'Yes to all')==1
                lcmidx = find(mainhandles.lcmodel.lcmidx > k-1,1,'first');
                dataidx = mainhandles.lcmodel.dataidx(lcmidx);
                
                
                if lcmidx>1
%                     [k lcmidx dataidx k-mainhandles.lcmodel.lcmidx(lcmidx-1)]
                    arrayidx = mainhandles.lcmodel.arrayidx{lcmidx}(k-mainhandles.lcmodel.lcmidx(lcmidx-1));
                else
%                     [k lcmidx dataidx k]
                    arrayidx = k;
                end
                dataidx_ref = data_idx;
%                 dataidx = mainhandles.lcmodel.dataidx(k);
%                 arrayidx = mainhandles.lcmodel.arrayidx{dat_idx}
                
                w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
                m_fid = (squeeze(mainhandles.datalist(dataidx).data.real(arrayidx,:,:) + 1i*mainhandles.datalist(dataidx).data.imag(arrayidx,:,:)));
                j_m  = (mainhandles.datalist(dataidx).process.lsfid);
                j_w  = (mainhandles.datalist(dataidx_ref).process.lsfid);
                
                [ECC_m_fid, ECC_corr] =  ECC_correction(m_fid,w_fid,j_m,j_w);
                
                %                     mainhandles.datalist(dataidx).data.real(1,1,:) = squeeze(real(ECC_m_fid));
                %                     mainhandles.datalist(dataidx).data.imag(1,1,:) =  squeeze(imag(ECC_m_fid));
                %                     mainhandles.datalist(dataidx_ref).data.real(1,1,:) = squeeze(real(ECC_w_fid));
                %                     mainhandles.datalist(dataidx_ref).data.imag(1,1,:) =  squeeze(imag(ECC_w_fid));%data_idx MET , Water
                mainhandles.datalist(dataidx).process.ECC=ECC_corr;
                %                     mainhandles.datalist(dataidx_ref).process.ECC=1;
            
            end
            mainhandles.reffile_counter = mainhandles.reffile_counter+1;
        end
        set(handles.filelistfig_pushbutton_LCModelRef,'Visible','Off')
        else
            
            if isempty(lcmodelhandles.yesall.ECC)
        ECCbutton = questdlg4('Do you want to apply ECC corection?','ECC correction','Yes','Yes to all','No','No to all','Yes to all');
        if strcmp(ECCbutton,'Yes to all')==1 || strcmp(ECCbutton,'No to all')==1
            lcmodelhandles.yesall.ECC = ECCbutton;
        else
            lcmodelhandles.yesall.ECC = '';
        end
        if strcmp(ECCbutton,'Yes')==1 || strcmp(ECCbutton,'Yes to all')==1
            dataidx_ref = data_idx;
            dataidx = mainhandles.lcmodel.dataidx(mainhandles.reffile_counter);
            w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
            m_fid = (squeeze(mainhandles.datalist(dataidx).data.real + 1i*mainhandles.datalist(dataidx).data.imag));
            
            j_m  = (mainhandles.datalist(dataidx).process.lsfid);
            j_w  = (mainhandles.datalist(dataidx_ref).process.lsfid);
            
            [ECC_m_fid, ECC_corr] =  ECC_correction(m_fid,w_fid,j_m,j_w);
            
            %         mainhandles.datalist(dataidx).data.real(1,1,:) = squeeze(real(ECC_m_fid));
            %         mainhandles.datalist(dataidx).data.imag(1,1,:) =  squeeze(imag(ECC_m_fid));
            %         mainhandles.datalist(dataidx_ref).data.real(1,1,:) = squeeze(real(ECC_w_fid));
            %         mainhandles.datalist(dataidx_ref).data.imag(1,1,:) =  squeeze(imag(ECC_w_fid));%data_idx MET , Water
            mainhandles.datalist(dataidx).process.ECC=ECC_corr;
            %         mainhandles.datalist(dataidx_ref).process.ECC=1;
        end
%          mainhandles.reffile_counter = mainhandles.reffile_counter+1;
    elseif  strcmp(lcmodelhandles.yesall.ECC,'Yes to all')
        dataidx_ref = data_idx;
        dataidx = mainhandles.lcmodel.dataidx(mainhandles.reffile_counter);
        w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
        m_fid = (squeeze(mainhandles.datalist(dataidx).data.real + 1i*mainhandles.datalist(dataidx).data.imag));
        j_m  = (mainhandles.datalist(dataidx).process.lsfid);
        j_w  = (mainhandles.datalist(dataidx_ref).process.lsfid);
        
        [ECC_m_fid, ECC_corr] =  ECC_correction(m_fid,w_fid,j_m,j_w);
        
        %         mainhandles.datalist(dataidx).data.real(1,1,:) = squeeze(real(ECC_m_fid));
        %         mainhandles.datalist(dataidx).data.imag(1,1,:) =  squeeze(imag(ECC_m_fid));
        %         mainhandles.datalist(dataidx_ref).data.real(1,1,:) = squeeze(real(ECC_w_fid));
        %         mainhandles.datalist(dataidx_ref).data.imag(1,1,:) =  squeeze(imag(ECC_w_fid));%data_idx MET , Water
        mainhandles.datalist(dataidx).process.ECC=ECC_corr;
        %         mainhandles.datalist(dataidx_ref).process.ECC=1;
%          mainhandles.reffile_counter = mainhandles.reffile_counter+1;
    end
        end
    % end
else
    lcmodelhandles.yesall.ECC
    if isempty(lcmodelhandles.yesall.ECC)
        ECCbutton = questdlg4('Do you want to apply ECC corection?','ECC correction','Yes','Yes to all','No','No to all','Yes to all');
        if strcmp(ECCbutton,'Yes to all')==1 || strcmp(ECCbutton,'No to all')==1
            lcmodelhandles.yesall.ECC = ECCbutton;
        else
            lcmodelhandles.yesall.ECC = '';
        end
        if strcmp(ECCbutton,'Yes')==1 || strcmp(ECCbutton,'Yes to all')==1
            dataidx_ref = data_idx;
            dataidx = mainhandles.lcmodel.dataidx(mainhandles.reffile_counter);
            w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
            m_fid = (squeeze(mainhandles.datalist(dataidx).data.real + 1i*mainhandles.datalist(dataidx).data.imag));
            
            j_m  = (mainhandles.datalist(dataidx).process.lsfid);
            j_w  = (mainhandles.datalist(dataidx_ref).process.lsfid);
            
            [ECC_m_fid, ECC_corr] =  ECC_correction(m_fid,w_fid,j_m,j_w);
            
            %         mainhandles.datalist(dataidx).data.real(1,1,:) = squeeze(real(ECC_m_fid));
            %         mainhandles.datalist(dataidx).data.imag(1,1,:) =  squeeze(imag(ECC_m_fid));
            %         mainhandles.datalist(dataidx_ref).data.real(1,1,:) = squeeze(real(ECC_w_fid));
            %         mainhandles.datalist(dataidx_ref).data.imag(1,1,:) =  squeeze(imag(ECC_w_fid));%data_idx MET , Water
            mainhandles.datalist(dataidx).process.ECC=ECC_corr;
            %         mainhandles.datalist(dataidx_ref).process.ECC=1;
        end
         mainhandles.reffile_counter = mainhandles.reffile_counter+1;
    elseif  strcmp(lcmodelhandles.yesall.ECC,'Yes to all')
        dataidx_ref = data_idx;
        dataidx = mainhandles.lcmodel.dataidx(mainhandles.reffile_counter);
        w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
        m_fid = (squeeze(mainhandles.datalist(dataidx).data.real + 1i*mainhandles.datalist(dataidx).data.imag));
        j_m  = (mainhandles.datalist(dataidx).process.lsfid);
        j_w  = (mainhandles.datalist(dataidx_ref).process.lsfid);
        
        [ECC_m_fid, ECC_corr] =  ECC_correction(m_fid,w_fid,j_m,j_w);
        
        %         mainhandles.datalist(dataidx).data.real(1,1,:) = squeeze(real(ECC_m_fid));
        %         mainhandles.datalist(dataidx).data.imag(1,1,:) =  squeeze(imag(ECC_m_fid));
        %         mainhandles.datalist(dataidx_ref).data.real(1,1,:) = squeeze(real(ECC_w_fid));
        %         mainhandles.datalist(dataidx_ref).data.imag(1,1,:) =  squeeze(imag(ECC_w_fid));%data_idx MET , Water
        mainhandles.datalist(dataidx).process.ECC=ECC_corr;
        %         mainhandles.datalist(dataidx_ref).process.ECC=1;
         mainhandles.reffile_counter = mainhandles.reffile_counter+1;
    end
end
% mainhandles.reffile_counter
% length(mainhandles.lcmodel.cur_controlfile)
if mainhandles.reffile_counter >= length(mainhandles.lcmodel.cur_controlfile) %??
    set(handles.filelistfig_pushbutton_LCModelRef,'Visible','Off')
end



guidata(findobj('Tag','filelistfig'),handles);
guidata(findobj('Tag','lcmodelfig'),lcmodelhandles);
if exist('dataidx','var')
    mainhandles.dispopts.dataidx = dataidx;
    mainhandles.dispopts.arrayidx = 1;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    displaycontrol;
else
    guidata(findobj('Tag','mainmenu'),mainhandles);
end

% set(0,'CurrentFigure', lcmodelhandles.lcmodelfig);
% mainhandles.reffile_counter
% length(mainhandles.lcmodel.cur_controlfile)
if mainhandles.reffile_counter >= length(mainhandles.lcmodel.cur_controlfile) %??
    set(handles.filelistfig_pushbutton_LCModelRef,'Visible','Off')
    set(lcmodelhandles.lcmodelfig,'Visible','on' );
else
    disp('Select the reference file for:')
    disp(['Control File: ' mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter}])
    
    set(filelisthandles.filelistfig,'Visible','on' );
    mainhandles.lcmodel.disp_control_file = msgbox(['Control File: ' mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter+1}],'Select the reference file for:');
    mainhandles.lcmodel.lcmidx
    mainhandles.reffile_counter
    lcm_idx = find(mainhandles.lcmodel.lcmidx==(mainhandles.reffile_counter));
    lcm_idx = lcm_idx(1);
    sum_idx = mainhandles.lcmodel.dataidx(lcm_idx);
    
    filelist = get(handles.filelistfig_listbox,'String');
    file = mainhandles.lcmodel.cur_controlfile{mainhandles.reffile_counter};
    [pathstr, name, ext, versn] = fileparts(file);
    pathstr = strrep(pathstr,'lcm',['fid' filesep 'fid']);
    met_idx = strmatch(pathstr,filelist,'exact');
    %     sum_idx
    %     met_idx
    try
        rule = char(mainhandles.lcmodel.rule);
        dataidx_next = eval(rule);
        %         dataidx_next
        if isempty(dataidx_next) || dataidx_next<1 || dataidx_next>length(mainhandles.datalist)
            disp('out of bound: select SUM spectra')
            %            dataidx_next = sum_idx;
        end
    catch
        disp('Rule not conform: select SUM spectra')
        dataidx_next = sum_idx;
    end
    set(handles.filelistfig_listbox,'Value',dataidx_next);
    guidata(findobj('Tag','filelistfig'),handles);
end
guidata(findobj('Tag','mainmenu'),mainhandles);

% --- Executes on button press in filelistfig_pushbutton_studyreport.
function filelistfig_pushbutton_studyreport_Callback(hObject, eventdata, handles)

studyreport

% --- Executes on button press in filelistfig_pushbutton_updatelist.
function filelistfig_pushbutton_updatelist_Callback(hObject, eventdata, handles)
% set(gcf,'Visible','off')
updatedata



% --- Executes on button press in filelistfig_pushbutton_cleardata.
function filelistfig_pushbutton_cleardata_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_cleardata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mainhandles = guidata(findobj('Tag','mainmenu'));
handles = guidata(findobj('Tag','filelistfig'));
% get the selected experiment
sellist = get(handles.filelistfig_listbox,'Value');

for k=1:length(sellist)
    if isfield(mainhandles.datalist(sellist(k)),'data')
        mainhandles.datalist(sellist(k)) = rmfield(mainhandles.datalist(sellist(k)),'data');
        mainhandles.datalist(sellist(k)).loaded = 0;
    end
end


%% --- CreatFcn -------------------------------------------------------------

% --- Executes during object creation, after setting all properties.
function filelistfig_listbox_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function filelistfig_popupmenu_selecttype_CreateFcn(hObject, eventdata, handles)

%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function filelistfig_popupmenu_selectformat_CreateFcn(hObject, eventdata, handles)

%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% % % % % --- Executes on button press in togglebutton1.
% % % % function togglebutton1_Callback(hObject, eventdata, handles)
% % % % % hObject    handle to togglebutton1 (see GCBO)
% % % % % eventdata  reserved - to be defined in a future version of MATLAB
% % % % % handles    structure with handles and user data (see GUIDATA)
% % % %
% % % % % Hint: get(hObject,'Value') returns toggle state of togglebutton1







% --------------------------------------------------------------------
% % % % % function Filelist_LeftClick_LCModel_ref_Callback(hObject, eventdata, handles)
% % % % % % hObject    handle to Filelist_LeftClick_LCModel_ref (see GCBO)
% % % % % % eventdata  reserved - to be defined in a future version of MATLAB
% % % % % % handles    structure with handles and user data (see GUIDATA)






% % % %
% % % % % --------------------------------------------------------------------
% % % % function Filelist_LeftClick_Callback(hObject, eventdata, handles)
% % % % % hObject    handle to Filelist_LeftClick (see GCBO)
% % % % % eventdata  reserved - to be defined in a future version of MATLAB
% % % % % handles    structure with handles and user data (see GUIDATA)










% --- Executes on button press in filelistfig_pushbutton_up.
function filelistfig_pushbutton_up_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in filelistfig_pushbutton_down.
function filelistfig_pushbutton_down_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in filelistfig_pushbutton_sort.
function filelistfig_pushbutton_sort_Callback(hObject, eventdata, handles)
% hObject    handle to filelistfig_pushbutton_sort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
