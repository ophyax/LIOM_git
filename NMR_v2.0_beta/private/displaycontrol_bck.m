function displaycontrol




mainhandles=guidata(findobj('Tag','mainmenu'));
set(0,'CurrentFigure',mainhandles.mainmenu)
current_fig = gcf;

dataidx = mainhandles.dispopts.dataidx;

if mainhandles.datalist(dataidx).loaded ~=1 
    load_data('displaycontrol')
end

%% things to do when the content of the mainaxes was changed --------------
if mainhandles.switch.phasecorrection==0 || mainhandles.switch.apodization==0 || mainhandles.switch.transformsize==0
    % update number of points in static processfig_text_np
    if isempty(findobj('Tag','processfig'))==0
        processfig_handles=guidata(findobj('Tag','processfig'));
        set(processfig_handles.processfig_text_np,'String',['transform size of FID ' num2str(mainhandles.datalist(mainhandles.dispopts.dataidx).np/2) ' points to'])
    end
end

%%  store current axes limits ---------------------------------------------
all_curaxes=findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes);
% all_curaxes_list=get(findobj('Type','axes','Parent',mainhandles.mainmenu_uipanel_axes),'Tag');
% findstr('display_axes',all_curaxes_list);
if isempty(all_curaxes)==0
    xlim=get(all_curaxes(1),'XLim');
    ylim=get(all_curaxes(1),'YLim');
end

%% Preparation normal mode or CSI mode ------------------------------------
dataidx = mainhandles.dispopts.dataidx;
if isempty(findstr(upper(mainhandles.datalist(dataidx).acqtype),'CSI'))==0
    set(mainhandles.dispopt_togglebutton_dispCSI,'Value',1);
end
% if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
%         mainhandles.datalist(dataidx).multiplicity>=1
if mainhandles.datalist(dataidx).multiplicity>=1
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

% get selection of real(=4),imag(=3), absval(=2), phase(=1)
selidx=find(cell2mat(get(get(mainhandles.dispopts_uipanel_dataformat,'children'),'Value'))==1);


stop_plot=0;
while stop_plot==0
    apptype_string = upper(mainhandles.datalist(dataidx).acqtype);
    switch apptype_string
%% case 'MRS'
        case {'MRS', 'PRESCAN'} % ------------------------------------------------------
            %             if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
            %                     mainhandles.datalist(dataidx).multiplicity>=1
            %                 set(findobj('Parent',mainhandles.mainmenu_uipanel_axes),'Visible','off')
            %             end
            %--- get data and apply apodization ---------------------
            if size(mainhandles.datalist(dataidx).data.real,2)==1
                data.real=squeeze(mainhandles.datalist(dataidx).data.real(arrayidx,:,:));
                data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(arrayidx,:,:));
            else
                nv1_idx=floor((arrayidx-1)/size(mainhandles.datalist(dataidx).data.real,1))+1;
                nv2_idx=mod(arrayidx,size(mainhandles.datalist(dataidx).data.real,1));
                if nv2_idx==0
                    nv2_idx=size(mainhandles.datalist(dataidx).data.real,1);
                end
                data.real=squeeze(mainhandles.datalist(dataidx).data.real(nv1_idx,nv2_idx,:));
                data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(nv1_idx,nv2_idx,:));
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
                    ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.reffrq);
                    % check if mainhandles.datalist(dataidx).param s.sfrq is not more correct
                    x_vec = ppm_vec;
                else % Hz
                    x_vec = flipdim(f_vec_shifted,1) + refoffset + df_vec ;
                end
            end            
            %--- phasecorrection ------------------------------------------------------           
            if isfield(mainhandles.datalist(dataidx),'process') && ...
                    ~isempty(mainhandles.datalist(dataidx).process)
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr0')
                    phasecorr0=mainhandles.datalist(dataidx).process(arrayidx).phasecorr0;
                else
                    phasecorr0=[];
                end
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr1')
                    phasecorr1=mainhandles.datalist(dataidx).process(arrayidx).phasecorr1;
                else
                    phasecorr1=[];
                end
                data = phasing(data, f_vec_shifted, phasecorr0, phasecorr1);
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
            %--- calculate FFT --------------------------------------------
            if isfield(mainhandles.datalist(dataidx).data,'real')==1
%                 dtot=[data.real data.imag];
%                 save('fid_02.txt','dtot','-ascii')
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    datasz = size(data.real,1)*size(data.real,2);
                    fid=data.real+sqrt(-1)*data.imag;
                    data = 1/length(data.real)*fftshift(squeeze(fft(fid)));
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
                    xlim=sort((-xlim+refoffset)/(mainhandles.datalist(dataidx).params.reffrq));
                end
                if length(xlim)~=2 || xlim(2)<=xlim(1) % serves also as initialization
                    xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                            xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
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
                    mainhandles.dispopts.axesscaling.x(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                        xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
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
%% case 'MRI'
        case 'MRI' % ------------------------------------------------------
            showfdf=0;
            if isfield(mainhandles.datalist(dataidx).data,'real')==1
                data.real=squeeze(mainhandles.datalist(dataidx).data.real(arrayidx,:,:));
                data.imag=squeeze(mainhandles.datalist(dataidx).data.imag(arrayidx,:,:));
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    datasz = size(data.real,1)*size(data.real,2);
                    data=rot90(fftshift(fft2(fftshift(squeeze(data.real+1i.*data.imag)))),1);
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
                            showfdf=1;                            
                        else
                            data=abs(data);
                            datastr = ['absolute value of ' datasetstr ' of'];
                        end
                    case 1 % phase
                        data=angle(data);%,dim1,dim2)))
                        datastr = ['phase of ' datasetstr ' of'];
                end
            end
            if showfdf==1
                if isfield(mainhandles.datalist(dataidx).data,'absval')==1
                    data=squeeze(mainhandles.datalist(dataidx).data.absval(arrayidx,:,:));
                    data=fliplr(rot90(data,-1));
                    datastr = 'prereconstructed';
                    if isfield(mainhandles.datalist(dataidx).data,'real')==0
                        disp('raw data does not exist')
                    end
                else
                    data=abs(data);
                    datastr = ['absolute value of ' datasetstr ' of'];
                    set(mainhandles.dispopts_togglebutton_format_fdf,'Value',0)
                    disp('image not available in "fdf" fromat')
                end
            end
            if exist('data','var')==0
                data = zeros(128,128);
                disp('no image data available')
            end
            %--- smooth & remove outlier in the center of the image, i.e. dc offset in the center
            remove_outlier=1;
            smoothall=0;
            if remove_outlier && sum(size(data)>4)>=2
                mu = mean2(data); sigma = std2(data);
                centerdata=data((size(data,1)/2-3):(size(data,1)/2+3),(size(data,2)/2-3):(size(data,2)/2+3));
                [r c] = find(abs(centerdata-mu)>10*sigma);
                data(size(data,1)/2-4+r,size(data,2)/2-4+c) = mean2(centerdata);
            end
            if smoothall
                data = wiener2(data);
            end
            %--- plots ----------------------------------------------------------------
            figure(mainhandles.mainmenu)
            if get(mainhandles.dispopt_togglebutton_dispCSI,'Value') && ...
                    mainhandles.datalist(dataidx).multiplicity>=1
                h_subplot(arrayidx) = axes('Parent',mainhandles.mainmenu_uipanel_axes,...
                    'YLim',ylim,'XLim',xlim,'XTick',[],'YTick',[],...
                    'Position',[csiaxespos(length(h_subplot),1:2) 0.5*csiaxespos(length(h_subplot),3:4)]);
                plotdata = data;
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
                plotdata = data;
                axes(mainhandles.axes1)
                mainhandles.currentplot=imagesc(plotdata);
                set(mainhandles.currentplot,'UserData',plotdata);
                lro=mainhandles.datalist(dataidx).params.lro;
                lpe=mainhandles.datalist(dataidx).params.lpe;
                pix_dy = lro/size(data,1);
                pix_dx = lpe/size(data,2);
                daspect([pix_dy pix_dx 1])
                set(gca,'Position',[0.05 0.05 0.9 0.9])
                set(gca,'XTick',[],'YTick',[]) % ,'Selected','off','SelectionHighlight','off')
                colormap(char(mainhandles.dispopts.cmap))
                if get(mainhandles.dispopt_radiobutton_cbar,'Value')
                    colorbar_axes = colorbar('peer',mainhandles.axes1);
                    set(colorbar_axes ,'Units','normalized','FontSize',8,...
                        'OuterPosition',[0 0 0.09 1],'yAxisLocation','left')
                end
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
                    ppm_vec = (-f_vec_shifted+refoffset)/(mainhandles.datalist(dataidx).params.reffrq);
                    % check if mainhandles.datalist(dataidx).param s.sfrq is not more correct
                    x_vec = ppm_vec;
                else % Hz
                    x_vec = flipdim(f_vec_shifted,1) + refoffset + df_vec ;
                end
            end
            %--- phasecorrection ------------------------------------------------------           
            if isfield(mainhandles.datalist(dataidx),'process') && ...
                    ~isempty(mainhandles.datalist(dataidx).process)
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr0')
                    phasecorr0=mainhandles.datalist(dataidx).process(arrayidx).phasecorr0;
                else
                    phasecorr0=[];
                end
                if isfield(mainhandles.datalist(dataidx).process,'phasecorr1')
                    phasecorr1=mainhandles.datalist(dataidx).process(arrayidx).phasecorr1;
                else
                    phasecorr1=[];
                end
                data = phasing(data, f_vec_shifted, phasecorr0, phasecorr1);
            end
            %--- calculate FFT --------------------------------------------
            if isfield(mainhandles.datalist(dataidx).data,'real')==1
                if get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')==0
                    %                     datasz = fid_length; % prod(size(data.real)); % size(data.real,1)*size(data.real,2);
                    if get(mainhandles.dispopt_togglebutton_dispCSI,'Value')==0
                        data = 1/length(data.real)*fftshift(squeeze(fft(fftshift(data.real+i*data.imag))));
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
                    xlim=sort((-xlim+refoffset)/(mainhandles.datalist(dataidx).params.reffrq));
                end
                if length(xlim)~=2 || xlim(2)<=xlim(1) % serves also as initialization
                    xlim=[min(x_vec(plotrange)) max(x_vec(plotrange))];
                    if get(mainhandles.dispopts_togglebutton_format_ppmhz,'Value')==0 % ppm
                        mainhandles.dispopts.axesscaling.x(...
                            get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                            xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
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
                    mainhandles.dispopts.axesscaling.x(...
                        get(mainhandles.dispopts_togglebutton_format_rawfft,'Value')+1,:)=...
                        xlim.*(mainhandles.datalist(dataidx).params.reffrq)+...
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
    end
end


%% update axes text 
if exist('nv1_idx','var')==0 % size(mainhandles.datalist(dataidx).data.real,2)==1
    datenum_str=[num2str(dataidx) '|' num2str(arrayidx)];
else
    datenum_str=[num2str(dataidx) '|' num2str(nv1_idx) '|' num2str(nv2_idx)];
end
set(mainhandles.text_currentfile,'String', ['Data (' datenum_str ') : ' ...
    char(mainhandles.datalist(dataidx).sequence) ' (' mainhandles.datalist(dataidx).liststring ')'])


% set(findobj('Parent',mainhandles.mainmenu_uipanel_axes,'Type','axes'),'Visible','off')
%%  in case that apodization or postprocessing was performed switch back to GUI_process = 'processfig
% update the Gui_process figure with current values of apodization
if ~isempty(findobj('Tag','processfig')) && (strcmp(apptype_string,'MRS') || strcmp(apptype_string,'CSI'))
    process_fig = guidata(findobj('Tag','processfig'));
    try,
        apodizefct=mainhandles.datalist(dataidx).process(arrayidx).apodizefct;
        apodparam1=mainhandles.datalist(dataidx).process(arrayidx).apodparam1;
        apodparam2=mainhandles.datalist(dataidx).process(arrayidx).apodparam2;
        phasecorr0 = mainhandles.datalist(dataidx).process(arrayidx).phasecorr0;
        phasecorr1 = mainhandles.datalist(dataidx).process(arrayidx).phasecorr1;
    catch,
        mainhandles.datalist(dataidx).process(arrayidx).apodizefct ='exponential'
        mainhandles.datalist(dataidx).process(arrayidx).apodparam1=0;
        mainhandles.datalist(dataidx).process(arrayidx).apodparam2=0;
        mainhandles.datalist(dataidx).process(arrayidx).phasecorr0=0;
        mainhandles.datalist(dataidx).process(arrayidx).phasecorr1=0;
        apodizefct=mainhandles.datalist(dataidx).process(arrayidx).apodizefct;
        apodparam1=mainhandles.datalist(dataidx).process(arrayidx).apodparam1;
        apodparam2=mainhandles.datalist(dataidx).process(arrayidx).apodparam2;
        phasecorr0 = mainhandles.datalist(dataidx).process(arrayidx).phasecorr0;
        phasecorr1 = mainhandles.datalist(dataidx).process(arrayidx).phasecorr1;
    end
        

    idx=find(ismember(get(process_fig.processfig_popupmenu_apodfunction,'String'),apodizefct));
    set(process_fig.processfig_popupmenu_apodfunction,'Value',idx)
    set(process_fig.processfig_edit_apodparam1,'String',num2str(apodparam1))
    set(process_fig.processfig_slider_apodparam1,'Value',apodparam1)
    set(process_fig.processfig_edit_apodparam2,'String',num2str(apodparam2))
    set(process_fig.processfig_slider_apodparam2,'Value',apodparam2)

    set(process_fig.processfig_edit_phasecorr0,'String',num2str(phasecorr0))
    set(process_fig.processfig_slider_phasecorr0,'Value',phasecorr0)
    set(process_fig.processfig_edit_phasecorr1,'String',num2str(phasecorr1))
    set(process_fig.processfig_slider_phasecorr1,'Value',phasecorr1)
    
    set(process_fig.processfig_edit_lsfid,'String',num2str(mainhandles.datalist(dataidx).process(arrayidx).lsfid))


    if strcmp(get(current_fig,'Tag'),'processfig')
        figure(current_fig);
    end
end

%% set switches back to 0
mainhandles.switch.phasecorrection=0;
mainhandles.switch.apodization=0;
mainhandles.switch.transformsize=0;
mainhandles.dispopts.resetdisp=0;
guidata(mainhandles.mainmenu,mainhandles)

try
    mainhandles.datalist(dataidx).params.seqfil{1}
    mainhandles.datalist(dataidx).params.time_run{1}
    mainhandles.datalist(dataidx).params.tn{1}
    mainhandles.datalist(dataidx).params.resto
    mainhandles.datalist(dataidx).params.p1pat{1}
    mainhandles.datalist(dataidx).params.nt
catch
end



