function tablefile=read_petable(homedir,tablefile)
% read petable from file tablefile
% if necessary convert from ASCII to mat-file

global petable

if exist(tablefile,'file')==0
    if exist([homedir filesep 'private' filesep 'tablib' filesep tablefile],'file')==2
        tablefile=[homedir filesep 'private' filesep 'tablib' filesep tablefile];
    else
%         button = questdlg({[char(params.petable{1}) ' could not be found!'];...
        button = questdlg({[tablefile ' could not be found!'];...
            'Do you want to search it?'},'Missing petable','Yes','No','Yes');
        if strcmp(button,'Yes')
            
            [filename, pathname] = ...
                uigetfile({'*';'*.mat';'*.*'},['Search file ''' tablefile '.mat'' with Petable']);
            tablefile = [pathname filename];
            read_petable(homedir,tablefile);
        else
            return
        end
    end
end

[pathstr,name,ext]=fileparts(tablefile);
if strcmpi(ext,'.mat')
    load(tablefile)
elseif strcmpi(ext,'')
    
    newData1 = importdata(tablefile);

    % Create new variables in the base workspace from those fields.
    vars = fieldnames(newData1);
    for i = 1:length(vars)
        assignin('base', vars{i}, newData1.(vars{i}));
    end
    
    t1=newData1.data;
    
%     fid=fopen(tablefile);
%     tline=fgetl(fid);
%     t1=[];
%     while 1
%         tline=fgetl(fid);
%         if ~ischar(tline)   
%             break,   
%         end
%         t1=[t1; str2num(tline)];
%     end
%     fclose(fid);
end

if exist('t1','var')==0
    herr = errordlg(['petable ' tablefile ' could not be read!']);
    waitfor(herr);
    petable=0;
else
    petable=t1;
end


