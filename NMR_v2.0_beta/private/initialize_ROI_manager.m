function initialize_ROI_manager(handles)
imghandles=guidata(findobj('Tag','GUI_ImageOrientation'));


%% create the first ROI
name='ROI1';
set(handles.info_edit_name,'String',name);
set(handles.roi_listbox,'String',name);
set(handles.info_pushbutton_color,'BackgroundColor',[1 0 0]);
set(handles.info_text_vol_mm,'String','0 mm3');
set(handles.info_text_vol_outp_s,'String','0/0 mm3/pix');
set(handles.info_text_vol_outp_v,'String','0/0 mm3/pix');
set(handles.info_text_val_outp_s,'String','----');
set(handles.info_text_val_outp_v,'String','----');

handles.size = size(imghandles.data.data.image);
handles.size = handles.size(1:3);
handles.roilist.(name).roi = zeros(handles.size);
% handles.roilist.(name).roi(50:200,6:16,40:90)=ones(151,11,51);
handles.roilist.(name).color = [1 0 0];
handles.roilist.(name).transp = 1;


set(handles.options_slider_thresmin,'Min',imghandles.imglim(1))
set(handles.options_slider_thresmin,'Max',imghandles.imglim(2))
set(handles.options_slider_thresmin,'Value',imghandles.imglim(1))
set(handles.options_slider_thresmin,'Min',imghandles.imglim(1))
set(handles.options_slider_thresmin,'Max',imghandles.imglim(2))
set(handles.options_slider_thresmin,'Value',imghandles.imglim(2))

set(handles.options_edit_thresmin,'String',num2str(imghandles.imglim(1)))
set(handles.options_edit_thresmin,'String',num2str(imghandles.imglim(2)))

guidata(handles.ROI_manager,handles);
