function roi_out = ROI_create(roi_in, tool,d_e,thres)


% roi_in is the input roi
% roi_out is the output roi
% is the tool name
% d_e = 1 to draw
% d_e = 0 to erase

roi_out=roi_in;

imghandles=guidata(findobj('Tag','GUI_ImageOrientation'));

img= imghandles.data.data.image;
if length(size(img))==4
    DWI_idx = get(imghandles.display_popupmenu_DWI,'Value');
    DWI_str = get(imghandles.display_popupmenu_DWI,'String');
    if ~isempty(strfind(char(DWI_str(DWI_idx)),'b_'))
        img = squeeze(imghandles.data.data.image(:,:,:,DWI_idx));
        if length(size(img))==2 %single slice
            tmp=img;
            slide_idx= find(size(imghandles.data.data.image)==1);
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
    else
        switch char(DWI_str(DWI_idx))
            case 'colormap'
                temp =imghandles.data.data.Tens.colormap;
                img=reshape(temp,[size(temp,1) size(temp,2)*size(temp,3) 3]);
                [img map_c2] =  rgb2ind(img,256);
                img=reshape(img,[size(temp,1) size(temp,2) size(temp,3)]);
            case 'GFA'
                img =imghandles.data.data.qball.(char(DWI_str(DWI_idx)));
            case 'ODF'
                q=3;
                img =squeeze(imghandles.data.data.qball.(char(DWI_str(DWI_idx)))(:,:,:,q));
            otherwise
                img =imghandles.data.data.Tens.(char(DWI_str(DWI_idx)));
        end
    end
end

img_lim = [min(min(min(img))) max(max(max(img)))];
dime=size(img);

%% img size order
slider(1) = round(get(imghandles.slider_Axial,'Value'));
slider(2) = round(get(imghandles.slider_Coronal,'Value'));
slider(3) = round(get(imghandles.slider_Sagittal,'Value'));

h_axes = get(imghandles.GUI_ImageOrientation,'CurrentAxes');
h_axes_name = get(h_axes,'Tag');
clear imghandles;


%% TOOLS


switch h_axes_name
    case 'axes_axial'
        tool_constr = [[0.4 dime(3)+0.6];[0.4 dime(2)+0.6]];
        roi_slide = roi_in(slider(1),:,:);
        img_slide = img(slider(1),:,:);
        roi_slide2 = zeros(size(roi_slide));
    case 'axes_coronal'
        tool_constr = [[0.4 dime(3)+0.6];[0.4 dime(1)+0.6]];
        roi_slide = roi_in(:,slider(2),:);
        img_slide = img(:,slider(2),:);
        roi_slide2 = zeros(size(roi_slide));
    case 'axes_sagittal'
        tool_constr = [[0.4 dime(2)+0.6];[0.4 dime(1)+0.6]];
        roi_slide = roi_in(:,:,slider(3));
        img_slide = img(:,:,slider(3));
        roi_slide2 = zeros(size(roi_slide));
end
h_imgs = get(h_axes,'Children');
h_type = get(h_imgs,'Type');
imgs_idx = find(ismember(h_type,'image')==1);
h_ghost = figure('Visible','off');
h_img = h_imgs(imgs_idx(1));

slide_apply=1;

switch tool
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paint %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Paint'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Draw %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Draw'
        h = imfreehand(h_axes);
        constr_fun = makeConstrainToRectFcn('imfreehand',tool_constr(1,:),tool_constr(2,:));
        setPositionConstraintFcn(h,constr_fun);
        pos = wait(h);
        roi_slide2 = createMask(h,h_img);
        delete(h)
        if ~isempty(thres)
            roi_slide2(img<thres(1))=0;
            roi_slide2(img>thres(2))=0;
        end
        
        roi_slide(roi_slide2==1)=d_e;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Polygone %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Polygone'
        h = impoly(h_axes);
        constr_fun = makeConstrainToRectFcn('impoly',tool_constr(1,:),tool_constr(2,:));
        setPositionConstraintFcn(h,constr_fun);
        pos = wait(h);
        roi_slide2 = createMask(h,h_img);
        delete(h)
        roi_slide(roi_slide2==1)=d_e;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Rectangle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Rectangle'
        h = imrect(h_axes);
        constr_fun = makeConstrainToRectFcn('imrect',tool_constr(1,:),tool_constr(2,:));
        setPositionConstraintFcn(h,constr_fun);
        pos = wait(h)
        roi_slide2 = createMask(h,h_img);
        delete(h)
        roi_slide(roi_slide2==1)=d_e;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Circle %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Circle'
        h = imellipse(h_axes);
        constr_fun = makeConstrainToRectFcn('imellipse',tool_constr);
        setPositionConstraintFcn(h,constr_fun);
        pos = wait(h)
        roi_slide2 = createMask(h,h_img);
        delete(h)
        roi_slide(roi_slide2==1)=d_e;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Thresholding %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'Thresholding'
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% erode %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'erode'
        button = questdlg('Do you want to apply changes to:','Apply to','Volume','Slice','Volume');
        if strcmp(button,'Volume')
            prompt = {'Enter radius:','Enter depth:'};
            dlg_title = 'Input for dilate';
            num_lines = 1;
            def = {'2','2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            
            SE = strel('ball', str2double(answer{1,1}), str2double(answer{1,2}),0);
            roi_out = imerode(roi_in,SE);
            slide_apply = 0;
        elseif strcmp(button,'Slice')
            prompt = {'Enter radius:'};
            dlg_title = 'Input for dilate';
            num_lines = 1;
            def = {'2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            SE = strel('disk', str2double(answer{1,1}), 0);
            SE = strel('disk', 2, 0);
            roi_slide = imerode(roi_slide,SE);
        else
            display('Modification not applied')
            return;
        end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EXPAND %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          
    case 'expand'
        button = questdlg('Do you want to apply changes to:','Apply to','Volume','Slice','Volume');
        
        if strcmp(button,'Volume')
            prompt = {'Enter radius:','Enter depth:'};
            dlg_title = 'Input for dilate';
            num_lines = 1;
            def = {'2','2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            
            SE = strel('ball', str2double(answer{1,1}), str2double(answer{1,2}),0);
            roi_out = imdilate(roi_in,SE);
            slide_apply = 0;
        elseif strcmp(button,'Slice')
            prompt = {'Enter radius:'};
            dlg_title = 'Input for dilate';
            num_lines = 1;
            def = {'2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            SE = strel('disk', str2double(answer{1,1}), 0);
            roi_slide = imdilate(roi_slide,SE);
            
        else
            display('Modification not applied')
            return;
        end
        slide_apply = 0;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COPY_NEXT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    case 'copy_next'
        
        switch h_axes_name
            case 'axes_axial'
                if slider(1)+1<=dime(1)
                    roi_out(slider(1)+1,:,:) = roi_in(slider(1),:,:);
                else
                    disp('Out of image dimensions')
                    return;
                end
            case 'axes_coronal'
                if slider(2)+1<=dime(2)
                    roi_out(:,slider(2)+1,:) = roi_in(:,slider(2),:);
                else
                    disp('Out of image dimensions')
                    return;
                end
            case 'axes_sagittal'
                if slider(3)+1<=dime(3)
                    roi_out(:,:,slider(3)+1) = roi_in(:,:,slider(3));
                else
                    disp('Out of image dimensions')
                    return;
                end
        end
        slide_apply = 0;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COPY_PREV %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    case 'copy_prev'   
        switch h_axes_name
            case 'axes_axial'
                if slider(1)-1>1
                    roi_out(slider(1)-1,:,:) = roi_in(slider(1),:,:);
                else
                    disp('Out of image dimensions')
                    return;
                end
            case 'axes_coronal'
                if slider(2)-1>1
                    roi_out(:,slider(2)-1,:) = roi_in(:,slider(2),:);
                else
                    disp('Out of image dimensions')
                    return;
                end
            case 'axes_sagittal'
                if slider(3)-1>1
                    roi_out(:,:,slider(3)-1) = roi_in(:,:,slider(3));
                else
                    disp('Out of image dimensions')
                    return;
                end
        end
        slide_apply = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% otherwise %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    otherwise
        display('%%%%%%%%%%%%%%%  Unknown tool %%%%%%%%%%%%%%%%%%%')
        roi_out=roi_in;
        return;
        
end

if slide_apply==1
    switch h_axes_name
        case 'axes_axial'
            roi_out(slider(1),:,:) = roi_slide;
        case 'axes_coronal'
            roi_out(:,slider(2),:) = roi_slide;
        case 'axes_sagittal'
            roi_out(:,:,slider(3)) = roi_slide;
    end
end

