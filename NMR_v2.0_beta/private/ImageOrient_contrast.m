function ImageOrient_contrast(varargin)

disp_debug = 0;

handles=guidata(findobj('Tag','GUI_ImageOrientation'));
% set(setxor(get(handles.uipanel_contrast,'Children'),[handles.axes_contrast handles.axes_colorbar]),'Enable','on');

if nargin>0
    if isnumeric(varargin{1})
        img=varargin{1};
        min_img = double(min(min(min(min(img)))));
        max_img = double(max(max(max(max(img)))));
%         handles.imglim(1)=min_img;
%         handles.imglim(2)=max_img;
    end
else
    img = handles.data.data.image;
    min_img = double(min(min(min(min(img)))));
    max_img = double(max(max(max(max(img)))));
%     handles.imglim(1)=min_img;
%     handles.imglim(2)=max_img;
end



min_axis = handles.clim(1);
max_axis =  handles.clim(2);
delta_axis=(max_axis-min_axis);



delta_img=(max_img-min_img);

cont=(delta_axis/delta_img);
br = ((max_axis+min_axis)/2-(max_img+min_img)/2)/delta_img;

%% set slider et edit box values
if min_axis<min_img
    set(handles.contrast_slider_min,'Min',min_axis);
    set(handles.contrast_slider_min,'Max',max_axis);
end
if max_axis>max_img
    set(handles.contrast_slider_max,'Max',max_axis);
    set(handles.contrast_slider_max,'Min',min_axis);
end

set(handles.contrast_slider_min,'Value',min_axis);
set(handles.contrast_slider_max,'Value',max_axis);
set(handles.contrast_edit_min,'String',num2str(min_axis));
set(handles.contrast_edit_max,'String',num2str(max_axis));
if cont>1
    set(handles.contrast_slider_contrast,'Value',cont-1);
    set(handles.display_slider_Contrast,'Value',cont-1);
else
    set(handles.contrast_slider_contrast,'Value',-1/cont+1);
    set(handles.display_slider_Contrast,'Value',-1/cont+1);
end

set(handles.contrast_slider_brightness,'Value',br);

set(handles.display_slider_Brightness,'Value',br);

if disp_debug==1
   display(['Contrast: ' num2str(cont)]); 
   display(['Brightness: ' num2str(br)]); 
   display(['Clim: ' num2str(handles.clim)]); 
   display(['Image lim: ' num2str(handles.imglim)]); 
end


h_view = flipdim(cell2mat(get(get(handles.uipanel_view,'Children'),'Value')),1);
choice_view = find(h_view==1);

if choice_view==1


if length(size(img))==4
    img=reshape(img,[size(img,1)*size(img,3) size(img,2)*size(img,4)]);
elseif length(size(img))==3
    img=reshape(img,[size(img,1)*size(img,3) size(img,2)]);
elseif length(size(img))==2
end

[counts,x] =imhist((img-min_img)./delta_img);
map=x';
x=(x.*delta_img)+min_img;

axes(handles.axes_contrast)
plot(handles.axes_contrast,x,counts)
if get(handles.contrast_radiobutton_zoom,'Value')
    if delta_img<delta_axis
        xlim([min_img max_img])
    end 
else
    xlim([min_axis max_axis])
end
ylim([0 1.1*max(counts)])
set(gca,'xticklabel','')
if get(handles.contrast_radiobutton_ylog,'Value')
set(gca,'Yscale','log')
end

set(handles.axes_colorbar,'Visible','on')

lm = length(x);
lmap=lm*cont;


delta_map = round(lmap-lm)/2;
shift_map = round(lm*br);

if get(handles.contrast_radiobutton_zoom,'Value') %% not implemented yet
    if delta_map>=0 %sclae longer than image
        map=0:lmap-1;
        map=map+shift_map;
        map=map+shift_map;
    else % scale shorter than image
        map=0:lm-1;
        lmap=lm;  
    end
    x_map=((0:lmap-1)./lmap).*delta_axis+min_axis;
    axes(handles.axes_colorbar)
    imagesc(map)
    x_tick = get(gca,'XTick');
    x_tick_label = x_map(x_tick);
    set(gca,'XTickLabel',x_tick_label)  
    set(gca,'Yticklabel','')
else
    if delta_map>=0 %sclae longer than image
        map=0:lmap-1;
        map=map+shift_map;
        map=map+shift_map;
    else % scale shorter than image
        map=0:lm-1;
        lmap=lm;  
    end
    x_map=((0:lmap-1)./lmap).*delta_axis+min_axis;
    axes(handles.axes_colorbar)
    imagesc(map)
    x_tick = get(gca,'XTick');
    x_tick_label = x_map(x_tick);
    set(gca,'XTickLabel',x_tick_label)
    set(gca,'Yticklabel','')
end
end
guidata(findobj('Tag','GUI_ImageOrientation'),handles);


