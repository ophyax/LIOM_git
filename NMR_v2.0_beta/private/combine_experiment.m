function combine_experiment(handles)


%get mainhandles
mainhandles = guidata(findobj('Tag','mainmenu'));
filelisthandles = guidata(findobj('Tag','filelistfig'));

% get the selected experiment
sellist = handles.comb_idx';

if sum(sellist==0)>=1
    valid_idx = find(sellist~=0);
    sellist=sellist(valid_idx);
end

if sum([mainhandles.datalist(sellist).loaded]) ~=length(sellist)
    set(filelisthandles.filelistfig_listbox,'Value',sellist)
    get(filelisthandles.filelistfig_listbox,'Value')
    load_data('filelistfig')
    mainhandles=guidata(findobj('Tag','mainmenu'));
end



%% name of the new experiment
newfilename = handles.filename_cur;

if isfield(handles,'options') %not implemented yet
    name='Do you want to aplly the followin postprocessing?';
    prompt = {'Apply phase? (0/1)'
        'Apply normalisation (voxel size/gain/nt)? (0/1)'
        'Apply Apodization ? (0/1)'
        'Apply B0_calc ? (0/1)'
        'Apply DC_offset ? (0/1)'
        'Apply lsfid ? (0/1)'
        };
    def = {'0' '0' '0' '0' '0' '0'};
    correction = inputdlg(prompt,name,1,def);
else
    correction = {'0' '0' '0' '0' '0' '0'};
end


%% check compatibility
if length(sellist)>1
    % do consistency check!
    check_acqtype = unique({mainhandles.datalist(sellist).acqtype});
    %     check_nucleus = unique([mainhandles.datalist(sellist).nucleus]);
    check_np = unique([mainhandles.datalist(sellist).np]);
    if length(check_acqtype)~=1  %|| length(check_nucleus)~=1
        errordlg('Data cannot not be summed! Format is varying.')
        return
    end
    if length(check_np)~=1
        min_np = min(check_np)/2;
        disp('Warning: Number of acquisition points is varying')
    else
        min_np = check_np/2;
    end
else
    min_np = mainhandles.datalist(sellist).np/2;
end

%% calculate the final size of the new experiment
final_size=zeros([1 length(sellist)]);
for k=1:length(sellist)
    final_size(k) = size(mainhandles.datalist(1,sellist(k)).data.real,1);
    nt{k} = mainhandles.datalist(1,sellist(k)).params.nt';
    if final_size(k)~=length(nt{k})
        temp = cell2mat(nt(k));
        temp= repmat(temp,[1 final_size(k)]);
        nt(k) = {temp};
    end
end

%%copy the params to the new experiment
mainhandles.datalist(1,size(mainhandles.datalist,2)+1)=mainhandles.datalist(1,sellist(1));
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).data
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).path
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).multiplicity
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).filename
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).multiplicity
clear mainhandles.datalist(1,size(mainhandles.datalist,2)).time
mainhandles.datalist(1,size(mainhandles.datalist,2)).data.real=zeros(sum(final_size),size(mainhandles.datalist(1,sellist(1)).data.real,2),size(mainhandles.datalist(1,sellist(k)).data.real,3));
mainhandles.datalist(1,size(mainhandles.datalist,2)).data.imag=zeros(sum(final_size),size(mainhandles.datalist(1,sellist(1)).data.imag,2),size(mainhandles.datalist(1,sellist(k)).data.imag,3));


%% combine the experiments

for k=1:length(sellist)
    
    if sum(strcmp(correction,'1'))>=1
        
        dataidx = sellist(k);
        data.real = mainhandles.datalist(1,sellist(k)).data.real(:,:,1:min_np);
        data.imag = mainhandles.datalist(1,sellist(k)).data.imag(:,:,1:min_np);
        
        fid_length=length(squeeze(data.real(1,:))'); %=mainhandles.datalist(dataidx).np/2;
        t_vec = (0:(fid_length-1))./mainhandles.datalist(1,sellist(k)).spectralwidth;
        cut = round(fid_length/2);
        df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
        f_vec_shifted = df_vec.*((0:fid_length-1)'-cut);
        
        for m=1:mainhandles.datalist(dataidx).multiplicity
            temp.real= squeeze(data.real(m,:,:));
            temp.imag= squeeze(data.real(m,:,:));
            if strcmp(correction{1},'1')==1
                phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(m);
                phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(m);
                temp = phasing(temp,f_vec_shifted,phasecorr0,phasecorr1);
            end
            if strcmp(correction{3},'1')==0
                mainhandles.datalist(dataidx).process.apodizefct = 'exponential';
                mainhandles.datalist(dataidx).process.apodparam1 = 0;
                mainhandles.datalist(dataidx).process.apodparam2 = 0;
            end
            if strcmp(correction{4},'1')==0
                if isfield(mainhandles.datalist(dataidx).process,'B0')
                    mainhandles.datalist(dataidx).process  = rmfield(mainhandles.datalist(dataidx).process,'B0');
                end
            end
            if strcmp(correction{5},'1')==0
                mainhandles.datalist(dataidx).process.DCoffset  = 0;
            end
            if strcmp(correction{6},'1')==0
                mainhandles.datalist(dataidx).process.lsfid  = 0;
            end
            
            temp1 = postprocessing(temp,dataidx,m);
            
            if strcmp(correction{2},'1')==1
                normalisation = 1/(mainhandles.datalist(1,sellist(k)).params.nt(m)*mainhandles.datalist(1,sellist(k)).params.vox1*mainhandles.datalist(1,sellist(k)).params.vox2*mainhandles.datalist(1,sellist(k)).params.vox3)*exp((60-mainhandles.datalist(1,sellist(k)).params.gain)*log(10)/20);
                [normalisation max(max(real(temp.real))) max(max(real(temp.real)))*normalisation]
            else
                normalisation = 1;
            end
            data.real(m,:,:) = temp.real'.*normalisation;
            data.imag(m,:,:) = temp.real'.*normalisation;
        end
    else
        data.real = mainhandles.datalist(1,sellist(k)).data.real(:,:,1:min_np);
        data.imag = mainhandles.datalist(1,sellist(k)).data.imag(:,:,1:min_np);
        normalisation = 1;
    end
    
    mainhandles.datalist(1,size(mainhandles.datalist,2)).data.real((sum(final_size(1:(k-1)))+1):sum(final_size(1:k)),:,:)=data.real;
    mainhandles.datalist(1,size(mainhandles.datalist,2)).data.imag((sum(final_size(1:(k-1)))+1):sum(final_size(1:k)),:,:)=data.imag;
end
if sum(strcmp(correction,'1'))>=1
    
    if strcmp(correction{1},'1')==1
        for j=1:sum(final_size)
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.phasecorr0(j)=0;
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.phasecorr1(j)=0;
        end
    end
    if strcmp(correction{3},'1')==1
        for j=1:sum(final_size)
            
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodizefct = 'exponential';
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodparam1=0;
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodparam2=0;
            mainhandles.datalist(1,size(mainhandles.datalist,2)).process.lsfid=0;
            
        end
    end
else
    for j=1:length(sellist)
        for n = 1:final_size(j)
            try
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.phasecorr0(n) = mainhandles.datalist(1,sellist(j)).process.phasecorr0(n);%n+sum(final_size(1:(j-1)))
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.phasecorr1 = mainhandles.datalist(1,sellist(j)).process.phasecorr1(n);
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodizefct = mainhandles.datalist(1,sellist(j)).process.apodizefct;
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodparam1 = mainhandles.datalist(1,sellist(j)).process.apodparam1;
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.apodparam2 = mainhandles.datalist(1,sellist(j)).process.apodparam2;
                mainhandles.datalist(1,size(mainhandles.datalist,2)).process.lsfid = mainhandles.datalist(1,sellist(j)).process.lsfid;
            catch
                %                 disp('combine_experiment: 179')
            end
        end
    end
end




%% correct the parameters
c=(clock);
time=[num2str(c(4)) ':' num2str(c(5)) ':' num2str(round(c(6)))];
mainhandles.datalist(1,size(mainhandles.datalist,2)).time = [date ' ' time];
mainhandles.datalist(1,size(mainhandles.datalist,2)).params.nt = cell2mat(nt)';
mainhandles.datalist(1,size(mainhandles.datalist,2)).multiplicity = sum(final_size);%size(mainhandles.datalist(1,size(mainhandles.datalist,2)).params.nt,1);
sum(final_size)
%%write to fid format the combine experiment
if strcmp(mainhandles.datalist(size(mainhandles.datalist,2)).format,'Varian')
    
    separetor = strfind( mainhandles.datalist(1,sellist(k)).path,filesep);
    mainhandles.datalist(1,size(mainhandles.datalist,2)).path=[char(mainhandles.datalist(1,sellist(k)).path(1:(separetor(length(separetor))-1)))];
    %     mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring = [char(mainhandles.datalist(1,size(mainhandles.datalist,2)).path) char(mainhandles.datalist(1,size(mainhandles.datalist,2)).filename)];
    
    
    
    mainhandles.datalist(size(mainhandles.datalist,2)).format = 'Matlab';
    
    datadir = mainhandles.datalist(1,size(mainhandles.datalist,2)).path
    
    [pathstr, name, ext] = fileparts(newfilename);
    if isempty(ext) || strcmp(ext,'.mat')==0
        newfilename = [name '.mat']
    end
    mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring = [datadir filesep newfilename];
    mainhandles.datalist(1,size(mainhandles.datalist,2)).filename=newfilename;
    
    
    study = mainhandles.datalist(size(mainhandles.datalist,2));
    
    save([datadir filesep newfilename],'study')
    mainhandles.datapath=[mainhandles.datapath pathsep datadir];
    formatlist = unique(cellstr({mainhandles.datalist.format}));
    set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
    
    set(findobj('Tag','filelistfig_listbox'),'Max',length({mainhandles.datalist.liststring}));
    
    set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring});
    set(findobj('Tag','filelistfig_listbox'),'Value',(size(mainhandles.datalist,2)));
    
    guidata(findobj('Tag','filelistfig'),filelisthandles);
    guidata(findobj('Tag','mainmenu'),mainhandles);
    updatedata(size(mainhandles.datalist,2));
    set(findobj('Tag','filelistfig_listbox'),'Value',(size(mainhandles.datalist,2)));
    
    
    
    
    
    
    
    
    
    
    
    
    
    %% to write in vaRIAN FORMAT
    %     [pathstr, name, ext] = fileparts(newfilename);
    %     if isempty(ext) || strcmp(ext,'.fid')==0
    %         newfilename = [name '.fid']
    %     end
    %     mainhandles.datalist(1,size(mainhandles.datalist,2)).path = [mainhandles.datalist(1,size(mainhandles.datalist,2)).path '\' newfilename];
    %     mainhandles.datalist(1,size(mainhandles.datalist,2)).filename='fid';
    %     datadir = mainhandles.datalist(1,size(mainhandles.datalist,2)).path;
    %     newfilename = mainhandles.datalist(1,size(mainhandles.datalist,2)).filename;
    %     comparams = mainhandles.datalist(1,size(mainhandles.datalist,2)).params;
    %     data_sum = mainhandles.datalist(1,size(mainhandles.datalist,2)).data;
    %
    %     if exist(datadir)==0
    %         mkdir(datadir);
    %     end
    %     disp('HERE HERE')
    %
    %     copyfile([mainhandles.datalist(sellist(1)).path '\procpar'],datadir);
    %     copyfile([mainhandles.datalist(sellist(1)).path '\text'],datadir);
    %     new_file = write_varian(comparams,data_sum,newfilename,datadir);
    %     mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring = [datadir '\' newfilename];
    %
    %     mainhandles.datapath=[mainhandles.datapath ';' datadir];
    %     formatlist = unique(cellstr({mainhandles.datalist.format}));
    %     set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
    % %     if get(findobj('Tag','filelistfig_togglebutton_expandlist'),'Value')
    % %         set(findobj('Tag','filelistfig_listbox'),'String',mainhandles.liststr_expanded,...
    % %             'Max',length({mainhandles.liststr_expanded}),'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
    % %     else
    %                 set(findobj('Tag','filelistfig_listbox'),'Max',length({mainhandles.datalist.liststring}));
    %
    %                 set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring});
    %
    %                 set(findobj('Tag','filelistfig_listbox'),'Value',(size(mainhandles.datalist,2)));
    %
    % %     end
    %
    %
    % %     create_filelist([datadir '\' newfilename])
    %     guidata(findobj('Tag','filelistfig'),filelisthandles);
    %     guidata(findobj('Tag','mainmenu'),mainhandles);
    %     updatedata(size(mainhandles.datalist,2));
    
else %strcmp(mainhandles.datalist(size(mainhandles.datalist,2)).format,'Siemens') || strcmp(mainhandles.datalist(size(mainhandles.datalist,2)).format,'Matlab')
    mainhandles.datalist(1,size(mainhandles.datalist,2)).path=[char(mainhandles.datalist(1,sellist(k)).path)];
    datadir = mainhandles.datalist(1,size(mainhandles.datalist,2)).path;
    
    [pathstr, name, ext] = fileparts(newfilename);
    if isempty(ext) || strcmp(ext,'.mat')==0
        newfilename = [name '.mat']
    end
    mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring = [datadir filesep newfilename];
    mainhandles.datalist(1,size(mainhandles.datalist,2)).filename=newfilename;
    mainhandles.datalist(1,size(mainhandles.datalist,2)).format = 'Matlab';
%     mainhandles.datalist(1,size(mainhandles.datalist,2)).type = 'Matlab';
    
    study = mainhandles.datalist(size(mainhandles.datalist,2));
    
    save([datadir filesep newfilename],'study')
    
    %     mainhandles.datalist=datalist;
    mainhandles.datapath=[mainhandles.datapath pathsep datadir];
    formatlist = unique(cellstr({mainhandles.datalist.format}));
    set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
    %     if get(findobj('Tag','filelistfig_togglebutton_expandlist'),'Value')
    %         set(findobj('Tag','filelistfig_listbox'),'String',mainhandles.liststr_expanded,...
    %             'Max',length({mainhandles.liststr_expanded}),'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
    %     else
    set(findobj('Tag','filelistfig_listbox'),'Max',length({mainhandles.datalist.liststring}));
    
    set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring});
    set(findobj('Tag','filelistfig_listbox'),'Value',(size(mainhandles.datalist,2)));
    
    %     end
    
    %     create_filelist([datadir '\' newfilename])
    guidata(findobj('Tag','filelistfig'),filelisthandles);
    guidata(findobj('Tag','mainmenu'),mainhandles);
    updatedata(size(mainhandles.datalist,2));
    set(findobj('Tag','filelistfig_listbox'),'Value',(size(mainhandles.datalist,2)));
    
end

% study.data

% fid2RAW(mainhandles.datalist(1,size(mainhandles.datalist,2)).liststring, mainhandles.datalist(1,size(mainhandles.datalist,2)).data,mainhandles.datalist(1,size(mainhandles.datalist,2)).params);

%% save mainhandles
guidata(findobj('Tag','mainmenu'),mainhandles);
disp('FIN combine')

get(findobj('Tag','filelistfig_listbox','Value','Max'))


