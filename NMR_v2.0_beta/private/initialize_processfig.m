function initialize_processfig(hObject)
% clc;
handles = guidata(hObject);
mainhandles= guidata(findobj('Tag','mainmenu'));
%% select data

dataidx = mainhandles.dispopts.dataidx;
try,
    arrayidx = mainhandles.dispopts.arrayidx;
catch,
    arrayidx=1;
    disp('12 initialize_processfig: arrayidx');
end
multplicity = mainhandles.datalist(dataidx).multiplicity;

transfsize_str = {'none','16','32','64','128','256','512','1k','2k','4k','8k','16k','32k','64k','128k'};
apodizefct_str = {'exponential','gaussian','doubleexp','lorentzian','TRAF'};

if isfield(mainhandles.datalist(dataidx),'process')==0 || isfield(mainhandles.datalist(dataidx).process,'apodparam1')==0 ||...
        isfield(mainhandles.datalist(dataidx).process,'lsfid')==0 || isfield(mainhandles.datalist(dataidx).process,'transfsize')==0 ||...
        isfield(mainhandles.datalist(dataidx).process,'phasecorr1')==0
    % --- prepare default options ---------------------------------------------
    if ~isfield(mainhandles.datalist(dataidx).process,'apodparam1')
        mainhandles.datalist(dataidx).process.apodizefct = 'exponential';
        mainhandles.datalist(dataidx).process.apodparam1(1:multplicity) = 0; % Hz = LB = first Parameter of apodzing function
        mainhandles.datalist(dataidx).process.apodparam2(1:multplicity) = 0; % Hz = second Parameter of apodzing function
        mainhandles.process.apodizefct= 'exponential';
    end
    
    if ~isfield(mainhandles.datalist(dataidx).process,'lsfid')
        mainhandles.datalist(dataidx).process.lsfid = 0;
    end
    if ~isfield(mainhandles.datalist(dataidx).process,'transfsize')
        mainhandles.datalist(dataidx).process.transfsize = 0;
    end
    if ~isfield(mainhandles.datalist(mainhandles.dispopts.dataidx).process,'appltoarray1')
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1 = 1;
        set(handles.processfig_togglebutton_appltoarray1,'Value',1);
    end
    if ~isfield(mainhandles.datalist(mainhandles.dispopts.dataidx).process,'appltoarray2')
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2 = 1;
        set(handles.processfig_togglebutton_appltoarray2,'Value',1);
    end
    if ~isfield(mainhandles.datalist(dataidx).process,'phasecorr1')
        mainhandles.datalist(dataidx).process.phasecorr0(1:multplicity) = 0;
        mainhandles.datalist(dataidx).process.phasecorr1(1:multplicity) = 0;
    end
    
%     %--- set switches
%     mainhandles.switch.transfsize = 1;
%     mainhandles.switch.apodizefct = 1;
%     mainhandles.switch.lsfid = 1;
%     mainhandles.switch.phase = 1;
%     mainhandles.switch.b0drift = 1;
%     for i=1:length(mainhandles.datalist)
%         for k=1:mainhandles.datalist(i).multiplicity
%             mainhandles.datalist(i).process(k).apodizefct=mainhandles.datalist(dataidx).process.apodizefct;
%             mainhandles.datalist(i).process(k).apodparam1=mainhandles.datalist(dataidx).process.apodparam1;
%             mainhandles.datalist(i).process(k).apodparam2=mainhandles.datalist(dataidx).process.apodparam2;
%             mainhandles.datalist(i).process(k).phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(arrayidx);
%             mainhandles.datalist(i).process(k).phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(arrayidx);
%             mainhandles.datalist(i).process(k).transfsize=mainhandles.datalist(dataidx).process.transfsize;
%             mainhandles.datalist(i).process(k).lsfid=mainhandles.datalist(i).process.lsfid;
%         end
%     end
else
end

if ~isfield(mainhandles.datalist(mainhandles.dispopts.dataidx).process,'appltoarray1')
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1 = 1;
        set(handles.processfig_togglebutton_appltoarray1,'Value',1);
else
    set(handles.processfig_togglebutton_appltoarray1,'Value',mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray1);
end

if ~isfield(mainhandles.datalist(mainhandles.dispopts.dataidx).process,'appltoarray2')
        mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2 = 1;
        set(handles.processfig_togglebutton_appltoarray2,'Value',1);
else
    set(handles.processfig_togglebutton_appltoarray2,'Value',mainhandles.datalist(mainhandles.dispopts.dataidx).process.appltoarray2);
end

%--- Setting up Uicontrols ---------------------
%--- Popupmenu
try
idx=find(ismember(apodizefct_str,mainhandles.datalist(dataidx).process.apodizefct));
catch err
    idx=1;
end
set(handles.processfig_popupmenu_apodfunction,'String',apodizefct_str,'Value',idx)
if mainhandles.datalist(dataidx).process.transfsize>=1024
    transfsize_cur_str=[num2str(mainhandles.datalist(dataidx).process.transfsize/1024) 'k'];
elseif mainhandles.datalist(dataidx).process.transfsize==0
    transfsize_cur_str='none';
else
    transfsize_cur_str=num2str(mainhandles.datalist(dataidx).process.transfsize);
end
[tf, idx] = ismember(transfsize_cur_str,transfsize_str);
set(handles.processfig_popupmenu_transfsize,'String',transfsize_str,'Value',idx)
set(handles.processfig_edit_lsfid,'String',num2str(mainhandles.datalist(dataidx).process.lsfid))

%--- Sliders
set(handles.processfig_slider_phasecorr0,'Min',-180,'Max',180,...
    'SliderStep',[1/360 10/360],'Value',mainhandles.datalist(dataidx).process.phasecorr0(arrayidx))
set(handles.processfig_slider_phasecorr1,'Min',-100,'Max',100,...
    'SliderStep',[0.01/200 0.1/200],'Value',mainhandles.datalist(dataidx).process.phasecorr1(arrayidx))
set(handles.processfig_slider_apodparam1,'Min',0,'Max',100,'Value',mainhandles.datalist(dataidx).process.apodparam1(arrayidx))
set(handles.processfig_slider_apodparam2,'Min',0,'Max',10,'Value',mainhandles.datalist(dataidx).process.apodparam2(arrayidx))
% sliderrange = abs(get(handles.par2_slider,'Max')-get(handles.par2_slider,'Min'));
% set(handles.par2_slider,'SliderStep',sliderrange*[0.01 0.1])

%--- edit text
set(handles.processfig_edit_apodparam1,'String',num2str(mainhandles.datalist(dataidx).process.apodparam1(arrayidx)))
set(handles.processfig_edit_apodparam2,'String',num2str(mainhandles.datalist(dataidx).process.apodparam2(arrayidx)))
set(handles.processfig_edit_phasecorr0,'String',num2str(mainhandles.datalist(dataidx).process.phasecorr0(arrayidx)))
set(handles.processfig_edit_phasecorr1,'String',num2str(mainhandles.datalist(dataidx).process.phasecorr1(arrayidx)))
set(handles.processfig_edit_lsfid,'String',num2str(mainhandles.datalist(dataidx).process.lsfid))

    %--- set switches
    mainhandles.switch.phasecorrection=1;
    mainhandles.switch.apodization=1;
    mainhandles.switch.transformsize=1;
    mainhandles.switch.lsfid=1;
    mainhandles.switch.dcoffset=1;
    mainhandles.switch.b0=1;
    mainhandles.switch.ECC=0;
    
    
    
    % ---- set myfunc
    file_list=dir([mainhandles.homedir filesep 'myfunc' filesep 'MRS']);
    func_count=0;
    func_list={};
    for k=1:length(file_list)
        if file_list(k).isdir~=1
            [path name ext] = fileparts(file_list(k).name);
            if strcmp(ext,'.m')
                func_count=func_count+1;
                func_list{func_count}=name;
            end
        end
    end
   if ~isempty(func_list)
       set(handles.processfig_popupmenu_myfunc,'String',func_list);
   else
       set(get(handles.uipanel_myfunc,'Children'),'Enable','off')
   end

%--- save handles ---------------------------------------------------------
mainhandles.process = mainhandles.datalist(dataidx).process;
mainhandles.process.phasecorr0 = mainhandles.process.phasecorr0(arrayidx);
mainhandles.process.phasecorr1 = mainhandles.process.phasecorr1(arrayidx);
guidata(hObject,handles);
guidata(findobj('Tag','mainmenu'),mainhandles);

