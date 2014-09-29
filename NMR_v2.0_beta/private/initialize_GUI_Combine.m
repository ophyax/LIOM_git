function initialize_GUI_Combine(hObject)
% clc
handles = guidata(hObject);
mainhandles = guidata(findobj('Tag','mainmenu'));
filelisthandles = guidata(findobj('Tag','filelistfig'));

sellist = get(filelisthandles.filelistfig_listbox,'Value');

if length(sellist)>1
    set(handles.comb_radiobutton_selection,'Value',1);
    set(get(handles.comb_uipanel_array,'Children'),'Enable','off')
else
    set(handles.comb_radiobutton_array,'Value',1);
    set(get(handles.comb_uipanel_array,'Children'),'Enable','on')
    set(handles.array_edit_start,'String','1');
    set(handles.array_edit_step,'String','1');
    set(handles.array_edit_end,'String',num2str(length(mainhandles.datalist)));
    handles.array.start = 1;
    handles.array.step=1;
    handles.array.end=length(mainhandles.datalist);
    
end

if isfield(filelisthandles,'combine')
    set(handles.comb_edit_filename,'String',filelisthandles.combine);
end
guidata(hObject,handles)