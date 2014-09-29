function param = rtp_varian(filename,printflag)
% read Varian procpar files; % input arguements: file or path to "procpar",
% printflag = 1 or 0 to output parameters or not

if nargin==1
    printflag=0;
end
if exist(filename)==7 % is it a directory or a file
    pathstr = filename;
else
    [pathstr, name, ext] = fileparts(filename);
end
d = dir(pathstr);
[tf, loc] = ismember({d.name},'procpar');
if sum(tf)>0
    filename = [pathstr filesep 'procpar'];
else
%     errordlg([pathstr '\procpar can not be found'])
    param = '';
    return
end

fileid = fopen(filename,'r','ieee-be');

if fileid==-1
    errordlg(['Cannot open file ' filename]);
    return
end

eofstat=0;
% fieldnum=1;
% param_str{1} = sprintf('name \t value');
procpar = struct;
while eofstat==0
    line1 = textscan(fileid,'%s %d %d %f64 %f64 %f64 %d %d %d %d %d',1);
%     param(fieldnum,1).name = line1{1};
    basictype=line1{3};
    if basictype==1 % real
        val_multi = textscan(fileid,'%n',1); % not specified
        value = cell2mat(textscan(fileid,'%n',val_multi{1})); %
        num_enumvalues = textscan(fileid,'%n',1);
        textscan(fileid,'%n',num_enumvalues{1});
    elseif basictype==2 % string
        val_multi = textscan(fileid,'%n');
        value = (textscan(fileid,'%q',val_multi{1}));
        num_enumvalues = textscan(fileid,'%n',1);
        textscan(fileid,'%q',num_enumvalues{1});
    end
    if isempty(char(line1{1}))==0
        try
        procpar=setfield(procpar,char(line1{1}),value);
        catch
            disp('stop')
        end
    end
%     param(fieldnum,1).value = value;
    eofstat = feof(fileid);
%     fieldnum=fieldnum+1;
end

param = procpar;
% disp([fieldnames(procpar) struct2cell(procpar)])
if printflag==1
    disp('rtp_varian: 64')
    disp([fieldnames(procpar) struct2cell(procpar)])
end
fclose(fileid);


