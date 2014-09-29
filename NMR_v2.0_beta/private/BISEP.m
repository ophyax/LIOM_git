% ddfunction data_sum = add_fid
%adding up selected spectra WITHOUT normalisation
function BISEP(varargin)
mainhandles=guidata(findobj('Tag','mainmenu'));

filelisthandles=guidata(findobj('Tag','filelistfig'));

if nargin
    filelisthandles=guidata(findobj('Tag','filelistfig'));
    data_idx = get(filelisthandles.filelistfig_listbox,'Value');
else
    data_idx = mainhandles.dispopts.dataidx;
end

ntraces=size(mainhandles.datalist(data_idx(1)).data.real,2);%header.file.ntraces;
np_half=size(mainhandles.datalist(data_idx(1)).data.real,3);%header.file.np/2;




%% --- start summation ----------------------------------------
time_allacq=0; addcount=0;
comparams=mainhandles.datalist(data_idx(1)).params;
nt=comparams.nt;
N_aver = inputdlg('Enter number of fid files:','BISEP',1,{'2'});
N_aver=str2num(N_aver{1});
mult=mainhandles.datalist(data_idx(1)).multiplicity;


if (mult/(2*N_aver)-round(mult/(2*N_aver)))~=0
    mult=2*floor(mult/(2*N_aver))*N_aver;
%     fprintf('Only the %d first FID are processed',mult)
%     fprintf('total number of fid %d is not divisible by %d',mult,N_aver)
%     return;
end
sel_idx=2:2:mult;

sel_idx_N =reshape(sel_idx,N_aver,ceil(mult/(2*N_aver)));
sel_idx_P =sel_idx_N-1;

data_SUB.real=zeros(1,size(sel_idx_N,2),np_half);
data_SUB.imag=zeros(1,size(sel_idx_N,2),np_half);

data_NEG.real=zeros(1,size(sel_idx_N,2),np_half);
data_NEG.imag=zeros(1,size(sel_idx_N,2),np_half);

try
        lsfid = mainhandles.datalist(data_idx(1)).process.lsfid;
catch
        lsfid=0;
end

try
    apodizefct = mainhandles.datalist(data_idx(1)).process.apodizefct;
    apodparam1 = mainhandles.datalist(data_idx(1)).process.apodparam1;
    apodparam2 = mainhandles.datalist(data_idx(1)).process.apodparam2;
catch
    apodizefct = 'exponential';
    apodparam1 = 0;
    apodparam2 = 0;

end

mainhandles.datalist(data_idx(1)).process.apodizefct = 'exponential';
mainhandles.datalist(data_idx(1)).process.apodparam1 = 0;
mainhandles.datalist(data_idx(1)).process.apodparam2 = 0;
mainhandles.datalist(data_idx(1)).process.lsfid = 0;
guidata(findobj('Tag','mainmenu'),mainhandles)

for i=1:mult
    
        try
            %store postprocess param
            try
                phasecorr0(i) = mainhandles.datalist(data_idx(1)).process.phasecorr0(i);
                phasecorr1(i) = mainhandles.datalist(data_idx(1)).process.phasecorr1(i);
            catch
                phasecorr0(i) = 0;
                phasecorr1(i) = 0;
            end
            %replace with param for summation: no apod, no phase, no lsfid
            mainhandles.datalist(data_idx(1)).process.phasecorr(i) = 0;
            mainhandles.datalist(data_idx(1)).process.phasecorr1(i) = 0;
            guidata(findobj('Tag','mainmenu'),mainhandles)
           
            
            temp(i).real =  squeeze(mainhandles.datalist(data_idx(1)).data.real(i,:,:));
            temp(i).imag =  squeeze(mainhandles.datalist(data_idx(1)).data.imag(i,:,:));
            
%             temp_NEG(i).real =  squeeze(mainhandles.datalist(data_idx(1)).data.real(k,:,:));
%             temp_NEG(i).imag =  squeeze(mainhandles.datalist(data_idx(1)).data.imag(k,:,:));
%             
            
            
            data_post(i) = postprocessing(squeeze(temp(i)),data_idx(1),i);
%             data_N(i) = postprocessing(squeeze(temp_NEG(i)),data_idx(1),k);
            
%             isequal(data_P(i),data_N(i))
%             data_SUB.real(1,:,:)=squeeze(data_SUB.real(1,:,:))+data_P(i).real;
%             data_SUB.imag(1,:,:)=squeeze(data_SUB.imag(1,:,:))+data_P(i).real;
%             data_NEG.real(1,:,:)=squeeze(data_NEG.real(1,:,:))+data_N(i).real;
%             data_NEG.imag(1,:,:)=squeeze(data_NEG.imag(1,:,:))+data_N(i).imag;
%             isequal(data_SUB.real,data_NEG.real)

%             clear data_P data_N temp_POS temp_NEG
        catch
            disp(i)
%             disp(k)
            errordlg('3Data cannot not be summed! Format is varying.')
            return
        end
    end

   
  for n_file=1:size(sel_idx_N,2)
    data_SUB.real(1,n_file,:)= sum(-[data_post(sel_idx_P(:,n_file)).real],2)+sum([data_post(sel_idx_N(:,n_file)).real],2);
    data_SUB.imag(1,n_file,:)= sum(-[data_post(sel_idx_P(:,n_file)).imag],2)+sum([data_post(sel_idx_N(:,n_file)).imag],2);
    data_NEG.real(1,n_file,:)= sum([data_post(sel_idx_N(:,n_file)).real],2);
    data_NEG.imag(1,n_file,:)= sum([data_post(sel_idx_N(:,n_file)).imag],2);
    type={'ADD' 'SUB'};
    for m=1:2
        comparams.nt = m*sum(nt(sel_idx_N(:,n_file)));
        
        comparams.arraydim=1;
        comparams.lsfid=lsfid(1);
        
        homedir=pwd;
        cd([mainhandles.datalist(data_idx(1)).path '\..'])
        datadir=pwd;
        cd(homedir)
        
        strlengths=zeros(1,length(data_idx));
        for kj=1:length(data_idx)
            filelist{kj} = mainhandles.datalist(1,data_idx(1)).liststring;
            strlengths(kj)=length(mainhandles.datalist(1,data_idx(1)).liststring);
        end
        strlength=max(strlengths);
        
        filelist_num=zeros(length(data_idx),strlength);
        for kj=1:length(data_idx)
            filelist_num(kj,1:strlengths(kj))=double(char(mainhandles.datalist(1,data_idx(1)).liststring));
        end
        
        %-------------------------------------------------------------------------
        
        % All following steps are adapted to Varian folder structure!!!!!!!!!!!!!!
        comstr_idx=find(std(filelist_num,1,1)==0);
        comstr=char(filelist(min(find(strlengths==strlength))));
        comstr=comstr(min(comstr_idx):max(comstr_idx));
        comstr=comstr(1:max(findstr(comstr,'\'))-1);
        
        comfilename=comstr(find(std([double(datadir) zeros(1,length(comstr)-length(datadir)); double(comstr)],1,1)));
        comfilename=regexprep(comfilename,'\','');
        comfilename=regexprep(comfilename,'.fid','');
        
        sum_idx =size(mainhandles.datalist,2)+1;
        mainhandles.datalist(1,sum_idx)=mainhandles.datalist(1,data_idx(1));
        mainhandles.datalist(1,sum_idx).data= rmfield(mainhandles.datalist(1,sum_idx).data,'real');
        mainhandles.datalist(1,sum_idx).data= rmfield(mainhandles.datalist(1,sum_idx).data,'imag');
      
       mainhandles.datalist(1,sum_idx).liststring=[];
        %     clear mainhandles.datalist(1,size(mainhandles.datalist,2)).path
        mainhandles.datalist(1,sum_idx).multiplicity=[];
        mainhandles.datalist(1,sum_idx).filename=[];
       mainhandles.datalist(1,sum_idx).time=[];
       if isfield(mainhandles.datalist(1,sum_idx).process,'B0nmr')
      mainhandles.datalist(1,sum_idx).process= rmfield(mainhandles.datalist(1,sum_idx).process,'B0');
       end
      if isfield(mainhandles.datalist(1,sum_idx).process,'ECC')
      mainhandles.datalist(1,sum_idx).process= rmfield(mainhandles.datalist(1,sum_idx).process,'ECC');
     end
        c=(clock);
        time=[num2str(c(4)) ':' num2str(c(5)) ':' num2str(round(c(6)))];
        mainhandles.datalist(1,sum_idx).time = [date ' ' time];
        if m==1
            mainhandles.datalist(1,sum_idx).data.real(1,1,:) = data_NEG.real(1,n_file,:);
            mainhandles.datalist(1,sum_idx).data.imag(1,1,:) = data_NEG.imag(1,n_file,:);
        elseif m==2
            mainhandles.datalist(1,sum_idx).data.real(1,1,:) = data_SUB.real(1,n_file,:);
            mainhandles.datalist(1,sum_idx).data.imag(1,1,:) = data_SUB.imag(1,n_file,:);
        end
        size(mainhandles.datalist(1,sum_idx).data.imag(1,1,:))
       size(mainhandles.datalist(1,sum_idx).data.real(1,1,:))

        mainhandles.datalist(1,sum_idx).multiplicity = 1;
        mainhandles.datalist(1,sum_idx).params = comparams;
        
        
        newfilename = [type{m} '_' mainhandles.datalist(1,data_idx(1)).filename '_' num2str(sel_idx_N(1,n_file)/2) '-' num2str(sel_idx_N(N_aver,n_file)/2)];
        newfilename=strrep(newfilename,'.mat','');
        [pathstr, name, ext] = fileparts(newfilename);
        if isempty(ext) || strcmp(ext,',.mat')==0
            newfilename = [name '.mat']
        end
        
        
        mainhandles.datalist(1,sum_idx).filename = newfilename;
        mainhandles.datalist(1,sum_idx).liststring = [mainhandles.datalist(1,data_idx(1)).path '\' newfilename];
        
        
        datadir = mainhandles.datalist(1,sum_idx).path;
        
        mainhandles.datalist(1,sum_idx).process.lsfid=lsfid(1);
        mainhandles.datalist(sum_idx).format = 'Matlab';
        study = mainhandles.datalist(sum_idx);
        
        save([datadir '\' newfilename],'study');
        
        %     mainhandles.datalist=datalist;
        mainhandles.datapath=[mainhandles.datapath ';' datadir];
        formatlist = unique(cellstr({mainhandles.datalist.format}));
        set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
        % if get(findobj('Tag','filelistfig_togglebutton_expandlist'),'Value')
        %     set(findobj('Tag','filelistfig_listbox'),'String',mainhandles.liststr_expanded,...
        %         'Max',length({mainhandles.liststr_expanded}),'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
        % else
        set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring},'Max',length({mainhandles.datalist.liststring}),...
            'Value',size(mainhandles.datalist,2));
        % end
        guidata(findobj('Tag','filelistfig'),filelisthandles);
        guidata(findobj('Tag','mainmenu'),mainhandles);
    end
    clear data_SUB data_NEG
end
mainhandles.dispopts.dataidx = sum_idx;
mainhandles.dispopts.arrayidx = 1;



%% restore parameters
try
    for i=1:length(data_idx)
        
        mainhandles.datalist(data_idx(1)).process.apodizefct = apodizefct{i,:};
        mainhandles.datalist(data_idx(1)).process.apodparam1 = apodparam1(i);
        mainhandles.datalist(data_idx(1)).process.apodparam2 = apodparam2(i);
        mainhandles.datalist(data_idx(1)).process.phasecorr = phasecorr0(i);
        mainhandles.datalist(data_idx(1)).process.phasecorr1 = phasecorr1(i);
        mainhandles.datalist(data_idx(1)).process.lsfid = lsfid(i);
        disp(mainhandles.datalist(data_idx(1)).process.lsfid)
        
    end
catch
    disp('add_fid: restore parameters')
end


guidata(findobj('Tag','filelistfig'),filelisthandles);
guidata(findobj('Tag','mainmenu'),mainhandles);


updatedata(size(mainhandles.datalist,2));
displaycontrol;



