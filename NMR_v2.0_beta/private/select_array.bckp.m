function sel_idx = select_array(multiplicity)
but_h = 30;
but_w = 50;
n_fid = multiplicity; %mainhandles.datalist(dataidx).multiplicity
nline = 1;
ncul=8;

if n_fid>8
    fig_w = but_w*ncul;
    nline = ceil(n_fid/ncul);
    fig_h = but_h*nline;
else
    fig_w = n_fid*but_w;
    ncul = n_fid;
    fig_h = but_h;
end
% fig_h = fig_h+but_w; %% add button like select all or deselect all

title = 'Select data to be added';
selectfid_fig = figure('Name',title,'NumberTitle','off',...
    'Tag','selectfid_fig','MenuBar','none','Units','pixel',...
    'Position',[200 300 fig_w+10 fig_h+but_h+10]);
selectfid_panel = uipanel('Parent',selectfid_fig,...
    'Tag','select_panel','Units','pixel',...
    'Position',[0 but_h+10 fig_w+10 fig_h+10]);
for k=1:n_fid
    posx = 5+(mod(k-1,ncul))*but_w;
    posy = fig_h - (floor((k-1)/8)+1)*but_h;
    tag = ['sel_' num2str(k)];
    button(k).sel = uicontrol('Style','togglebutton','Parent',selectfid_panel,'Units','pixel',...
    'String',num2str(k),'Position',[posx posy but_w but_h],...
    'Tag',tag,'Callback',{@button_sel_callback});
end

button_all = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','All','Position',[5 5 but_w but_h],...
    'Tag','applytoall_button','Callback',{@button_all_callback});
button_none = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','None','Position',[60 5 50 30],...
    'Tag','none_button','Callback',{@button_none_callback});
button_apply = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','Apply','Position',[fig_w-but_w-5 5 50 30],...
    'Tag','apply','Callback',{@button_apply_callback});

button_all_callback;

function button_sel_callback(hObject,eventdata)
% handles = guidata(findobj('Tag','selectfid_panel'));
% sel = get(findobj('Tag','select_panel'),'Children');
cur_val = get(hObject,'Value');

function button_all_callback(hObject,eventdata)
% handles = guidata(findobj('Tag','selectfid_panel'));
sel = get(findobj('Tag','select_panel'),'Children');
set(sel,'Value',1);
function button_none_callback(hObject,eventdata)
% handles = guidata(finobj,'Tag','selectfid_fig');
sel = get(findobj('Tag','select_panel'),'Children');
set(sel,'Value' ,0);
function sel_idx = button_apply_callback(hObject,eventdata)
sel = get(findobj('Tag','select_panel'),'Children');
sel_idx = flipdim(get(sel,'Value'),1);
delete(findobj('Tag','selectfid_fig'));
