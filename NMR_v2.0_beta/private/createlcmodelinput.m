% createlcmodelinput.m
%
% prepare .RAW and .PLOTIN file for LCModel
%
% adapted from pgh Sep 2001

function status = createlcmodelinput(controlfile,params,lcm_idx,echo_switch)



% 
global yesall_plotin yesall_raw
% 
% if nargin<3
%     echo_switch=1;
% end
% 
% status=0;
% if echo_switch
%     fprintf('\n***** CREATING INPUT FILES (.CONTROL & .PLOTIN) FOR LCMODEL *****\n');
% end

mainhandles=guidata(findobj('Tag','mainmenu'));
handles = guidata(findobj('Tag','lcmodelfig'));

%% --- prepare filenames -------------------------------------------------

[path name] = fileparts(char(controlfile));
[restpath homedir dirext]= fileparts(path);
fidname=[homedir dirext];
% create filenames on server as written to *.CONTROL
targetfolder_str=get(findobj('Tag','lcmodelfig_edit_targetfolder'),'String'); 
if strcmp(targetfolder_str(length(targetfolder_str)),'/')
    targetfolder=[targetfolder_str fidname '/'];
else
    targetfolder=[targetfolder_str '/' fidname '/'];
end

%% filenames of local files 
 plotinfile_loc=[path filesep name '.PLOTIN'];
if exist(plotinfile_loc,'file') && isempty(handles.yesall.overwrite.plotin,'Yes to All')
    answer=questdlg({'Overwrite existing file:'; plotinfile_loc},'Overwrite File','Yes','Yes to All','No','Yes');
    if strcmp(answer,'No')
        status=1;
        handles.yesall.overwrite.plotin = '';
        return;
    elseif strcmp(answer,'Yes to All')
        handles.yesall.overwrite.plotin = answer;
    end
end
controlfile_loc = [path filesep name '.CONTROL'];

if exist(controlfile_loc,'file') && isempty(handles.yesall.overwrite.controlfile)
            answer=questdlg({'Overwrite existing file:'; controlfile_loc},'Overwrite File','Yes','Yes to All','No','Yes');

    if strcmp(answer,'No')
        handles.yesall.overwrite.controlfile = '';
        return;
    elseif strcmp(answer,'Yes to All')
        handles.yesall.overwrite.controlfile = 'Yes to All';
    end
end
 
%% filenames on server
rawfile = [targetfolder name '.RAW'];
reffile = [targetfolder name '.h2o'];
psfile = [targetfolder name '.PS'];
coordfile = [targetfolder name '.COORD'];
controlfile = [targetfolder name '.CONTROL'];
plotinfile=[targetfolder name '.PLOTIN'];


%% --- write files ---------------------------------------------------------
%% create .CONTROL file for LCModel

%% Read copy of original control file %%%TO BE IMPROVED!!!!!
fileid=fopen(controlfile_loc,'r');
eofstat=0;
i=0;
% fgetl(fileid)
while  eofstat==0
    i=i+1;

    orig{i} = fgetl(fileid);

    eofstat = feof(fileid);
end
fclose(fileid)


%% complete file path

i=1;
n = 5;
complete=0;

matrix.title=strfind(orig,'TITLE');
matrix.filps=strfind(orig,'FILPS');
matrix.filcoo=strfind(orig,'FILCOO');
matrix.filraw=strfind(orig,'FILRAW');
if strcmp(mainhandles.lcmodel.reffile{1},'')==0 %{lcm_idx}
    matrix.filh2o=strfind(orig,'FILH2O');
    idx.filh2o=1;
    flag.filh2o=0;
else
    n=n-1;
end


idx.title=1;
idx.filps=1;
idx.filcoo=1;
idx.filraw=1;


flag.title=0;
flag.filps=0;
flag.filcoo=0;
flag.filraw=0;



while complete<n && i<size(matrix.title,2)
    
    if isempty(matrix.title{i})==0 
        complete = complete+1;
        flag.title = 1;
    elseif flag.title == 0
        idx.title=idx.title+1;
    end
    
    if isempty(matrix.filps{i})==0 
        complete = complete+1;
        flag.filps = 1;
    elseif flag.filps == 0
        idx.filps=idx.filps+1;
    end
    
    if isempty(matrix.filcoo{i})==0 
        complete = complete+1;
        flag.filcoo = 1;
    elseif flag.filcoo == 0
        idx.filcoo=idx.filcoo+1;
    end
    
    if isempty(matrix.filraw{i})==0 
        complete = complete+1;
        flag.filraw = 1;
    elseif flag.filraw == 0
        idx.filraw=idx.filraw+1;
    end
    if isfield(matrix,'filh2o')
        if isempty(matrix.filh2o{i})==0
            complete = complete+1;
            flag.filh2o = 1;
        elseif flag.filh2o == 0
            idx.filh2o=idx.filh2o+1;
        end
    end
    i=i+1;
end

if complete ~= n
    errordlg('controlfile not created')
end


orig{idx.title} = [' TITLE = ''' char(name) ''''];
orig{idx.filps} = [' FILPS = ''' char(psfile) ''''];
orig{idx.filcoo} = [' FILCOO = ''' char(coordfile) ''''];
orig{idx.filraw} = [' FILRAW = ''' char(rawfile) ''''];
if isfield(matrix,'filh2o')
    orig{idx.filh2o} = [' FILH2O = ''' char(reffile) ''''];
end
% orig{idx.plotin} = ['TITLE = ''' char(generate) '''']

%% write control file
disp(controlfile_loc)
fileid=fopen(controlfile_loc,'w');
eofstat=0;
i=0;
% fgetl(fileid)
while  i<length(orig)
    i=i+1;
    fprintf(fileid,'%s\n',orig{i});
   
    eofstat = feof(fileid);
end
fclose(fileid);

% %% write command file
% [pathstr, name, ext] = fileparts(controlfile_loc);
% commandfile = [pathstr '\' 'run_lcmodel'];
% fileid2=fopen(commandfile,'w');
% fprintf(fileid2,'#!/bin/bash \n');
% fprintf(fileid2,'/home/lcmodel/.lcmodel/bin/lcmodel < %s',[name ext]);
% fclose(fileid2);

%% transfer by Winscp
disp('prepare fail to transfer to lcmodel')
% temp_path=['c:\matlab\NMR_gui\'];
% if ~isdir(temp_path)
%     mkdir(temp_path)
% end
[inpathstr, inname, inext] = fileparts(controlfile_loc);
sep=findstr(inpathstr,filesep);
lsep=length(sep);
cur_path = [inpathstr((sep(lsep)+1):length(inpathstr))];
temp_path = inpathstr(1:sep(lsep));
% copyfile([inpathstr '\*.CONTROL'],[temp_path cur_path '\']);
% copyfile([inpathstr '\*.RAW'],[temp_path cur_path '\']);
% try
% copyfile([inpathstr '\*.h2o'],[temp_path cur_path '\']);
% catch
% end


disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Transfer file to selected server and Run LCModel')
% 

winscp = mainhandles.lcmodel.winscp;
user = mainhandles.lcmodel.server.login;
pwd = mainhandles.lcmodel.server.pwd;
tfold = mainhandles.lcmodel.targetfolder;
[folder, file] = fileparts(winscp);
cd(folder)
[f_name, file_name, ext_name] = fileparts(controlfile);

% if strfind(tfold,' ')
%     disp('SPACE in the target folder, change it....')
%     return;
% end
if (strcmp(tfold(length(tfold)),'/'))~=1
    tfold=[tfold '/'];
end
% str1=' option batch on option confirm off';
% str2=[' open scp://' user ':' pwd '@lifmetserv5'  ' -timeout=180'];
% 
% str3=[' mkdir '  [tfold cur_path] ''];
% str4 = ;
% str5 =;
% str6=[' call /home/lcmodel/.lcmodel/bin/lcmodel < *' inext ''];
% str7=[' get *.PS *.COORD '  '\*'];
% strE=' ';
fid=fopen([temp_path cur_path filesep 'transfer_lcmodel.txt'],'wt');
fprintf(fid,'option batch on \n');
fprintf(fid,'option confirm off \n');
fprintf(fid,['open scp://%s:%s@' mainhandles.lcmodel.server.name ' -timeout=180\n'],user,pwd);
fprintf(fid,'mkdir "%s" \n',[tfold cur_path '/']);
fprintf(fid,'cd "%s" \n',[tfold cur_path '/']);
fprintf(fid,'put "%s" \n',  [temp_path cur_path filesep file_name '.RAW']);
fprintf(fid,'put "%s" \n',  [temp_path cur_path filesep file_name '.h2o']);
fprintf(fid,'put "%s" \n',  [temp_path cur_path filesep file_name '.CONTROL']);
fprintf(fid,'call /home/lcmodel/.lcmodel/bin/lcmodel < "%s%s" \n',inname,inext);
fprintf(fid,'call ps2pdf "%s" "%s" \n',[inname '.PS'],[inname '.pdf']);
% fprintf(fid,'get "%s.PS" "%s"  \n',file_name,[temp_path cur_path '\*']);
fprintf(fid,'get "%s.COORD" "%s"  \n',file_name,[temp_path cur_path filesep '*']);
fprintf(fid,'get "%s.pdf" "%s"  \n',file_name,[temp_path cur_path filesep '*']);
fprintf(fid,'rm *.*  \n');
fprintf(fid,'rmdir "%s" \n',[tfold cur_path '/']);

fprintf(fid,'close \n');
fprintf(fid,'exit');
fclose(fid);

dos(['WinSCP.com /script="' temp_path cur_path filesep 'transfer_lcmodel.txt"']);
% dos('WinSCP.com /open sftp://kunz:caudoz41@lifmetserv5.epfl.ch')

% copyfile([temp_path cur_path '\*'],inpathstr);
% rmdir([temp_path cur_path],'s');
cd(inpathstr);
disp(' ')
disp('Finish to transfer file to selected server')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')


%% generate .PLOTIN file for PlotRaw
% fileid=fopen(plotinfile_loc,'w');
% 
% fprintf(fileid,' $PLTRAW\n');
% fprintf(fileid,[' HZPPPM=' num2str(params.sfrq) '\n']); % = hzpppm
% fprintf(fileid,[' NUNFIL=' num2str(params.np/2) '\n']); % = nbpoints
% fprintf(fileid,[' DELTAT=' num2str(1/params.sw) '\n']);
% fprintf(fileid,' FILRAW=\''%s\''\n',rawfile);
% % fprintf(fileid,[' FILRAW=''' path '\' name '.RAW''\n']);
% fprintf(fileid,' FILRAW=\''%s\''\n',psfile);
% % fprintf(fileid,[' FILPS=''' path '\' name '.PS''\n']);
% fprintf(fileid,[' DEGZER=' num2str(-(params.rp+0.5*params.lp)) '\n']);
% fprintf(fileid,[' DEGPPM=' num2str(-(params.lp)/(params.sw/params.sfrq)) '\n']);
% fprintf(fileid,' $END\n');
% 
% fclose(fileid);
% if echo_switch
%     disp(['finished writing ' plotinfile_loc])
% end
status=1;
guidata(findobj('Tag','lcmodelfig'),handles);
