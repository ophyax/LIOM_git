function initialize_filelistfig(hObject)

handles = guidata(hObject);
mainhandles = guidata(findobj('Tag','mainmenu'));

try
    %--- initilize uicontrols
    if isfield(mainhandles,'datalist')==0 || isempty(mainhandles.datalist)==1
        set(handles.filelistfig_popupmenu_selectformat,'Value',1,'String','Format')
        set(handles.filelistfig_popupmenu_selecttype,'Value',1,'String','Acqtype')
        set(handles.filelistfig_listbox,'Value',1,'Max',1,'String','empty');
    else
        formatlist = unique(cellstr({mainhandles.datalist.format}));
        set(handles.filelistfig_popupmenu_selectformat,'Value',1,'String',formatlist)
        if isfield(mainhandles,'dispopts')
            if isfield(mainhandles.dispopts,'dataidx')
                dataidx = mainhandles.dispopts.dataidx;
            else
                dataidx=1;
            end
        else
            dataidx=1;
        end
        set(handles.filelistfig_listbox,'Value',dataidx,'String',{mainhandles.datalist.liststring},...
            'Max',length({mainhandles.datalist.liststring}))
        if isfield(mainhandles.datalist,'acqtype')==1
            acqtypelist = unique(cellstr({mainhandles.datalist.acqtype}));
            set(handles.filelistfig_popupmenu_selecttype,'Value',1,'String',acqtypelist)
        else
            set(handles.filelistfig_popupmenu_selecttype,'Value',1,'String','','enable','off')
        end
        set(handles.filelistfig_listbox,'Value',mainhandles.dispopts.arrayidx);
    end

catch
    updatedata
end
set(handles.filelistfig_pushbutton_LCModelRef,'Visible','Off')

%--- save handles ---------------------------------------------------------
guidata(hObject,handles);