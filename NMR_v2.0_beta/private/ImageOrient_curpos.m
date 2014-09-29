function ImageOrient_curpos(handles)


set(handles.GUI_ImageOrientation,'Unit','points')
set(handles.ImageOrient_uipanel_axes,'Unit','points')
set(get(handles.ImageOrient_uipanel_axes,'Children'),'Unit','points')

curpoint=get(handles.GUI_ImageOrientation,'CurrentPoint')

mainpanelpos = get(handles.ImageOrient_uipanel_axes,'Position')
curpoint = curpoint-mainpanelpos(1:2)

h_view = flipdim(cell2mat(get(get(handles.uipanel_view,'Children'),'Value')),1);
choice_view = find(h_view==1);

switch choice_view
    case 1 %3 axes
        pos.axial = get(handles.axes_axial,'Position');
        pos.sagittal = get(handles.axes_sagittal,'Position');
        pos.coronal = get(handles.axes_coronal,'Position');
        
        if curpoint(1)>pos.axial(1) && curpoint(1)<pos.axial(1)+pos.axial(3) ...
                && curpoint(2)>pos.axial(2) && curpoint(2)<pos.axial(2)+pos.axial(3)
            disp('axial')
            curpoint = curpoint-pos.axial(1:2)
            datacursormode(handles.GUI_ImageOrientation);
            limX = floor(get(handles.axes_axial,'Xlim'));
            limY = floor(get(handles.axes_axial,'Ylim'));
            
        end
        if curpoint(1)>pos.sagittal(1) && curpoint(1)<pos.sagittal(1)+pos.sagittal(3) ...
                && curpoint(2)>pos.sagittal(2) && curpoint(2)<pos.sagittal(2)+pos.sagittal(3)
            disp('sagittal')
            curpoint = curpoint-pos.sagittal(1:2);
        end
        if curpoint(1)>pos.coronal(1) && curpoint(1)<pos.coronal(1)+pos.coronal(3) ...
                && curpoint(2)>pos.coronal(2) && curpoint(2)<pos.coronal(2)+pos.coronal(3)
            disp('coronal')
            curpoint = curpoint-pos.coronal(1:2);
        end        
    case 2 % axial
        pos.axial = get(handles.axes_axial,'Position');
        curpoint = curpoint-pos.axial(1:2);
    case 3 % sagittal
        pos.sagittal = get(handles.axes_axial,'Position');
        curpoint = curpoint-pos.sagittal(1:2);
    case 4 % coronal
        pos.coronal = get(handles.axes_axial,'Position');
        curpoint = curpoint-pos.coronal(1:2);
end



set(handles.GUI_ImageOrientation,'Unit','normalized')
set(handles.ImageOrient_uipanel_axes,'Unit','normalized')
set(get(handles.ImageOrient_uipanel_axes,'Children'),'Unit','normalized')