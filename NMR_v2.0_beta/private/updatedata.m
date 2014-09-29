function updatedata(varargin)
tic
global data_idx petable % needed for read_varian
disp_debug = 1;
mainhandles = guidata(findobj('Tag','mainmenu'));
if ~isfield(mainhandles,'datalist')
    return
end
if isempty(mainhandles.datalist)
    return
end

%varargin optional input to update one data or a range of datalist
%if empty update all the data in the datalist
if nargin
    if length(varargin)==1
        start_loop=round(varargin{1});
        end_loop = round(varargin{1});
    else
        start_loop=round(varargin{1});
        end_loop = round(varargin{2});
    end
else
    start_loop=1;
    end_loop = length(mainhandles.datalist);
end

% read and sort data as in the listbox of the GUI_filelist



h_wait = waitbar(0,'Please wait, while updating data set');

%% reading data and parameter files
readswitch=0;
err_data_idx= 0;
% % outputstr=cell(length(mainhandles.datalist)+1,13);
% % outputstr{1,1}='apptype';
% % outputstr{1,2}='seqfil';
% % outputstr{1,3}='arelemts';
% % outputstr{1,4}='acqdim';
% % outputstr{1,5}='acqcyc';
% % outputstr{1,6}='ardim';
% % outputstr{1,7}='celem'; % # of completed FID elements
% % outputstr{1,8}='#slices'; % # of slices
% % outputstr{1,9}='nt'; % # of transient
% % outputstr{1,10}='#RO'; % # of Readouts
% % outputstr{1,11}='#PE'; % # of phase-encoding steps
% % outputstr{1,12}='#FID';
% % outputstr{1,13}='datsz';
% % fprintf(txtfid,'%10s |\t %12s |\t %8s |\t %6s |\t %5s |\t %5s |\t %5s |\t %6s |\t %2s |\t %6s |\t %3s |\t %4s |\t %7s \n',outputstr{1,:});

for i=start_loop:end_loop
    
    if isfield(mainhandles.datalist(i),'data') && isempty(mainhandles.datalist(i).data)==0
        datafieldnames = fieldnames(mainhandles.datalist(i).data);
        for k=1:length(datafieldnames) % if data already read, i.e. "isnumeric", skip reading
            readswitch = readswitch+isnumeric(mainhandles.datalist(i).data.(datafieldnames{k}));
        end
        readswitch=readswitch/length(datafieldnames);
    end
    if nargin
        readswitch = 0;
    end
    
    if readswitch==0
        try
            
            data_idx = i;
            disp(mainhandles.datalist(i).format)
            switch mainhandles.datalist(i).format
                case 'Varian'
                    mainhandles.datalist(i).params = rtp_varian(mainhandles.datalist(i).path,0); % argues=filename,printflag
                    mainhandles.datalist(i).acq_time = mainhandles.datalist(i).params.at;
                    mainhandles.datalist(i).spectralwidth = mainhandles.datalist(i).params.sw;
                    mainhandles.datalist(i).np = mainhandles.datalist(i).params.np;
                    mainhandles.datalist(i).sequence = mainhandles.datalist(i).params.seqfil{:};
                    mainhandles.datalist(i).pslabel = mainhandles.datalist(i).params.pslabel{:};
                    try
                        mainhandles.datalist(i).time = datestr(datenum(mainhandles.datalist(i).params.time_run{:},'yyyymmddTHHMMSS'));
                    catch
                        temp=char(mainhandles.datalist(i).params.time_run{:});
                        if size(temp,2)<15
                            temp2 = '00000000T000000';
                            temp2(1:size(temp,2))=temp;
                            mainhandles.datalist(i).time =datestr(datenum(temp2,'yyyymmddTHHMMSS'));
                        end
                    end
                    mainhandles.datalist(i).nucleus = mainhandles.datalist(i).params.tn{:};
                    mainhandles.datalist(i).resfreq = mainhandles.datalist(i).params.sfrq;
                    mainhandles.datalist(i).ppm_ref = 0; % initializes referenz for ppm scale
                    if isfield(mainhandles.datalist(i).params,'lsfid')==1
                        
                        mainhandles.datalist(i).process.lsfid = mainhandles.datalist(i).params.lsfid+1;
                        mainhandles.process.lsfid = mainhandles.datalist(i).params.lsfid+1;
                        %                         disp('updatedata: process.lsfid')
                        %                         disp(mainhandles.datalist(i).process.lsfid)
                    end
                    if isfield(mainhandles.datalist(i).params,'petable')==1 && ...
                            isempty(char(mainhandles.datalist(i).params.petable{1}))==0 && ...
                            strcmpi(char(mainhandles.datalist(i).params.petable{1}),'n')==0
                        if exist('tablefile','var')
                            [fpathstr, fname, fext]=fileparts(tablefile);
%                             clear fpathstr fext fversn
                        end
                        if  exist('fname','var') && ...
                                strcmpi(fname,char(mainhandles.datalist(i).params.petable{1}))==1
                            tablefile=read_petable(mainhandles.homedir,tablefile);
                        else
                            tablefile=read_petable(mainhandles.homedir,char(mainhandles.datalist(i).params.petable{1}));
                        end
                    else
                        petable=0;
                    end
                    mainhandles.datalist(i).petable = petable;
                    guidata(findobj('Tag','mainmenu'),mainhandles);
                    readdata = read_header_varian(mainhandles.datalist(i).path,mainhandles.datalist(i).filename,mainhandles.datalist(i).params);
                    mainhandles.datalist(i).header = readdata.header;
                    %                 mainhandles.datalist(i).data = readdata.data;
                    if ~isfield(mainhandles.datalist(i),'loaded')
                        mainhandles.datalist(i).loaded = 0;
                    end
                    mainhandles.datalist(i).apptype = readdata.apptype;
                    mainhandles.datalist(i).acqtype = readdata.acqtype;
                    mainhandles.datalist(i).multiplicity = readdata.multiplicity;
                    guidata(findobj('Tag','mainmenu'),mainhandles);
                    
                    % --- write format parameters to text file ----------------
                    % %                 datsz=zeros(1,3);
                    % %                 if isfield(mainhandles.datalist(i).data,'real')
                    % %                     datasz = size(mainhandles.datalist(i).data.real);
                    % %                 else
                    % %                     datasz = size(mainhandles.datalist(i).data.absval);
                    % %                 end
                    % %                 datsz(1:length(datasz))=datasz;
                    % %                 outputstr{i+1,1}=char(mainhandles.datalist(i).params.apptype{1});
                    % %                 outputstr{i+1,2}=char(mainhandles.datalist(i).params.seqfil{1});
                    % %                 outputstr{i+1,3}=num2str(mainhandles.datalist(i).params.arrayelemts);
                    % %                 outputstr{i+1,4}=num2str(mainhandles.datalist(i).params.acqdim);
                    % %                 outputstr{i+1,5}=num2str(mainhandles.datalist(i).params.acqcycles);
                    % %                 outputstr{i+1,6}=num2str(mainhandles.datalist(i).params.arraydim);
                    % %                 outputstr{i+1,7}=num2str(mainhandles.datalist(i).params.celem); % # of completed FID elements
                    % %                 outputstr{i+1,8}=num2str(mainhandles.datalist(i).params.ns); % # of slices
                    % %                 outputstr{i+1,9}=num2str(mainhandles.datalist(i).params.nt); % # of transients
                    % %                 if mainhandles.datalist(i).params.nt>1e-6
                    % %                     outputstr{i+1,9}=num2str(64);
                    % %                 end
                    % %                 outputstr{i+1,10}=num2str(mainhandles.datalist(i).params.np); % # of readouts=# complex points
                    % %                 if isfield(mainhandles.datalist(i).params,'nv')
                    % %                     outputstr{i+1,11}=num2str(mainhandles.datalist(i).params.nv); % # of phase-encoding steps
                    % %                 else
                    % %                     outputstr{i+1,11}=num2str(0); % # of phase-encoding steps
                    % %                 end
                    % %                 if isfield(mainhandles.datalist(i).params,'nf')
                    % %                     outputstr{i+1,12}=num2str(mainhandles.datalist(i).params.nf); % # of FIDs
                    % %                 else
                    % %                     outputstr{i+1,12}=num2str(0); % # of FIDs
                    % %                 end
                    % %                 outputstr{i+1,13}=[num2str(datsz(1)),' ',num2str(datsz(2)),' ',num2str(datsz(3))];
                    % %                 fprintf(txtfid,'%10s |\t %12s |\t %8s |\t %6s |\t %5s |\t %5s |\t %5s |\t %6s |\t %2s |\t %6s |\t %3s |\t %4s |\t %7s \n',outputstr{i+1,:});
                    % ---------------------------------------------------------
                case 'Siemens'
                    params = rtp_siemens(mainhandles.datalist(i).liststring);
                    mainhandles.datalist(i).params = params;
                    mainhandles.datalist(i).nucleus = '1H';
                    mainhandles.datalist(i).params.sfrq = mainhandles.datalist(i).params.sfrq/10^6;
                    mainhandles.datalist(i).resfreq = mainhandles.datalist(i).params.sfrq;
                    
                    mainhandles.datalist(i).ppm_ref = 0; % initializes referenz for ppm scale
                    mainhandles.datalist(i).acq_time = mainhandles.datalist(i).params.at;
                    mainhandles.datalist(i).spectralwidth = mainhandles.datalist(i).params.sw;
                    mainhandles.datalist(i).np = mainhandles.datalist(i).params.np;
                    
                    mainhandles.datalist(i).acqtype='MRS';
                    %                 mainhandles.datalist(i).sequence = mainhandles.datalist(i).params.seqfil{:};
                    %                 mainhandles.datalist(i).pslabel = mainhandles.datalist(i).params.pslabel{:};
                    if isfield(params,'multiplicity')
                        mainhandles.datalist(i).multiplicity = params.multiplicity;
                    else
                        mainhandles.datalist(i).multiplicity = 1;
                    end
                    mainhandles.datalist(i).params.lsfid = 0;
                    mainhandles.datalist(i).process.lsfid = 0;
                    if ~isfield(mainhandles.datalist(i),'loaded')
                        mainhandles.datalist(i).loaded = 0;
                    end
                    mainhandles.datalist(i).params.arraydim = 1;
                    
                    %                     tim =  mainhandles.datalist(i).params.acqtime;
                    mainhandles.datalist(i).time =datestr(datenum(mainhandles.datalist(i).params.acqtime,'yyyymmddTHHMMSS'));
                    %                 read_header_siemens
                case 'Philips'
                    %                     rtp_philips
                    %                     read_header_philips
                case 'Bruker'
                    %                     rtp_bruker
                    %                     read_header_bruker
                case {'Analyse', 'NIFTI'}
                    hdr = load_nii_hdr([mainhandles.datalist(i).path filesep mainhandles.datalist(i).filename]);
                    params.lro = hdr.dime.pixdim(3)*hdr.dime.dim(3);
                    params.lpe = hdr.dime.pixdim(2)*hdr.dime.dim(2);
                    params.thk = hdr.dime.pixdim(4);
                    
                    params.np = hdr.dime.dim(3)*2;
                    params.nv = hdr.dime.dim(2);
                    params.ns= hdr.dime.dim(4);
                    params.orient{1}{1} = 'trans';
                    
                    
                    
                    %
                    mainhandles.datalist(i).params = params; % argues=filename,printflag
                    mainhandles.datalist(i).multiplicity = params.ns;
                    %                 mainhandles.datalist(i).acq_time = mainhandles.datalist(i).params.at;
                    %                 mainhandles.datalist(i).spectralwidth = mainhandles.datalist(i).params.sw;
                    mainhandles.datalist(i).np = mainhandles.datalist(i).params.np;
                    %                 mainhandles.datalist(i).sequence = mainhandles.datalist(i).params.seqfil{:};
                    %                 mainhandles.datalist(i).pslabel = mainhandles.datalist(i).params.pslabel{:};
                    mainhandles.datalist(i).time = datestr(now,'dd-mmm-yyyy HH:MM:SS');
                    %                 mainhandles.datalist(i).nucleus = mainhandles.datalist(i).params.tn{:};
                    %                 mainhandles.datalist(i).resfreq = mainhandles.datalist(i).params.sfrq;
                    %                 mainhandles.datalist(i).ppm_ref = 0;
                    
                    mainhandles.datalist(i).acqtype='MRI';
                    if ~isfield(mainhandles.datalist(i),'loaded')
                        mainhandles.datalist(i).loaded = 0;
                    end
                    
                    
                case 'Nrrd'
                case 'DICOM'
                    hdr = dicominfo([mainhandles.datalist(i).path filesep mainhandles.datalist(i).filename]);
                    
                    params.acqtime=[hdr.StudyDate 'T' hdr.StudyTime(1:6)];
                    mainhandles.datalist(i).time =datestr(datenum(params.acqtime,'yyyymmddTHHMMSS'),'dd-mmm-yyyy HH:MM:SS');
                    
                    if (hdr.AcquisitionMatrix(1)==0 && hdr.AcquisitionMatrix(4)==0) && (hdr.AcquisitionMatrix(2)~=0 && hdr.AcquisitionMatrix(3)~=0)
                        params.ns = 1;
                        params.np =  double(hdr.AcquisitionMatrix(2))*2;
                        params.nv =  double(hdr.AcquisitionMatrix(3));
                        
                        
                    elseif (hdr.AcquisitionMatrix(2)==0 && hdr.AcquisitionMatrix(3)==0) && (hdr.AcquisitionMatrix(1)~=0 && hdr.AcquisitionMatrix(4)~=0)
                        
                        params.np =  double(hdr.AcquisitionMatrix(1))*2;
                        params.nv = double(hdr.AcquisitionMatrix(4));
                        params.mosaique.row=hdr.Rows/hdr.AcquisitionMatrix(1);
                        params.mosaique.col=hdr.Columns/hdr.AcquisitionMatrix(4);
                        params.ns =  double(hdr.Private_0019_100a);
                        
                    else
                        params.np = double(hdr.Rows)*2;
                        params.nv = double(hdr.Columns);
                        
                    end
                    
                    params.lro =double(hdr.PixelSpacing(1))*params.np/2/10;
                    params.lpe =double(hdr.PixelSpacing(2))*params.nv/10;
                    params.thk = double(hdr.SliceThickness);
                    
                    
                    orient= hdr.Private_0051_100e(1:3);
                    switch orient
                        case 'Tra'
                            orient = 'trans';
                        case 'Sag'
                            orient = 'sag';
                        case 'Cor'
                            orient = 'cor';
                    end
                    params.orient{1}{1} = orient;
                    params.hdr=hdr;
                    mainhandles.datalist(i).params = params; % argues=filename,printflag
                    mainhandles.datalist(i).multiplicity = params.ns;
                    if ~isfield(mainhandles.datalist(i),'loaded')
                        mainhandles.datalist(i).loaded = 0;
                    end
                    
                    mainhandles.datalist(i).acqtype='MRI';
                case 'Matlab'
                    study = load(mainhandles.datalist(i).liststring);
                    mainhandles.datalist(i).params = study.study.params;
                    mainhandles.datalist(i).data = study.study.data;
                    mainhandles.datalist(i).nucleus = study.study.nucleus;
                    mainhandles.datalist(i).resfreq = study.study.resfreq;
                    mainhandles.datalist(i).ppm_ref = study.study.ppm_ref;
                    mainhandles.datalist(i).acq_time = study.study.acq_time;
                    mainhandles.datalist(i).spectralwidth = study.study.spectralwidth;
                    mainhandles.datalist(i).acqtype = study.study.acqtype;
                    mainhandles.datalist(i).multiplicity = study.study.multiplicity;
                    mainhandles.datalist(i).process = study.study.process;
                    mainhandles.datalist(i).loaded = 1;
                    mainhandles.datalist(i).time = study.study.time;
                    mainhandles.datalist(i).np = study.study.np;
                case 'Raw'
                    
                    if isfield(mainhandles.datalist(i),'params')
                        if ~isempty(mainhandles.datalist(i).params)
                            controlfile = mainhandles.datalist(i).params.controlfile;
                            if strcmp(controlfile,'manual')
                                answer = questdlg({'Do you want to modify the parameters of:',...
                                                    mainhandles.datalist(i).filename},'Yes','No');
                                if strcmp(answer,'Yes')
                                    prompt = {'Enter nucleus:','Enter resonance frequency:','Enter spectral width:'};
                                    dlg_title = 'Input paramters';
                                    num_lines = 1;
                                    def = {'1H','599.438','7022.5'};
                                    para = inputdlg(prompt,dlg_title,num_lines,def);
                                    params.nucleus = str2double(para{1});
                                    params.sfrq = str2double(para{2});
                                    params.sw = str2double(para{3});
                                    params.dw = 1/params.sw;
                                      else
                                break;
                                end

                            end
                        else
                            dirfile = dir([mainhandles.datalist(i).path filesep '*.control']);
%                         dirfile = dir(['D:\DATA\DATA-TEST\RAW filesep' '.control'])
                        if size(dirfile,1)==0
                            answer = questdlg({'No controlfile was found in the RAW file directory.', ...
                                                'Do you want to select a file in a different directory',...
                                                'or input manually the required parameters?'},...
                                                'No control file','Browse','Manual','Browse');
                            if strcmp(answer,'Manual') || isempty(answer)
                                prompt = {'Enter nucleus:','Enter resonance frequency:','Enter spectral width:'};
                                dlg_title = 'Input paramters';
                                num_lines = 1;
                                def = {'1H','599.438','7022.5'};
                                para = inputdlg(prompt,dlg_title,num_lines,def);
                                params.nucleus = str2double(para{1});
                                params.sfrq = str2double(para{2});
                                params.sw = str2double(para{3});
                                params.dw = 1/params.sw;
                                
%                                 params.at = para{1};
%                                 params.np = para{1};
                                
                                controlfile = 'manual';
                                
                            elseif strcmp(answer,'Browse')
                                [FileName,PathName,FilterIndex] = uigetfile('*.*','DefaultPath',mainhandles.datalist(i).path);
                                controlfile = [PathName filesep FileName];
                            end
                        elseif size(dirfile,1)>1
                            controlfile_list = {dirfile.name};
                            [s,v] = listdlg('PromptString',mainhandles.datalist(i).filename,'Name','Select a file:',...
                                            'SelectionMode','single',...
                                            'ListString',controlfile_list);                            
                            if ~isempty(s)
                                controlfile = [mainhandles.datalist(i).path filesep dirfile(s).name];
                            else
                                display('No controlfile selected')
                                break;
                            end
                        else
                            controlfile = [mainhandles.datalist(i).path filesep dirfile.name];
                        end
                        end
                    else
                        dirfile = dir([mainhandles.datalist(i).path filesep '*.control']);
%                         dirfile = dir(['D:\DATA\DATA-TEST\RAW filesep' '.control'])
                        if size(dirfile,1)==0
                            answer = questdlg({'No controlfile was found in the RAW file directory.', ...
                                                'Do you want to select a file in a different directory',...
                                                'or input manually the required parameters?'},...
                                                'No control file','Browse','Manual','Browse');
                            if strcmp(answer,'Manual') || isempty(answer)
                                prompt = {'Enter nucleus:','Enter resonance frequency:','Enter spectral width:'};
                                dlg_title = 'Input paramters';
                                num_lines = 1;
                                def = {'1H','599.438','7022.5'};
                                para = inputdlg(prompt,dlg_title,num_lines,def);
                                params.nucleus = str2double(para{1});
                                params.sfrq = str2double(para{2});
                                params.sw = str2double(para{3});
                                params.dw = 1/params.sw;
                                
%                                 params.at = para{1};
%                                 params.np = para{1};
                                
                                controlfile = 'manual';
                                
                            elseif strcmp(answer,'Browse')
                                [FileName,PathName,FilterIndex] = uigetfile('*.*','DefaultPath',mainhandles.datalist(i).path);
                                controlfile = [PathName filesep FileName];
                            end
                        elseif size(dirfile,1)>1
                            controlfile_list = {dirfile.name};
                            [s,v] = listdlg('PromptString',mainhandles.datalist(i).filename,'Name','Select a file:',...
                                            'SelectionMode','single',...
                                            'ListString',controlfile_list);
                            if ~isempty(s)
                                controlfile = [mainhandles.datalist(i).path filesep dirfile(s).name];
                            else
                                display('No controlfile selected')
                                break;
                            end
                        else
                            controlfile = [mainhandles.datalist(i).path filesep dirfile.name];
                        end
                        
              
                    end
                    params.controlfile = controlfile;
                    params.nt=1;
                    params.vox1 = 1;
                     params.vox2 = 1;
                      params.vox3 = 1;
                      
                    if ~strcmp(controlfile,'manual')
                        fid = fopen(params.controlfile);
                        fileend=1;
                        while fileend>0
                            l = fgetl(fid);
                            if l<0  %%en of file
                                fileend=l;
                                break;
                            end
                            sep = findstr(l,'=');
                            if ~isempty(sep)
                            par_name = lower(strrep(l(1:sep-1),' ' ,''));
                            par_name=strrep(strrep(par_name,'(','_'),')','');
                            par_str = l(sep+1:length(l));
                            
                            par_val = str2double(par_str);
                            if isnan(par_val) %string
                                par_val = (par_str);
                            end 
                            params.(par_name) = par_val;
                            end
                            
                        end
                        fclose(fid);
                             params.sw = 1/params.deltat;
                             params.sfrq = params.hzpppm;
                             params.dw= params.deltat;
                            if isfield(params,'ppmend') && isfield(params,'ppmst')
                                if params.ppmst-params.ppmend<6
                                    params.nucleus='1H';
                                else
                                    params.nucleus = '13C';
                                end
                            else
                                params.nucleus = '1H';
                            end
                            
                    end
                    if disp_debug==1
                        display('%%%%%%%%%%%%%%55 RAW %%%%%%%%%%%%%%%%%%%')
                        display(params)
                    end
                    mainhandles.datalist(i).params = params;
                    mainhandles.datalist(i).nucleus = params.nucleus;
%                     mainhandles.datalist(i).acq_time = mainhandles.datalist(i).params.at;
                    mainhandles.datalist(i).spectralwidth = params.sw;
%                     mainhandles.datalist(i).np = mainhandles.datalist(i).params.np;
                    mainhandles.datalist(i).acqtype='MRS';
                    
%                     mainhandles.datalist(i).params.sfrq = mainhandles.datalist(i).params.sfrq/10^6;
                    mainhandles.datalist(i).resfreq = params.sfrq;
                    
                    mainhandles.datalist(i).ppm_ref = 0; % initializes referenz for ppm scale
                    mainhandles.datalist(i).params.lsfid = 0;
                    mainhandles.datalist(i).process.lsfid = 0;
                    mainhandles.datalist(i).params.arraydim = 1;
                    file = dir([mainhandles.datalist(i).path filesep mainhandles.datalist(i).filename]);
                    mainhandles.datalist(i).time =datestr(file.datenum,'dd-mmm-yyyy HH:MM:SS');

                    if isfield(params,'multiplicity')
                        mainhandles.datalist(i).multiplicity = params.multiplicity;
                    else
                        mainhandles.datalist(i).multiplicity = 1;
                    end
                    
                    if ~isfield(mainhandles.datalist(i),'loaded')
                        mainhandles.datalist(i).loaded = 0;
                    end
                    
            end
        catch
            
            err_data_idx=err_data_idx+1;
            %             disp('*****************************************************************************');
            %             disp('*****************************************************************************');
            %             disp('Error: impossible to load data');
            disp('Unknown file type')
            disp(mainhandles.datalist(i).liststring)
            err_data(err_data_idx)=i;
            
        end
    else
        readswitch=0;
    end
    waitbar(i/length(mainhandles.datalist))
    %     fieldnames(mainhandles.datalist(i).data)
    
end
% fclose(txtfid)
% edit([fileparts(which('NMR_eval')) '\dataformatparams.txt'])
close(h_wait)

if err_data_idx>0
    
    
    filelisthandles = guidata(findobj('Tag','filelistfig'));
    filelist = get(filelisthandles.filelistfig_listbox,'String');
    all_data = 1:length(mainhandles.datalist);
    [tf, loc] = ismember(all_data, err_data);
    
    ok_data = all_data(tf~=1);
    mainhandles.datalist= mainhandles.datalist(ok_data);
    filelist= filelist(ok_data);
    
    %     if err_data(e)~=1 || err_data(e)~=length(mainhandles.datalist)
    %         mainhandles.datalist= mainhandles.datalist([1:(err_data(e)-1) (err_data(e)+1):length(mainhandles.datalist)]);
    %         filelist= filelist{[1:(err_data(e)-1) (err_data(e)+1):length(mainhandles.datalist)]};
    %     elseif err_data(e)==1
    %         mainhandles.datalist= mainhandles.datalist(2:length(mainhandles.datalist));
    %         filelist= filelist(2:length(mainhandles.datalist));
    %     elseif err_data(e)==length(mainhandles.datalist)
    %         mainhandles.datalist= mainhandles.datalist(1:(length(mainhandles.datalist)-1));
    %         filelist= filelist{2:length(mainhandles.datalist)};
    %     end
    if isempty(filelist)
        filelist='empty';
    end
    set(findobj('Tag','filelistfig_listbox'),'String',filelist);
    guidata(findobj('Tag','filelistfig'),filelisthandles);
    
    if isempty(mainhandles.datalist)
        return;
    end
    
end


data_path =  {mainhandles.datalist.path};



data_path_uni=unique(data_path);
rmv_idx = [];

if length(data_path_uni) ~= length(data_path)
    for i=1:length(data_path_uni)
        idx_cur=find(strcmp(data_path_uni(i),data_path)==1);
        fidsum_idx = ismember({mainhandles.datalist(idx_cur).type},'fid_sum');
        idx_cur=idx_cur(fidsum_idx~=1);
        
        if ~isempty(idx_cur)
            if length(idx_cur)>1||strcmp(mainhandles.datalist(idx_cur(1)).type,'fdf') %multiple file in hte same directory
                adddata_ct=0;
                %             disp('Combine file in the folowwing directory:');
                %             disp(data_path_uni(i));
                if strcmp(mainhandles.datalist(idx_cur(1)).type,'fdf')
                    %                 try
                    %                     fid_idx = find(strcmp(strrep(data_path_uni{i},'img','fid'),data_path)==1);
                    %                 catch
                    %                     fid_idx =[];
                    %                 end
                    %                 if isempty(fid_idx)==0
                    %                     for j=1:length(idx_cur)
                    %                         adddata_ct=adddata_ct+1;
                    %                         rmv_idx = [rmv_idx idx_cur(j)];
                    %                     end
                    %                     if mainhandles.datalist(fid_idx).multiplicity ~= adddata_ct
                    %                         %             %%%%%%%%%%%%         pas sure
                    %                         %                             mainhandles.datalist(fid_idx).multiplicity
                    %                         %                             mainhandles.datalist(fid_idx).multiplicity = adddata_ct;
                    %                         %                             disp('fdf size does not fid fid size')
                    %                     end
                    %                     mainhandles.datalist(fid_idx).fdf=1;
                    %                 else
                    adddata_ct=adddata_ct+1;
                    for j=2:length(idx_cur)
                        adddata_ct=adddata_ct+1;
                        rmv_idx = [rmv_idx idx_cur(j)];
                    end
                    mainhandles.datalist(idx_cur(1)).fdf=1;
                    mainhandles.datalist(idx_cur(1)).multiplicity = adddata_ct;
                    mainhandles.datalist(idx_cur(1)).params.ns = adddata_ct;
                    %                 end
                    
                elseif strcmp(mainhandles.datalist(idx_cur(1)).type,'dcm')
                    adddata_ct=adddata_ct+1;
                    for j=2:length(idx_cur)
                        adddata_ct=adddata_ct+1;
                        rmv_idx = [rmv_idx idx_cur(j)];
                    end
                    mainhandles.datalist(idx_cur(1)).multiplicity = adddata_ct;
                    mainhandles.datalist(idx_cur(1)).params.ns = adddata_ct;
                end
                % disp(rmv_idx)
                
            end
        end
    end
end

mainhandles.datalist = mainhandles.datalist(setxor([1:length(mainhandles.datalist)],rmv_idx));
guidata(findobj('Tag','mainmenu'),mainhandles);
%% sorting and merging data with same timestamp and format, if possible
% set switch cases for Varian and others ...
% (i.e. Varian images consist of one .fid folder with the complex data and
% an .fdf folder with the absval images for the same images)


[tf sortidx] = sort({mainhandles.datalist.time});
mainhandles.datalist = mainhandles.datalist(sortidx);
guidata(findobj('Tag','mainmenu'),mainhandles);

% sortidx

% % sort data by their date
date_nums = datenum({mainhandles.datalist.time},'dd-mmm-yyyy HH:MM:SS');
date_nums_uni=unique(date_nums);
rmv_idx = [];
% if length(date_nums_uni) ~= length(date_nums)
%     for i=1:length(date_nums_uni)
%         idx_cur=find(date_nums_uni(i)==date_nums);
%         fidsum_idx = ismember({mainhandles.datalist(idx_cur).type},'fid_sum');
%         idx_cur=idx_cur(fidsum_idx~=1);
%         if length(idx_cur)>1
%             %             if length(idx_cur)-1~=mainhandles.datalist(idx_cur(1)).multiplicity
%             %                 disp(['updatedta.m line 131: ' mainhandles.datalist(idx_cur(1)).liststring])
%             %             end
%             adddata_ct=1;
%             for j=2:length(idx_cur)
%                 strctfields = fieldnames(mainhandles.datalist(idx_cur(j)).data);
%                 for k=1:length(strctfields)
%                     if isfield(mainhandles.datalist(idx_cur(1)).data,char(strctfields(k)))==0
%                         % a new field is added to "data", e.g. "absval" added to "data.real" and "data.imag"
%                         mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k))) = ...
%                             mainhandles.datalist(idx_cur(j)).data.(char(strctfields(k)));
%                         rmv_idx = [rmv_idx idx_cur(j)];
%                     else % field already exists -> check if data alrady exist -> if not, add data (check match with "multiplicity")
%                         newdata = mainhandles.datalist(idx_cur(j)).data.(char(strctfields(k)));
%                         olddata = mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k)));
%                         %                         singledim = setxor(size(newdata),size(olddata));
%                         % check: olddata has to be of same dimension or one less
%                         sz_new = size(newdata);
%                         sz_old = size(olddata);
%                         if sz_new(length(sz_new))==sz_old(length(sz_old)) && ...
%                                 sz_new(length(sz_new)-1)==sz_old(length(sz_old)-1)
%                             dataequals = 0; % check if dataset already exists
%                             if ndims(newdata)>ndims(olddata)
%                                 for m=1:sz_new(1)
%                                     if isequal(squeeze(newdata(m,:,:)),olddata)
%                                         dataequals = 1;
%                                     end
%                                 end
%                             elseif ndims(newdata)<ndims(olddata)
%                                 for m=1:sz_old(1)
%                                     if isequal(squeeze(olddata(m,:,:)),newdata)
%                                         dataequals = 1;
%                                     end
%                                 end
%                             else
%                                 if isequal(newdata,olddata)
%                                     dataequals = 1;
%                                 end
%                             end
%                             if dataequals==0
%                                 if ndims(newdata)==2 && ndims(olddata)==2
%                                     alldata = ...
%                                         cat(ndims(newdata)+1,mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k))),newdata);
%                                     mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k))) = ...
%                                         permute(alldata,[length(size(alldata)) 1:length(size(alldata))-1]);
%                                 elseif ndims(newdata)==3 && ndims(olddata)==3
%                                     mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k)))((sz_old(1)+1):(sz_old(1)+sz_new(1)),:,:)=...
%                                         newdata;
%                                 elseif ndims(newdata)==2 && ndims(olddata)==3
%                                     mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k)))(sz_old(1)+1,:,:)=newdata;
%                                 elseif ndims(newdata)==3 && ndims(olddata)==2
%                                     alldata = cat(1,mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k))),newdata);
%                                     mainhandles.datalist(idx_cur(1)).data.(char(strctfields(k))) = alldata;
%                                 end
%                                 clear alldata
%                             end
%                             adddata_ct=adddata_ct+1;
%                             rmv_idx = [rmv_idx idx_cur(j)];
%                         else
%                             disp('size of data with same time stamp does not match, thus will not be added')
%                         end
%                         clear newdata olddata
%                     end
%                 end
%             end
%             if isfield(mainhandles.datalist(idx_cur(1)).data,'real') && ...
%                     mainhandles.datalist(idx_cur(1)).multiplicity~=...
%                     size(mainhandles.datalist(idx_cur(1)).data.real,1)
%                 mainhandles.datalist(idx_cur(1)).multiplicity=...
%                     size(mainhandles.datalist(idx_cur(1)).data.real,1);
%                 disp('multiplicity does not match size of data and was adpated for file:')
%                 disp([mainhandles.datalist(idx_cur(1)).liststring])
%             end
%         end
%
%     end
% %     %KAI update for multiplicity correction MRS
% %         for k=1:size(mainhandles.datalist)
% %         if mainhandles.datalist(k).multiplicity~=...
% %                 size(mainhandles.datalist(k).data.real,1)
% %             mainhandles.datalist(k).multiplicity=...
% %                 size(mainhandles.datalist(k).data.real,1);
% %             disp('multiplicity does not match size of data and was adpated for file:')
% %             disp([mainhandles.datalist.liststring])
% %         end
% %     end
%
% end


mainhandles.datalist=mainhandles.datalist(setxor(1:length(mainhandles.datalist),unique(rmv_idx)));
guidata(findobj('Tag','mainmenu'),mainhandles);

%% --- transform results to figures and update settings of uicontrols
if isfield(mainhandles,'datalist') && isempty(mainhandles.datalist)==0
    %     set(mainhandles.mainmenu_pushbutton_process,'Enable','on')
    %     set(mainhandles.mainmenu_pushbutton_display,'Enable','on')
    %     %     set(mainhandles.mainmenu_pushbutton_empty,'Enable','on')
    %     set(mainhandles.mainmenu_pushbutton_lcmodel,'Enable','on')
    %
    if length(mainhandles.datalist)>1 || nnz([mainhandles.datalist.multiplicity]~=1)>0
        set(mainhandles.dispopt_edit_datanum,'Enable','on')
        set(mainhandles.dispopt_pushbutton_dispnext,'Enable','on')
        set(mainhandles.dispopt_pushbutton_dispbefore,'Enable','on')
        set(mainhandles.text_currentfile,'Visible','on')
    end
    set(mainhandles.dispopt_pushbutton_dispinfo,'Enable','on')
    %
    if sum(strcmp(upper({mainhandles.datalist.acqtype}),'MRS'))>0 || ...
            sum(strcmp(upper({mainhandles.datalist.acqtype}),'CSI'))>0
        set(mainhandles.dispopt_pushbutton_dispMRS,'Enable','on')
        set(mainhandles.dispopts_togglebutton_format_ppmhz,'Enable','on')
        set(mainhandles.dispopt_radiobutton_grid,'Value',1,'Enable','on')
        set(mainhandles.dispopt_radiobutton_datacursor,'Enable','on')
        if sum(cell2mat({mainhandles.datalist.multiplicity})>1)
            set(mainhandles.dispopt_togglebutton_dispCSI,'Enable','on')
        end
    end
    
    if sum(strcmp(upper({mainhandles.datalist.acqtype}),'MRI'))>0
        set(mainhandles.dispopt_pushbutton_dispMRI,'Enable','on')
        %                 set(mainhandles.dispopts_togglebutton_format_fdf,'Enable','on')
        %         set(mainhandles.dispopt_radiobutton_cbar,'Enable','on')
        %         set(mainhandles.dispopt_popupmenu_cmap,'Enable','on');
        if sum(cell2mat({mainhandles.datalist.multiplicity})>1)
            set(mainhandles.dispopt_togglebutton_dispCSI,'Enable','on')
        end
    end
    %
    set(mainhandles.dispopts_togglebutton_format_rawfft,'Enable','on')
    %     set(get(mainhandles.dispopts_uipanel_dataformat,'Children'),'Enable','on')
    set(mainhandles.dispopt_pushbutton_resetdisp,'Enable','on')
end

%% get expanded datalist
ct=1;
for i=1:length({mainhandles.datalist.liststring})
    for k=1:mainhandles.datalist(i).multiplicity
        liststring_exp{ct}=[mainhandles.datalist(i).liststring '_' num2str(k)];
        ct=ct+1;
    end
end
mainhandles.liststr_expanded = liststring_exp;

% update GUI_filelist
formatlist = unique(cellstr({mainhandles.datalist.format}));
set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
acqtypelist = unique(cellstr({mainhandles.datalist.acqtype}));
set(findobj('Tag','filelistfig_popupmenu_selecttype'),'String',acqtypelist)

filelisthandles=guidata(findobj('Tag','filelistfig'));
if isempty(mainhandles.dispopts.dataidx)
    mainhandles.dispopts.dataidx=1;
end
% if get(filelisthandles.filelistfig_togglebutton_expandlist,'Value')
%     cumsum_vec=cumsum([mainhandles.datalist.multiplicity]);
%     if mainhandles.dispopts.dataidx>1
%         curidx=cumsum_vec(mainhandles.dispopts.dataidx-1)+mainhandles.dispopts.arrayidx;
%     else
%         curidx=mainhandles.dispopts.arrayidx;
%     end
%     set(filelisthandles.filelistfig_listbox,'String',mainhandles.liststr_expanded,...
%         'Value',curidx,'Max',length(mainhandles.liststr_expanded))
% else
set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring},...
    'Value',mainhandles.dispopts.dataidx,'Max',length({mainhandles.datalist.liststring}))
% end


% set(mainhandles.dispopt_togglebutton_dispCSI,'Value',0)
guidata(findobj('Tag','mainmenu'),mainhandles)

set(findobj('Tag','filelistfig_pushbutton_updatelist'),'BackgroundColor',[0.9255 0.9137 0.8471],...
    'FontAngle','normal','FontWeight','normal')
disp('update data')
toc
% sfrq = [mainhandles.datalist(2).params.sfrq];
% disp(sfrq)
% mainmenu('dispopt_edit_datanum_Callback',mainhandles.mainmenu,[],mainhandles)

