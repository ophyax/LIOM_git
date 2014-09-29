% ddfunction data_sum = add_fid
%adding up selected spectra WITHOUT normalisation
function add_fid(varargin)
mainhandles=guidata(findobj('Tag','mainmenu'));

filelisthandles=guidata(findobj('Tag','filelistfig'));

if nargin
    filelisthandles=guidata(findobj('Tag','filelistfig'));
    data_idx = get(filelisthandles.filelistfig_listbox,'Value');
else
    data_idx = mainhandles.dispopts.dataidx;
end

% try
% filelisthandles=guidata(findobj('Tag','filelistfig'));
%
% filelistidx = get(filelisthandles.filelistfig_listbox,'Value');
% filelist_tot = get(filelisthandles.filelistfig_listbox,'String');
% catch
%     GUI_Filelist
%     filelisthandles=guidata(findobj('Tag','filelistfig'));
%
%     filelistidx = get(filelisthandles.filelistfig_listbox,'Value');
%     filelist_tot = get(filelisthandles.filelistfig_listbox,'String');
%
% end
%
% filelist={filelist_tot{filelistidx}};
% data_idx=[];
% array_idx=[];
% if length(filelist_tot)>max(size(mainhandles.datalist)) % = expanded list
%     for i=1:length(filelist)
%         curfile=filelist{i};
%         cutidx=max(strfind(curfile,'_'));
%         curfilestr=curfile(1:cutidx-1);
%         [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
%         data_idx=[data_idx; idx];
%         array_idx=[array_idx str2double(curfile(cutidx+1:length(curfile)))];
%     end
% else
%     for i=1:length(filelist)
%         curfilestr=filelist{i};
%         [tf idx]=ismember(curfilestr,{mainhandles.datalist.liststring});
%         data_idx=[data_idx; idx];
%     end
% end

% data_idx = mainhandles.dispopts.dataidx;

% if mainhandles.dispopts.dataidx ~= data_idx
%     button = questdlg('Displayed data differ from filelist','Error','Displayed','Filelist','Displayed');
%     if strcmp(button,'Displayed')==1
%         clear data_idx filelist;
% data_idx = mainhandles.dispopts.dataidx;
% filelist{1} = mainhandles.datalist(1,data_idx).liststring;
% filelistidx = 1;
%     end
% end

% if length(filelistidx)==1 && mainhandles.datalist(data_idx).multiplicity==1
%     errordlg('Data cannot not be summed! There is only one file selected.')
%     return
% end

ntraces=size(mainhandles.datalist(data_idx(1)).data.real,2);%header.file.ntraces;
np_half=size(mainhandles.datalist(data_idx(1)).data.real,3);%header.file.np/2;
data_sum.real=zeros(1,ntraces,np_half);
data_sum.imag=zeros(1,ntraces,np_half);

if length(data_idx)>1
    % do consistency check!
    check_acqtype = unique({mainhandles.datalist(data_idx).acqtype});
    check_nucleus = unique([mainhandles.datalist(data_idx).nucleus]);
    check_np = unique([mainhandles.datalist(data_idx).np]);
    if length(check_acqtype)~=1 || length(check_nucleus)~=1 || length(check_np)~=1
        errordlg('1Data cannot not be summed! Format is varying.')
        return
    end
    
    check_ntraces=size(mainhandles.datalist(data_idx(1)),2);
    for i=2:length(data_idx)
        ratio=size(mainhandles.datalist(data_idx(i)),2)/check_ntraces;
        if ratio~=1
            errordlg('2Data cannot not be summed! Format is varying.')
            return
        end
    end
end

%% --- start summation ----------------------------------------
time_allacq=0; addcount=0;
comparams=mainhandles.datalist(data_idx(1)).params;
% if get(filelisthandles.filelistfig_togglebutton_expandlist,'Value')
%     for i=1:length(filelist)
%         try
%             %store postprocess param
%             apodizefct{i,:} = mainhandles.datalist(data_idx(i)).process.apodizefct;
%             apodparam1(i) = mainhandles.datalist(data_idx(i)).process.apodparam1;
%             apodparam2(i) = mainhandles.datalist(data_idx(i)).process.apodparam2;
%             phasecorr0(i,:) = mainhandles.datalist(data_idx(i)).process.phasecorr0(i);
%             phasecorr1(i,:) = mainhandles.datalist(data_idx(i)).process.phasecorr1(i);
%             lsfid(i) = mainhandles.datalist(data_idx(i)).process.lsfid;
%
%             %replace with param for summation: no apod, no phase, no lsfid
%             mainhandles.datalist(data_idx(i)).process.apodizefct = 'exponential';
%             mainhandles.datalist(data_idx(i)).process.apodparam1 = 0;
%             mainhandles.datalist(data_idx(i)).process.apodparam2 = 0;
%             mainhandles.datalist(data_idx(i)).process.phasecorr(:) = 0;
%             mainhandles.datalist(data_idx(i)).process.phasecorr1(:) = 0;
%             mainhandles.datalist(data_idx(i)).process.lsfid = 0;
%             guidata(findobj('Tag','mainmenu'),mainhandles)
%
%
%             data(i).real =  squeeze(mainhandles.datalist(data_idx(i)).data.real(array_idx(i),:,:));
%             data(i).imag =  squeeze(mainhandles.datalist(data_idx(i)).data.imag(array_idx(i),:,:));
%
%             data(i) = postprocessing(squeeze(data(i)),data_idx(i),array_idx(i));
%             data_sum.real(1,:,:)=data_sum.real(1,:,:)+data(i).real(1,:,:);
%             data_sum.imag(1,:,:)=data_sum.imag(1,:,:)+data(i).imag(1,:,:);
%
%             clear data
% %             data_sum.real(1,:,:)=data_sum.real(1,:,:)+...
% %                 mainhandles.datalist(data_idx(i)).data.real(array_idx(i),:,:);
% %             data_sum.imag(1,:,:)=data_sum.imag(1,:,:)+...
% %                 mainhandles.datalist(data_idx(i)).data.imag(array_idx(i),:,:);
% %             addcount=addcount+1;
%         catch
%             errordlg('5Data cannot not be summed! Format is varying or not complex.')
%             return
%         end
%     end
% else
    mainhandles.switch_bkp = mainhandles.switch;
    mainhandles.switch.phasecorrection=1;
    mainhandles.switch.apodization=0;
    mainhandles.switch.transformsize=0;
    mainhandles.switch.lsfid=0;
    mainhandles.switch.dcoffset=1;
    mainhandles.switch.b0=1;
    mainhandles.switch.ECC=0;
guidata(findobj('Tag','mainmenu'),mainhandles);
for i=1:length(data_idx)
    if mainhandles.datalist(data_idx(i)).multiplicity>1
        
        a=gui_dataselect('add', mainhandles.datalist(data_idx(i)).multiplicity);
        uiwait(a);
        if ~isempty(findobj('Tag','dataselect'))
        h=guidata(a); 
        sel_idx = get(h.listbox,'Value');


        mainhandles.switch.phasecorrection=h.switch.phasecorrection;
        mainhandles.switch.apodization=h.switch.apodization;
        mainhandles.switch.transformsize=h.switch.transformsize;
        mainhandles.switch.lsfid=h.switch.lsfid;
        mainhandles.switch.dcoffset=h.switch.dcoffset;
        mainhandles.switch.b0=h.switch.b0;
        mainhandles.switch.normalization=h.switch.normalization;
        delete(a)
        clear h
        else
                mainhandles.switch = mainhandles.switch_bkp;
                guidata(findobj('Tag','mainmenu'),mainhandles);
            return;
        end
        
        if mainhandles.switch.dcoffset==1
           mainhandles.datalist(data_idx(i)).process.DCoffset=1;
        end
guidata(findobj('Tag','mainmenu'),mainhandles);
%         sel_log = select_array(mainhandles.datalist(data_idx(i)).multiplicity);
%         sel_idx = find([sel_log{:}]==1);
        
        try
            lsfid(i) = mainhandles.datalist(data_idx(i)).process.lsfid;
        catch
            lsfid(i)=0;
        end
        
%         for k=1:mainhandles.datalist(data_idx(i)).multiplicity
          for t=1:length(sel_idx);
            k=sel_idx(t);
            try
                %store postprocess param
%                 try
%                 apodizefct{i,:} = mainhandles.datalist(data_idx(i)).process.apodizefct;
%                 apodparam1(i,k) = mainhandles.datalist(data_idx(i)).process.apodparam1(k);
%                 apodparam2(i,k) = mainhandles.datalist(data_idx(i)).process.apodparam2(k);
%                 catch
%                     apodizefct{i,:} = 'exponential';
%                     apodparam1(i,k) = 0;
%                     apodparam2(i,k) = 0;
%                 end
                try
                    phasecorr0(i,k) = mainhandles.datalist(data_idx(i)).process.phasecorr0(k);
                    phasecorr1(i,k) = mainhandles.datalist(data_idx(i)).process.phasecorr1(k);
                catch
                    phasecorr0(i,k) = 0;
                    phasecorr1(i,k) = 0;
                end

%                 %replace with param for summation: no apod, no phase, no lsfid
%                 mainhandles.datalist(data_idx(i)).process.apodizefct = 'exponential';
%                 mainhandles.datalist(data_idx(i)).process.apodparam1 = 0;
%                 mainhandles.datalist(data_idx(i)).process.apodparam2 = 0;
%                 mainhandles.datalist(data_idx(i)).process.phasecorr0(k) = 0;
%                 mainhandles.datalist(data_idx(i)).process.phasecorr1(k) = 0;
%                 mainhandles.datalist(data_idx(i)).process.lsfid = 0;
                guidata(findobj('Tag','mainmenu'),mainhandles)
                
                temp(i).real =  squeeze(mainhandles.datalist(data_idx(i)).data.real(k,:,:));
                temp(i).imag =  squeeze(mainhandles.datalist(data_idx(i)).data.imag(k,:,:));
                
                if mainhandles.switch.phasecorrection==1
                    fid_length=length(temp(i).real); %=mainhandles.datalist(dataidx).np/2;
                    t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(data_idx(i)).spectralwidth;
%                     t=t_vec;
                    % calculation of x-axis for frequency-space
                    cut = round(fid_length/2);
                    df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                    f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

                    temp(i) = phasing(squeeze(temp(i)), f_vec_shifted, phasecorr0(i,k), phasecorr1(i,k));
                    mainhandles.datalist(data_idx(i)).process.phasecorr0(k)=0;
                    mainhandles.datalist(data_idx(i)).process.phasecorr1(k)=0;
                end

                
                data(i) = postprocessing(squeeze(temp(i)),data_idx(i),k);
                sum(isequal(data(i).real,temp(i).real))
                %
                %                     fid = data(i).real + data(i).imag.*sqrt(-1);
                %                     spect=real(fftshift(fft(fid(:))));
                %                     figure(1)
                %                     hold on
                %                     plot(spect)
                %                     hold off
                
                data_sum.real(1,:,:)=squeeze(data_sum.real(1,:,:))+data(i).real;
                data_sum.imag(1,:,:)=squeeze(data_sum.imag(1,:,:))+data(i).imag;
                
                
                mainhandles.datalist(data_idx(i)).process.apodparam1 = 0;
                mainhandles.datalist(data_idx(i)).process.apodparam2 = 0;
                %                     fid_sum = data_sum.real + data_sum.imag.*sqrt(-1);
                %                     spect_sum=real(fftshift(fft(fid_sum(:))));
                %                     figure(2)
                %                     hold on
                %                     plot(spect_sum)
                %                     hold off
                %
                %                     data_sum.real(1,:,:)=data_sum.real(1,:,:)+...
                %                         mainhandles.datalist(data_idx(i)).data.real(k,:,:);
                %                     data_sum.imag(1,:,:)=data_sum.imag(1,:,:)+...
                %                         mainhandles.datalist(data_idx(i)).data.imag(k,:,:);
                addcount=addcount+1;
            catch
                errordlg('3Data cannot not be summed! Format is varying.')
                return
            end
        end
    else
        sel_idx=1;
        try
            %store postprocess param
%             apodizefct{i,:} = mainhandles.datalist(data_idx(i)).process.apodizefct;
%             apodparam1(i) = mainhandles.datalist(data_idx(i)).process.apodparam1;
%             apodparam2(i) = mainhandles.datalist(data_idx(i)).process.apodparam2;
            phasecorr0(i) = mainhandles.datalist(data_idx(i)).process.phasecorr0;
            phasecorr1(i) = mainhandles.datalist(data_idx(i)).process.phasecorr1;
%             lsfid(i) = mainhandles.datalist(data_idx(i)).process.lsfid;
%             
%             %replace with param for summation: no apod, no phase, no lsfid
%             mainhandles.datalist(data_idx(i)).process.apodizefct = 'exponential';
%             mainhandles.datalist(data_idx(i)).process.apodparam1 = 0;
%             mainhandles.datalist(data_idx(i)).process.apodparam2 = 0;
%             mainhandles.datalist(data_idx(i)).process.phasecorr = 0;
%             mainhandles.datalist(data_idx(i)).process.phasecorr1 = 0;
%             mainhandles.datalist(data_idx(i)).process.lsfid = 0;
            guidata(findobj('Tag','mainmenu'),mainhandles)
            
            temp(i).real =  squeeze(mainhandles.datalist(data_idx(i)).data.real(1,:,:));
            temp(i).imag =  squeeze(mainhandles.datalist(data_idx(i)).data.imag(1,:,:));
            
            
               if mainhandles.switch.phasecorrection==1
                    fid_length=length(temp(i).real); %=mainhandles.datalist(dataidx).np/2;
                    t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(data_idx(i)).spectralwidth;
%                     t=t_vec;
                    % calculation of x-axis for frequency-space
                    cut = round(fid_length/2);
                    df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                    f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

                    temp(i) = phasing(squeeze(temp(i)), f_vec_shifted, phasecorr0(i), phasecorr1(i));
                     mainhandles.datalist(data_idx(i)).process.phasecorr0=0;
                      mainhandles.datalist(data_idx(i)).process.phasecorr1=0;
                end
            
            
            data(i) = postprocessing(squeeze(temp(i)),data_idx(i),k);
                
                data_sum.real(1,:,:)=squeeze(data_sum.real(1,:,:))+data(i).real;
                data_sum.imag(1,:,:)=squeeze(data_sum.imag(1,:,:))+data(i).imag;
                
                 mainhandles.datalist(data_idx(i)).process.apodparam1 = 0;
                  mainhandles.datalist(data_idx(i)).process.apodparam2 = 0;
            
            %                 data_sum.real(1,:,:)=...
            %                     data_sum.real(1,:,:)+mainhandles.datalist(data_idx(i)).data.real;
            %                 data_sum.imag(1,:,:)=...
            %                     data_sum.imag(1,:,:)+mainhandles.datalist(data_idx(i)).data.imag;
            addcount=addcount+1;
        catch
            errordlg('4Data cannot not be summed! Format is varying.')
            return
        end
    end
end
% end

% % normalize data




% collect and merge parameters
for i=1:length(data_idx)
    time_allacq=time_allacq+mainhandles.datalist(data_idx(i)).params.tr; % in sec
    if isequal(comparams,mainhandles.datalist(data_idx(i)).params)==0
        fieldnames_all = fieldnames(comparams);
        for k=1:length(fieldnames_all)
            if isequal(eval(['comparams.' char(fieldnames_all(k))]),...
                    eval(['mainhandles.datalist(data_idx(i)).params.' char(fieldnames_all(k))]))==0 && ...
                    isequal(eval(['comparams.' char(fieldnames_all(k))]),'XXX')==0
                eval(['comparams.' char(fieldnames_all(k)) ' =''XXX'' ']);
            end
        end
    end
end
if length(comparams.nt)>1
comparams.nt=sum(comparams.nt(sel_idx));
comparams.arraydim=1;
else
    comparams.nt=sum(comparams.nt(1));
end

if mainhandles.switch.normalization ==1
data_sum.real=data_sum.real/comparams.nt;
data_sum.imag=data_sum.imag/comparams.nt;
display(['data normalized:' num2str(comparams.nt)])
end



if mainhandles.switch.lsfid==1
    comparams.lsfid=0;
else
comparams.lsfid=lsfid(1);
end
if mainhandles.switch.transformsize==1;
    comparams.np = 2*size(data_sum.real,3);
end
% disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
% disp(lsfid(1))

% mainhandles.datalist(data_idx(i)).type='fid_sum';


% create new direcory with data_sum (*.sum) and procpar from first selection
homedir=pwd;
cd([mainhandles.datalist(data_idx(1)).path filesep '..'])
datadir=pwd;
cd(homedir)

strlengths=zeros(1,length(data_idx));
for i=1:length(data_idx)
    filelist{i} = mainhandles.datalist(1,data_idx(i)).liststring;
    strlengths(i)=length(mainhandles.datalist(1,data_idx(i)).liststring);
end
strlength=max(strlengths);

filelist_num=zeros(length(data_idx),strlength);
for i=1:length(data_idx)
    filelist_num(i,1:strlengths(i))=double(char(mainhandles.datalist(1,data_idx(i)).liststring));
end

%-------------------------------------------------------------------------

% All following steps are adapted to Varian folder structure!!!!!!!!!!!!!!
comstr_idx=find(std(filelist_num,1,1)==0);
comstr = char(filelist(min(find(strlengths==strlength))));
comstr=comstr(min(comstr_idx):max(comstr_idx));
comstr=comstr(1:max(findstr(comstr,filesep))-1);

comfilename=comstr(find(std([double(datadir) zeros(1,length(comstr)-length(datadir)); double(comstr)],1,1)));
comfilename=regexprep(comfilename,filesep,'');
comfilename=regexprep(comfilename,'.fid','');
% if strcmp(mainhandles.datalist(data_idx(1)).format,'Varian')
%     newfilename = ['SUM_' comfilename '.fid'];
%
%     if exist([datadir '\' newfilename])==0
%         mkdir([datadir '\' newfilename]);
%     end
%     copyfile([mainhandles.datalist(data_idx(1)).path '\procpar'],[datadir '\' newfilename]);
%     copyfile([mainhandles.datalist(data_idx(1)).path '\text'],[datadir '\' newfilename]);
%     new_file = write_varian(comparams,data_sum,newfilename,datadir);
%
%     create_filelist(new_file)
%
%     guidata(findobj('Tag','filelistfig'),filelisthandles);
%     guidata(findobj('Tag','mainmenu'),mainhandles);
%
%     updatedata
% else
sum_idx =size(mainhandles.datalist,2)+1;
mainhandles.datalist(1,sum_idx)=mainhandles.datalist(1,data_idx(1));
clear mainhandles.datalist(1,sum_idx).data
clear mainhandles.datalist(1,sum_idx).liststring
%     clear mainhandles.datalist(1,size(mainhandles.datalist,2)).path
clear mainhandles.datalist(1,sum_idx).multiplicity
clear mainhandles.datalist(1,sum_idx).filename
clear mainhandles.datalist(1,sum_idx).multiplicity
clear mainhandles.datalist(1,sum_idx).time

c=(clock);
time=[num2str(c(4)) ':' num2str(c(5)) ':' num2str(round(c(6)))];
mainhandles.datalist(1,sum_idx).time = [date ' ' time];
mainhandles.datalist(1,sum_idx).data = data_sum;
mainhandles.datalist(1,sum_idx).multiplicity = 1;
mainhandles.datalist(1,sum_idx).params = comparams;
if strcmp(mainhandles.datalist(data_idx(1)).format,'Varian')
    newfilename = ['SUM_' comfilename];
    [pathstr, name, ext] = fileparts(newfilename);
    %     if strcmp(mainhandles.datalist(data_idx(1)).format,'Varian')
    %         clear mainhandles.datalist(1,sum_idx).path
    %         if isempty(ext) || strcmp(ext,',.fid')==0
    %             newfilename = [name '.fid']
    %         end
    %          mainhandles.datalist(1,sum_idx).filename = 'fid'
    %          mainhandles.datalist(1,sum_idx).path = ;
    %     else
    if isempty(ext) || strcmp(ext,',.mat')==0
        newfilename = [name '.mat'];
    end
else
    newfilename = ['SUM_' mainhandles.datalist(1,data_idx(1)).filename];
    [pathstr, name, ext] = fileparts(newfilename);
    if isempty(ext) || strcmp(ext,',.mat')==0
        newfilename = [name '.mat'];
    end
end

newfilename = inputdlg('Enter sum filename:','SUM filename',1,{newfilename});
[pathstr, name, ext] = fileparts(newfilename{1});
    if isempty(ext) || strcmp(ext,',.mat')==0
        newfilename = [name '.mat'];
    else
        newfilename=newfilename{1};
    end


mainhandles.datalist(1,sum_idx).filename = newfilename;
mainhandles.datalist(1,sum_idx).liststring = [mainhandles.datalist(1,data_idx(1)).path filesep newfilename];

%     end


datadir = mainhandles.datalist(1,sum_idx).path;


mainhandles.datalist(1,sum_idx).process.lsfid=lsfid(1);
mainhandles.datalist(sum_idx).format = 'Matlab';
study = mainhandles.datalist(sum_idx);

save([datadir filesep newfilename],'study');

%     mainhandles.datalist=datalist;
mainhandles.datapath=[mainhandles.datapath pathsep datadir];
formatlist = unique(cellstr({mainhandles.datalist.format}));
set(findobj('Tag','filelistfig_popupmenu_selectformat'),'String',formatlist)
% if get(findobj('Tag','filelistfig_togglebutton_expandlist'),'Value')
%     set(findobj('Tag','filelistfig_listbox'),'String',mainhandles.liststr_expanded,...
%         'Max',length({mainhandles.liststr_expanded}),'Value',min(get(findobj('Tag','filelistfig_listbox'),'Value')));
% else
    set(findobj('Tag','filelistfig_listbox'),'String',{mainhandles.datalist.liststring},'Max',length({mainhandles.datalist.liststring}),...
        'Value',size(mainhandles.datalist,2));
% end

mainhandles.dispopts.dataidx = sum_idx;
mainhandles.dispopts.arrayidx = 1;
% mainhandles.process.lsfid = lsfid(1);

%     create_filelist([datadir '\' newfilename])



%% restore parameters
% try
% for i=1:length(data_idx)
% 
%         mainhandles.datalist(data_idx(i)).process.apodizefct = apodizefct{i,:};
%         mainhandles.datalist(data_idx(i)).process.apodparam1 = apodparam1(i);
%         mainhandles.datalist(data_idx(i)).process.apodparam2 = apodparam2(i);
%         mainhandles.datalist(data_idx(i)).process.phasecorr = phasecorr0(i);
%         mainhandles.datalist(data_idx(i)).process.phasecorr1 = phasecorr1(i);
%         mainhandles.datalist(data_idx(i)).process.lsfid = lsfid(i);
%         disp(mainhandles.datalist(data_idx(i)).process.lsfid)
% 
% end
% catch
%     disp('add_fid: restore parameters')
% end

mainhandles.switch = mainhandles.switch_bkp;

guidata(findobj('Tag','filelistfig'),filelisthandles);
guidata(findobj('Tag','mainmenu'),mainhandles);
updatedata(size(mainhandles.datalist,2));
displaycontrol;





%%
function sel_log = select_array(multiplicity)
but_h = 30;
but_w = 50;
n_fid = multiplicity; %mainhandles.datalist(dataidx).multiplicity
nline = 1;
ncul=8;

if n_fid>8
    fig_w = but_w*ncul;
    nline = ceil(n_fid/ncul);
    fig_h = but_h*nline;
else
    fig_w = n_fid*but_w;
    ncul = n_fid;
    fig_h = but_h;
end
% fig_h = fig_h+but_w; %% add button like select all or deselect all

title = 'Select data to be added';
selectfid_fig = figure('Name',title,'NumberTitle','off',...
    'Tag','selectfid_fig','MenuBar','none','Units','pixel',...
    'Position',[200 300 fig_w+10 fig_h+but_h+10]);
selectfid_panel = uipanel('Parent',selectfid_fig,...
    'Tag','select_panel','Units','pixel',...
    'Position',[0 but_h+10 fig_w+10 fig_h+10]);
for k=1:n_fid
    posx = 5+(mod(k-1,ncul))*but_w;
    posy = fig_h - (floor((k-1)/8)+1)*but_h;
    tag = ['sel_' num2str(k)];
    button(k).sel = uicontrol('Style','togglebutton','Parent',selectfid_panel,'Units','pixel',...
    'String',num2str(k),'Position',[posx posy but_w but_h],...
    'Tag',tag,'Callback',{@button_sel_callback});
end

button_all = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','All','Position',[5 5 but_w but_h],...
    'Tag','applytoall_button','Callback',{@button_all_callback});
button_none = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','None','Position',[60 5 50 30],...
    'Tag','none_button','Callback',{@button_none_callback});
button_apply = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
    'String','Apply','Position',[fig_w-but_w-5 5 50 30],...
    'Tag','apply','Callback',{@button_apply_callback});

button_all_callback;
uiwait(findobj('Tag','selectfid_fig'))
sel_h = get(findobj('Tag','select_panel'),'Children');
sel_log = get(sel_h,'Value')';
sel_log=flipdim(sel_log,2);
delete(findobj('Tag','selectfid_fig'));
function button_sel_callback(hObject,eventdata)
% handles = guidata(findobj('Tag','selectfid_panel'));
% sel = get(findobj('Tag','select_panel'),'Children');
cur_val = get(hObject,'Value');

function button_all_callback(hObject,eventdata)
% handles = guidata(findobj('Tag','selectfid_panel'));
sel = get(findobj('Tag','select_panel'),'Children');
set(sel,'Value',1);
function button_none_callback(hObject,eventdata)
% handles = guidata(finobj,'Tag','selectfid_fig');
sel = get(findobj('Tag','select_panel'),'Children');
set(sel,'Value' ,0);
function button_apply_callback(hObject,eventdata)
% sel_h = get(findobj('Tag','select_panel'),'Children');
% sel_log = get(sel_h,'Value');
uiresume(findobj('Tag','selectfid_fig'))
% delete(findobj('Tag','selectfid_fig'));
% return;