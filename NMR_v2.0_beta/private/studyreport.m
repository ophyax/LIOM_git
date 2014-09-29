function studyreport

global sellist paramnames presetlist

handles = guidata(findobj('Tag','filelistfig'));
mainhandles=guidata(findobj('Tag','mainmenu'));

% prepare "sellist"
if isfield(mainhandles,'studyreport')
    handles.studyreport=mainhandles.studyreport;
    if ~isfield(handles.studyreport,'default')
        handles.studyreport.default.fields=...
            {'nt' 'resto'  'studyid_'  'seqfil'  'tof'  'time_exp'  'time_run'  'tn'};
        mainhandles.studyreport=handles.studyreport;
        guidata(findobj('Tag','filelistfig'),mainhandles)
        disp('list of fields neu initialisert')
    end
else
    handles.studyreport.default.fields=...
        {'nt' 'resto'  'studyid_'  'seqfil'  'tof'  'time_exp'  'time_run'  'tn'};
    mainhandles.studyreport=handles.studyreport;
    guidata(findobj('Tag','filelistfig'),mainhandles)
    disp('list of fields neu initialisert')
end


for k=1:length(mainhandles.datalist)
    paramnames=union(paramnames, fieldnames(mainhandles.datalist(k).params));
end
sellist=[];
for k=1:length(handles.studyreport.default.fields)
    sellist=[sellist find(ismember(paramnames,handles.studyreport.default.fields{k}))];
end
handles.studyreport.sellist=sellist;
% ---
if ~isempty(findobj('Tag','Parameterlistfig'))
    figure(findobj('Tag','Parameterlistfig'))
    paramlistfig = gcf;
else
    paramlistfig = figure('Name','Parameterlist for studyreport','NumberTitle','off',...
        'Tag','Parameterlistfig','MenuBar','none',...
        'Units','normalized','Position',[0.5 0.5 0.15 0.375]);
end
presetlist_tot=fieldnames(handles.studyreport);
presetlist_tot=setxor(presetlist_tot,'sellist');
presetlist_idx = find(strcmp(presetlist_tot,'default')==1);
h0=0.05;
presetparamlist_popupmenu = uicontrol('Style','popupmenu','Parent',paramlistfig,...
    'String',presetlist_tot,'Value',presetlist_idx,'Units','normalized','Position',[0 1-h0 0.5 h0],...
    'Tag','presetparamlist_popupmenu','Callback',{@presetparamlist_popupmenu_callback});
saveparamlist_button = uicontrol('Style','pushbutton','Parent',paramlistfig,...
    'String','Save','Units','normalized','Position',[0.5 1-h0 0.5 h0],...
    'Tag','saveparamlist_button','Callback',{@saveparamlist_button_callback});
h1=0.3;
paramsel_uipanel = uipanel('Parent',paramlistfig,'Title','Selection',...
    'Units','normalized','Position',[0 1-h1-h0 1 h1]);

paramsel_edit = uicontrol('Style','edit','Parent',paramsel_uipanel,...
    'Min',1,'Max',(1+length(sellist)),'HorizontalAlignment','left',...
    'Units','normalized','Position',[0 0 1 1],'String',paramnames(sellist),...
    'Tag','paramsel_editbox','Callback',{@paramsel_edit_callback});

h2=0.05;
paramlist_button = uicontrol('Style','pushbutton','Parent',paramlistfig,...
    'String','Done','Units','normalized','Position',[0 0 1 h2],...
    'Tag','paramlistbutton','Callback',{@paramlistbutton_callback});

paramlist = uicontrol('Style','listbox','Parent',paramlistfig,...
    'String',paramnames,'Units','normalized','Position',[0 h2 1 1-h1-h2],...
    'Min',1,'Max',length(paramnames),'Value',sellist,...
    'Tag','paramlistbox','Callback',{@paramlistcallback});

guidata(findobj('Tag','filelistfig'),handles)
%% fuction presetparamlist_popupmenu_callback
function presetparamlist_popupmenu_callback(hObject,eventdata)

global sellist paramnames presetlist

handles = guidata(findobj('Tag','filelistfig'));
presetlist_tot = (get(findobj('Tag','presetparamlist_popupmenu'),'String'));
presetlist_idx= (get(findobj('Tag','presetparamlist_popupmenu'),'Value'));
presetlist = char(presetlist_tot{presetlist_idx});
sellist=[];
% disp(handles.studyreport.(presetlist).fields)
for k=1:length(handles.studyreport.(presetlist).fields)

    sellist=[sellist find(ismember(paramnames,handles.studyreport.(presetlist).fields{k}))];  
end
set(findobj('Tag','paramlistbox'),'Value',sellist);
set(findobj('Tag','paramsel_editbox'),'String',paramnames(sellist));
handles.studyreport.sellist=sellist;
guidata(findobj('Tag','filelistfig'),handles);


%% function saveparamlist_button_callback
function saveparamlist_button_callback(hObject,eventdata)

global sellist paramnames presetlist

handles = guidata(findobj('Tag','filelistfig'));
mainhandles=guidata(findobj('Tag','mainmenu'));

prompt='Enter Paramlist name:';
dlg_title = 'Save Paramlist';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)
    return;
end
presetlist = char(answer);
% presetlist_tot = (get(findobj('Tag','presetparamlist_popupmenu'),'String'));

if isfield(handles.studyreport,presetlist)
    handles.studyreport = rmfield(handles.studyreport,presetlist);
end
temp=paramnames(sellist);
handles.studyreport.(presetlist).fields= temp;
% disp(paramnames(sellist));
presetlist_tot=fieldnames(handles.studyreport);
presetlist_tot=setxor(presetlist_tot,'sellist');
presetlist_idx = find(strcmp(presetlist_tot,presetlist)==1);
set(findobj('Tag','presetparamlist_popupmenu'),'String',presetlist_tot)
set(findobj('Tag','presetparamlist_popupmenu'),'Value',presetlist_idx)

mainhandles.studyreport = handles.studyreport;
guidata(findobj('Tag','filelistfig'),handles);
guidata(findobj('Tag','mainmenu'),mainhandles);


%% function paramlistcallback
function paramlistcallback(hObject,eventdata)

global sellist paramnames presetlist

handles = guidata(findobj('Tag','filelistfig'));

get(findobj('Tag','paramlistbox'),'Value');
try
    sellist_cur = get(findobj('Tag','paramlistbox'),'Value');
catch
    disp('here')
    sellist_cur = cell2mat(get(findobj('Tag','paramlistbox'),'Value'));
end

if length(sellist_cur)==1
    if nnz(sellist_cur==sellist)==0
        try
            sellist=[sellist sellist_cur];
        catch
            sellist=[sellist; sellist_cur];
        end
    else
        sellist=sellist(sellist~=sellist_cur);
    end
else
    sellist=sellist_cur;
end
sellist=nonzeros(sellist);

if length(sellist)<=1
    numlines=2;
else
    numlines=length(sellist);
end

set(findobj('Tag','paramlistbox'),'Value',sellist)
set(findobj('Tag','paramsel_editbox'),'Min',1,'Max',numlines,...
    'String',paramnames(sellist))

handles.studyreport.sellist=sellist;
guidata(findobj('Tag','filelistfig'),handles)

%% function paramsel_edit_callback
function paramsel_edit_callback(hObject,eventdata)

global sellist paramnames presetlist

paramliststr=get(hObject,'String');
sellist=[];
for m=1:length(paramliststr)
    nextstr=strtrim(paramliststr(m));
    next_idx = find(ismember(paramnames,nextstr));
    if ~isempty(next_idx)
        sellist=[sellist next_idx];
    end
end
set(hObject,'String',paramnames(sellist))
set(findobj('Tag','paramlistbox'),'Value',sellist)

handles.studyreport.sellist=sellist;
guidata(findobj('Tag','filelistfig'),handles)

%% function paramlistbutton_callback
function paramlistbutton_callback(hObject,eventdata)

global sellist paramnames presetlist

handles = guidata(findobj('Tag','filelistfig'));
mainhandles=guidata(findobj('Tag','mainmenu'));

% ---
% sellist=[];
% for i=1:length(handles.studyreport.(presetlist).fields)
%     sellist=[sellist find(ismember(paramnames,handles.studyreport.(presetlist).fields{i}))];
% end
% handles.studyreport.sellist=sellist;
sellist=handles.studyreport.sellist;
% ---

h_wait = waitbar(0,'Please wait, creating study report file');


field_1='A1';
for n=1:length(mainhandles.datalist)+1
    waitbar(n/length(mainhandles.datalist)+1)
    if n>1
        paramstruct_cur = mainhandles.datalist(n-1).params;
    end
    for j=1:length(sellist)+1
        if j==1
            paramstr = 'file';
        else
            paramstr = char(paramnames(sellist(j-1)));
        end
        if n==1
            studyrep_cell{n,j}=paramstr;
            if j>1
                studyrep_fields{j-1}=paramstr;
            end
        else
            if j==1
                [pth name ext] = fileparts(mainhandles.datalist(n-1).path);
                studyrep_cell{n,j}=[name ext];
            else
                try
                    try
                        nextfield=char(paramstruct_cur.(paramstr){:});
                    catch
                        nextfield=paramstruct_cur.(paramstr);
                    end
                catch
                    nextfield='';
                end
                if size(nextfield,1)>1
                    temp='';
                    for k = 1:size(nextfield,1)
                        temp = [temp num2str(nextfield(k)) ', '];
                    end
                    studyrep_cell{n,j}=temp;
                else
                    studyrep_cell{n,j}=nextfield;
                end
            end
        end
    end
end

filedir=[mainhandles.homedir filesep 'studyreport'];
if ~isdir(filedir)
    mkdir(filedir)
end
studystart=char(mainhandles.datalist(1).params.time_svfdate{1});
filename=['studyreport_' studystart '.xls'];
fileloc = [filedir filesep filename];
xlswrite(fileloc, studyrep_cell) % , 'studyrpt',field_1)
disp('studyreport written to: '), disp(fileloc)

close(h_wait)
% record selection for log file
mainhandles.studyreport.(presetlist).fields=studyrep_fields;
guidata(findobj('Tag','mainmenu'),mainhandles);

close(gcf)
