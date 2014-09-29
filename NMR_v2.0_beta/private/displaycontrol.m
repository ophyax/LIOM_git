function displaycontrol

% disp('displaycontrol')
mainhandles=guidata(findobj('Tag','mainmenu'));
set(0,'CurrentFigure',mainhandles.mainmenu)
disp_debub=1;

%% select data
dataidx = mainhandles.dispopts.dataidx;
% disp(dataidx)
try,
    arrayidx = mainhandles.dispopts.arrayidx;
catch,
    arrayidx=1;
    
    disp('l14 displaycontrol: arrayidx');
end

if ~isempty(findobj('Tag','processfig'))
    initialize_processfig(findobj('Tag','processfig'));
end

%% load data
if isempty(mainhandles.datalist(dataidx).loaded)
    load_data('displaycontrol')
    mainhandles=guidata(findobj('Tag','mainmenu'));
elseif mainhandles.datalist(dataidx).loaded ~=1
    load_data('displaycontrol')
    mainhandles=guidata(findobj('Tag','mainmenu'));
end
mainmenu('dispopt_edit_datanum_Callback',mainhandles.mainmenu,[],mainhandles,0)
%% prepare mainmenu
set(get(mainhandles.dispopts_uipanel_dataformat,'Children'),'Enable','off');
set(mainhandles.dispopt_uipanel_DWI,'Visible','off');
set(mainhandles.dispopt_popupmenu_DWI,'Enable','off');
data_type = fieldnames(mainhandles.datalist(dataidx).data);
% set(mainhandles.dispopt_popupmenu_DWI,'String','');
% data_type
if sum(strcmp(data_type,'real')+strcmp(data_type,'imag'))==2
    set(mainhandles.dispopts_radiobutton_format_real,'Enable','on');
    set(mainhandles.dispopts_radiobutton_format_imag,'Enable','on');
    set(mainhandles.dispopts_radiobutton_format_absval,'Enable','on');
    set(mainhandles.dispopts_radiobutton_format_phase,'Enable','on');
    set(mainhandles.dispopts_togglebutton_format_rawfft,'Enable','on');
end
if sum(strcmp(data_type,'fdf'))==1
    set(mainhandles.dispopts_radiobutton_format_fdf,'Enable','on');
end

if length(size(getfield(mainhandles.datalist(dataidx).data,data_type{1})))==4
    
    if isfield(mainhandles.datalist(dataidx),'DWI_string')
        set(mainhandles.dispopt_popupmenu_DWI,'String',mainhandles.datalist(dataidx).DWI_string);
    else
        for k=1:size(getfield(mainhandles.datalist(dataidx).data,data_type{1}),4)
            diff_str{k}=['b_' num2str(k-1)];
        end
        set(mainhandles.dispopt_popupmenu_DWI,'String',diff_str);
        mainhandles.datalist(dataidx).DWI_string=diff_str;
        guidata(findobj('Tag','mainmenu'),mainhandles);
    end
    set(mainhandles.dispopt_uipanel_DWI,'Visible','on');
    set(mainhandles.dispopt_popupmenu_DWI,'Visible','on');
    set(mainhandles.dispopt_popupmenu_DWI,'Enable','on');
end

if strcmp(mainhandles.datalist(dataidx).acqtype,'MRI')
    set(mainhandles.process_pushbutton_orient,'Enable','on')
else
    set(mainhandles.process_pushbutton_orient,'Enable','off')
end
if strcmp(mainhandles.datalist(dataidx).acqtype,'MRS')
    set(mainhandles.process_pushbutton_process,'Enable','on')
    set(mainhandles.dispopt_radiobutton_axislim,'Enable','on')
    set(mainhandles.dispopt_radiobutton_datacursor,'Enable','on')
    %     set(mainhandles.dispopts_pushbutton_format_ref,'Enable','on');
    if ~isempty(findobj('Tag','processfig'))
        set(findobj('Tag','processfig'),'Visible','on')
        initialize_processfig(findobj('Tag','processfig'));
        set(0,'CurrentFigure',mainhandles.mainmenu);
    end
else
    set(mainhandles.process_pushbutton_process,'Enable','off')
    set(mainhandles.dispopt_radiobutton_axislim,'Enable','off')
    set(mainhandles.dispopt_radiobutton_datacursor,'Enable','off')
    %     set(mainhandles.dispopts_pushbutton_format_ref,'Enable','off');
    if ~isempty(findobj('Tag','processfig'))
        set(findobj('Tag','processfig'),'Visible','off')
    end
end




% if mainhandles.datalist(dataidx).acqtype == 'MRI'
%     GUI_ImageOrientation
%     return
% end

% %% things to do when the content of the mainaxes was changed --------------dispopts_radiobutton_format_real
% if mainhandles.switch.phasecorrection==0 || mainhandles.switch.apodization==0 || mainhandles.switch.transformsize==0
%     % update number of points in static processfig_text_np
%     if isempty(findobj('Tag','processfig'))==0
%         processfig_handles=guidata(findobj('Tag','processfig'));
%         set(processfig_handles.processfig_text_np,'String',['transform size of FID ' num2str(mainhandles.datalist(mainhandles.dispopts.dataidx).np/2) ' points to'])
%     end
% end

%%  store current axes limits ---------------------------------------------
all_curaxes=findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes);

if isempty(all_curaxes)==0
    xlim=get(all_curaxes(1),'XLim');
    ylim=get(all_curaxes(1),'YLim');
    cla; %clear current axes content
end

%% Preparation normal mode or CSI mode ------------------------------------
% dataidx = mainhandles.dispopts.dataidx;
% if isempty(findstr(upper(mainhandles.datalist(dataidx).acqtype),'CSI'))==0
%     set(mainhandles.dispopt_togglebutton_dispCSI,'Value',1);
% end
if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
        mainhandles.datalist(dataidx).multiplicity>=1
    subplotdim=sort([floor(sqrt(mainhandles.datalist(dataidx).multiplicity)) ...
        ceil(sqrt(mainhandles.datalist(dataidx).multiplicity))]);
    while max(cumprod(subplotdim))<mainhandles.datalist(dataidx).multiplicity
        if subplotdim(1)<subplotdim(2)
            subplotdim(1)=subplotdim(1)+1;
        else
            subplotdim(2)=subplotdim(2)+1;
        end
    end
    mainhandles.currentplot=zeros(1,mainhandles.datalist(dataidx).multiplicity);
    while subplotdim(1)*subplotdim(2)<mainhandles.datalist(dataidx).multiplicity
        subplotdim(1)=subplotdim(1)+1;
        subplotdim=sort(subplotdim);
    end
    axesheight=ones(subplotdim(1)*subplotdim(2),1)./subplotdim(1);
    axeswidth=ones(subplotdim(1)*subplotdim(2),1)./subplotdim(2);
    off_x=repmat((1:subplotdim(2))-1,1,subplotdim(1)).*axeswidth(1);
    off_y=reshape(repmat(((subplotdim(1)):-1:1)-1,subplotdim(2),1),1,subplotdim(1)*subplotdim(2)).*axesheight(1);
    csiaxespos = [off_x' off_y' 0.99*axeswidth 0.99*axesheight];
    delete(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))
    h_subplot=zeros(1,subplotdim(1)*subplotdim(2));
    arrayidx = 1;
else
    mainhandles.currentplot = 0;
    if length(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))>1
        delete(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))
        mainhandles.axes1=axes('Parent',mainhandles.mainmenu_uipanel_axes);
    elseif length(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))==1
        axes(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))
        mainhandles.axes1=gca;
    elseif isempty(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes))
        mainhandles.axes1=axes('Parent',mainhandles.mainmenu_uipanel_axes);
    end
    arrayidx = mainhandles.dispopts.arrayidx;
end





%% get selection of real(=4),imag(=3), absval(=2), fdf , phase(=1)
selidx=find(cell2mat(get(get(mainhandles.dispopts_uipanel_dataformat,'children'),'Value'))==1);
children = get(mainhandles.dispopts_uipanel_dataformat,'children');
selidx_chk = get(children,'Enable');
if strcmp(selidx_chk(selidx),'off')
    selidx_safe = find(strcmp(selidx_chk,'on'));
    selidx=selidx_safe(1);
    set(children(selidx_safe(1)),'Value',1);
end

% 
% try
%     mainhandles.datalist(dataidx).params.hdr.Private_0019_1012
%     mainhandles.datalist(dataidx).params.hdr.Private_0019_1013
%     mainhandles.datalist(dataidx).params.hdr.Private_0019_1014
%     mainhandles.datalist(dataidx).params.hdr.Private_0019_1015
% mainhandles.datalist(dataidx).params.hdr.Private_0019_1018
% 
% catch
% end

if disp_debub==1
    display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    display(mainhandles.datalist(dataidx))
    display(['Multiplicity: ' num2str(mainhandles.datalist(dataidx).multiplicity)])
    display(['Data size: ' ])
    display(mainhandles.datalist(dataidx).data)
    if strcmp(mainhandles.datalist(dataidx).acqtype,'MRI')
        display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  MRI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        display(['lro: ' num2str(mainhandles.datalist(dataidx).params.lro)])
        display(['lpe: ' num2str(mainhandles.datalist(dataidx).params.lpe)])
        display(['RO_dim: ' num2str(mainhandles.datalist(dataidx).params.RO_dim)])
        display(['PE_dim: ' num2str(mainhandles.datalist(dataidx).params.PE_dim)])
        display(['orient: ' num2str(mainhandles.datalist(dataidx).params.orient{1}{1})])
        display(['Rotation: ' num2str(mainhandles.datalist(dataidx).params.rotation)])
%        display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  PARAMS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
%         display(mainhandles.datalist(dataidx).params)
        if isfield(mainhandles.datalist(dataidx).params,'hdr')
%             display('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Header %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
%         mainhandles.datalist(dataidx).params.hdr
        end
    end
    pause(0.5)
    
end
stop_plot=0;
while stop_plot==0
    apptype_string = upper(mainhandles.datalist(dataidx).acqtype);
    switch apptype_string
        
        %% case 'MRS' ----------------------------------------------------------------
        case {'MRS'}%, 'PRESCAN'} % ------------------------------------------------------
            if mainhandles.datalist(dataidx).multiplicity>=1
                if get(mainhandles.dispopt_togglebutton_dispDSS,'Value') ==1
                    
                DSS = 1;
                try
                    tt_start = str2num(get(mainhandles.mainmenu_options_edit1,'String'));
                    tt_end =  str2num(get(mainhandles.mainmenu_options_edit2,'String'));
                    tt_step = str2num(get(mainhandles.mainmenu_options_edit3,'String'));
                    DSS_vert=str2num(get(mainhandles.mainmenu_options_edit4,'String'));
                    DSS_hor=str2num(get(mainhandles.mainmenu_options_edit5,'String'));
                catch
                    tt_start=1;
                    tt_end=mainhandles.datalist(dataidx).multiplicity;
                    tt_step=1;
                end
                else
                DSS=0;
                DSS_hor=0;
                DSS_vert=0;
                tt_start = arrayidx;
                tt_step=1;
                tt_end = arrayidx;
                end
            else
                DSS=0;
                DSS_hor=0;
                DSS_vert=0;
                tt_start = arrayidx;
                tt_step=1;
                tt_end = arrayidx;
            end
            
            
            for tt = tt_start:tt_step:tt_end
                arrayidx = tt;
                if tt>tt_start
                    clear data
                end
                %--- get data and apply apodization ---------------------
                if size(mainhandles.datalist(dataidx).data.real,2)==1
                    data.real=squeeze(mainhandles.datalist(dataidx).data.real(arrayidx,:,:));
                    data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(arrayidx,:,:));
                else %select data array
                    nv1_idx=floor((arrayidx-1)/size(mainhandles.datalist(dataidx).data.real,1))+1;
                    nv2_idx=mod(arrayidx,size(mainhandles.datalist(dataidx).data.real,1));
                    if nv2_idx==0
                        nv2_idx=size(mainhandles.datalist(dataidx).data.real,1);
                    end
                    data.real=squeeze(mainhandles.datalist(dataidx).data.real(nv1_idx,nv2_idx,:));
                    data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(nv1_idx,nv2_idx,:));
                end
                %             data
                
                %--- x-axes in time space -------------------------------------
                fid_length=length(data.real); %=mainhandles.datalist(dataidx).np/2;
                
                %             disp('# points')
                %             disp(fid_length)
                t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
                x_vec = t_vec;
                % calculation of x-axis for frequency-space
                cut = round(fid_length/2);
                df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing
                
                
                
                
                
                if isfield(mainhandles.datalist(dataidx),'process') && ...
                        ~isempty(mainhandles.datalist(dataidx).process)
                    if isfield(mainhandles.process,'transfsize')
                        if mainhandles.process.transfsize~=0
                            fid_length=mainhandles.process.transfsize;
                            t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
                            x_vec = t_vec;
                            % calculation of x-axis for frequency-space
                            cut = round(fid_length/2);
                            df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                            f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing
                            
                        end
                    end
                end
                
                
                
                
                if isfield(mainhandles.dispopts,'refoffset')
                    refoffset = mainhandles.dispopts.refoffset;
                else
                    refoffset = 0;
                end
                
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0 % = FFT
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                        % warum minus zur Berechnung von ppm e.g. ppm_vec = f_vec_shifted./100.65; % at 9.4T
                        %                     ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.reffrq);
                        ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.sfrq);
                        % check if mainhandles.datalist(dataidx).param s.sfrq is not more correct
                        x_vec = ppm_vec;
                    else % Hz
                        x_vec = flipdim(f_vec_shifted,1) + refoffset + df_vec ;
                        %                     disp('reoffset')
                        %                     disp(reoffset)
                    end
                end
                
                
                %--- postprocessing
                if isfield(mainhandles.datalist(dataidx),'process') && ...
                        ~isempty(mainhandles.datalist(dataidx).process)
                    if ndims(data.real)>2
                        for idx1=1:size(data.real,1)
                            for idx2=1:size(data.real,2)
                                data_cur.real=squeeze(data.real(idx1,idx2,:));
                                data_cur.imag=squeeze(data.imag(idx1,idx2,:));
                                data = postprocessing(data_cur);
                            end
                        end
                    else
                        data = postprocessing(data);
                    end
                end
                
                %--- phasecorrection ------------------------------------------------------
                if mainhandles.switch.phasecorrection==1
                if isfield(mainhandles.datalist(dataidx),'process') && ...
                        ~isempty(mainhandles.datalist(dataidx).process)
                    if isfield(mainhandles.datalist(dataidx).process,'phasecorr0')
                        phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(arrayidx);
                    else
                        phasecorr0=[];
                    end
                    if isfield(mainhandles.datalist(dataidx).process,'phasecorr1')
                        phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(arrayidx);
                    else
                        phasecorr1=[];
                    end
                    data = phasing(data, f_vec_shifted, phasecorr0, phasecorr1);
                end
                end
                
                %--- calculate FFT --------------------------------------------
                if isfield(mainhandles.datalist(dataidx).data,'real')==1
                    %                 dtot=[data.real data.imag];
                    %                 save('fid_02.txt','dtot','-ascii')
                    if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                        %                     datasz = size(data.real,1)*size(data.real,2);
                        fid=data.real+sqrt(-1)*data.imag;
                        data = 1/length(data.real)*fftshift(squeeze(fft(fid)));
                        
                        datasetstr='FFT';
                    else
                        datasetstr='raw data';
                        data=data.real+1i.*data.imag;
                    end
%                     tmp.real=real(data);
%                     tmp.imag=imag(data);
%                     tmp = phasing(tmp, f_vec_shifted, phasecorr0, phasecorr1);
%                     data = tmp.real+1i.*tmp.imag;
                    switch selidx
                        case 5 % real
                            data=real(data);%,dim1,dim2)))
                            datastr = ['real parts of ' datasetstr ' of'];
                        case 4 % imag
                            data=imag(data);%,dim1,dim2)))
                            datastr = ['imaginary parts of ' datasetstr ' of'];
                        case 3 % absval
                            %                         if get(mainhandles.dispopts_togglebutton_format_fdf,'Value') && ...
                            %                                 get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                            %                             data = fft_data.*conj(fft_data);
                            %                             datastr = ['power of ' datasetstr ' of'];
                            %                         else
                            data=abs(data);
                            datastr = ['absolute value of ' datasetstr ' of'];
                            %                         end
                        case 2 % phase
                            data=angle(data);%,dim1,dim2)))
                            datastr = ['phase of ' datasetstr ' of'];
                    end
                end
                %--- prepare x-axis ----------------------------------------------------
                plotrange=1:length(data); % 1:round(length(data)/2-1); %(length(data)/2-1);%
                %             mainhandles.dispopts.resetdisp=1;
                if mainhandles.dispopts.resetdisp==0
                    % determine xlim
                    xlim=mainhandles.dispopts.axesscaling.x(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:); % =0 means 'FFT'
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 && ... % ppm
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0 % FFTed data
                        %                     xlim=sort((-xlim+refoffset)/(mainhandles.datalist(dataidx).params.reffrq));
                        xlim=sort((xlim)/(mainhandles.datalist(dataidx).params.sfrq));
                    end
                    if length(xlim)~=2 || xlim(2)<=xlim(1) % serves also as initialization
                        xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                        if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                            %                         mainhandles.dispopts.axesscaling.x(...
                            %                             get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                            %                             xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
                            %                             mainhandles.datalist(dataidx).ppm_ref;
                            mainhandles.dispopts.axesscaling.x(...
                                get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                                xlim.*(mainhandles.datalist(dataidx).params.sfrq)+...
                                mainhandles.datalist(dataidx).ppm_ref;
                        else
                            mainhandles.dispopts.axesscaling.x(...
                                get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=xlim;
                        end
                    else
                        xmin=min(xlim);
                        xmax=max(xlim);
                        % now find next point in the x_vec
                        x_vec_asc=sort(x_vec,1,'ascend');
                        if isempty(x_vec_asc(find(x_vec_asc<=xmin,1,'last')))
                            % x_vec(min(find(flipdim(f_vec_shifted,1)<=xmin))) also works
                            xlim(1)=min(x_vec);
                        else
                            xlim(1)=x_vec_asc(find(x_vec_asc<=xmin,1,'last'));
                        end
                        if isempty(x_vec_asc(find(x_vec_asc>=xmax,1,'first')));
                            % x_vec(max(find(flipdim(f_vec_shifted,1)>=xmax)))) also works
                            xlim(2)=max(x_vec);
                        else
                            xlim(2)=x_vec_asc(find(x_vec_asc>=xmax,1,'first'));
                        end
                    end
                    % determine ylim
                    %                 disp(mainhandles.dispopts.axesscaling.y)
                    ylim=mainhandles.dispopts.axesscaling.y(get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:);
                    if length(ylim)~=2 || ylim(2)<=ylim(1)
                        ylim=1.1*[min(data(plotrange)) max(data(plotrange))];
                        mainhandles.dispopts.axesscaling.y(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:)=ylim;
                    end
                else
                    xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                        %                     mainhandles.dispopts.axesscaling.x(...
                        %                         get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                        %                         xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
                        %                         mainhandles.datalist(dataidx).ppm_ref;
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                            xlim.*(mainhandles.datalist(dataidx).params.sfrq)+...
                            mainhandles.datalist(dataidx).ppm_ref;
                    else
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=xlim;
                    end
                    ylim=1.1*[min(data(plotrange)) max(data(plotrange))];
                    mainhandles.dispopts.axesscaling.y(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:)=ylim;
                end
                % Notbremse
                if ylim(1)==ylim(2)
                    disp('Notbremse y')
                    ylim(2)=ylim(1)+eps;
                    ylim(1)=ylim(1)-eps;
                end
                if xlim(1)==xlim(2)
                    disp('Notbremse x')
                    xlim(2)=xlim(1)+eps;
                    xlim(1)=xlim(1)-eps;
                end
                %             disp('---')
                %             xlim
                %             mainhandles.dispopts.axesscaling.x
                %             mainhandles.dispopts.axesscaling.y
                %--- smooth & remove outlier in the center of the image, i.e. dc offset in the center
                remove_outlier=1;
                smoothall=0;
                if remove_outlier
                    mu = mean(data); sigma = std(data);
                    centerdata=data(floor(length(data)/2-3):ceil(length(data)/2+3));
                    outl = find(abs(centerdata-mu)>10*sigma);
                    data(outl) = mean(centerdata);
                end
                if smoothall
                    data = wiener2(data);
                end
                % plots ---------------------------------
                figure(mainhandles.mainmenu)
                if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
                        mainhandles.datalist(dataidx).multiplicity>=1
                    % subplot generates errors (no idea why)
                    %                 h_subplot(arrayidx) = subplot(subplotdim(1),subplotdim(2),arrayidx);
                    %                 set(h_subplot(arrayidx),'Parent',mainhandles.mainmenu_uipanel_axes,...
                    %                     'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],...
                    %                     'OuterPosition',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)])
                    plotdata=data(plotrange);
                    h_subplot(arrayidx) = axes('Parent',mainhandles.mainmenu_uipanel_axes,...
                        'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],...
                        'Position',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)]);
                    mainhandles.currentplot(arrayidx) = plot(h_subplot(arrayidx),x_vec(plotrange),plotdata,'k',...
                        'Tag',['currentplot_' num2str(arrayidx)]);
                    set(mainhandles.currentplot(arrayidx),'UserData',plotdata);
                    if get(mainhandles.dispopt_radiobutton_grid,'Value')
                        grid on
                    else
                        grid off
                    end
                    set(h_subplot(arrayidx),'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],'Position',csiaxespos(arrayidx,:))
                    if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                        set(h_subplot(arrayidx),'XDir','reverse')
                    end
                    if arrayidx==mainhandles.datalist(dataidx).multiplicity
                        stop_plot=1;
                        %                     set(findobj('Parent',mainhandles.mainmenu_uipanel_axes),'Visible','on')
                    else
                        arrayidx=arrayidx+1;
                        clear data
                    end
                else
                    if ishandle(mainhandles.axes1)==0
                        mainhandles.axes1=findobj('Parent',mainhandles.mainmenu_uipanel_axes,'Type','axes');
                    end
                    plotdata = data(plotrange);
                    if DSS==1
                        plotdata = plotdata+(tt-1)*DSS_vert/tt_step;
                    end
                    hold on
                    mainhandles.currentplot = plot(mainhandles.axes1,...
                        x_vec(plotrange)+(tt-1)*DSS_hor,plotdata,'k','Tag','currentplot');
                    hold off
                    if DSS==1 && tt~=tt_start
                        
%                         UD = get(mainhandles.currentplot,'UserData');
                        UD(:,size(UD,2)+1) = plotdata;
                       
                    else
                        UD =plotdata;
                    end
                     set(mainhandles.currentplot,'UserData',UD);
                    if get(mainhandles.dispopt_radiobutton_grid,'Value')
                        grid on
                    else
                        grid off
                    end
                    set(gca,'Position',[0.05 0.05 0.9 0.9],'FontSize',8)
                    set(mainhandles.axes1,'YLim',ylim,'XLim',xlim) % ,'Selected','off','SelectionHighlight','off')
                    %                 set(mainhandles.display_edit_ylim2,'String',num2str(max(ylim)))%,'Visible','on')
                    %                 set(mainhandles.display_edit_ylim1,'String',num2str(min(ylim)))%,'Visible','on')
                    if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                        set(mainhandles.axes1,'XDir','reverse')
                        %                     set(mainhandles.display_edit_xlim1,'String',num2str(max(xlim)))%,'Visible','on')
                        %                     set(mainhandles.display_edit_xlim2,'String',num2str(min(xlim)))%,'Visible','on')
                        if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0
                            set(get(mainhandles.axes1,'XLabel'),'String','frequency [ppm]')
                            %                         set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'Spectrum'])
                            set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'Spectrum'],...
                                'TitlePosition','centertop')
                        else
                            set(get(mainhandles.axes1,'XLabel'),'String','frequency [Hz]')
                            %                         set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'Spectrum'])
                            set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'Spectrum'],...
                                'TitlePosition','centertop')
                        end
                    else
                        set(get(mainhandles.axes1,'XLabel'),'String','time [s]')
                        % set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'FID'])
                        set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'FID'],...
                            'TitlePosition','centertop')
                        %                     set(mainhandles.display_edit_xlim1,'String',num2str(min(xlim)))%,'Visible','on')
                        %                     set(mainhandles.display_edit_xlim2,'String',num2str(max(xlim)))%,'Visible','on')
                    end
                    stop_plot=1;
                end
                guidata(findobj('Tag','mainmenu'),mainhandles);
                %%  case 'MRI'
            end
            
        case 'MRI' % ------------------------------------------------------
            %% load data
            % type of data: fid - fdf - absval (analyse, nifti,...)
            % get selection of real(=4),imag(=3), absval(=2), fdf , phase(=1)
            orient = mainhandles.datalist(dataidx).params.rotation;
            RO_dim = mainhandles.datalist(dataidx).params.RO_dim;
            PE_dim = mainhandles.datalist(dataidx).params.PE_dim;
            %             disp('%%%%% MULTIPLICITY %%%%%%%%%%')
            %             disp(mainhandles.datalist(dataidx).multiplicity)
            %             disp(size(mainhandles.datalist(dataidx).data.real))
            %             selidx
            switch selidx
                case {5,4,3,2} %real
                    
                    
                    
                    
                    %                     data.real=squeeze(mainhandles.datalist(dataidx).data.real(arrayidx,:,:));
                    %                     data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(arrayidx,:,:));
                    %                     if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    %                         datasz = size(data.real,1)*size(data.real,2);
                    %                         data1=(fftshift(fft2(fftshift(squeeze(data.real+1i.*data.imag)))));
                    %                         datasetstr='FFT';
                    %                     else
                    %                         datasetstr='raw data';
                    %                         data=data.real+1i.*data.imag;
                    %                     end
                    %                     'real'
                    temp.real=mainhandles.datalist(dataidx).data.real;
                    temp.imag=mainhandles.datalist(dataidx).data.imag;
                    if length(size(temp.real))==4 %4d data set: DTI
                        DWI_idx = get(mainhandles.dispopt_popupmenu_DWI,'Value');
                        temp2.real=squeeze(temp.real(arrayidx,:,:,DWI_idx));
                        temp2.imag=squeeze(temp.imag(arrayidx,:,:,DWI_idx));
                    elseif length(size(temp.real))==3
                        temp2.real=squeeze(temp.real(arrayidx,:,:));
                        temp2.imag=squeeze(temp.imag(arrayidx,:,:));
                    elseif length(size(temp.real))==2
                        disp('405 DISPLAYCONTROL: WARNING data 2D matrix******************')
                        disp('405 DISPLAYCONTROL: WARNING data 2D matrix******************')
                        temp2.real=squeeze(temp.real(:,:));
                        temp2.imag=squeeze(temp.imag(:,:));
                    end
                    clear temp;
                    %
                    if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                        %                         datasz = size(temp2.real,1)*size(temp2.real,2);
                        data=(fftshift(fft2(fftshift((temp2.real+1i.*temp2.imag)))));
                        datasetstr='FFT';
                    else
                        datasetstr='raw data';
                        data=temp2.real+1i.*temp2.imag;
                    end
                    clear temp2;
                    if selidx == 5 %real
                        data=real(data);%,dim1,dim2)))
                        datastr = ['real parts of ' datasetstr ' of'];
                    elseif selidx == 4 %imag
                        data=imag(data);%,dim1,dim2)))
                        datastr = ['imaginary parts of ' datasetstr ' of'];
                    elseif selidx == 3 %absval
                        data=abs(data);%,dim1,dim2)))
                        datastr = ['Absolute value parts of ' datasetstr ' of'];
                    elseif selidx == 2 %phase
                        data=angle(data);%,dim1,dim2)))
                        datastr = ['phase parts of ' datasetstr ' of'];
                    end
                    %                     mainhandles.datalist(dataidx).params.ppe = -6;
                    %                     disp('params.ppe DISPLAYCONTROL')
                    %                     disp(mainhandles.datalist(dataidx).params.ppe)
                    if mainhandles.datalist(dataidx).params.ppe ~= 0 && isfield(mainhandles.datalist(dataidx).params,'ppe')
                        shift = round(mainhandles.datalist(dataidx).params.ppe / (mainhandles.datalist(dataidx).params.lpe/mainhandles.datalist(dataidx).params.nv));
                        if mod(orient,2) == 1
                            shift = -shift;
                        end
                        %                        shift=-6;
                        dimToShift = PE_dim;%size(size(data),PE_dim)-1;
                        shiftsize = zeros(size(size(data)));
                        shiftsize(dimToShift) = shift;
                        %                        data = circshift(data,shiftsize);
                        data = circshift(data,shiftsize);
                    end
                case 1 %fdf
                    temp=mainhandles.datalist(dataidx).data.fdf;
                    if length(size(temp))==4 %4d data set: DTI
                        DWI_idx = get(mainhandles.dispopt_popupmenu_DWI,'Value');
                        data=squeeze(temp(arrayidx,:,:,DWI_idx));
                    else
                        data=squeeze(temp(arrayidx,:,:));
                    end
                    datasetstr='FFT';
                    
                    datastr = ['FDF parts of ' datasetstr ' of'];
            end
            
            if exist('data','var')==0
                data = zeros(128,128);
                disp('no image data available')
            end
            
            %% correction
            %--- smooth & remove outlier in the center of the image, i.e. dc offset in the center
            %             remove_outlier=1;
            %             smoothall=0;
            %             if remove_outlier && sum(size(data)>4)>=2
            %                 mu = mean2(data); sigma = std2(data);
            %                 centerdata=data((size(data,1)/2-3):(size(data,1)/2+3),(size(data,2)/2-3):(size(data,2)/2+3));
            %                 [r c] = find(abs(centerdata-mu)>10*sigma);
            %                 data(size(data,1)/2-4+r,size(data,2)/2-4+c) = mean2(centerdata);
            %             end
            %             if smoothall
            %                 data = wiener2(data);
            %             end
            
            %--- plots ----------------------------------------------------------------
            figure(mainhandles.mainmenu)
            % %
            if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
                    mainhandles.datalist(dataidx).multiplicity>=1
                h_subplot(arrayidx) = axes('Parent',mainhandles.mainmenu_uipanel_axes,...
                    'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],...
                    'Position',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)]);
                plotdata = rot90(data,orient);
                mainhandles.currentplot(arrayidx) = imagesc(plotdata);
                set(mainhandles.currentplot(arrayidx),'UserData',plotdata);
                daspect([1 1 1])
                set(h_subplot(arrayidx),'XTick',[],'YTick',[],...
                    'Position',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)]);
                set(h_subplot(arrayidx),'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],'Position',csiaxespos(arrayidx,:))
                if arrayidx==mainhandles.datalist(dataidx).multiplicity
                    stop_plot=1;
                else
                    arrayidx=arrayidx+1;
                    clear data
                end
            else
                
                
                %             try
                %                 disp('******************3here******************3')
                %                 size(mainhandles.datalist(dataidx).data.real)
                %             catch %#ok<CTCH>
                %             end
                %                 plotdata = data;
                
                
                
                plotdata = rot90(data,orient);
                axes(mainhandles.axes1);
                mainhandles.currentplot=imagesc(plotdata);
                set(mainhandles.currentplot,'UserData',plotdata);
                lro=double(mainhandles.datalist(dataidx).params.lro);
                lpe=double(mainhandles.datalist(dataidx).params.lpe);
                pix=[0 0];
                pix(RO_dim) = lro/size(data,RO_dim);
                pix(PE_dim) = lpe/size(data,PE_dim);
                if mod(orient,2)==1
                    pix = flipdim(pix,2);
                end
                %             disp(size(data))
                %             disp(RO_dim)
                %             disp(PE_dim)
                daspect([[pix] 1]);
                set(gca,'Position',[0.05 0.05 0.9 0.9]);
                set(gca,'XTick',[],'YTick',[]) % ,'Selected','off','SelectionHighlight','off')
                colormap('gray')
                %                  colormap(char(mainhandles.dispopts.cmap))
                %                 if get(mainhandles.dispopt_radiobutton_cbar,'Value')
                %                     colorbar_axes = colorbar('peer',mainhandles.axes1);
                %                     set(colorbar_axes ,'Units','normalized','FontSize',8,...
                %                         'OuterPosition',[0 0 0.09 1],'yAxisLocation','left')
                %                 end
                stop_plot=1;
            end
            set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr ' image'],...
                'TitlePosition','centertop')
            %% case 'CSI'
        case 'CSI' % ------------------------------------------------------
            %             if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
            %                     mainhandles.datalist(dataidx).multiplicity>=1
            %                 set(findobj('Parent',mainhandles.mainmenu_uipanel_axes),'Visible','off')
            %             end
            %--- get data and apply apodization ---------------------
            if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
                    mainhandles.datalist(dataidx).multiplicity>=1
                data.real=squeeze(mainhandles.datalist(dataidx).data.real);
                data.imag=squeeze(mainhandles.datalist(dataidx).data.imag);
            else
                nv1_idx=floor((arrayidx-1)/size(mainhandles.datalist(dataidx).data.real,1))+1;
                nv2_idx=mod(arrayidx,size(mainhandles.datalist(dataidx).data.real,1));
                if nv2_idx==0
                    nv2_idx=size(mainhandles.datalist(dataidx).data.real,1);
                end
                % %                 %--- alternative1
                % %                 d.real=fftshift(fftshift(mainhandles.datalist(dataidx).data.real,1),2)
                % %                 d.imag=fftshift(fftshift(mainhandles.datalist(dataidx).data.imag,1),2)
                % %                 data.real=squeeze(d.real(nv1_idx,nv2_idx,:));
                % %                 data.imag=squeeze(d.imag(nv1_idx,nv2_idx,:));
                %--- alternative2
                row_idcs=fftshift(((1:size(mainhandles.datalist(dataidx).data.real,1))'*ones(1,size(mainhandles.datalist(dataidx).data.real,2))));
                col_idcs=fftshift((ones(size(mainhandles.datalist(dataidx).data.real,1),1)*(1:size(mainhandles.datalist(dataidx).data.real,2))));
                nv1_idx_shift=row_idcs(nv1_idx); % row_idcs(nv1_idx,1);
                nv2_idx_shift=col_idcs(nv2_idx); % col_idcs(1,nv2_idx);
                data.real=squeeze(mainhandles.datalist(dataidx).data.real(nv1_idx_shift,nv2_idx_shift,:));
                data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(nv1_idx_shift,nv2_idx_shift,:));
            end
            %--- postprocessing
            if isfield(mainhandles.datalist(dataidx),'process') && ...
                    ~isempty(mainhandles.datalist(dataidx).process)
                if ndims(data.real)>2
                    for idx1=1:size(data.real,1)
                        for idx2=1:size(data.real,2)
                            data_cur.real=squeeze(data.real(idx1,idx2,:));
                            data_cur.imag=squeeze(data.imag(idx1,idx2,:));
                            data = postprocessing(data_cur);
                        end
                    end
                else
                    data = postprocessing(data);
                end
            end
            %--- x-axes in time space -------------------------------------
            fid_length=length(data.real); %=mainhandles.datalist(dataidx).np/2;
            t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
            x_vec = t_vec;
            % calculation of x-axis for frequency-space
            cut = round(fid_length/2);
            df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
            f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing
            if isfield(mainhandles.dispopts,'refoffset')
                refoffset = mainhandles.dispopts.refoffset;
            else
                refoffset = 0;
            end
            if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0 % = FFT
                if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                    % warum minus zur Berechnung von ppm e.g. ppm_vec = f_vec_shifted./100.65; % at 9.4T
                    %                     ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.reffrq);
                    ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.sfrq);
                    % check if mainhandles.datalist(dataidx).param s.sfrq is not more correct
                    x_vec = ppm_vec;
                else % Hz
                    x_vec = flipdim(f_vec_shifted,1) + refoffset + df_vec ;
                end
            end
            %--- phasecorrection ------------------------------------------------------
            if mainhandles.switch.phasecorrection==1
            if isfield(mainhandles.datalist(dataidx),'process') && ...
                    ~isempty(mainhandles.datalist(dataidx).process)
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr0')
                    phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(arrayidx);
                else
                    phasecorr0=[];
                end
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr1')
                    phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(arrayidx);
                else
                    phasecorr1=[];
                end
                data = phasing(data, f_vec_shifted, phasecorr0, phasecorr1);
            end
            end
            %--- calculate FFT --------------------------------------------
            if isfield(mainhandles.datalist(dataidx).data,'real')==1
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    %                     datasz = fid_length; % prod(size(data.real)); % size(data.real,1)*size(data.real,2);
                    if get(mainhandles.dispopt_togglebutton_dispCSI,'Value')==0
                        data = 1/length(data.real)*fftshift(squeeze(fft(fftshift(data.real+1i*data.imag))));
                        %                         abs(max(data))
                    else
                        data=1/numel(data.real)*fftshift(fftshift(fftshift(fftn(fftshift(fftshift(data.real+1i.*data.imag,1),2)),1),2),3);
                        %                         data=fftshift(fftshift(fftshift(fftn(fftshift(fftshift(data.real+1i.*data.imag,1),2)),1),2),3);
                        %                         max(max(max(data)))
                    end
                    datasetstr='FFT';
                else
                    datasetstr='raw data';
                    data=data.real+1i.*data.imag;
                end
                switch selidx
                    case 4 % real
                        data=real(data);%,dim1,dim2)))
                        datastr = ['real parts of ' datasetstr ' of'];
                    case 3 % imag
                        data=imag(data);%,dim1,dim2)))
                        datastr = ['imaginary parts of ' datasetstr ' of'];
                    case 2 % absval
                        if get(mainhandles.dispopts_togglebutton_format_fdf,'Value') && ...
                                get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                            data = fft_data.*conj(fft_data);
                            datastr = ['power of ' datasetstr ' of'];
                        else
                            data=abs(data);
                            datastr = ['absolute value of ' datasetstr ' of'];
                        end
                    case 1 % phase
                        data=angle(data);%,dim1,dim2)))
                        datastr = ['phase of ' datasetstr ' of'];
                end
            end
            %--- prepare x-axis ----------------------------------------------------
            plotrange=1:length(data); % 1:round(length(data)/2-1); %(length(data)/2-1);%
            if mainhandles.dispopts.resetdisp==0
                % determine xlim
                xlim=mainhandles.dispopts.axesscaling.x(...
                    get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:); % =0 means 'FFT'
                if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 && ... % ppm
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0 % FFTed data
                    %                     xlim=sort((-xlim+refoffset)/(mainhandles.datalist(dataidx).params.reffrq));
                    xlim=sort((xlim+refoffset)/(mainhandles.datalist(dataidx).params.sfrq));
                    
                end
                if length(xlim)~=2 || xlim(2)<=xlim(1) % serves also as initialization
                    xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                        %                         mainhandles.dispopts.axesscaling.x(...
                        %                             get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                        %                             xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
                        %                             mainhandles.datalist(dataidx).ppm_ref;
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                            xlim.*(mainhandles.datalist(dataidx).params.sfrq)+...
                            mainhandles.datalist(dataidx).ppm_ref;
                    else
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=xlim;
                    end
                else
                    xmin=min(xlim);
                    xmax=max(xlim);
                    % now find next point in the x_vec
                    x_vec_asc=sort(x_vec,1,'ascend');
                    if isempty(x_vec_asc(find(x_vec_asc<=xmin,1,'last')))
                        % x_vec(min(find(flipdim(f_vec_shifted,1)<=xmin))) also works
                        xlim(1)=min(x_vec);
                    else
                        xlim(1)=x_vec_asc(find(x_vec_asc<=xmin,1,'last'));
                    end
                    if isempty(x_vec_asc(find(x_vec_asc>=xmax,1,'first')));
                        % x_vec(max(find(flipdim(f_vec_shifted,1)>=xmax)))) also works
                        xlim(2)=max(x_vec);
                    else
                        xlim(2)=x_vec_asc(find(x_vec_asc>=xmax,1,'first'));
                    end
                end
                % determine ylim
                ylim=mainhandles.dispopts.axesscaling.y(get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:);
                if length(ylim)~=2 || ylim(2)<=ylim(1)
                    ylim=1.1*[min(data(plotrange)) max(data(plotrange))];
                    mainhandles.dispopts.axesscaling.y(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:)=ylim;
                end
            else
                xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                    %                     mainhandles.dispopts.axesscaling.x(...
                    %                         get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                    %                         xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
                    %                         mainhandles.datalist(dataidx).ppm_ref;
                    mainhandles.dispopts.axesscaling.x(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                        xlim.*(mainhandles.datalist(dataidx).params.sfrq)+...
                        mainhandles.datalist(dataidx).ppm_ref;
                else
                    mainhandles.dispopts.axesscaling.x(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=xlim;
                end
                ylim=squeeze(1.1*[min(data(plotrange)) max(data(plotrange))]);
                mainhandles.dispopts.axesscaling.y(...
                    get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,selidx,:)=ylim;
            end
            % Notbremse
            if ylim(1)==ylim(2)
                disp('Notbremse')
                ylim(2)=ylim(1)+eps;
                ylim(1)=ylim(1)-eps;
            end
            if xlim(1)==xlim(2)
                disp('Notbremse')
                xlim(2)=xlim(1)+eps;
                xlim(1)=xlim(1)-eps;
            end
            %             disp('---')
            %             xlim
            %             mainhandles.dispopts.axesscaling.x
            %             mainhandles.dispopts.axesscaling.y
            % plots ---------------------------------
            figure(mainhandles.mainmenu)
            if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
                    mainhandles.datalist(dataidx).multiplicity>=1
                %                 ylim=[0 max(max(max(data)))];
                % subplot generates errors (no idea why)
                %                 h_subplot(arrayidx) = subplot(subplotdim(1),subplotdim(2),arrayidx);
                %                 set(h_subplot(arrayidx),'Parent',mainhandles.mainmenu_uipanel_axes,...
                %                     'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],...
                %                     'OuterPosition',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)])
                while stop_plot==0
                    nv1_idx=floor((arrayidx-1)/size(mainhandles.datalist(dataidx).data.real,1))+1;
                    nv2_idx=mod(arrayidx,size(mainhandles.datalist(dataidx).data.real,1));
                    if nv2_idx==0
                        nv2_idx=size(mainhandles.datalist(dataidx).data.real,1);
                    end
                    plotdata=squeeze(data(nv1_idx,nv2_idx,plotrange));
                    h_subplot(arrayidx) = axes('Parent',mainhandles.mainmenu_uipanel_axes,'XTick',[],'YTick',[],...
                        'Position',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)]);
                    %                     'YLim',ylim,'XLim',xlim,
                    mainhandles.currentplot(arrayidx) = plot(h_subplot(arrayidx),x_vec(plotrange),...
                        plotdata,'k','Tag',['currentplot_' num2str(arrayidx)]);
                    set(mainhandles.currentplot(arrayidx),'UserData',plotdata);
                    if get(mainhandles.dispopt_radiobutton_grid,'Value')
                        grid on
                    else
                        grid off
                    end
                    set(h_subplot(arrayidx),'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],'Position',csiaxespos(arrayidx,:))
                    if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                        set(h_subplot(arrayidx),'XDir','reverse')
                    end
                    if arrayidx==mainhandles.datalist(dataidx).multiplicity
                        stop_plot=1;
                    else
                        arrayidx=arrayidx+1;
                        clear plotdata
                    end
                end
                plotdata = data;
            else
                if ishandle(mainhandles.axes1)==0
                    mainhandles.axes1=findobj('Parent',mainhandles.mainmenu_uipanel_axes,'Type','axes');
                end
                plotdata = data(plotrange);
                
                mainhandles.currentplot = plot(mainhandles.axes1,...
                    x_vec(plotrange),plotdata,'k','Tag','currentplot');
                set(mainhandles.currentplot,'UserData',plotdata);
                if get(mainhandles.dispopt_radiobutton_grid,'Value')
                    grid on
                else
                    grid off
                end
                set(gca,'Position',[0.05 0.05 0.9 0.9],'FontSize',8)
                set(mainhandles.axes1,'YLim',ylim,'XLim',xlim) % ,'Selected','off','SelectionHighlight','off')
                set(mainhandles.display_edit_ylim2,'String',num2str(max(ylim)))%,'Visible','on')
                set(mainhandles.display_edit_ylim1,'String',num2str(min(ylim)))%,'Visible','on')
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    set(mainhandles.axes1,'XDir','reverse')
                    set(mainhandles.display_edit_xlim1,'String',num2str(max(xlim)))%,'Visible','on')
                    set(mainhandles.display_edit_xlim2,'String',num2str(min(xlim)))%,'Visible','on')
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0
                        set(get(mainhandles.axes1,'XLabel'),'String','frequency [ppm]')
                        %                         set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'Spectrum'])
                        set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'Spectrum'],...
                            'TitlePosition','centertop')
                    else
                        set(get(mainhandles.axes1,'XLabel'),'String','frequency [Hz]')
                        %                         set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'Spectrum'])
                        set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'Spectrum'],...
                            'TitlePosition','centertop')
                    end
                else
                    set(get(mainhandles.axes1,'XLabel'),'String','time [s]')
                    % set(get(mainhandles.axes1,'YLabel'),'String',[datastr 'FID'])
                    set(mainhandles.mainmenu_uipanel_axes,'Title',[datastr 'FID'],...
                        'TitlePosition','centertop')
                    set(mainhandles.display_edit_xlim1,'String',num2str(min(xlim)))%,'Visible','on')
                    set(mainhandles.display_edit_xlim2,'String',num2str(max(xlim)))%,'Visible','on')
                end
                stop_plot=1;
            end
            %% case otherwise
        otherwise % -------------------------------------------------------
            stop_plot=1;
            disp('Not implemented yet')
    end
end


%% update axes text
if exist('nv1_idx','var')==0 % size(mainhandles.datalist(dataidx).data.real,2)==1
    datenum_str=[num2str(dataidx) '|' num2str(arrayidx)];
else
    datenum_str=[num2str(dataidx) '|' num2str(nv1_idx) '|' num2str(nv2_idx)];
end
if isfield(mainhandles.datalist(dataidx),'sequence')
set(mainhandles.text_currentfile,'String', ['Data (' datenum_str ') : ' ...
    char(mainhandles.datalist(dataidx).sequence) ' (' mainhandles.datalist(dataidx).liststring ')'])
else
    set(mainhandles.text_currentfile,'String', ['Data (' datenum_str ') : ' ...
     ' (' mainhandles.datalist(dataidx).liststring ')'])
end

mainhandles.dispopts.resetdisp=0;
guidata(findobj('Tag','mainmenu'),mainhandles);





