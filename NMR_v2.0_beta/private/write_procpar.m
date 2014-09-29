function write_procpar(filepath,params,prototype_procpar)

% get another procpar to write the values from 'params' into this 'procpar_orig'
if exist([filepath, [filesep 'procpar']],'file')==0
    if nargin==3 && exist(prototype_procpar)
        copyfile(prototype_procpar,[prototype_procpar, '_orig']);
    else
        [FileName,PathName] = uigetfile('*.*','Select parameter file to be adapted for current fid');
        prototype_procpar = [PathName FileName];
%         mkdir([filepath, '\procpar_orig']); %%added
        copyfile(prototype_procpar,[filepath, [filesep 'procpar_orig']]);
    end
else
    copyfile([filepath, [filesep 'procpar']],[filepath, [filesep 'procpar_orig']]);
end

filename = [filepath, [filesep 'procpar']];

% open new procpar for writing
fileid_w = fopen(filename,'w','ieee-be');
if fileid_w==-1
    errordlg(['Cannot open file ' filename]);
    return
end
% open old procpar (='procpar_orgi') for reading
fileid_r = fopen([filename '_orig'],'r','ieee-be');
if fileid_r==-1
    errordlg(['Cannot open file ' filename]);
    return
end

eofstat=0;
% fieldnum=1;
% param_str{1} = sprintf('name \t value');
% procpar = struct;
paramfields = fieldnames(params);
while eofstat==0
    filepos=ftell(fileid_r);
    line1 = textscan(fileid_r,'%s %d %d %f64 %f64 %f64 %d %d %d %d %d \n',1);
    basictype=line1{3};
    paramname=char(line1{1});

    fprintf(fileid_w,'%s ',char(line1{1}));
    fprintf(fileid_w,'%d ',line1{2});
    fprintf(fileid_w,'%d ',line1{3});
    fprintf(fileid_w,'%g ',line1{4});
    fprintf(fileid_w,'%g ',line1{5});
    fprintf(fileid_w,'%g ',line1{6});
    fprintf(fileid_w,'%d ',line1{7});
    fprintf(fileid_w,'%d ',line1{8});
    fprintf(fileid_w,'%d ',line1{9});
    fprintf(fileid_w,'%d ',line1{10});
    fprintf(fileid_w,'%d \n',line1{11});

    if isempty(paramname)==0 && isempty(find(ismember(paramfields,paramname)==1,1))==0
        curvalue = eval(['params.', paramfields{find(ismember(paramfields,paramname)==1)}]);
        if basictype==1 % real
            if strcmp(paramname,'nt')==1
                val_multi_r = textscan(fileid_r,'%n ',1);
                val_multi = {length(curvalue)};
                fprintf(fileid_w,'%d ',val_multi{1});
                for i=1:cell2mat(val_multi)
                        fprintf(fileid_w,'%g ',curvalue(i));
                                         
                end
                 for i=1:cell2mat(val_multi_r)
                        
                        value = textscan(fileid_r,'%n',1);                  
                end
                
            elseif strcmp(paramname,'arraydim')==1
                val_multi = textscan(fileid_r,'%n ',1); % not specified
                fprintf(fileid_w,'%d ',val_multi{1});
                curvalue=length(params.nt);
                for i=1:cell2mat(val_multi)
                        fprintf(fileid_w,'%g ',curvalue(i));
                        value = textscan(fileid_r,'%n',1);
                end
                elseif strcmp(paramname,'celem')==1
                val_multi = textscan(fileid_r,'%n ',1); % not specified
                fprintf(fileid_w,'%d ',val_multi{1});
                curvalue=length(params.nt);
                for i=1:cell2mat(val_multi)
                        fprintf(fileid_w,'%g ',curvalue(i));
                        value = textscan(fileid_r,'%n',1);
                end
            elseif (strcmp(paramname,'arraydim')==0 && strcmp(paramname,'nt')==0 && strcmp(paramname,'celem')==0)
                val_multi = textscan(fileid_r,'%n ',1); % not specified
                fprintf(fileid_w,'%d ',val_multi{1});
                for i=1:cell2mat(val_multi)
                        fprintf(fileid_w,'%g ',curvalue(i));
                        value = textscan(fileid_r,'%n',1);
                end
            end


            fprintf(fileid_w,'\n');
            num_enumvalues = textscan(fileid_r,'%n',1);
            lastline=textscan(fileid_r,'%n',num_enumvalues{1});
            fprintf(fileid_w,'%d ',num_enumvalues{1});
            if cell2mat(num_enumvalues)>0
                for i=1:cell2mat(num_enumvalues)
                    try
                        fprintf(fileid_w,'%d ',cell2mat(lastline{i}));
                    catch
                        disp('stop')
                    end
                end
            end
        elseif basictype==2 % string
            val_multi = textscan(fileid_r,'%n ',1);
            fprintf(fileid_w,'%d ',val_multi{1});
            for i=1:cell2mat(val_multi)
                if strcmp(paramname,'time_run')==1
                    c=(clock);
                    dd = datevec(date)
                    annee=num2str(dd(1));
                    if dd(2)<10
                        mois = ['0' num2str(dd(2))];
                    else
                        mois = num2str(dd(2));
                    end
                    if dd(3)<10
                        jour = ['0' num2str(dd(3))];
                    else
                        jour = num2str(dd(3));
                    end
                    temps=[num2str(c(4))  num2str(c(5)) num2str(round(c(6)))];
                    dd1 = [annee mois jour 'T' temps]
                    fprintf(fileid_w,'%s \n',['"' char(dd1) '"']);
                    value = textscan(fileid_r,'%q',1);
                else
                    fprintf(fileid_w,'%s \n',['"' char(curvalue{1}(i)) '"']);
                    value = textscan(fileid_r,'%q',1);
                end
            end
            num_enumvalues = textscan(fileid_r,'%n',1);
            lastline=textscan(fileid_r,'%q ',num_enumvalues{1});
            fprintf(fileid_w,'%d ',num_enumvalues{1});
            for i=1:cell2mat(num_enumvalues)
                fprintf(fileid_w,'%s ',['"' char(lastline{1}(i)) '"']);
            end
        end
        fprintf(fileid_w,'\n');
    end
    eofstat = feof(fileid_r);
end
disp('***** procpar is written *****')
filepos_r=ftell(fileid_r)
filepos_w=ftell(fileid_w)
fclose(fileid_r);
fclose(fileid_w);

delete([filepath, [filesep 'procpar_orig']])