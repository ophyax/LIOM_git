function create_filelist(new_datadir)

% curhandles = guidata(findobj('Tag','filelistfig'));
mainhandles = guidata(findobj('Tag','mainmenu'));

% homedir=pwd;

if nargin==0
    if strcmp(mainhandles.startpath,'')
        % following is not necessary, since this is done in "initaliez_mainfig.m"
        
        try
            load([fileparts(which('create_filelist.m')) filesep 'session_log.mat']);
            startpath = sessionlog.startpaths; % 'C:\Kai\Kais EPFL\CIBM\Research\data\from 9.4T';
        catch
            startpath = pwd;
        end
    else
        startpath = mainhandles.startpath;
    end
    
    %%%%%%%%%%%%%%%% change to uigetfile to select multiple folder
    datadir = uigetdir(startpath,'Select directory containing data');%,x,y)
    if datadir==0
        return
    end
else
    if exist(new_datadir,'file')==2
        datadir=fileparts(new_datadir);
    elseif exist(new_datadir,'dir')==7
        datadir=new_datadir;
    else
        herr=errordlg('file or folder does not exist!');
        uiwait(herr)
        return
    end
end

%% write searchpath to sessionlog
mainhandles.startpath=datadir;

%%
datapath = genpath(datadir);
% if strcmp(computer,'PCWIN')
% pathseps = findstr(datapath,';');
% else
%     pathseps = findstr(datapath,':');
% end
pathseps = findstr(datapath,pathsep);

if isfield(mainhandles,'datalist')
    datalist=mainhandles.datalist;
    datacount=length(mainhandles.datalist)+1;
else
    datacount=1;
end

% if directory is a varian data directory, then it contains an "fid" and
% "Procpar" file
curdir=[datapath(1:pathseps(1)-1)];
cursearchpath = '';

for i=1:length(pathseps)
    if i==1
        curdir=datapath(1:pathseps(1)-1);
    else
        curdir=datapath(pathseps(i-1)+1:pathseps(i)-1);
    end
    % look for all files in that directory
    curdir_struct = dir(curdir);
    if isempty(find([curdir_struct.isdir]==0,1))==0 % search files
        file_idx = find([curdir_struct.isdir]==0);
        for j=1:length(file_idx)
            curfile=curdir_struct(file_idx(j)).name;
            [pathstr, name, ext] = fileparts(curfile);
            if (isempty(findstr(curfile,'.fid'))==0 || isempty(findstr(curfile,'.FID'))== 0)&&mainhandles.options.load.fid==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Varian';
                if isempty(findstr(curdir(length(curdir)-3:length(curdir)),'.sum'))==0 || ...
                        isempty(findstr(curdir(length(curdir)-3:length(curdir)),'.SUM'))==0
                    datalist(datacount).type = 'fid_sum';
                else
                    datalist(datacount).type = 'fid';
                end
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.fdf'))==0 || isempty(findstr(curfile,'.FDF'))==0)&&mainhandles.options.load.fdf==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path '\' datalist(datacount).filename];
                datalist(datacount).format='Varian';
                datalist(datacount).type = 'fdf';
                cursearchpath = [cursearchpath ';' curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.hdr'))==0 || isempty(findstr(curfile,'.HDR'))==0)&&mainhandles.options.load.analyse==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Analyse';
                datalist(datacount).type = 'analyse';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.nii'))==0 || isempty(findstr(curfile,'.NII'))==0)&&mainhandles.options.load.analyse==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='NIFTI';
                datalist(datacount).type = 'nifti';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.mat'))==0 || isempty(findstr(curfile,'.MAT'))==0)&&mainhandles.options.load.matlab==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Matlab';
                datalist(datacount).type = 'matlab';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
%             elseif isempty(findstr(curfile,'.nrrd'))==0 || isempty(findstr(curfile,'.NRRD'))==0
%                 datalist(datacount).path=curdir;
%                 datalist(datacount).filename=curfile;
%                 datalist(datacount).liststring=[datalist(datacount).path '\' datalist(datacount).filename];
%                 datalist(datacount).format='Nrrd';
%                 datalist(datacount).type = 'nrrd';
%                 cursearchpath = [cursearchpath ';' curdir];
%                 datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.dcm'))==0 || isempty(findstr(curfile,'.DCM'))==0)&&mainhandles.options.load.dicom==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='DICOM';
                datalist(datacount).type = 'dcm';
                datalist(datacount).acqtype = 'MRI';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.ima'))==0 || isempty(findstr(curfile,'.IMA'))==0)&&mainhandles.options.load.siemens==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Siemens';
                datalist(datacount).type = 'ima';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.rda'))==0 || isempty(findstr(curfile,'.RDA'))==0)&&mainhandles.options.load.siemens==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Siemens';
                datalist(datacount).type = 'rda';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(ext) && isempty(findstr(curfile,'procpar'))==1 && isempty(findstr(curfile,'text'))==1 ...
                     && isempty(findstr(curfile,'fid'))==1 && isempty(findstr(curfile,'log'))==1 ...
                     && isempty(findstr(curfile,'savepar'))==1 && isempty(findstr(curfile,'prop'))==1 ...
                     && isempty(findstr(curfile,'rx'))==1)&&mainhandles.options.load.siemens==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Siemens';
                datalist(datacount).type = 'dcm';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
            elseif (isempty(findstr(curfile,'.raw'))==0 || isempty(findstr(curfile,'.RAW'))==0)&&mainhandles.options.load.raw==1
                datalist(datacount).path=curdir;
                datalist(datacount).filename=curfile;
                datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
                datalist(datacount).format='Raw';
                datalist(datacount).type = 'raw';
                cursearchpath = [cursearchpath pathsep curdir];
                datacount=datacount+1;
%             elseif isempty(findstr(curfile,'.sdat'))==0 || isempty(findstr(curfile,'.SDAT'))==0
%                 datalist(datacount).path=curdir;
%                 datalist(datacount).filename=curfile;
%                 datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
%                 datalist(datacount).format='Philips';
%                 datalist(datacount).type = 'sdat';
%                 cursearchpath = [cursearchpath pathsep curdir];
%                 datacount=datacount+1;
%             elseif isempty(findstr(curfile,'.bruker'))==0 || isempty(findstr(curfile,'.BRUKER'))==0
%                 datalist(datacount).path=curdir;
%                 datalist(datacount).filename=curfile;
%                 datalist(datacount).liststring=[datalist(datacount).path filesep datalist(datacount).filename];
%                 datalist(datacount).format='Bruker';
%                 datalist(datacount).type = 'bruker';
%                 cursearchpath = [cursearchpath pathsep curdir];
%                 datacount=datacount+1;
            end
        end
    end
end

if isfield(mainhandles,'datapath')==0
    mainhandles.datapath=[];
end
if exist('datalist','var')
    mainhandles.datalist=datalist;
    mainhandles.datapath=[mainhandles.datapath cursearchpath];
    formatlist = unique(cellstr({datalist.format}));
    set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
%     if get(findobj('Tag','filelistfig_togglebutton_expandlist'),'Value')
%         set(findobj('Tag','filelistfig_listbox'),'String',mainhandles.liststr_expanded,...
%             'Max',length({mainhandles.liststr_expanded}),'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
%     else
        set(findobj('Tag','filelistfig_listbox'),'String',{datalist.liststring},'Max',length({datalist.liststring}),...
            'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
%     end
end


guidata(findobj('Tag','mainmenu'),mainhandles);
