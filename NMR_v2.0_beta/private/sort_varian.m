function [data params] = sort_varian(data, d, params, filename, file_ext)
% resort data according to FID, MRI or CSI data

global petable

% params.seqcon{1}
% params.apptype{1}
data.multiplicity=0;
data.acqtype='';
if isfield(params,'nv')==0
    params.nv=0;
end
disp([params.seqfil{1} params.time_run{1}])

switch lower(file_ext)
    case{'fid'}
        
      
        if isfield(params,'nv') && params.acqdim==1
               if params.nv>1
                   params.acqdim=2;
               end
        end
        
        % 1. determine mulitplictiy & acqtype
        %% acqdim ==1
        if params.acqdim==1 % FID
            data.acqtype='MRS';
            %             data.multiplicity=1;
            data.multiplicity=params.arraydim;%size(params.nt,1);
%             if data.multiplicity ~= data.header.file.ntraces
%                 data.multiplicity = data.header.file.ntraces;
%             end
            %% acqdim ==2
        elseif params.acqdim==2
            if params.nv==0 % apptype='prescan_ex' & seqfil='prescanfreq'
                data.multiplicity=1;
                if params.ns==0
                    data.acqtype='MRS: fastmap';
                elseif params.ns==1
                    data.acqtype='MRS: prescan_ex (mems)';
                else
                    data.acqtype='MRS: prescan w/o PE';
                end
            elseif params.nv==1 % (apptype='prescan_ex' OR 'imFM') & (seqfil='mems' OR 'fastestmap')
                data.multiplicity=1;
                if params.ns==1
                    data.acqtype='prescan_ex: mems';
                else
                    data.acqtype='prescanfreq with PE';
                end
                if data.header.file.ntraces<=1 && data.header.file.nblocks>1
                    data.multiplictiy=data.header.file.nblocks;
                end
            elseif params.nv>=2 % images=MRI
                data.acqtype='MRI';
                if params.nv~=data.header.file.ntraces
                    data.multiplicity=data.header.file.ntraces/params.nv;
                    %                     if ~isempty(cell2mat(strcmp(data.pslabel,'sems')))||~isempty(cell2mat(strfind(data.pslabel,'mems')))||~isempty(cell2mat(strfind(data.pslabel,'ck_diff')))
                    if (~isempty(cell2mat(strfind(data.pslabel,'sems')))||~isempty(cell2mat(strfind(data.pslabel,'mems')))||~isempty(cell2mat(strfind(data.pslabel,'ck_diff'))))...
                            &&isempty(cell2mat(strfind(data.pslabel,'fsems')))
    
                        data.multiplicity = data.header.file.ntraces;
                        d.real=flipdim(permute(d.real,[2 1 3]),2);
                        d.imag=flipdim(permute(d.imag,[2 1 3]),2);
                        %                         if strcmp(data.pslabel,'sems')
                        %                         end
                    elseif ~isempty(cell2mat(strfind(params.orient{1},'3orthogonal'))) %scout
                        d.real=reshape(d.real,[3*size(d.real,1) size(d.real,2)/3 size(d.real,3)]);
                        d.imag=reshape(d.imag,[params.arraydim*size(d.imag,1) size(d.imag,2)/params.arraydim size(d.imag,3)]);
                        data.multiplicity=data.multiplicity*params.arraydim;
                        
                    end
                else
                    
                    data.multiplicity = data.header.file.nblocks;
                    if ~isempty(cell2mat(strfind(data.pslabel,'epi')))
                        data.multiplicity = params.ns;
                    end
                    
                    %                 else
                    %                     disp('!!! resorting of data fails: acqtype and multiplicity could not be determined !!!')
                    
                end
            else                                                                                                                                                 
                disp('!!! resorting of data fails: acqtype and multiplicity could not be determined !!!')
            end
            %% acqdim >= 3
        elseif params.acqdim >= 3 % spectroscopic imaging = CSI
            if params.nv >= 2 % CSI
                data.acqtype='CSI';
                data.multiplicity = data.header.file.nblocks*params.nv;
            else
                if params.nv==0
                    data.acqtype='CSI';
                    data.multiplicity = data.header.file.nblocks*1;
                else
                    disp('resorting of data fails: appropriate acquistion mode not defined')
                end
            end
            
        end
        if data.multiplicity==0
            disp({'resorting of data failed: appropriate multiplictiy could not be determined';...
                ['file : ' filename]});
            return
        elseif strcmp(data.acqtype,'')==1
            disp('resorting of data failed: appropriate acquistion mode could not be determined')
            return
        end
        %% 2. resort according mutliplictiy
        if params.nv == 0
            %             data.data.real=zeros(data.multiplicity,1,data.header.file.np/2);
            %             data.data.imag=zeros(data.multiplicity,1,data.header.file.np/2);
            data.data.real=zeros(data.multiplicity,data.header.file.ntraces,data.header.file.np/2);
            data.data.imag=zeros(data.multiplicity,data.header.file.ntraces,data.header.file.np/2);
        else
            if strcmp(data.acqtype,'MRI') || strcmp(data.acqtype,'prescan_ex: mems')
                data.data.real=zeros(data.multiplicity,params.nv,data.header.file.np/2);
                data.data.imag=zeros(data.multiplicity,params.nv,data.header.file.np/2);
                
            elseif strcmp(data.acqtype,'CSI')
                if isempty(findstr(char(params.seqfil{1}),'dnpepsi'))
                    data.data.real=zeros(data.multiplicity/params.nv,params.nv,data.header.file.np/2);
                    data.data.imag=zeros(data.multiplicity/params.nv,params.nv,data.header.file.np/2);
                else
                    data.data.real=zeros(params.np/2,params.nv,params.ne);
                    data.data.imag=zeros(params.np/2,params.nv,params.ne);
                end
            end
        end
        if ~isempty(findstr(char(params.seqfil{1}),'epi')) || ~isempty(findstr(char(params.apptype{1}),'EPI'))
            data.acqtype='MRI';
            [data.data params] = sort_epi_adiab_2grora(d,params);
            data.multiplicity = size(data.data.real,1);
        elseif (~isempty(findstr(char(params.seqfil{1}),'fsems'))&&~isempty(findstr(char(params.seqfil{1}),'csi')))
            
        elseif data.header.file.nblocks==1 % params.ns==multiplicity
            % consider seqcon !!! & check if params.petable is used i.e. ~='n'
            if ~isempty(findstr(char(params.seqfil{1}),'dnpepsi'))
                data = sort_dnpepsi(data,d,params);
            else
                if isequal(petable,0)==0 && strcmp(char(params.seqfil{1}),'fsems_9T_csi')==0
                    t1=petable;
                    ct=1;
                    for j=1:size(t1,1)
                        for i=1:data.multiplicity
                            for k=1:size(t1,2)
                                try
                                    idx = -(t1(j,k)-params.nv/2)+1;
                                    data.data.real(i,idx,:)=squeeze(d.real(1,ct,:));
                                    data.data.imag(i,idx,:)=squeeze(d.imag(1,ct,:));
                                    ct=ct+1;
                                catch
                                    disp('k0')
                                end
                            end
                        end
                    end
                else
                    
                    for i=1:data.multiplicity
                        data.data.real(i,:,:)=...
                            squeeze(d.real(1,i:data.multiplicity:data.header.file.ntraces,:));
                        data.data.imag(i,:,:)=...
                            squeeze(d.imag(1,i:data.multiplicity:data.header.file.ntraces,:));
                    end
                    
                end
            end
        else
            if data.multiplicity==0 || data.multiplicity==1
                data.multiplicity = size(data.data.real,1);
                % data.multiplicity = data.header.file.nblocks;
            end
            if ~isequal(size(d.real),size(data.data.real))
                if isfield(params,'diff') && strcmp(data.acqtype,'MRI')
                    
                    dime=size(d.real);
                    Ndiff=max([length(params.dro),length(params.dpe),length(params.dsl)]);
                    data.data.real=zeros([dime(1) dime(2)/Ndiff dime(3) Ndiff]);
                    data.data.imag=zeros([dime(1) dime(2)/Ndiff dime(3) Ndiff]);
                    for k=1:Ndiff
                        data.data.real(:,:,:,k)=d.real(:,k:Ndiff:size(d.real,2),:);
                        data.data.imag(:,:,:,k)=d.imag(:,k:Ndiff:size(d.imag,2),:);
                    end
                    data.data.real = flipdim(data.data.real,4);
                    data.data.imag = flipdim(data.data.imag,4);
                elseif strcmp(data.acqtype,'MRS')
                    
                    data.data.real=d.real;
                    data.data.imag=d.imag;
                    data.multiplicity = size(data.data.real,1);
                    
                    %%old vnmr
                elseif strcmp(data.pslabel,'ck_diff')
                    params.dro = params.dir_ro;
                    params.dpe = params.dir_pe;
                    params.dsl = params.dir_ss;
                    grad_norm = sum([params.dro.^2 params.dpe.^2 params.dsl.^2],2).^0.5;
                    gamma=26.752e7/(10000);
                    params.bvalue = (params.gdiff.*grad_norm).^2.*gamma^2.*params.tdelta^2.*(params.tDELTA-params.tdelta/3);
                    
                    dime=size(d.real);
                    Ndiff=max([length(params.dro),length(params.dpe),length(params.dsl)]);
                    data.data.real=zeros([dime(1) dime(2)/Ndiff dime(3) Ndiff]);
                    data.data.imag=zeros([dime(1) dime(2)/Ndiff dime(3) Ndiff]);
                    for k=1:Ndiff
                        data.data.real(:,:,:,k)=d.real(:,k:Ndiff:size(d.real,2),:);
                        data.data.imag(:,:,:,k)=d.imag(:,k:Ndiff:size(d.imag,2),:);
                    end
                end
            else
                data.data.real=d.real;
                data.data.imag=d.imag;
            end
            
        end
        if strcmp(data.acqtype,'MRI')
            if ~isfield(params,'orient')
                params.orient{1}='trans';
            end
            
            switch char(params.orient{1})
                case 'trans'
%                     disp('trans')
                    params.rotation = 1;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
                case 'trans90'
%                     disp('trans90')
                    params.rotation  = 2;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
                case 'cor'
%                     disp('cor')
                    params.rotation  = -1;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
                case 'cor90'
%                     disp('cor90')
                    params.rotation  = 0;
                    params.RO_dim = 1;
                    params.PE_dim = 2;
                case 'sag'
%                     disp('sag')
                    params.rotation  = 0;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
                case 'sag90'
%                     disp('sag90')
                    params.rotation  = 1;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
                otherwise
%                     disp('otherwise')
                    params.rotation  = 1;
                    params.RO_dim = 2;
                    params.PE_dim = 1;
            end
            
            
            if isfield(params,'pss') && isempty(cell2mat(strfind(params.orient{1},'3orthogonal')))
%                 if isempy(params.pss)~=0
                    [slice order] = sort(params.pss);
%                     slide_order=zeros(size(order));
                    clear temp
                    temp.real=zeros(size(data.data.real));
                    temp.imag=zeros(size(data.data.real));
                    if length(size(data.data.imag))==4
                        temp.real(:,:,:,:)=data.data.real(order,:,:,:);
                        temp.imag(:,:,:,:)=data.data.imag(order,:,:,:);
                    elseif length(size(data.data.imag))==3
                        temp.real(:,:,:)=data.data.real(order,:,:);
                        temp.imag(:,:,:)=data.data.imag(order,:,:);
                    end
                    data.data.real=temp.real;
                    data.data.imag=temp.imag;
%                 end
            end
        end



case {'fdf'}
    data.acqtype='MRI';
    data.multiplicity=1;
    if isempty(findstr(data.header.file.type,'absval'))==0
        data.multiplicity =1; % data.header.file.matrix(1);
    elseif isempty(findstr(data.header.file.type,'complex'))==0
        data.multiplicity = 1;
    end
    data.data.fdf=d.abs; % fliplr(rot90(d.abs,-1));
    otherwise
        data.data.fdf = 0;
        data.data.real = 0;
        data.data.imag = 0;
        disp({'data could not be sorted, data set to zero.';''})
end
% disp('*********************3 MULTPLICITY ***************************')
% data.multiplicity
% if isfield(data.data,'real') && ndims(data.data.real)>3
%     disp('here')
% end