function load_data(called)
tic
global petable

mainhandles=guidata(findobj('Tag','mainmenu'));

switch called
    case 'displaycontrol'
%         disp('displaycontrol')
        dataidx(1) = mainhandles.dispopts.dataidx;
%         arrayidx(1) = mainhandles.dispopts.arrayidx;
    case 'filelistfig'
%         disp('filelistfig')
        filelisthandles = guidata(findobj('Tag','filelistfig'));
        dataidx = get(filelisthandles.filelistfig_listbox,'Value');  
end

h_wait = waitbar(0,'Please wait, while loading data points,...');

for i=1:length(dataidx)
    
    dataformat = mainhandles.datalist(dataidx(i)).format;
    datatype = mainhandles.datalist(dataidx(i)).type;
    
    if isfield(mainhandles.datalist(dataidx(i)),'petable')
        petable = mainhandles.datalist(dataidx(i)).petable;
    else
        petable=0;
    end
    if isfield(mainhandles.datalist(dataidx(i)),'data')
        mainhandles.datalist(dataidx(i)).data = [];%=rmfield(mainhandles.datalist(dataidx(i)),'data');
    end
     if isfield(mainhandles.datalist(dataidx(i)),'params')
         if strcmp(dataformat,'Varian')==1
             mainhandles.datalist(dataidx(i)).params=rtp_varian(mainhandles.datalist(dataidx(i)).path);%rmfield(mainhandles.datalist(dataidx(i)),'params');
         else
%              mainhandles.datalist(dataidx(i)).params=[];
         end
     end
    switch dataformat
        case 'Varian'
            [data params]=read_varian(mainhandles.datalist(dataidx(i)).path,mainhandles.datalist(dataidx(i)).filename,mainhandles.datalist(dataidx(i)).params);
            mainhandles.datalist(dataidx(i)).data = data.data;
%             params.rotation = 0;
            mainhandles.datalist(dataidx(i)).params = params;
            if strcmp(datatype,'fdf')||(strcmp(datatype,'fid')&& strcmp(mainhandles.datalist(dataidx(i)).acqtype,'MRI')&&isfield(mainhandles.datalist(dataidx(i)),'fdf'))
                if isempty(mainhandles.datalist(dataidx(i)).fdf)~=1
                    mainhandles.datalist(dataidx(i)).data.fdf=[];
%                     mainhandles.datalist(dataidx(i)).data = rmfield(mainhandles.datalist(dataidx(i)).data,'fdf');
                    fdf_path = strrep(mainhandles.datalist(dataidx(i)).path,'.fid','.img');
                    filename = dir([fdf_path filesep '*.fdf']);
                    for k =1:length(filename)
                        data=read_varian(fdf_path,filename(k).name,mainhandles.datalist(dataidx(i)).params);
                        mainhandles.datalist(dataidx(i)).data.fdf(k,:,:) = data.data.fdf;
                        waitbar((i-1+k/length(filename))/length(dataidx))
                    end
                    
                    mainhandles.datalist(dataidx(i)).multiplicity = length(filename);
                    mainhandles.datalist(dataidx(i)).orient = 0;
                                mainhandles.datalist(dataidx(i)).loaded=1;
            mainhandles.datalist(dataidx(i)).params.rotation = 1;
            mainhandles.datalist(dataidx(i)).params.RO_dim = 2;
            mainhandles.datalist(dataidx(i)).params.PE_dim = 1;
                else
                    disp('47 LOAD_DATA: no fdf file available')
                end
            end 
            try,
                if length(size(data.data.real))==4
                    for k=1:size(data.data.real,4)
                    diff_str{k}=['b_' num2str(k-1)]; 
                end
                set(mainhandles.dispopt_popupmenu_DWI,'String',diff_str);
                mainhandles.datalist(dataidx(i)).DWI_string=diff_str;
                end
            catch,
%                 'load_data mainhandles.datalist(dataidx(i)).DWI_string'
            end
            try,
                if length(size(data.data.fdf))==4
                    for k=1:size(data.data.fdf,4)
                    diff_str{k}=['b_' num2str(k-1)]; 
                end
                set(mainhandles.dispopt_popupmenu_DWI,'String',diff_str);
                mainhandles.datalist(dataidx(i)).DWI_string=diff_str;
                end
            catch,
%                 'load_data mainhandles.datalist(dataidx(i)).DWI_string'
            end

            mainhandles.datalist(dataidx(i)).loaded=1;
        case 'Siemens'
            mainhandles.datalist(dataidx(i)).data = read_siemens(mainhandles.datalist(dataidx(i)).liststring);
            mainhandles.datalist(dataidx(i)).loaded=1;
%             disp('PARAMS')
%             mainhandles.datalist(dataidx(i)).params
        case 'Brucker'
        case 'Philips'
        case {'Analyse' 'NIFTI'}
            data = load_nii(mainhandles.datalist(dataidx(i)).liststring);
            
            if length(size(data.img))==3
                data.img=permute(data.img,[3 1 2]);
                mainhandles.datalist(dataidx(i)).data.fdf(:,:,:) = data.img;
            elseif length(size(data.img))==4
                data.img=permute(data.img,[3 1 2 4]);
                mainhandles.datalist(dataidx(i)).data.fdf = data.img;
%                 mainhandles.datalist(dataidx(i)).data.diff = (data.img(:,:,:,:));
                for k=1:size(data.img,4)
                    diff_str{k}=['b_' num2str(k-1)]; 
                end
                set(mainhandles.dispopt_popupmenu_DWI,'String',diff_str);
                mainhandles.datalist(dataidx(i)).DWI_string=diff_str;
            end
            mainhandles.datalist(dataidx(i)).loaded=1;
            mainhandles.datalist(dataidx(i)).params.rotation = 1;
            mainhandles.datalist(dataidx(i)).params.RO_dim = 2;
            mainhandles.datalist(dataidx(i)).params.PE_dim = 1;
        case 'Nrrd'
        case 'DICOM'
%             data = dicomread(mainhandles.datalist(dataidx(i)).liststring);
            params= mainhandles.datalist(dataidx(i)).params;
            [path name ext] = fileparts(mainhandles.datalist(dataidx(i)).liststring);
            filename=dir([path filesep '*.dcm']);
               dro=[];
               dpe=[];
               dsl=[];
               bval=[];
             for k =1:length(filename)
                 data = dicomread([path filesep filename(k).name]);
                 hdr = dicominfo([path filesep filename(k).name]);
                 if isfield(params,'mosaique')
                    ns =  params.mosaique.row*params.mosaique.col;
                    data=reshape(data,[params.np/2 params.mosaique.row params.nv params.mosaique.col]);
                    data=permute(data,[4,2,3,1]); 
                    data=reshape(data,[ns params.nv params.np/2]);
                    mainhandles.datalist(dataidx(i)).data.fdf(:,:,:,k) = data;
%                     k
                    params.ns = hdr.Private_0019_100a;
                    if isfield(hdr,'Private_0019_100c')
                        bval =[bval hdr.Private_0019_100c];
                        if isfield(hdr,'Private_0019_100e')
                            g_dir = hdr.Private_0019_100e;
                            im_dir = hdr.ImageOrientationPatient;
                            m_rot=[im_dir(1:3) im_dir(4:6) cross(im_dir(1:3),im_dir(4:6))];
%                             m_rot=m_rot;
                            
                            g_dir = m_rot*g_dir;
                            dro=[dro g_dir(2)];
                            dpe=[dpe g_dir(1)];
                            dsl=[dsl g_dir(3)];  
                        elseif hdr.Private_0019_100c==0;
                        dro=[dro 0];
                        dpe=[dpe 0];
                        dsl=[dsl 0];
                        end
%                         save('grad_dir.mat','m_rot','dro','dpe','dsl')
                    else
                        bval =[];
                        dro=[];
                        dpe=[];
                        dsl=[];
                    end

                 else
                     mainhandles.datalist(dataidx(i)).data.fdf(k,:,:) = flipdim(data',1);
                 end  
                 waitbar((i-1+k/length(filename))/length(dataidx))
             end
             
            mainhandles.datalist(dataidx(i)).params.ns = size(mainhandles.datalist(dataidx(i)).data.fdf,1);
                mainhandles.datalist(dataidx(i)).multiplicity = size(mainhandles.datalist(dataidx(i)).data.fdf,1);
            if length(size(mainhandles.datalist(dataidx(i)).data.fdf))==4              
                for k=1:size(mainhandles.datalist(dataidx(i)).data.fdf,4)
                    diff_str{k}=['b_' num2str(k-1)]; 
                end
                mainhandles.datalist(dataidx(i)).params.bvalue = bval;
                mainhandles.datalist(dataidx(i)).params.dro = dro;
                mainhandles.datalist(dataidx(i)).params.dpe = dpe;
                mainhandles.datalist(dataidx(i)).params.dsl = dsl;
                set(mainhandles.dispopt_popupmenu_DWI,'String',diff_str);
                mainhandles.datalist(dataidx(i)).DWI_string=diff_str;
            end
            mainhandles.datalist(dataidx(i)).loaded=1;
            mainhandles.datalist(dataidx(i)).params.rotation = 1;
            mainhandles.datalist(dataidx(i)).params.RO_dim = 1;
            mainhandles.datalist(dataidx(i)).params.PE_dim = 2;
        case 'Matlab'

                study = load(mainhandles.datalist(dataidx(i)).liststring);
                mainhandles.datalist(dataidx(i)).params = study.study.params;
                mainhandles.datalist(dataidx(i)).data = study.study.data;
                mainhandles.datalist(dataidx(i)).nucleus = study.study.nucleus;
                mainhandles.datalist(dataidx(i)).resfreq = study.study.resfreq;
                mainhandles.datalist(dataidx(i)).ppm_ref = study.study.ppm_ref;
                mainhandles.datalist(dataidx(i)).acq_time = study.study.acq_time;
                mainhandles.datalist(dataidx(i)).spectralwidth = study.study.spectralwidth;
                mainhandles.datalist(dataidx(i)).acqtype = study.study.acqtype;
                mainhandles.datalist(dataidx(i)).multiplicity = study.study.multiplicity;
                mainhandles.datalist(dataidx(i)).process = study.study.process;
                mainhandles.datalist(dataidx(i)).loaded = 1;
                mainhandles.datalist(dataidx(i)).time = study.study.time;
                mainhandles.datalist(dataidx(i)).np = study.study.np;
%                 disp(mainhandles.datalist(dataidx).acqtype)
                disp('Matlab')
                disp(char(mainhandles.datalist(dataidx(i)).filename))
        case 'Raw'
            
           filename = [mainhandles.datalist(dataidx(i)).path filesep mainhandles.datalist(dataidx(i)).filename];
           fid = fopen(filename);
           endfile=1;
           while endfile>0
               l = fgetl(fid);
               if ~isempty(strfind(l,'FMTDAT'));
                   sep = findstr(l,'''');
                   format = l(sep(1)+2:sep(2)-2);
                   num_col = str2double(format(1));
               end
               if ~isempty(strfind(l,'$END')) %end of header;
                   [A, count]  = fscanf(fid,'%f',[num_col, inf]);
                   endfile = -1;
               end
               if l==-1
                   endfile = -1;
                   break;
               end
               
           end
           fclose(fid)
           
           R = reshape(A(1:2:num_col,:),[1 size(A,2)*num_col/2]);
           I = reshape(A(2:2:num_col,:),[1 size(A,2)*num_col/2]);
           mainhandles.datalist(dataidx(i)).data.real(1,1,:) = R';
           mainhandles.datalist(dataidx(i)).data.imag(1,1,:) = I';
           mainhandles.datalist(dataidx(i)).params.np = 2*size(R,2);
           mainhandles.datalist(dataidx(i)).params.at = size(R,2).*mainhandles.datalist(dataidx(i)).params.dw;
           
           mainhandles.datalist(dataidx(i)).acq_time = mainhandles.datalist(dataidx(i)).params.at;
           mainhandles.datalist(i).np = 2*size(R,2);
           
            disp('Raw')
            disp(char(mainhandles.datalist(dataidx(i)).filename))
        otherwise
            disp('format unknown')
            return
    end
    
    %% prepare handles in function of the acq type %%
    
    switch datatype
        case 'MRS'
            multplicity = mainhandles.datalist(dataidx(i)).multiplicity;
            if ~isfield(mainhandles.datalist(dataidx(i)).process,'apodparam1')
                mainhandles.datalist(dataidx(i)).process.apodizefct = 'exponential';
                mainhandles.datalist(dataidx(i)).process.apodparam1(1:multplicity) = 0; % Hz = LB = first Parameter of apodzing function
                mainhandles.datalist(dataidx(i)).process.apodparam2(1:multplicity) = 0; % Hz = second Parameter of apodzing function
            end

            if ~isfield(mainhandles.datalist(dataidx(i)).process,'lsfid')
                mainhandles.datalist(dataidx(i)).process.lsfid = 0;
            end
            if ~isfield(mainhandles.datalist(dataidx(i)).process,'transfsize')
                mainhandles.datalist(dataidx(i)).process.transfsize = 0;
            end
            if ~isfield(mainhandles.datalist(dataidx(i)).process,'appltoarray1')
                mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1 = 1;

            end
            if ~isfield(mainhandles.datalist(dataidx(i)).process,'appltoarray2')
                mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2 = 1;

            end
            if ~isfield(mainhandles.datalist(dataidx(i)).process,'phasecorr1')
                mainhandles.datalist(dataidx(i)).process.phasecorr0(1:multplicity) = 0;
                mainhandles.datalist(dataidx(i)).process.phasecorr1(1:multplicity) = 0;
            end      
        case 'MRI'
        case 'CSI'
    end
    
    
    
    waitbar(i/length(dataidx))
    guidata(findobj('Tag','mainmenu'),mainhandles);
end
close(h_wait);

disp('Finish to load data')
toc