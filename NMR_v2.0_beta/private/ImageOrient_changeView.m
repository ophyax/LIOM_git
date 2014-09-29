function ImageOrient_changeView
handles=guidata(findobj('Tag','GUI_ImageOrientation'));

h_view = flipdim(cell2mat(get(get(handles.uipanel_view,'Children'),'Value')),1);

choice_view = find(h_view==1);

switch choice_view
    case 1 %3 axes
        set(handles.text_title,'String','3 axes')
        
        set(handles.axes_coronal,'Position',[0.049 0.562 0.43 0.409],'Visible','on')
        set(handles.slider_edit_C_current,'Position',[0.049 0.513 0.037 0.02],'Visible','on')
        set(handles.slider_Coronal,'Position',[0.089 0.513 0.34 0.02],'Visible','on')
        set(handles.slider_text_C_end,'Position',[0.433 0.513 0.037 0.02],'Visible','on')
        set(handles.text_title_coronal,'Visible','on')
        
        set(handles.axes_sagittal,'Position',[0.545 0.562 0.43 0.409],'Visible','on')
        set(handles.slider_edit_S_current,'Position',[0.552 0.513 0.037 0.02],'Visible','on')
        set(handles.slider_Sagittal,'Position',[0.591 0.513 0.34 0.02],'Visible','on')
        set(handles.slider_text_S_end,'Position',[0.929 0.513 0.037 0.02],'Visible','on')
        set(handles.text_title_sagittal,'Visible','on')

        set(handles.axes_axial,'Position',[0.049 0.068 0.43 0.409],'Visible','on')
        set(handles.slider_edit_A_current,'Position',[0.049 0.026 0.037 0.02],'Visible','on')
        set(handles.slider_Axial,'Position',[0.089 0.026 0.34 0.02],'Visible','on')
        set(handles.slider_text_A_end,'Position',[0.433 0.026 0.037 0.02],'Visible','on')
        set(handles.text_title_axial,'Visible','on')
        
        set(handles.uipanel_contrast,'Visible','on')
        set(handles.ImageOrient_uipanel_orientation,'Visible','on')
        
    case 2 %Axial
        set(handles.uipanel_contrast,'Visible','off')
        set(handles.ImageOrient_uipanel_orientation,'Visible','off')
        set(handles.text_title_axial,'Visible','off')
        set(handles.text_title_sagittal,'Visible','off')
        set(handles.text_title_coronal,'Visible','off')
        set(handles.text_title,'Visible','on')
        set(handles.text_title,'String','Axial')
        
        set(handles.axes_sagittal,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_sagittal)
        cla;
        set(handles.slider_edit_S_current,'Visible','off')
        set(handles.slider_Sagittal,'Visible','off')
        set(handles.slider_text_S_end,'Visible','off')
        
        set(handles.axes_coronal,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_coronal)
        cla;
        set(handles.slider_edit_C_current,'Visible','off')
        set(handles.slider_Coronal,'Visible','off')
        set(handles.slider_text_C_end,'Visible','off')
                    
        set(handles.axes_axial,'Position',[0.03 0.09 0.95 0.88],'Visible','on')
        set(handles.slider_edit_A_current,'Position',[0.049 0.026 0.037 0.02],'Visible','on')
        set(handles.slider_Axial,'Position',[0.089 0.026 0.34 0.02],'Visible','on')
        set(handles.slider_text_A_end,'Position',[0.433 0.026 0.037 0.02],'Visible','on')   
        
    case 3 %Sagittal
        set(handles.uipanel_contrast,'Visible','off')
        set(handles.ImageOrient_uipanel_orientation,'Visible','off')
        set(handles.text_title_axial,'Visible','off')
        set(handles.text_title_sagittal,'Visible','off')
        set(handles.text_title_coronal,'Visible','off')
        set(handles.text_title,'Visible','on')
        set(handles.text_title,'String','Sagittal')
        
        set(handles.axes_axial,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_axial)
        cla;
        set(handles.slider_edit_A_current,'Visible','off')
        set(handles.slider_Axial,'Visible','off')
        set(handles.slider_text_A_end,'Visible','off')
        
        set(handles.axes_coronal,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_coronal)
        cla;
        set(handles.slider_edit_C_current,'Visible','off')
        set(handles.slider_Coronal,'Visible','off')
        set(handles.slider_text_C_end,'Visible','off')
        
        set(handles.axes_sagittal,'Position',[0.03 0.09 0.95 0.89],'Visible','on')
        set(handles.slider_edit_S_current,'Position',[0.049 0.026 0.037 0.02],'Visible','on')
        set(handles.slider_Sagittal,'Position',[0.089 0.026 0.34 0.02],'Visible','on')
        set(handles.slider_text_S_end,'Position',[0.433 0.026 0.037 0.02],'Visible','on')  
        
    case 4 % Coronal
        set(handles.uipanel_contrast,'Visible','off')
        set(handles.ImageOrient_uipanel_orientation,'Visible','off')
        set(handles.text_title_axial,'Visible','off')
        set(handles.text_title_sagittal,'Visible','off')
        set(handles.text_title_coronal,'Visible','off')
        set(handles.text_title,'Visible','on')
        set(handles.text_title,'String','Coronal')
        
        set(handles.axes_sagittal,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_sagittal)
        cla;
        set(handles.slider_edit_S_current,'Visible','off')
        set(handles.slider_Sagittal,'Visible','off')
        set(handles.slider_text_S_end,'Visible','off')
        
        set(handles.axes_axial,'Visible','off')
        set(gcf,'CurrentAxes',handles.axes_axial)
        cla;
        set(handles.slider_edit_A_current,'Visible','off')
        set(handles.slider_Axial,'Visible','off')
        set(handles.slider_text_A_end,'Visible','off')
                    
        set(handles.axes_coronal,'Position',[0.03 0.09 0.95 0.89],'Visible','on')
        set(handles.slider_edit_C_current,'Position',[0.049 0.026 0.037 0.02],'Visible','on')
        set(handles.slider_Coronal,'Position',[0.089 0.026 0.34 0.02],'Visible','on')
        set(handles.slider_text_C_end,'Position',[0.433 0.026 0.037 0.02],'Visible','on')  
end

ImageOrient_display;
