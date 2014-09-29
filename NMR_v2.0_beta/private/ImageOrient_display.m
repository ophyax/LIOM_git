function ImageOrient_display
% clc
disp_debug =0;
ImageOrient_AdjustSliders;

handles=guidata(findobj('Tag','GUI_ImageOrientation'));

set(0,'CurrentFigure',handles.GUI_ImageOrientation)
% all_curaxes=findobj('Type','axes','Parent',handles.ImageOrient_uipanel_axes);


set(get(handles.ImageOrient_uipanel_orientation,'Children'),'Enable','off');
set(get(handles.ImageOrient_uipanel_dims,'Children'),'Enable','off');


slider(1) = round(get(handles.slider_Axial,'Value'));
slider(2) = round(get(handles.slider_Coronal,'Value'));
slider(3) = round(get(handles.slider_Sagittal,'Value'));

%% prepare data
img_color=0;   %% tag for colormap;
range= handles.clim;
if length(size(handles.data.data.image))==4
    DWI_idx = get(handles.display_popupmenu_DWI,'Value');
    DWI_str = get(handles.display_popupmenu_DWI,'String');
    if ~isempty(strfind(char(DWI_str(DWI_idx)),'b_'))
        
        img = squeeze(handles.data.data.image(:,:,:,DWI_idx));
        if length(size(img))==2 %single slice
            tmp=img;
            
            
            slide_idx= find(size(handles.data.data.image)==1);
            switch  slide_idx(1)
                case 1
                    img=zeros(1,size(tmp,1),size(tmp,2));
                    img(1,:,:)=tmp;
                case 2
                    img=zeros(size(tmp,1),1,size(tmp,2));
                    img(:,1,:)=tmp;
                    
                case 3
                    img=zeros([size(tmp,1) size(tmp,2) 2]); %%problem can not have the last dimension = 1
                    img(:,:,1)=tmp;
                    
            end
            
        end
        if get(handles.process_checkbox_bias,'Value')==1
            img=handles.data.BiasFilter;
        else
            
        end
        set(get(handles.ImageOrient_uipanel_orientation,'Children'),'Enable','on');
        set(get(handles.ImageOrient_uipanel_dims,'Children'),'Enable','on');
        ImageOrient_contrast
    else
        switch char(DWI_str(DWI_idx))
            case 'colormap'
                temp =handles.data.data.Tens.colormap;
                
                img=reshape(temp,[size(temp,1) size(temp,2)*size(temp,3) 3]);
                [img map_c2] =  rgb2ind(img,256);
                img=reshape(img,[size(temp,1) size(temp,2) size(temp,3)]);
                % ImageOrient_contrast(img_c)
                
                set(setxor(get(handles.uipanel_contrast,'Children'),[handles.axes_contrast handles.axes_colorbar]),'Enable','on');
                img_color = 1;
                
                range=[0 256];
                
                
            case 'GFA'
                img =handles.data.data.qball.(char(DWI_str(DWI_idx)));
                ImageOrient_contrast(img)
                %                 scale=64*cont/double(max(max(max(max(img)))));
            case 'ODF'
                q=3;
                img =squeeze(handles.data.data.qball.(char(DWI_str(DWI_idx)))(:,:,:,q));
                ImageOrient_contrast(img)
                
            otherwise
                img =handles.data.data.Tens.(char(DWI_str(DWI_idx)));
                ImageOrient_contrast(img)
        end
    end
    %     scale=1;
else
    img = handles.data.data.image(:,:,:);
    if get(handles.process_checkbox_bias,'Value')==1
        img = img./handles.data.BiasFilter;
    end
    set(get(handles.ImageOrient_uipanel_orientation,'Children'),'Enable','on');
    set(get(handles.ImageOrient_uipanel_dims,'Children'),'Enable','on');
    ImageOrient_contrast
end

if disp_debug ==1
    display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% img info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    display(['Size img: ' num2str(size(img))])
    display(['Slice position: '  num2str(slider([2 3 1]))])
end

%% axes limits
if get(handles.display_radiobutton_zoom,'Value')==1 || get(handles.display_radiobutton_pan,'Value')==1
    dim.x.axial =  get(handles.axes_axial,'Xlim');
    dim.y.axial = get(handles.axes_axial,'Ylim');
    dim.x.sagittal =  get(handles.axes_sagittal,'Xlim');
    dim.y.sagittal = get(handles.axes_sagittal,'Ylim');
    dim.x.coronal =  get(handles.axes_coronal,'Xlim');
    dim.y.coronal = get(handles.axes_coronal,'Ylim');
    dime_axes(1) = dim.y.sagittal(2);
    dime_axes(2) = dim.y.axial(2);
    dime_axes(3) = dim.x.axial(2);
else
    dime_axes = size(img);
    dim.x.axial =  [0.5 dime_axes(3)+0.5];
    dim.y.axial = [0.5 dime_axes(2)+0.5];
    dim.x.sagittal =  [0.5 dime_axes(2)+0.5];
    dim.y.sagittal = [0.5 dime_axes(1)+0.5];
    dim.x.coronal =  [0.5 dime_axes(3)+0.5];
    dim.y.coronal = [0.5 dime_axes(1)+0.5];
end
% orient = 0;
if disp_debug==1;
    display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% axes info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    display(['Dim axes coronal (x/y): ' num2str(dim.x.coronal) ' / ' num2str(dim.y.coronal)])
    display(['Dim axes sagittal (x/y): ' num2str(dim.x.sagittal) ' / ' num2str(dim.y.sagittal)])
    display(['Dim axes axial (x/y): ' num2str(dim.x.axial) ' / ' num2str(dim.y.axial)])
end

%% pixel size
if get(handles.display_radiobutton_aspect,'Value')==1;
    pix.RO = double(handles.data.params.lro)/handles.data.params.np*2*10;
    pix.PE = double(handles.data.params.lpe)/handles.data.params.nv*10;
    pix.SS = handles.data.params.thk;
    
    pix.axial=[pix.(char(handles.data.orientation{1,2})) pix.(char(handles.data.orientation{1,3}))];
    pix.cor = [pix.(char(handles.data.orientation{1,1})) pix.(char(handles.data.orientation{1,3}))];
    pix.sag =[pix.(char(handles.data.orientation{1,1})) pix.(char(handles.data.orientation{1,2}))];
else
    dime = size(img);
    
    pix.axial = [1 dime(2)/dime(3)];
    pix.cor = [1 dime(1)/dime(3)];
    pix.sag = [1 dime(1)/dime(2)];
end
handles.data.pix=pix;
if disp_debug==1
    display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% pix info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    display(pix)
end

%% display images
h_view = flipdim(cell2mat(get(get(handles.uipanel_view,'Children'),'Value')),1);
choice_view = find(h_view==1);

if choice_view==1 || choice_view==2
    set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
    %     axes(handles.axes_axial)
    cla;
    hold on
    
    if img_color==1
        slide_c = squeeze(img(slider(1),:,:,:));
        map_c = map_c2;
        imagesc(slide_c, 'HitTest', 'off');
        colormap(map_c)
        caxis([0 255])
    else
        userdata= squeeze(img(round(slider(1)),:,:));  % one dimension (e,g, one slice)
        if sum(size(userdata)==1)==1
            userdata = rot90(userdata,1);
        end
        imagesc(userdata, 'HitTest', 'off');
        set(handles.axes_axial,'UserData',userdata);
        caxis(handles.clim)
    end
    daspect([[pix.axial] 1])
    
    xlim(dim.x.axial)
    ylim(dim.y.axial)
    
    hold off
end


if choice_view==1 || choice_view==3
    set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
    cla;
    hold on
    if img_color==1
        slide_c = squeeze(img(:,:,slider(3),:));
        map_c = map_c2;
        imagesc(slide_c, 'HitTest', 'off');
        colormap(map_c)
        caxis([0 255])
    else
        userdata= squeeze(img(:,:,round(slider(3))));
        %         if sum(size(userdata)==1)==1 % one dimension (e,g, one slice)
        %             userdata = rot90(userdata,1);
        %         end
        imagesc(userdata, 'HitTest', 'off');
        set(handles.axes_sagittal,'UserData',userdata);
        caxis(handles.clim)
    end
    
    xlim(dim.x.sagittal)
    ylim(dim.y.sagittal)
    daspect([[pix.sag] 1])
    
    hold off
end

if choice_view==1 || choice_view==4
    set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
    hold on
    if img_color==1
        slide_c = squeeze(img(:,slider(2),:,:));
        map_c = map_c2;
        imagesc(slide_c, 'HitTest', 'off');
        colormap(map_c)
        caxis([0 255])
        
        if disp_debug==1
            display('%%%%%%%%%%%%%%%%%%%%%% CMAP INFO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
            display(['size mpa_c: ' num2str(size(map_c))])
            display(['Min/Max map_c: ' num2str(min(min(map_c))) ' ' num2str(max(max(map_c)))])
            display(['Min/Max image: ' num2str(min(min(slide_c))) ' ' num2str(max(max(slide_c)))])
            
            figure(1)
            subplot(131)
            imshow(squeeze(img(:,slider(2),:,:)))
            subplot(132)
            hold on
            image(slide_c);
            colormap(map_c)
            hold off
            xlim(dim.x.coronal)
            ylim(dim.y.coronal)
            caxis([1 max(max(slide_c))])
            subplot(133)
            imshow(slide_c,map_c);
        end
    else
        userdata= squeeze(img(:,round(slider(2)),:));
        if sum(size(userdata)==1)==1 % one dimension (e,g, one slice)
            userdata = rot90(userdata,1);
        end
        imagesc(userdata, 'HitTest', 'off');
        set(handles.axes_coronal,'UserData',userdata);
        caxis(handles.clim)
    end
    
    xlim(dim.x.coronal)
    ylim(dim.y.coronal)
    daspect([[pix.cor] 1])
    
    hold off
end

%% ROI
hh = findobj('Tag','ROI_manager');
if ~isempty(hh)
    if strcmp(get(hh,'Visible'),'on')
        ROIhandles = guidata(hh);
        roi_list = cellstr(get(ROIhandles.roi_listbox,'String'));
        roi_sel = get(ROIhandles.roi_listbox,'Value');
        if disp_debug==1
            display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% display ROI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
            display(['ROI to be displayed: ' num2str(roi_sel)]);
        end
        
        contents = cellstr(get(handles.display_popupmenu_colormap,'String'));
        map = contents{get(handles.display_popupmenu_colormap,'Value')};
        cmap = colormap([map '(256)']);
        roi_cmap=zeros(length(roi_sel)+size(cmap,1),3);
        roi_cmap(1:size(cmap,1),:)=cmap;
        cmap_step = (handles.clim(2)-handles.clim(1))/256;
        for k=1:1:length(roi_sel)
            transp = 0.5;%ROIhandles.roilist.(roi_list{roi_sel(k)}).roi.transp;
            roi = ROIhandles.roilist.(roi_list{roi_sel(k)}).roi.*handles.clim(2)-1*(length(roi_sel)-k)*cmap_step;
            roi2 = ROIhandles.roilist.(roi_list{roi_sel(k)}).roi.*transp;

            color = ROIhandles.roilist.(roi_list{roi_sel(k)}).color;
            roi_cmap(k+size(cmap,1),:)=color;

            if disp_debug==1
               display(['name: ' roi_list{roi_sel(k)}]);
               display(['color: ' num2str(color)]);
               display(['clim: ' num2str(handles.clim)])
               display(['roi lim: ' num2str([min(min(min(roi))) max(max(max(roi)))])])
%                figure(2)
%                subplot(121)
%                imagesc(squeeze(roi(:,10,:)))
%                subplot(122)
%                imshow(squeeze(roi2(:,10,:,:)))
%                alim([0 max(max(roi_cmap))])
               
            end
            if choice_view==1 || choice_view==2
                set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
                hold on
                userdata= squeeze(roi(round(slider(1)),:,:));  % one dimension (e,g, one slice)
                userdata2= squeeze(roi2(round(slider(1)),:,:));  % one dimension (e,g, one slice)
                if sum(size(userdata)==1)==1
                    userdata = rot90(userdata,1);
                    userdata2 = rot90(userdata2,1);
                end

                h_roi_ax = imagesc(userdata, 'HitTest', 'off');
                colormap(roi_cmap)
                set(h_roi_ax,'AlphaData',userdata2);
                alim([0 1])

                hold off
                
%                 if disp_debug==1
%                     figure(3)
%                     subplot(223)
%                     imshow(userdata);
%                 end
            end
            if choice_view==1 || choice_view==3 
                set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
                hold on
                userdata= squeeze(roi(:,:,round(slider(3))));
                userdata2= squeeze(roi2(:,:,round(slider(3))));
                %         if sum(size(userdata)==1)==1 % one dimension (e,g, one slice)
                %             userdata = rot90(userdata,1);
                %         end
                h_roi_sag = imagesc(userdata, 'HitTest', 'off');
                colormap(roi_cmap)
                set(h_roi_sag,'AlphaData',userdata2);
                alim([0 1])

                hold off
%                  if disp_debug==1
%                     figure(3)
%                     subplot(222)
%                     imshow(userdata,roi_cmap);
%                 end
            end
            if choice_view==1 || choice_view==4
                set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
                hold on
                userdata= squeeze(roi(:,round(slider(2)),:));
                userdata2= squeeze(roi2(:,round(slider(2)),:));
                if sum(size(userdata)==1)==1 % one dimension (e,g, one slice)
                    userdata = rot90(userdata,1);
                    userdata2 = rot90(userdata2,1);
                end
                
                h_roi_cor = imagesc(userdata, 'HitTest', 'off');
                colormap(roi_cmap)
                set(h_roi_cor,'AlphaData',userdata2);
                alim([0 1])
                hold off
                
%                 if disp_debug==1
%                     figure(3)
%                     subplot(221)
%                     imagesc(userdata);
%                 end
            end
        end
    end
end

%% px/mm
if get(handles.display_togglebutton_px_mm,'Value') == 1  %display cross
    num_format = '% 10.1f';
    if choice_view==1 || choice_view==2
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
        x_ticks = (get(handles.axes_axial,'XTick'));
        y_ticks = get(handles.axes_axial,'YTick');
        x_ticks=x_ticks.*pix.axial(2);
        y_ticks=y_ticks.*pix.axial(1);
        set(handles.axes_axial,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_axial,'YTickLabel',num2str(y_ticks',num_format))
    end
    if choice_view==1 || choice_view==3
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
        x_ticks = (get(handles.axes_sagittal,'XTick'));
        y_ticks = get(handles.axes_sagittal,'YTick');
        x_ticks=x_ticks.*pix.sag(2);
        y_ticks=y_ticks.*pix.sag(1);
        set(handles.axes_sagittal,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_sagittal,'YTickLabel',num2str(y_ticks',num_format))
    end
    if choice_view==1 || choice_view==4
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
        x_ticks = (get(handles.axes_coronal,'XTick'));
        y_ticks = get(handles.axes_coronal,'YTick');
        x_ticks=x_ticks.*pix.cor(2);
        y_ticks=y_ticks.*pix.cor(1);
        set(handles.axes_coronal,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_coronal,'YTickLabel',num2str(y_ticks',num_format))
    end
else
    num_format = '% 10.0f';
    if choice_view==1 || choice_view==2
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
        x_ticks = (get(handles.axes_axial,'XTick'));
        y_ticks = get(handles.axes_axial,'YTick');
        set(handles.axes_axial,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_axial,'YTickLabel',num2str(y_ticks',num_format))
    end
    if choice_view==1 || choice_view==3
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
        x_ticks = (get(handles.axes_sagittal,'XTick'));
        y_ticks = get(handles.axes_sagittal,'YTick');
        set(handles.axes_sagittal,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_sagittal,'YTickLabel',num2str(y_ticks',num_format))
    end
    if choice_view==1 || choice_view==4
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
        x_ticks = (get(handles.axes_coronal,'XTick'));
        y_ticks = get(handles.axes_coronal,'YTick');
        set(handles.axes_coronal,'XTickLabel',num2str(x_ticks',num_format))
        set(handles.axes_coronal,'YTickLabel',num2str(y_ticks',num_format))
    end
end


%% grid
if get(handles.display_radiobutton_grid,'Value') == 1  %display cross
    grid_c = get(handles.pushbutton_color_grid,'BackgroundColor');
    grid_int = 1;
    %     color = uisetcolor([0 0 0])
    X=1:grid_int:dime_axes(2); %axe X vertical on Axial image
    Y=1:grid_int:dime_axes(3);
    Z=1:grid_int:dime_axes(1);
    if choice_view==1 || choice_view==2
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
        hold on
        for k=1:length(X)
            line([0.5 dime_axes(3)+1/2],[X(k) X(k)]-1/2,'Color',grid_c,'HitTest','off')
        end
        for k=1:length(Y)
            line([Y(k) Y(k)]-1/2,[0.5 dime_axes(2)+1/2],'Color',grid_c,'HitTest','off')
        end
        hold off
    end
    if choice_view==1 || choice_view==3
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
        hold on
        for k=1:length(Z)
            line([0.5 dime_axes(2)+1/2],[Z(k) Z(k)]-1/2,'Color',grid_c,'HitTest','off')
        end
        for k=1:length(X)
            line([X(k) X(k)]-1/2,[0.5 dime_axes(1)+1/2],'Color',grid_c,'HitTest','off')
        end
        hold off
    end
    if choice_view==1 || choice_view==4
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
        hold on
        for k=1:length(Z)
            line([1 dime_axes(3)+1/2],[Z(k) Z(k)]-1/2,'Color',grid_c,'HitTest','off')
        end
        for k=1:length(Y)
            line([Y(k) Y(k)]-1/2,[1 dime_axes(1)+1/2],'Color',grid_c,'HitTest','off')
        end
        hold off
    end
end


%% crusor
if get(handles.display_radiobutton_cross,'Value') == 1  %display cross
    cur_c = get(handles.pushbutton_color_cur,'BackgroundColor');
    X=1:1:dime_axes(2); %axe X vertical on Axial image
    Y=1:1:dime_axes(3);
    Z=1:1:dime_axes(1);
    
    A_pos=round(slider(1));
    S_pos=round(slider(2));
    C_pos = round(slider(3));
    
    if choice_view==1 || choice_view==2
        hold on
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_axial)
        line(dim.x.axial,[X(S_pos) X(S_pos)],'Color',cur_c,'HitTest','off')
        line([Y(C_pos) Y(C_pos)],dim.y.axial,'Color',cur_c,'HitTest','off')
        hold off
    end
    if choice_view==1 || choice_view==3
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_sagittal)
        hold on
        line(dim.x.sagittal,[Z(A_pos) Z(A_pos)],'Color',cur_c,'HitTest','off')
        line([X(S_pos) X(S_pos)],dim.y.sagittal,'Color',cur_c,'HitTest','off')
        hold off
    end
    if choice_view==1 || choice_view==4
        hold on
        set(handles.GUI_ImageOrientation,'CurrentAxes',handles.axes_coronal)
        line(dim.x.coronal,[Z(A_pos) Z(A_pos)],'Color',cur_c,'HitTest','off')
        line([Y(C_pos) Y(C_pos)],dim.y.coronal,'Color',cur_c,'HitTest','off')
        hold off
    end
    
end

disp_value=img(slider(1),slider(2),slider(3));
prec_val = floor(log10(abs(max(range))));
if prec_val>=1
    format = prec_val+2;
elseif prec_val>=0 && prec_val<1
    format=4;
elseif prec_val<0 && prec_val>-1
    format=4;
elseif prec_val<=-1;
    format=4;
end

% format=abs(prec_val)+1;

if disp_debug==1
    display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cursur value %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    if ~ischar(format)
        formattt=num2str(format);
    end
    display(['value display format: ' formattt])
    display(['prec_val: ' num2str(prec_val)])
    display(disp_value)
    display(['Range: ' num2str(range)])
end
set(handles.dims_text_curval,'String',['Value: ' num2str(disp_value,format)]);

guidata(handles.GUI_ImageOrientation,handles)