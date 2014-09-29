function initialize_Save_gui(hObject)
clc
handles = guidata(hObject);
% mainhandles = guidata(findobj('Tag','mainmenu'));
imagehandles = guidata(findobj('Tag','GUI_ImageOrientation'));
handles.options(1).outputpath = imagehandles.data.path;
set(handles.save_edit_outputdir,'String',handles.options(1).outputpath);

if length(size(imagehandles.data.data.image))==4
    set(get(handles.save_uipanel_DTI,'Children'),'Visible','on','Enable','on');
    handles.options(1).dim = get(handles.DT_popupmenu_3D4D,'Value');
    
    DWI_str = get(imagehandles.display_popupmenu_DWI,'String');
%     DWI_idx = findsrt(DWI_str,'b_');
%     if sum(DWI_idx)<length(DWI_idx)
    handles.options(1).DWdata=DWI_str;
    set(handles.DTI_listbox_DWdata,'String',handles.options(1).DWdata,'Max',length(DWI_str));
    set(handles.DTI_listbox_DWdata,'Value',(1:1:length(DWI_str))');
%     end
else
    set(get(handles.save_uipanel_DTI,'Children'),'Visible','off','Enable','off');
end

handles.soft = {'Default',  'ImageJ', 'MRIcro', 'Slicer', 'MedINRIA', 'DTIStudio', 'Matlab'};
handles.fileformat = {'Analyse', 'NII', 'Matlab', 'NRRD'};
handles.bitetype = {'uint8', 'int16', 'float32', 'double'};
handles.dim3D4D = {'3D', '4D'};

set(handles.save_popupmenu_soft,'String',handles.soft);
set(handles.save_popupmenu_fileformat,'String',handles.fileformat);
set(handles.save_popupmenu_bitetype,'String',handles.bitetype);
set(handles.DT_popupmenu_3D4D,'String',handles.dim3D4D);

set(handles.save_popupmenu_soft,'Value',1);
set(handles.save_popupmenu_fileformat,'Value',1);
set(handles.save_popupmenu_bitetype,'Value',1);
set(handles.save_checkbox_sepfolder,'Value',0);
set(handles.save_edit_filename,'String','Input_filename');

handles.options(1).soft = 1;
handles.options(1).fileformat = 1;
handles.options(1).bitetype = 2;
handles.options(1).sepfolder = 0;
handles.options(1).filename = 'Input_filename';



set(handles.save_edit_idx,'String','1/1');

guidata(hObject,handles);