function [data params]=read_varian(datadir,vnmrdatafilename,params)
% read VNMR binary file
% data is returned as a vector of two-column tables
% first column = real part
% second column = imaginary part
%
% pgh Sep 2001
%--------------------------------------------------------------------------
global data_idx petable

%% preparation
info = 0;
homedir=pwd;


% open file (big indian byte order)
if strcmp(datadir(length(datadir)),filesep) == 0 && ...
        strcmp(vnmrdatafilename(1),filesep) == 0
    datadir = [datadir filesep];
end

cd(char(datadir));
% d = dir(datadir);
filename = [char(datadir) char(vnmrdatafilename)];
if exist(filename,'file')==0
    errordlg([filename ' does not exist']);
    return
end
cd(homedir)

if nargin<=2
    mainhandles = guidata(findobj('Tag','mainfig'));
    try,
        data.time = datestr(datenum(mainhandles.datalist(data_idx).params.('time_run'){1},'yyyymmddTHHMMSS'));
    catch,
        temp=char(params.('time_run'){1});
        if size(temp,2)<15
            temp2 = '00000000T000000';
            temp2(1:size(temp,2))=temp;
            data.time =datestr(datenum(temp2,'yyyymmddTHHMMSS'));
        end
    end
    data.pslabel = mainhandles.datalist(data_idx).params.('pslabel'){1};
    data.nucleus = mainhandles.datalist(data_idx).params.('tn'){1};
    data.apptype = mainhandles.datalist(data_idx).params.('apptype'){1};
else
    try,
        data.time = datestr(datenum(params.('time_run'){1},'yyyymmddTHHMMSS'));
    catch,
        temp=char(params.('time_run'){1});
        if size(temp,2)<15
            temp2 = '00000000T000000';
            temp2(1:size(temp,2))=temp;
            data.time =datestr(datenum(temp2,'yyyymmddTHHMMSS'));
        end
    end
    data.pslabel = params.('pslabel'){1};
    data.nucleus = params.('tn'){1};
    data.apptype = params.('apptype'){1};
end

cd(char(datadir));

if iscell(vnmrdatafilename)
    vnmrdatafilename = char(vnmrdatafilename{1});
end
file_ext = vnmrdatafilename(length(vnmrdatafilename)-2:length(vnmrdatafilename));

%% read file
switch lower(file_ext)
    case {'fid'} % ,'FID','Fid'}
        fileid=fopen(filename,'r','ieee-be');
        if fileid == -1
            errordlg(['Cannot open file: ' filename]);
            return
        else
            if info
                disp('***** READING VNMR DATA *****'); % disp(' ')
                disp(['Opening file  ' filename]);
            end
        end
        %% ----- read main header of fid file -----
        data.header.file=struct('nblocks',0,'ntraces',0,'np',0,'ebytes',0,'tbytes',0,'bbytes',0,'vers_id',0,'status',0,'nbheaders',0);
        data.header.block=struct('scale',0,'status',0,'index',0,'mode',0,'ctcount',0,'lpval',0,'rpval',0,'lvl',0,'tlt',0);

        data.header.file.nblocks=fread(fileid,1,'long');
        data.header.file.ntraces=fread(fileid,1,'long');
        data.header.file.np=fread(fileid,1,'long');
        data.header.file.ebytes=fread(fileid,1,'long');
        data.header.file.tbytes=fread(fileid,1,'long');
        data.header.file.bbytes=fread(fileid,1,'long');
        data.header.file.vers_id=fread(fileid,1,'short');
        data.header.file.status=fread(fileid,1,'short');
        data.header.file.nbheaders=fread(fileid,1,'long');

        data.header.block.scale=fread(fileid,1,'short');
        data.header.block.status=fread(fileid,1,'short');
        data.header.block.index=fread(fileid,1,'short');
        data.header.block.mode=fread(fileid,1,'short');
        data.header.block.ctcount=fread(fileid,1,'long');
        data.header.block.lpval=fread(fileid,1,'float');
        data.header.block.rpval=fread(fileid,1,'float');
        data.header.block.lvl=fread(fileid,1,'float');
        data.header.block.tlt=fread(fileid,1,'float');

        blockheader=data.header.block;
        s=whos('-regexp','blockheader');
        blockheadersize = s.bytes;
        % ----- read data -----
        %         bitget(data.header.file.status,1:8);
        if (bitget(data.header.file.status,4)==1)
            precision='float';
            if info, fprintf('Data type = float\n'); end
        else
            if (bitget(data.header.file.status,3)==0)
                precision='short';
                if info, fprintf('Data type = short\n'); end
            else
                precision='long';
                if info, fprintf('Data type = long\n'); end
            end
        end
        % % %         if (bitget(data.header.file.status,3)==0)
        % % %             if (bitget(data.header.file.status,2)==0)
        % % %                 precision='short';
        % % %                 if info, fprintf('Data type = short\n'); end
        % % %             else
        % % %                 precision='float';
        % % %                 if info, fprintf('Data type = float\n'); end
        % % %             end
        % % %         end
        % % %         if (bitget(data.header.file.status,3)==1)
        % % %             precision='long';
        % % %             if info, fprintf('Data type = long\n'); end
        % % %         end
        if info
            fprintf('Number of blocks: %d\n',data.header.file.nblocks);
            fprintf('Number of traces: %d\n',data.header.file.ntraces);
            fprintf('Number of points (real+imag) per block: %d\n',data.header.file.np);
        end

%         if data.header.file.nblocks>params.celem  %incomplete data set
%             data.header.file.nblocks = params.celem;
%         end
        d.real=zeros(data.header.file.nblocks,data.header.file.ntraces,data.header.file.np/2);
        d.imag=zeros(data.header.file.nblocks,data.header.file.ntraces,data.header.file.np/2);
        fseek(fileid,32,-1); % size of data.header.file = 32
        for i=1:data.header.file.nblocks
            %             if i>params.celem
            %                 d.real = squeeze(d.real(1:params.celem,:,:));
            %                 d.imag = squeeze(d.imag(1:params.celem,:,:));
            %                 size(d.real)
            %                 params.nt = squeeze(params.nt(1:params.celem));
            %                 params.arraydim = params.celem;
            %                 break;
            %             end
            fread(fileid,1,'short'); % scale=
            fread(fileid,1,'short'); % status=
            fread(fileid,1,'short'); % index=
            fread(fileid,1,'short'); % mode=
            fread(fileid,1,'long');     % ctcount=
            fread(fileid,1,'float'); % lpval=
            fread(fileid,1,'float'); % rpval=
            lvl=fread(fileid,1,'float'); % lvl=
            tlt=fread(fileid,1,'float'); % tlt=

            for j=1:data.header.file.ntraces
                %         fseek(fileid,data.header.file.nbheaders*28,0); % size of data.header.block = 28
                buffer=fread(fileid,data.header.file.np,precision);
                d.real(i,j,:)=buffer(1:2:data.header.file.np)-lvl;      % real part
                d.imag(i,j,:)=buffer(2:2:data.header.file.np)-tlt;      % imaginary part
            end
        end
    case {'fdf'} % ,'FDF','Fdf'} % ,'img','IMG','Img'}
        if strcmp(params.console{1},'inova')==1
            fileid=fopen(filename,'r','ieee-be');
        else
            fileid=fopen(filename,'r','l');
        end
        if fileid == -1
            errordlg(['Cannot open file: ' filename]);
            return
        else
            if info
                disp('***** READING VNMR DATA *****'); % disp(' ')
                disp(['Opening file  ' filename]);
            end
        end
        %% ----- read main header of fid file -----
        data.header.file=struct;
        line1 = textscan(fileid,'%s',1);
        line1 = char([line1{1}]);
        if strcmp(line1(1:2),'#!')==0
            errordlg('file is not of flexible data format (fdf)')
            return
        end
        paramformat='';
        while isempty(findstr(paramformat,'checksum'))==1
            paramformat = textscan(fileid,'%s',1);
            paramformat = char([paramformat{1}]);
            paramname=textscan(fileid,'%[^= ]',1);
            paramname = char([paramname{1}]);
            paramname(findstr(paramname,'['))='';
            paramname(findstr(paramname,']'))='';
            textscan(fileid,'%[=[] ]'); % '='
            paramvalue=textscan(fileid,'%[^;]',1);
            paramvalue = char([paramvalue{1}]);
            textscan(fileid,'%c',1); % =';'
            if strcmp(paramformat,'char')
                paramname(findstr(paramname,'*'))='';
                paramvalue(findstr(paramvalue,'"'))='''';
                paramvalue(findstr(paramvalue,''''))='';
            else
                if isempty(findstr(paramvalue,'{'))==0
                    paramvalue(findstr(paramvalue,'{'))='[';
                    paramvalue(findstr(paramvalue,'}'))=']';
                end
                paramvalue = str2num(paramvalue);
            end
            if strcmp(paramname,'checksum') % Is checksum read correctly????
                data.header.file=setfield(data.header.file,paramname,int32(paramvalue));
                break
            else
                data.header.file=setfield(data.header.file,paramname,paramvalue);
            end
        end
        paramvalue=textscan(fileid,'%c',1);
        paramvalue = char([paramvalue{1}]);
        if double(paramvalue)==12
            if info, disp('fdf header read!'); end
        else
            errordlg('fdf header could not be read!')
            return
        end

        precision = [data.header.file.storage num2str(data.header.file.bits)];
        if info
            fprintf('Matrix = Number of datapoints: %d x %d\n',data.header.file.matrix(1), data.header.file.matrix(2));
            fprintf('Resolution (ro x pe): %d x %d\n',data.header.file.ro_size,data.header.file.pe_size);
            fprintf('Data type: %s \n',precision);
        end
        offset = data.header.file.matrix(1)*data.header.file.matrix(2)*data.header.file.bits/8;
        status = fseek(fileid,-offset,'eof');

        if isempty(findstr(data.header.file.type,'absval'))==0
            d.abs = zeros(data.header.file.matrix);
            d.abs = fread(fileid, [data.header.file.matrix(1), data.header.file.matrix(2)], precision);%'float32')
        elseif isempty(findstr(data.header.file.type,'complex'))==0
            disp('reading complex data from fdf file')
            d.real = zeros(data.header.file.matrix./2,2);
            d.imag = zeros(data.header.file.matrix./2,2);
            for i=1:data.header.file.matrix(1)
                for j=1:data.header.file.matrix(2)
                    buffer = fread(fileid,1, precision);
                    d.real(i,j,:)=buffer(1)-data.header.block.lvl;      % real part
                    d.imag(i,j,:)=buffer(2)-data.header.block.tlt;      % imaginary part
                end
            end
        elseif isempty(findstr(data.header.file.type,'real'))==0
            disp('reading real data from fdf file not implemented')
        elseif isempty(findstr(data.header.file.type,'imag'))==0
            disp('reading imag data from fdf file not implemented')
        end
    otherwise
        errordlg('no data read')
        return
end

%% resortation of data according acqtype
resort=1;
if resort==1
    [data params] = sort_varian(data, d, params, filename, file_ext);
else
    data.multiplicity = data.header.file.nblocks;
    %      data.multiplicity = size(d.real,2);
    data.data=d;
end

%% output of status
if info
    s=dir(filename);
    if ftell(fileid)==s.bytes
        fprintf('Vnmr data read successfully until eof (%d bytes).\n', ftell(fileid));
    else
        fprintf('%d bytes of file read (filelength: %d bytes)\n',ftell(fileid), s.bytes);
    end
    fprintf('*****************************\n')
end

%% close file and return home
fclose(fileid);
cd(homedir);

