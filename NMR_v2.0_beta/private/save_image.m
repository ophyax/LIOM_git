function save_image
% clc;
disp_debug = 1;
%%
handles=guidata(findobj('Tag','Save_gui'));
imagehandles=guidata(findobj('Tag','GUI_ImageOrientation'));

%%
datain = imagehandles.data.data.image;
if disp_debug ==1
    display(['size datain: ' num2str(size(datain))])
end

dim=size(imagehandles.data.data.image);
pixin=[0 0 0];
for k=1:3
    
    switch char(imagehandles.data.orientation{1,k})
        case 'RO'
            pixin(k) = 10*imagehandles.data.params.lro/dim(k);
        case 'PE'
            pixin(k) = 10*imagehandles.data.params.lpe/dim(k);
        case 'SS'
            pixin(k) = imagehandles.data.params.thk;
    end
end




%% display images
h_view = flipdim(cell2mat(get(get(imagehandles.uipanel_view,'Children'),'Value')),1);
choice_view = find(h_view==1);
perm_view = [2 3 1];
switch choice_view
    case 1 %%three axis
        orient = imagehandles.data.params.orient{1}{1};
        format =  imagehandles.data.format;
        
        if disp_debug ==1
            display(['Orientation: ' orient])
            display(['Format: ' format])
        end
        switch format
            case 'Varian'  %animal (cor and trans are inverted)
                switch orient
                    case 'trans'
                        perm_view = [1 3 2];
                        choice_view = 4;
                    case 'sag'
                        perm_view = [1 2 3];
                        choice_view = 3;
                    case 'cor'
                        perm_view = [2 3 1];
                        choice_view = 2;
                end
            otherwise % human
                switch orient
                    case 'trans'
                        perm_view = [2 3 1];
                        choice_view = 2;
                    case 'sag'
                        perm_view = [1 2 3];
                        choice_view = 3;
                    case 'cor'
                        perm_view = [1 3 2];
                        choice_view = 4;
                end
        end
    case 2
        perm_view = [2 3 1];
    case 3
        perm_view = [1 2 3];
    case 4
        perm_view = [1 3 2];
end

% pixin = permute(pixin,perm_view);

if disp_debug ==1
    display(['choice_view: ' num2str(choice_view)])
    display(['perm_view: ' num2str(perm_view)])
    display(['pixin: ' num2str(pixin)])
end


%previous rot90 and need to permute slice dimension in third position
%%
%     0 None                     (Unknown bit per voxel) % DT_NONE, DT_UNKNOWN
%     1 Binary                         (ubit1, bitpix=1) % DT_BINARY
%     2 Unsigned char         (uchar or uint8, bitpix=8) % DT_UINT8, NIFTI_TYPE_UINT8
%     4 Signed short                  (int16, bitpix=16) % DT_INT16, NIFTI_TYPE_INT16
%     8 Signed integer                (int32, bitpix=32) % DT_INT32, NIFTI_TYPE_INT32
%    16 Floating point    (single or float32, bitpix=32) % DT_FLOAT32, NIFTI_TYPE_FLOAT32
%    32 Complex, 2 float32      (Use float32, bitpix=64) % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
%    64 Double precision  (double or float64, bitpix=64) % DT_FLOAT64, NIFTI_TYPE_FLOAT64
%   128 Red-Green-Blue            (Use uint8, bitpix=24) % DT_RGB24, NIFTI_TYPE_RGB24
%   256 Signed char            (schar or int8, bitpix=8) % DT_INT8, NIFTI_TYPE_INT8
%   512 Unsigned short               (uint16, bitpix=16) % DT_UNINT16, NIFTI_TYPE_UNINT16
%   768 Unsigned integer             (uint32, bitpix=32) % DT_UNINT32, NIFTI_TYPE_UNINT32
%  1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
%  1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64
%  1536 Long double, float128  (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128
%  1792 Complex128, 2 float64  (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128
%  2048 Complex256, 2 float128 (Unsupported, bitpix=256) % DT_COMPLEX128,
%  NIFTI_TYPE_COMPLEX128

idx_str = get(handles.save_edit_idx,'String');
sep=findstr(idx_str,'/');
idx=str2num(idx_str(1:(sep(1)-1)));
tot_idx = str2num(idx_str((sep(1)+1):length(idx_str)));

cont_soft = get(handles.save_popupmenu_soft,'String');
cont_fileformat =  get(handles.save_popupmenu_fileformat,'String');
cont_bitetype =  get(handles.save_popupmenu_bitetype,'String');
cont_dim3D4D = get(handles.DT_popupmenu_3D4D,'String');

%%



for i=1:tot_idx
    soft = cont_soft(handles.options(i).soft);
    
    data = adj_orient(datain,soft,choice_view);
    
    %     disp(pixin)
    pix = adj_orient(pixin,soft,choice_view);
    
    if disp_debug ==1
        display(['size data after adj_orient: ' num2str(size(data))])
        display(['pix: ' num2str(pix)])
        display(pix)
    end
    pix = pix(perm_view);
    if disp_debug ==1
        display(['pix: '])
        display(pix)
    end
    
    %     disp(pix)
    fileformat = cont_fileformat{handles.options(i).fileformat};
    filename = handles.options(i).filename;
    outputpath = handles.options(i).outputpath;
    if ~strcmp(outputpath(length(outputpath)),filesep)
        outputpath =[outputpath filesep];
    end
    if ~isdir(outputpath)
        mkdir(outputpath);
    end
    
    bitetype = cont_bitetype(handles.options(i).bitetype);
    maxval=max(max(max(max(data))));
    minval=min(min(min(min(data))));
    switch bitetype{1}
        case 'uint8'
            bitpix = 2;
            scale = 64000/maxval;
            data=data.*scale;
            data=uint8(data);
        case 'int16'
            bitpix = 4;
            scale = 32000/maxval;
            data=data.*scale;
            data=int16(data);
        case 'int32'
            bitpix = 8;
            scale = 2147480000/maxval;
            data=data.*scale;
            data=int32(data);
        case 'float32'
            bitpix = 16;
            data=single(data);
        case 'double'
            bitpix = 64;
            data=double(data);
        otherwise
            
    end
    
    
    switch fileformat
        case {'Analyse', 'NII'}
            switch fileformat
                case 'Analyse'
                    ext = '.hdr';
                case 'NII'
                    ext = '.nii';
            end
            
            if length(dim)==4;
                DWI_str = get(handles.DTI_listbox_DWdata,'String');
                DWI = strncmp(DWI_str,'b_',2);
                if length(DWI_str)>dim(4)
                    maps = abs(DWI-1);
                    cmap = strcmp(DWI_str,'colormap');
                    gfa = strcmp(DWI_str,'GFA');
                    odf = strcmp(DWI_str,'ODF');
                    maps=maps-cmap-gfa-odf;
                else
                    maps = 0;
                    cmap = 0;
                    gfa = 0;
                    odf = 0;
                end
                
                selection = get(handles.DTI_listbox_DWdata,'Value');
                idx =(1:length(DWI_str))';
                DWI_idx = intersect(selection,idx.*DWI);
                maps_idx = intersect(selection,idx.*maps);
                cmap_idx = intersect(selection,idx.*cmap);
                gfa_idx = intersect(selection,idx.*gfa);
                odf_idx = intersect(selection,idx.*odf);
                for k=1:length(odf_idx)
                    filename_DWI = [filename '_' DWI_str{odf_idx(k)} ext];
                    temp1 = imagehandles.data.data.qball.(char(DWI_str{odf_idx(k)}));
                    temp1 = adj_orient(temp1,soft,choice_view);
                    data_DWI = (permute(squeeze(temp1),[perm_view 4]));
                    clear temp1
                    temp = make_nii(data_DWI,pix,128);
                    temp.hdr.dime.xyzt_units=2;
                    temp.hdr.dime.bitpix = 128;
                    save_nii(temp,filename_DWI);
                    clear temp
                end
                
                for k=1:length(gfa_idx)
                    filename_DWI = [filename '_' DWI_str{gfa_idx(k)} ext];
                    temp1 = imagehandles.data.data.qball.(char(DWI_str{gfa_idx(k)}));
                    temp1 = adj_orient(temp1,soft,choice_view);
                    data_DWI = (permute(squeeze(temp1),perm_view));
                    data_DWI=single(data_DWI);
                    clear temp1
                    temp = make_nii(data_DWI,pix,16);
                    temp.hdr.dime.xyzt_units=2;
                    temp.hdr.dime.bitpix = 16;
                    save_nii(temp,filename_DWI);
                    %                        save_nii_hdr(temp.hdr,filename_DWI);
                    clear temp filename_DWI data_DWI
                end
                
                for k=1:length(cmap_idx)
                    filename_DWI = [filename '_' DWI_str{cmap_idx(k)} ext];
                    temp1 = imagehandles.data.data.Tens.(char(DWI_str{cmap_idx(k)}));
                    temp1 = adj_orient(temp1,soft,choice_view);
                    data_DWI = (permute(squeeze(temp1),[perm_view 4]));
                    clear temp1
                    temp = make_nii(data_DWI,pix,128);
                    temp.hdr.dime.xyzt_units=2;
                    temp.hdr.dime.bitpix = 128;
                    save_nii(temp,filename_DWI);
                    clear temp
                end
                for k=1:length(maps_idx)
                    filename_DWI = [filename '_' DWI_str{maps_idx(k)} ext];
                    temp1 = imagehandles.data.data.Tens.(char(DWI_str{maps_idx(k)}));
                    temp1 = adj_orient(temp1,soft,choice_view);
                    data_DWI = (permute(squeeze(temp1),perm_view));
                    data_DWI=single(data_DWI);
                    clear temp1
                    temp = make_nii(data_DWI,pix,16);
                    temp.hdr.dime.xyzt_units=2;
                    temp.hdr.dime.bitpix = 16;
                    save_nii(temp,filename_DWI);
                    %                        save_nii_hdr(temp.hdr,filename_DWI);
                    clear temp filename_DWI data_DWI
                end
                
                if  handles.options(i).dim == 1 % 3D images
                    for k = 1:length(DWI_idx)
                        filename_DWI = [filename '_' DWI_str{DWI_idx(k)} ext];
                        dataout = (permute(squeeze(data(:,:,:,DWI_idx(k))),[perm_view]));
                        if disp_debug ==1
                            display(['size dataout: ' num2str(size(dataout))])
                            display(['pix: '])
                            display(pix)
                        end
                        temp = make_nii(dataout,pix,bitpix);
                        temp.hdr.dime.xyzt_units=2;
                        temp.hdr.dime.bitpix = bitpix;
                        save_nii(temp,filename_DWI);
                        %                        save_nii_hdr(temp.hdr,filename_DWI);
                        clear temp filename_DWI dataout
                    end
                    
                elseif handles.options(i).dim == 2 % 4D images
                    
                    filename_DTI = [filename '_DTI.hdr'];
                    dataout = permute(squeeze(data(:,:,:,DWI_idx)), [perm_view 4]);
                    temp = make_nii(dataout,pix,bitpix);
                    temp.hdr.dime.xyzt_units=2;
                    if disp_debug ==1
                        display(['size dataout: ' num2str(size(dataout))])
                        display(['pix: '])
                        display(pix)
                    end
                    
                    temp.hdr.dime.bitpix = bitpix;
                    save_nii(temp,filename_DTI);
                    %                         save_nii_hdr(temp.hdr,filename_DTI);
                    clear temp filename_DTI dataout
                    %                     end
                end
            else
                filename_analyse = [filename ext];
                temp = make_nii((permute(data,[perm_view])),pix);
                temp.hdr.dime.bitpix = bitpix;
                temp.hdr.dime.xyzt_units=2;
                save_nii(temp,filename_analyse);
                %                 save_nii_hdr(temp.hdr,filename_analyse);
                clear temp filename_analyse
            end
            if  ~isdir(outputpath)
                mkdir(outputpath)
            end
            if ~isequal([pwd filesep],outputpath)
                movefile([filename '*'],outputpath,'f');
            end
            
        case 'NRRD'
            if length(dim)~=4;
                disp('No diffusion data fileformat inapropriate');
                return;
            end
            
            cd(outputpath)
            
            %% nrrd header
            fid = fopen([filename '.nhdr'],'w');
            fprintf(fid,'NRRD0005\n');
            fprintf(fid,'type: short\n');
            fprintf(fid,'dimension: 4\n');
            fprintf(fid,'sizes: %s %s %s %s\n',num2str(size(data,1)),num2str(size(data,2)),num2str(size(data,3)),num2str(size(data,4)));
            fprintf(fid,'kinds: space space space list\n');
            fprintf(fid,'centers: cell cell cell none\n');
            
            fprintf(fid,'space: left-posterior-superior\n');
            
            fprintf(fid,'space units: "mm" "mm" "mm"\n');
            fprintf(fid,'space origin: (-119.169,-119.169,71.4)\n');
            fprintf(fid,'space directions: (%f,0,0) (0,%f,0) (0,0,%f) none\n',pix(1),pix(2),pix(3));
            fprintf(fid,'encoding: raw\n');
            fprintf(fid,'endian: little\n');
            fprintf(fid,'byteskip: -1\n');
            fprintf(fid,'data file: RAW_%s/%s_%s.raw 1 %s 1 2\n',filename,filename,'%06d',num2str(size(data,3)*size(data,4)));
            
            fprintf(fid,'measurement frame: (1,0,0) (0,1,0) (0,0,1)\n');
            
            fprintf(fid,'modality:=DWMRI\n');
            fprintf(fid,'DWMRI_b-value:=%s\n',mean(imagehandles.data.params.bvalue(2:length(imagehandles.data.params.bvalue))));
            for k = 1:size(imagehandles.data.params.dro)/2
                fprintf(fid,'DWMRI_gradient_%04d:=  %0.6f %0.6f %0.6f\n',k-1,(imagehandles.data.params.dro(k)),(imagehandles.data.params.dpe(k)),(imagehandles.data.params.dsl(k)));
            end
            fclose(fid);
            
            %% creat RAW image files
            mkdir([outputpath 'RAW_' filename filesep])
            cd([outputpath 'RAW_' filename filesep])
            index=0;
            for i = 1:size(data,4)
                for j = 1:size(data,3)
                    index=index+1;
                    if index<10
                        fid2=fopen([filename '_00000' num2str(index) '.raw'],'w');
                    elseif index>9 && index<100
                        fid2=fopen([filename '_0000' num2str(index) '.raw'],'w');
                    elseif index>99 && index<1000
                        fid2=fopen([filename '_000' num2str(index) '.raw'],'w');
                    elseif index>999 && index<10000
                        fid2=fopen([filename '_00' num2str(index) '.raw'],'w');
                    elseif index>9999 && index<100000
                        fid2=fopen([filename '_0' num2str(index) '.raw'],'w');
                    elseif index>99999 && index<1000000
                        fid2=fopen([filename '_' num2str(index) '.raw'],'w');
                    end
                    fwrite(fid,squeeze(data(:,:,j,i)),'int16');
                    fclose(fid);
                    clear fid2;
                end
            end
            
            
            %% EXAMPLE
            % NRRD0005
            % type: short
            % dimension: 4
            % sizes: 144 144 85 59
            % kinds: space space space list
            % centers: cell cell cell none
            % space: left-posterior-superior
            % space units: "mm" "mm" "mm"
            % space origin: (-119.169,-119.169,71.4)
            % space directions: (1.6667,0,0) (0,1.6667,0) (0,0,-1.7) none
            % encoding: gzip
            % endian: little
            % byteskip: -1
            % data file: 000004.SER/00%04d.IMA.gz 1 5015 1 2
            % measurement frame: (-1,0,0) (0,-1,0) (0,0,1)
            % modality:=DWMRI
            % DWMRI_b-value:=900
            % DWMRI_gradient_0000:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0001:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0002:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0003:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0004:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0005:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0006:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0007:=  0.000000  0.000000  0.000000
            % DWMRI_gradient_0008:=  1.000000  0.000000  0.000000
            % DWMRI_gradient_0009:=  0.164000  0.987000  0.000000
            % DWMRI_gradient_0010:= -0.208000  0.608000  0.766000
            % DWMRI_gradient_0011:=  0.900000 -0.329000  0.287000
            % DWMRI_gradient_0012:= -0.182000 -0.808000  0.560000
            % DWMRI_gradient_0013:= -0.902000  0.030000  0.430000
            % DWMRI_gradient_0014:=  0.587000  0.412000  0.697000
            % DWMRI_gradient_0015:= -0.565000  0.823000 -0.063000
            % DWMRI_gradient_0016:=  0.762000  0.120000  0.637000
            % DWMRI_gradient_0017:= -0.607000 -0.660000 -0.443000
            % DWMRI_gradient_0018:=  0.032000 -0.962000 -0.273000
            % DWMRI_gradient_0019:=  0.376000 -0.761000 -0.529000
            % DWMRI_gradient_0020:= -0.746000 -0.367000  0.556000
            % DWMRI_gradient_0021:= -0.361000  0.902000  0.237000
            
        case 'Matlab'
            cd(outputpath);
            mkdir('Matlab');
            cd('Matlab');
            filename = [filename '.mat'];
            image=datain;
            pix=pixin;
            params=imagehandles.data.params;
            save filename image params pix;
            if isfield(imagehandles.data.data,'Tens')
                Tens = imagehandles.data.data.Tens;
                save -append filename Tens
            end
            if isfield(imagehandles.data.data,'qball')
                Qball = imagehandles.data.data.qball;
                save -append filename Qball
            end
        otherwise
    end
end

function orient_data = adj_orient(data,soft,choice_view)
% size(data)
% soft{1}
switch choice_view
    case 2
        %Axial
        ax = 'A_rot90CW';
        if size(data,1)==1 && size(data,2)==3  %pix
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data([1 3 2]);
                case {'ImageJ'}
                    orient_data=data([1 3 2]);
                case {'MedINRIA'}
                    orient_data=data([1 3 2]);
                case {'MRIcro'}
                    orient_data=data([1 3 2]);
                case {'Slicer'}
                    orient_data=data([1 3 2]);
                case {'DTIStudio'}
                    orient_data=data([1 3 2]);
            end
        else %image
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data;
                case {'ImageJ'}
                    display(size(data))
                    orient_data=orientation(data,ax);
                    display(size(orient_data))
                case {'MedINRIA'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'MRIcro'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'Slicer'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'DTIStudio'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
            end
        end
    case 3
        %Sagital
        ax = 'S_rot90CCW';
        if size(data,1)==1 && size(data,2)==3  %pix
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data([2 3 1]);
                case {'ImageJ'}
                    orient_data=data([2 1 3]);
                case {'MedINRIA'}
                    orient_data=data([2 1 3]);
                case {'MRIcro'}
                    orient_data=data([2 1 3]);
                case {'Slicer'}
                    orient_data=data([2 1 3]);
                case {'DTIStudio'}
                    orient_data=data([2 1 3]);
            end
        else %image
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data;
                case {'ImageJ'}
                    display(size(data))
                    orient_data=orientation(data,ax);
                    display(size(orient_data))
                case {'MedINRIA'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'MRIcro'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'Slicer'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'DTIStudio'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
            end
        end
    case 4
        %Coronal
        ax = 'C_rot90CW';
        if size(data,1)==1 && size(data,2)==3  %pix
            
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data([2 3 1]);
                case {'ImageJ'}
                    orient_data=data([3 2 1]);
                    %               orient_data=data;
                case {'MedINRIA'}
                    orient_data=data([3 2 1]);
                case {'MRIcro'}
                    orient_data=data([3 2 1]);
                case {'Slicer'}
                    orient_data=data([3 2 1]);
                case {'DTIStudio'}
                    orient_data=data([3 2 1]);
            end
        else %image
            switch soft{1}
                case {'Default', 'Matlab'}
                    orient_data=data;
                case {'ImageJ'}
                    display(size(data))
                    orient_data=orientation(data,ax);
                    display(size(orient_data))
                case {'MedINRIA'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'MRIcro'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'Slicer'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
                case {'DTIStudio'}
                    orient_data=orientation(data,[ax '_rot90CW']);
                    orient_data=orientation(orient_data,[ax '_flipvert']);
            end
        end
end

