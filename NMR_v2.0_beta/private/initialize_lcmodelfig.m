function initialize_lcmodelfig(hObject)
% clc
handles = guidata(hObject);
mainhandles= guidata(findobj('Tag','mainmenu'));

%basis bouton invisible
set(get(handles.lcmodelfig_uipanel_options,'Children'),'Enable','off','Visible','off');
set(get(handles.lcmodelfig_uipanel_result,'Children'),'Enable','on','Visible','on');


if isfield(mainhandles,'lcmodel')==0
    
    %mainhandles.lcmodel.server.name = %'lifmetserv5.epfl.ch'; PP
    
    login_serv5 = login;
   
    
    [FileName,winscp] = uigetfile('WinSCP.com','Select the WinSCP executalbe');
    
    mainhandles.lcmodel.server.login = login_serv5{1};
    mainhandles.lcmodel.server.pwd = login_serv5{2};
    mainhandles.lcmodel.targetfolder = ['/home/' login_serv5{1}];
    mainhandles.lcmodel.winscp = [winscp FileName];
     %% first connection to save the  server host key
    FileName=strrep(FileName,'.com','.exe');
    cd(winscp)
    dos([FileName ' /open scp://' login_serv5{1} ':' login_serv5{2} '@'  mainhandles.lcmodel.server.name])
    
    %% if GUI_LCModel called from process panel -> open filelistfig
else
    try
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'orig_controlfile');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'sel_controlfile');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'cur_controlfile');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'basisfile');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'reffile');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'dataidx');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'arrayidx');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'dataiidx_ref');
    mainhandles.lcmodel = rmfield(mainhandles.lcmodel,'arrayidx_ref');
    catch
    end
end


mainhandles.lcmodel.orig_controlfile{1}='Original Control file';
mainhandles.lcmodel.sel_controlfile{1}='Selected Control file';
mainhandles.lcmodel.cur_controlfile{1}='Current Control file';
mainhandles.lcmodel.basisfile{1}='Basis file'; % '/home/lcmodel/.lcmodel/basis-sets/ACaveragebasis.BASIS'
mainhandles.lcmodel.reffile{1}='';

%% if GUI_LCModel called from process panel -> adjust filelist indexes
if strcmp(handles.called,'processfig')
    data_idx = mainhandles.dispopts.dataidx;
    if mainhandles.datalist(data_idx).multiplicity >1
        button = questdlg('Do you want to process?','LCModel', 'current spectrum','Entire array','Entire array');
        if strcmp(button,'Entire array')
            array_idx = {1:mainhandles.datalist(data_idx).multiplicity};
            lcmidx=1:mainhandles.datalist(data_idx).multiplicity;
        else
             array_idx =  {mainhandles.dispopts.arrayidx};
             lcmidx=1;
        end
    else
        array_idx =  {mainhandles.dispopts.arrayidx};
        lcmidx=1;
    end
    
elseif strcmp(handles.called,'filelistfig') == 1
    filelisthandles=guidata(findobj('Tag','filelistfig'));
    filelistidx = get(filelisthandles.filelistfig_listbox,'Value');
    filelist_tot = get(filelisthandles.filelistfig_listbox,'String');
    filelist={filelist_tot{filelistidx}};
    data_idx=[];
    array_idx=[];
    
    
    if length(filelist_tot)>max(size(mainhandles.datalist)) % = expanded list
        for i=1:length(filelist)
            curfile=filelist{i};
            cutidx=max(strfind(curfile,'_'));
            curfilestr=curfile(1:cutidx-1);
            [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
            data_idx=[data_idx; idx];
            array_idx{i}=[array_idx str2double(curfile(cutidx+1:length(curfile)))];
            lcmidx(i)=i;
        end
    else
        for i=1:length(filelist)
            curfilestr=filelist{i};
            [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
            data_idx=[data_idx; idx];
            array_idx{i}=(1:mainhandles.datalist(data_idx(i)).multiplicity)';
            if i>1
              lcmidx(i) = lcmidx(i-1) + mainhandles.datalist(data_idx(i)).multiplicity;
            else
              lcmidx(i) = mainhandles.datalist(data_idx(i)).multiplicity;
            end
        end
    end
end
if isempty(array_idx)==1
    for i=1:length(data_idx)
        array_idx{i}=(1:mainhandles.datalist(data_idx(i)).multiplicity)';
    end
end

for k=1:length(data_idx)
    idx_temp{k} = ones(size(array_idx{k})).*data_idx(k);
end
% data_idx = [idx_temp{:}];
% array_idx = [array_idx{:}];
mainhandles.lcmodel.dataidx = data_idx;
mainhandles.lcmodel.arrayidx = array_idx;
mainhandles.lcmodel.lcmidx = lcmidx;

    


cur_controlfile{1}='Current Control file';
for i=2:lcmidx(length(lcmidx))
    mainhandles.lcmodel.cur_controlfile{i} = 'Current Control file';
  
%     if exist(mainhandles.lcmodel.cur_controlfile{i},'file')
%         cur_controlfile{ct}=mainhandles.lcmodel.cur_controlfile{i};
%         ct=ct+1;
%     end
end
% mainhandles.lcmodel.cur_controlfile=cur_controlfile;
if length(mainhandles.lcmodel.cur_controlfile)>1
    set(handles.lcmodelfig_edit_Controlfile,'Style','popupmenu',...
        'String',mainhandles.lcmodel.cur_controlfile)
else
    set(handles.lcmodelfig_edit_Controlfile,'Style','edit',...
        'String',mainhandles.lcmodel.cur_controlfile{1})
end

sel_controlfile_idx = ...
    find(ismember(mainhandles.lcmodel.cur_controlfile,mainhandles.lcmodel.sel_controlfile)==1);
if isnumeric(sel_controlfile_idx)==0 || isempty(sel_controlfile_idx)
    sel_controlfile_idx=1;
end
%--- set switches
handles.yesall.fid2raw.zerofill = '';
handles.yesall.ECC = '';
handles.yesall.overwrite.controlfile = '';
handles.yesall.overwrite.plotin = '';

%--- Setting up Uicontrols ---------------------
%--- edit text
set(handles.lcmodelfig_edit_Controlfile,'Value',1)
% set(handles.lcmodelfig_edit_Basisfile,'String',mainhandles.lcmodel.basisfile)
set(handles.lcmodelfig_edit_reffile,'String',mainhandles.lcmodel.reffile)
set(handles.lcmodelfig_edit_server,'String',mainhandles.lcmodel.server.name)
set(handles.lcmodelfig_edit_targetfolder,'String',mainhandles.lcmodel.targetfolder)


%--- save handles ---------------------------------------------------------
guidata(hObject,handles);
guidata(findobj('Tag','mainmenu'),mainhandles);

