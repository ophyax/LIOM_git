function new_file = write_varian(params,data,filename_in,pathname_in)


homedir=pwd;
if nargin>=4
    cd(pathname_in);
end
if nargin<3
    filename_in='';
end

% -----------------------------------------------------------------------
%Select folder to write data
options.Resize='on';  % options for inputdlg
% if exist([pathname_in '\' filename_in],'dir')==7    
%     response = questdlg({'Do you want to use following folder to write to?'; ...
%         [pathname_in '\' filename_in]},'Save','Yes','No','Yes');
% end
response = 'Yes';
if strcmp(response,'Yes')
    pathname_new=pathname_in;
    filename_new=filename_in;    
else
    pathname_new=uigetdir(pathname_in);
    while pathname_new==0
        pathname_new = uigetdir('','Select folder to save fid',pathname_in);
    end
    filename_new={};
    while isempty(filename_new)
        filename_new = inputdlg('Please, put in the file name!','Save file',1,{filename_in},options);
    end
    filename_new=char(filename_new{1});
    if exist([pathname_new filesep filename_new])==7
        while exist([pathname_new filesep filename_new])==7 % is existing directory
            response = questdlg('Directory already exists! Should the content be overwriten?','Save','No','Yes','No');
            if strcmp(response,'Yes')
                break
            end
            pathname_new = uigetdir('','Save summed fid',pathname_new);
            filename_new = inputdlg('Please, put in file name!','Save file',1,{filename_new},options);
            if isempty(filename_new)
                filename_new = filename_in;
            end
            filename_new=char(filename_new{1});
        end
    else
        mkdir([pathname_new filesep filename_new]);
    end
end
% -----------------------------------------------------------------------
% !!! write 'params' into procpar !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% take selected procpar, copy to folder with new fid and write params into it

write_procpar([pathname_new filesep filename_new],params);

cd(homedir)

% write data into fid
fileid=fopen([pathname_new filesep filename_new filesep 'fid'],'w','ieee-be');
if fileid == -1
    errordlg(['Cannot open file: ' pathname_new filesep filename_new filesep 'fid']);
    return
else
    disp('***** Writing VNMR DATA *****'); disp(' ')
end
% ----- write main header of fid file -----
% ----- file header -----
nblocks=size(data.real,1);
fwrite(fileid,nblocks,'long'); % nblocks
ntraces=size(data.real,2);
fwrite(fileid,ntraces,'long'); % ntraces
fwrite(fileid,params.np,'long'); % np
one_elem = data.real(1,1,1);
data_s = whos('one_elem');
if data_s.bytes==2
    ebytes=2;
else
    ebytes=4;
end
fwrite(fileid,ebytes,'long'); % ebytes
fwrite(fileid,ebytes*params.np,'long'); % tbytes
nbheaders=1; % number of header per block
fwrite(fileid,(ntraces*ebytes*params.np+nbheaders*28),'long'); % bbytes (28=size of sturcture datablockhead)
fwrite(fileid,0,'short'); % vers_id
status=69;
fwrite(fileid,status,'short'); % status
fwrite(fileid,nbheaders,'long'); % nbheaders
% ----- block header -----
fwrite(fileid,0,'short'); % scale
fwrite(fileid,status,'short'); % status
fwrite(fileid,1,'short'); % index
fwrite(fileid,0,'short'); % mode
fwrite(fileid,params.ct,'long'); % ctcount
fwrite(fileid,params.lp,'float'); % lpval
fwrite(fileid,params.rp,'float'); % rpval
fwrite(fileid,params.lvl,'float'); % lvl
fwrite(fileid,params.tlt,'float'); % tlt
% ----- write data in blocks & traces ----
if (bitget(status,3)==0)
    if (bitget(status,2)==0)
        precision='short'; fprintf('Data type = short\n');
    else
        precision='float'; fprintf('Data type = float\n');
    end
end
if (bitget(status,3)==1)
    precision='long'; fprintf('Data type = long\n');
end

fseek(fileid,32,-1)
buffer=zeros(1,params.np);
for i=1:nblocks
    fwrite(fileid,0,'short'); % scale
    fwrite(fileid,status,'short'); % status
    fwrite(fileid,1,'short'); % index
    fwrite(fileid,0,'short'); % mode
    fwrite(fileid,params.ct,'long'); % ctcount
    fwrite(fileid,params.lp,'float'); % lpval
    fwrite(fileid,params.rp,'float'); % rpval
    fwrite(fileid,params.lvl,'float'); % lvl
    fwrite(fileid,params.tlt,'float'); % tlt
    for j=1:ntraces
        buffer(1:2:params.np)=data.real(i,j,:);      % real part
        buffer(2:2:params.np)=data.imag(i,j,:);      % imaginary part
        fwrite(fileid,buffer,precision);
    end
end

s=dir([pathname_new filesep filename_new filesep 'fid']);
nbytes_tot = nblocks*(ntraces*ebytes*params.np+nbheaders*28);

if ftell(fileid)==nbytes_tot
    fprintf('Vnmr data wrote successfully until eof (%d bytes).\n\n', ftell(fileid));
else
    fprintf('%d bytes of file wrote (filelength: %d bytes)\n\n',ftell(fileid), nbytes_tot);
end

% close file
fclose(fileid);

new_file=[pathname_new filesep filename_new filesep 'fid'];

