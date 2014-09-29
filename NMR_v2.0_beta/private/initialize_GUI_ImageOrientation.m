function initialize_GUI_ImageOrientation(hObject)
% clc
%% Data
handles = guidata(hObject);
mainhandles=guidata(findobj('Tag','mainmenu'));
handles.homedir=mainhandles.homedir;
disp_debug=0;

dataidx = mainhandles.dispopts.dataidx;
try
    arrayidx = mainhandles.dispopts.arrayidx;
catch exception
    arrayidx=1;
    display('l1 initialize_GUI_ImageOrientation: arrayidx');
    display(exception)
end

handles.data.arrayidx=arrayidx;
% size(mainhandles.datalist(dataidx).data.real)

%% prepare mainfig

set(handles.display_uipanel_DWI,'Visible','off');
set(handles.display_popupmenu_DWI,'Enable','off');
data_type = fieldnames(mainhandles.datalist(dataidx).data);
% rotat = mainhandles.datalist(dataidx).params.rotation;
RO_dim = mainhandles.datalist(dataidx).params.RO_dim;
PE_dim = mainhandles.datalist(dataidx).params.PE_dim;
% PE_dim = mainhandles.datalist(dataidx).params.RO_dim;
% RO_dim = mainhandles.datalist(dataidx).params.PE_dim;
orient = mainhandles.datalist(dataidx).params.orient{1}{1};
format =  mainhandles.datalist(dataidx).format;

handles.data = mainhandles.datalist(dataidx);

selidx=find(cell2mat(get(get(mainhandles.dispopts_uipanel_dataformat,'children'),'Value'))==1);
children = get(mainhandles.dispopts_uipanel_dataformat,'children');
selidx_chk = get(children,'Enable');
if strcmp(selidx_chk(selidx),'off')
    selidx_safe = find(strcmp(selidx_chk,'on'));
    selidx=selidx_safe(1);
    set(children(selidx_safe(1)),'Value',1);
end

switch selidx
    case {5,4,3,2} %real
        if disp_debug==1;
        display('real')
        end
        
        temp2.real=mainhandles.datalist(dataidx).data.real;
        temp2.imag=mainhandles.datalist(dataidx).data.imag;
        
        data=fftshift(fft(fftshift((temp2.real+1i.*temp2.imag),3),[],3),3);
        data=fftshift(fft(fftshift((data),2),[],2),2);
        clear temp2;
        
        if selidx == 5 %real
            data=real(data);%,dim1,dim2)))
            %             datastr = ['real parts of ' datasetstr ' of'];
        elseif selidx == 4 %imag
            data=imag(data);%,dim1,dim2)))
            %             datastr = ['imaginary parts of ' datasetstr ' of'];
        elseif selidx == 3 %absval
            data=abs(data);%,dim1,dim2)))
            %             datastr = ['Absolute value parts of ' datasetstr ' of'];
        elseif selidx == 2 %phase
            data=angle(data);%,dim1,dim2)))
            %             datastr = ['phase parts of ' datasetstr ' of'];
        end
        
        %         mainhandles.datalist(dataidx).params.ppe = -20;
        ppe = mainhandles.datalist(dataidx).params.ppe;
        disp(ppe)
        if mainhandles.datalist(dataidx).params.ppe ~= 0 && isempty(mainhandles.datalist(dataidx).params.ppe)==0
            shift = round(mainhandles.datalist(dataidx).params.ppe / (mainhandles.datalist(dataidx).params.lpe/mainhandles.datalist(dataidx).params.nv));
            %         if mod(orient,2) == 1
            %             shift = -shift;
            %         end
            dimToShift = PE_dim+1;%size(size(data),PE_dim+1)-1;
            shiftsize = zeros(size(size(data)));
            shiftsize(dimToShift) = shift;
            data = circshift(data,shiftsize);
            %             data = circshift(data,shiftsize);
        end
        
    case 1 %fdf
        if disp_debug==1;
            display('fdf')
        end
        temp=mainhandles.datalist(dataidx).data.fdf;
        if length(size(temp))==4 %4d data set: DTI
            DWI_idx = get(mainhandles.dispopt_popupmenu_DWI,'Value');
            data=(temp(:,:,:,:));
        else
            data=squeeze(temp(:,:,:));
        end
end

if exist('data','var')==0
    data = zeros(128,128,1);
    disp('no image data available')
end

%% close NMR toolkit
close_nmr = questdlg({'Do you want to close NMR toolkit?' '(Current work will be stored and you can retrive later)'},'Close NMR toolkit');

if ischar(close_nmr)
    if strcmp(close_nmr,'Yes')
        save_open_mainhandles('save',[handles.homedir filesep 'temp_study.mat'])
        mainhandles.switch.close='ImageOrientation';
        close_exit(mainhandles);
    end
end



try
    handles.data.data.image = double(data);
catch exception
    handles.data.data.image = single(data);
    display(exception)
    display('Out of memory, data points stored as single')
end
% handles.data.params.ns=3;
handles.data.params = mainhandles.datalist(dataidx).params;
handles.data.orientation{1}={'SS'};
handles.data.orientation{PE_dim+1} = {'PE'};
handles.data.orientation{RO_dim+1} = {'RO'};

if disp_debug==1
    disp(['Format: ' char(format)]);
    disp(['Data size: ' num2str(size(data))]);
    orientat = [handles.data.orientation{:}];
    disp(['Orientation: ' (orientat)]);   
end


%% FOV ATTENTäION a generalisé si image vient d'analyse ou autre
set(handles.dims_edit_FOV_RO,'Value',handles.data.params.lro*10);
set(handles.dims_edit_FOV_RO,'String',num2str(handles.data.params.lro*10));
set(handles.dims_edit_FOV_PE,'Value',handles.data.params.lpe*10);
set(handles.dims_edit_FOV_PE,'String',num2str(handles.data.params.lpe*10));
set(handles.dims_edit_FOV_SS,'Value',handles.data.params.thk);
set(handles.dims_edit_FOV_SS,'String',num2str(handles.data.params.thk));
%% Acqu matrix
set(handles.dims_edit_matrix_RO,'Value',handles.data.params.np/2);
set(handles.dims_edit_matrix_RO,'String',num2str(handles.data.params.np/2));
set(handles.dims_edit_matrix_PE,'Value',handles.data.params.nv);
set(handles.dims_edit_matrix_PE,'String',num2str(handles.data.params.nv));
set(handles.dims_edit_matrix_SS,'Value',handles.data.params.ns);
set(handles.dims_edit_matrix_SS,'String',num2str(handles.data.params.ns));
%% sliders

set(handles.slider_Axial,'Value',1);
set(handles.slider_Coronal,'Value',1);
set(handles.slider_Sagittal,'Value',1);


%% DWI data
if length(size(mainhandles.datalist(dataidx).data.(data_type{1})))==4
    
    if isfield(mainhandles.datalist(dataidx).params,'dro')
        bmat = zeros([length(mainhandles.datalist(dataidx).params.dpe) 3]);
        bval = [mainhandles.datalist(dataidx).params.bvalue];
        if disp_debug==1
            display('b-values: ')
            display(bval);
        end
        for k = 1:3
            switch char(handles.data.orientation{1,k})
                case 'RO'
                    bmat(:,1) = mainhandles.datalist(dataidx).params.dro;
                case 'PE'
                    bmat(:,2) = mainhandles.datalist(dataidx).params.dpe;
                case 'SS'
                    bmat(:,3) = mainhandles.datalist(dataidx).params.dsl;
            end
        end
        norm = (sqrt(sum(bmat(2,:).^2)));
        if norm~=0
            bmat = bmat./norm;
        else
            norm = round(sqrt(sum(bmat(3,:).^2)));
            bmat = bmat./norm;
        end
        if disp_debug==1
            display('bmat: ')
            display(bmat);
        end
        temp=[0 0];
        count=0;
        for k=1:length(bmat)
            for l = 1:length(bmat)
                if k~=l
                    test1 = sum(bmat(k,:).*bmat(l,:));
                    if mod(test1,1)<0.01 || mod(test1,1)>0.99
                        test1 = round(test1);
                    end
                    if test1 == 0 && isequal(bmat(k,:),[0 0 0]) && isequal(bmat(l,:),[0 0 0])
                        count=count+1;
                        temp(count,:)=[k l];
                    elseif test1 == -1 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                        count=count+1;
                        temp(count,:)=[k l];
                    elseif test1 == -2 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                        count=count+1;
                        temp(count,:)=[k l];
                    elseif test1 == -3 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                        count=count+1;
                        temp(count,:)=[k l];
                    end
                end
            end
        end
        button=[];
        if length(temp)==length(bmat) %opposite scheme apply
            button = questdlg('Do you want to average opposite directions?','Opposite shceme','Yes','No','Yes') ;
            if strcmp(button,'Yes')
                temp = unique(sort(temp,2),'rows');
                bval_tmp = zeros([1 length(temp)]);
                bmat_tmp = zeros([length(temp) 3]);
                image_tmp = zeros([size(handles.data.data.image,1) size(handles.data.data.image,2) size(handles.data.data.image,3) length(temp)]);
                temp_imag = handles.data.data.image;
                %             temp_imag=fftshift(fft(fftshift(handles.data.data.image,2),[],2),2);
                %             temp_imag=fftshift(fft(fftshift(handles.data.data.image,3),[],3),3);
                for k=1:length(temp)
                    bval_tmp(k)=(bval(temp(k,1))+bval(temp(k,2)))/2;
                    image_tmp(:,:,:,k)=(temp_imag(:,:,:,temp(k,1)).*temp_imag(:,:,:,temp(k,2))).^0.5;
                    bmat_tmp(k,:) = bmat(temp(k,1),:);
                end
                bval = bval_tmp;
                bmat = bmat_tmp.*norm;
                %             temp_k=fftshift(ifft(ifftshift(image_tmp,2),[],2),2);
                %             temp_k=fftshift(ifft(ifftshift(image_tmp,3),[],3),3);
                temp_k= image_tmp;
                handles.data.data.image = temp_k;
                clear bval_tmp bmat_tmp image_tmp
            else
                button=[];
                if size(bval,1)<size(bval,2)
                    bval=bval';
                end
                temp=(1:length(bmat))';
                
            end
        end
    end
    
    
    if isfield(mainhandles.datalist(dataidx).params,'orient')
        if isempty(cell2mat(strfind(mainhandles.datalist(dataidx).params.orient{1},'90')))
            bmat = bmat(:,[2 1 3]);
        end
    end
    handles.data.gradsheme = bmat;
    handles.data.bvalue = bval;
    handles.data.params.bvalue = bval;
    for k = 1:3
        switch char(handles.data.orientation{1,k})
            case 'RO'
                mainhandles.datalist(dataidx).params.dro = bmat(:,1);
            case 'PE'
                mainhandles.datalist(dataidx).params.dpe = bmat(:,2);
            case 'SS'
                mainhandles.datalist(dataidx).params.dsl = bmat(:,3);
        end
    end
    if disp_debug==1
        display('bmat: ')
        display(bmat)
    end
    
    if ~isempty(button)
        DWI_string = mainhandles.datalist(dataidx).DWI_string(1,temp(:,1));
        if disp_debug==1
        display('DWI_string: ')
        display(DWI_string)
        end
    else
        DWI_string = mainhandles.datalist(dataidx).DWI_string;
        if disp_debug==1
        display('DWI_string: ')
        display(DWI_string)
        end
    end
    set(handles.display_uipanel_DWI,'Visible','on');
    set(handles.display_popupmenu_DWI,'Visible','on');
    set(handles.display_popupmenu_DWI,'Enable','on');
    set(handles.display_popupmenu_DWI,'String',DWI_string);
end


%% re-orient data

guidata(hObject,handles);
ImageOrient_AdjustSliders;


switch format
    case 'Varian'
        switch orient
            case 'trans'
                if disp_debug==1;
                disp('trans')
                end
                handles.data.data.image = orientation(handles.data.data.image,'perm_CA');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('perm_CA');
                handles = guidata(hObject);
                handles.data.data.image = orientation(handles.data.data.image,'C_rot90CW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('C_rot90CW');
                handles = guidata(hObject);
            case 'trans90'
                if disp_debug==1;
                disp('trans90')
                end
%                 handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('A_rot90CCW');
%                 guidata(hObject,handles);
%                 handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('A_rot90CCW');
%                 guidata(hObject,handles);
            case 'cor'
                if disp_debug==1;
                disp('cor')
                end
                %         handles.data.data.image = orientation(handles.data.data.image,'A_rot90CW');
                %         guidata(hObject,handles);
                %         ImageOrient_AdjustSliders('A_rot90CW');
%                 handles.data.data.image = orientation(handles.data.data.image,'perm_CA');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('perm_CA');
%                 handles.data.data.image = orientation(handles.data.data.image,'C_rot90CCW');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('C_rot90CCW');
%                 handles.data.data.image = orientation(handles.data.data.image,'A_fliphoriz');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('A_fliphoriz');
            case 'cor90'
                if disp_debug==1;
                disp('cor90')
                end
                
            case 'sag'
                if disp_debug==1;
                disp('sag')
                end
                handles.data.data.image = orientation(handles.data.data.image,'perm_AS');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('perm_AS');
                handles = guidata(hObject);
                handles.data.data.image = orientation(handles.data.data.image,'S_rot90CW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('S_rot90CW');
                handles = guidata(hObject);
                
            case 'sag90'
                if disp_debug==1;
                disp('sag90')
                end
%                 handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
%                 guidata(hObject,handles);
%                 ImageOrient_AdjustSliders('A_rot90CCW');
                
            otherwise
                if disp_debug==1;
                disp('otherwise')
                end
                handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('A_rot90CCW');
                handles = guidata(hObject);
        end
    otherwise  %human
        
        switch orient
            case 'trans'
                if disp_debug==1;
                disp('trans')
                end
                handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('A_rot90CCW');
            case 'cor'
                if disp_debug==1;
                disp('cor')
                end
                handles.data.data.image = orientation(handles.data.data.image,'perm_CA');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('perm_CA');
                handles = guidata(hObject);
                handles.data.data.image = orientation(handles.data.data.image,'C_rot90CCW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('C_rot90CCW');
                handles = guidata(hObject);
                handles.data.data.image = orientation(handles.data.data.image,'A_fliphoriz');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('A_fliphoriz');
                handles = guidata(hObject);

            case 'sag'  %% a verifier
                if disp_debug==1;
                disp('sag')
                end

                handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('A_rot90CCW');
                handles = guidata(hObject);

                
            otherwise
                if disp_debug==1;
                disp('otherwise')
                end
                handles.data.data.image = orientation(handles.data.data.image,'A_rot90CCW');
                guidata(hObject,handles);
                ImageOrient_AdjustSliders('A_rot90CCW');
                handles = guidata(hObject);
                
        end
end
% guidata(hObject,handles);

%% prepare contrast panel
colormap(gray(256))

min_axis = min(min(min(min(handles.data.data.image))));
max_axis=max(max(max(max(handles.data.data.image))));
handles.clim=[min_axis max_axis];
handles.imglim=[min_axis max_axis];

set(handles.contrast_edit_min,'String',num2str(min_axis))
set(handles.contrast_slider_min,'Value',min_axis)
set(handles.contrast_slider_min,'Min',min_axis)
set(handles.contrast_slider_min,'Max',max_axis)

set(handles.contrast_edit_max,'String',num2str(max_axis))
set(handles.contrast_slider_max,'Value',max_axis)
set(handles.contrast_slider_max,'Min',get(handles.contrast_slider_min,'Value'))
set(handles.contrast_slider_max,'Max',max_axis)

set(handles.contrast_slider_contrast,'Value',0);
set(handles.contrast_slider_contrast,'Min',-10);
set(handles.contrast_slider_contrast,'Max',10);
set(handles.display_slider_Contrast,'Value',0);
set(handles.display_slider_Contrast,'Min',-10);
set(handles.display_slider_Contrast,'Max',10);


set(handles.contrast_slider_brightness,'Value',0);
set(handles.contrast_slider_brightness,'Min',-0.99);
set(handles.contrast_slider_brightness,'Max',0.99);
set(handles.display_slider_Brightness,'Value',0);
set(handles.display_slider_Brightness,'Min',-0.99);
set(handles.display_slider_Brightness,'Max',0.99);


% set(handles.Gui_ImageOrientation,'CurrentAxes',handles.axes_contrast)

% set(handles.axes_contrast,'Units','Normalized');
% % Get axis position and make room for color stripe.
% pos = get(handles.axes_contrast,'pos');
% stripe = 0.075;
% set(handles.axes_contrast,'pos',[pos(1) pos(2)+stripe*pos(4) pos(3) (1-stripe)*pos(4)])
%
% set(handles.axes_contrast,'xticklabel','')
% % xlim([min_img max_img/0.3]./max_img)
% stripe_axes = axes('Parent',get(gca,'Parent'),'Tag','axes_colorbar',...
%                 'Position', [pos(1) pos(2) pos(3) stripe*pos(4)]);
%
% handles.axes_colorbar=stripe_axes;


%% color options
set(handles.pushbutton_color_cur,'BackgroundColor',[1 0 0]);
set(handles.pushbutton_color_grid,'BackgroundColor',[0 0 1]);


guidata(hObject,handles);

if disp_debug==1
    disp(['Format: ' char(format)]);
    disp(['Data size: ' num2str(size(handles.data.data.image))]);
    orientat = [handles.data.orientation{:}];
    disp(['Orientation: ' (orientat)]);   
end

ImageOrient_display;
% size(handles.data.data.image)


