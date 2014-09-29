function Autophase(varargin)
clc;
mainhandles=guidata(findobj('Tag','mainmenu'));
% close(findobj('Tag','processfig'))
display=1;
%get data index
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx; %1?

%get current diplayed data
temp.real = squeeze(mainhandles.datalist(dataidx).data.real);
temp.imag = squeeze(mainhandles.datalist(dataidx).data.imag);
params=mainhandles.datalist(mainhandles.dispopts.dataidx).params;


if sum(find(size(temp.real)==params.np/2)==2)
    n_spectra=size(temp.real,1);
    NFFT = size(temp.real,2);
    temp.real=temp.real';
    temp.imag=temp.imag';
    
elseif find(size(temp.real)==params.np/2)==1 %% only one spectra
    n_spectra=size(temp.real,2);
    NFFT = size(temp.real,1);
end

%% set parameters for postprocessing
lsfid = mainhandles.datalist(dataidx).process.lsfid;

fid_length=length(temp(1).real); %=mainhandles.datalist(dataidx).np/2;
t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
cut = round(fid_length/2);
df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
f_vec_shifted = df_vec.*((0:fid_length-1)'-cut);


%% set postprocessing switches required for autohphase
mainhandles.switch_bkp = mainhandles.switch;
guidata(findobj('Tag','mainmenu'),mainhandles);


%% prepare data with current postprocessing
fid=zeros(n_spectra,NFFT);
spectrum=zeros(1,NFFT);
for k =1:n_spectra
    
    data(k).real = squeeze(temp.real(:,k));
    data(k).imag = squeeze(temp.imag(:,k));
    data(k) = postprocessing(squeeze(data(k)),dataidx,arrayidx);
    fid_raw(k,:) = data(k).real+sqrt(-1)*data(k).imag;
    
end

%% select peak


%%select reference scan idx
a=gui_dataselect('b0',n_spectra,'autophase');
if length(varargin)==3
    set(a.listbox,'Value',varargin{1}(3))  %% set value to b0_cal ref idx
end
uiwait(a);
if ~isempty(findobj('Tag','dataselect'))
    h=guidata(a);
    ref_idx = get(h.listbox,'Value');
    mainhandles.switch.phasecorrection=h.switch.phasecorrection;
    mainhandles.switch.apodization=h.switch.apodization;
    mainhandles.switch.transformsize=h.switch.transformsize;
    mainhandles.switch.lsfid=h.switch.lsfid;
    mainhandles.switch.dcoffset=h.switch.dcoffset;
    mainhandles.switch.b0=h.switch.b0;
    mainhandles.switch.method=h.switch.method;
    delete(a)
    clear h
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end


phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(ref_idx);
phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(ref_idx);

data_phase = phasing(squeeze(data(ref_idx)), f_vec_shifted, phasecorr0, phasecorr1);
fid_phase = data_phase.real+sqrt(-1)*data_phase.imag;
spectrum_ref = real(fftshift(fft(squeeze(fid_phase),NFFT)));


%% swithc methods  {{'Peak max'} {'Comp to  abs'} {'Entropy'}};
switch mainhandles.switch.method
    case {'Peak max' 'Comp to  abs'}  
        if  length(varargin)==0
            figure(mainhandles.mainmenu)
            cla
            hold off
            plot(f_vec_shifted,spectrum_ref)
            
            % plot(spectrum)
            % % set(gca,'XDir','reverse')
            x=[0 ;0];
            y=0;
            
         if strcmp(mainhandles.switch.method,'Peak max')==1
            hhelp=helpdlg({'Select a singlet (e.g. Cr), by cliking around it' '(press enter to zoom between the two points)' 'When finished, press enter'},'Peak selection');
         
        elseif strcmp(mainhandles.switch.method,'Comp to  abs')==1
            hhelp=helpdlg({'Select a region (e.g. Tau-Cr), by cliking around it' '(press enter to zoom between the two points)' 'When finished, press enter'},'Peak selection');
        end
            
            
            %%%%%%%%%%%%%%%% selection of a singlet
            while size(x,1)>1
                [x,y]=getpts(mainhandles.mainmenu);
                if size(x,1)<2
                    break
                end
                for i=1:length(f_vec_shifted)
                    if f_vec_shifted(i)==x(1) || (f_vec_shifted(i)<x(1) && f_vec_shifted(i+1)>x(1))
                        x_min=i;
                    end
                    if f_vec_shifted(i)==x(2) || (f_vec_shifted(i)<x(2) && f_vec_shifted(i+1)>x(2))
                        x_max=i;
                    end
                end
                figure(mainhandles.mainmenu)
                plot(f_vec_shifted(x_min:x_max),spectrum_ref(x_min:x_max))
                
            end
            
            if isempty(hhelp)
                close(hhelp)
            end
            
        else
            x_min = varargin{1}(1);
            x_max = varargin{1}(2);
            phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(ref_idx);
            phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(ref_idx);
            data_phase = phasing(squeeze(data(ref_idx)), f_vec_shifted, phasecorr0, phasecorr1);
            fid_phase = data_phase.real+sqrt(-1)*data_phase.imag;
            spectrum_ref = real(fftshift(fft(squeeze(fid_phase),NFFT)));
            
        end
        
        if display ==1
            spectrum_raw = real(fftshift(fft(squeeze(fid_raw(ref_idx,:)),NFFT)));
            figure(1)
            hold on
            plot(f_vec_shifted,spectrum_ref,'r')
            plot(f_vec_shifted(x_min:x_max),spectrum_ref(x_min:x_max),'b')
            plot(f_vec_shifted(x_min:x_max),spectrum_raw(x_min:x_max),'g')
            hold off
        end
        
        if strcmp(mainhandles.switch.method,'Peak max')==1
            h=waitbar(0,'Wait, zero order phase correction (peak maximaziation),...');
         
        elseif strcmp(mainhandles.switch.method,'Comp to  abs')==1
            h=waitbar(0,'Wait, zero order phase correction (Comparaison to absolute spectrum),...');
        end
        
        
        
        pp=-180:1:180;
        max_spec = zeros(1,length(pp));
        for i= 1:size(fid_raw,1)
%             fid = squeeze(fid_raw(i,:));
            for p=1:length(pp)
                waitbar((p+(i-1)*length(pp))/(size(fid_raw,1)*length(pp)))
                fid=squeeze(fid_raw(i,:)).*exp(-1i*deg2rad(pp(p)));
                spectrum_ph= real(fftshift(fft(fid,NFFT)));
                spectrum_abs= abs(fftshift(fft(fid,NFFT)));
                max_spec(p)=max(spectrum_ph(x_min:x_max));
                test(p)=sum(spectrum_abs(x_min:x_max)-spectrum_ph(x_min:x_max));
                if display==1 && i==1 && mod(p,5)==0 && p<9*9*5
                    figure(2)
                    subplot(9,9,round(p/5))
                    hold on
                    plot(f_vec_shifted(x_min:x_max),spectrum_ph(x_min:x_max),'r');
                    plot(f_vec_shifted(x_min:x_max),spectrum_abs(x_min:x_max),'g');
                    hold off
                end
                
            end
            
            [a max_idx]=find(max_spec==max(max_spec));
            phcor_manual(1) = pp(max_idx);
            [a min_idx]=find(test==min(test));
            phcor_manual2(1) = pp(min_idx);
            
            fid_final=squeeze(fid_raw(i,:)).*exp(-1i*deg2rad(pp(max_idx)));
            spectrum_final= real(fftshift(fft(fid_final,NFFT)));
            if display ==1
                figure(3)
                cla;
                hold on
                plot(f_vec_shifted,spectrum_ref,'r')
                plot(f_vec_shifted(x_min:x_max),spectrum_final(x_min:x_max),'b')
                hold off
                figure(4)
                cla;
                plot(f_vec_shifted,spectrum_final,'b')
            end
            
            if strcmp(mainhandles.switch.method,'Peak max')==1
                mainhandles.datalist(dataidx).process.phasecorr0(i) = phcor_manual;
            elseif strcmp(mainhandles.switch.method,'Comp to  abs')==1
                mainhandles.datalist(dataidx).process.phasecorr0(i) = phcor_manual2;
            end
            i
        end
        if ishandle(h)
            close(h)
        end
        
    case 'Entropy'
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  entropy  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
        disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  entropy  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
            phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(ref_idx);
            phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(ref_idx);
            data_phase = phasing(squeeze(data(ref_idx)), f_vec_shifted, phasecorr0, phasecorr1);
            fid_phase = data_phase.real+sqrt(-1)*data_phase.imag;
            spectrum_ref = real(fftshift(fft(squeeze(fid_phase),NFFT)));
            spectrum_ref_abs= abs(fftshift(fft(squeeze(fid_phase),NFFT)));
            if display ==1
                figure(1)
                cla
                hold on
%                 plot(f_vec_shifted,spectrum_ref_abs,'b')
                plot(f_vec_shifted,spectrum_ref_abs,'b')
                plot(f_vec_shifted(1:ceil(length(spectrum_ref_abs)/10)),spectrum_ref_abs(1:ceil(length(spectrum_ref_abs)/10)),'r')
                hold off
            end
            
            thres.noise.mean=mean(spectrum_ref_abs(1:ceil(length(spectrum_ref_abs)/10)));
            thres.noise.std=std(spectrum_ref_abs(1:ceil(length(spectrum_ref_abs)/10)));
            thres.peak.max = max(spectrum_ref_abs);
            thres_val=thres.noise.mean+6*thres.noise.std;
            
            if thres_val>0.4*thres.peak.max
                disp('thes to high')
                thres_val=0.4*thres.peak.max;
            end
            [start_wat a]=find(spectrum_ref_abs>thres_val,1,'first');
            [start_met a]=find(spectrum_ref_abs((start_wat+1):length(spectrum_ref))<thres_val,1,'first');
            [end_met a]=find(flipdim(spectrum_ref_abs,1)>thres_val,1,'first');
            end_met = length(spectrum_ref_abs)-end_met;
            start_met = start_wat+start_met+round(length(spectrum)/100);
            start_wat = start_wat-round(length(spectrum)/100);
%             end_met = length(spectrum_ref_abs);
%             start_met = 1;
            thres.peak.start=start_met;
            thres.peak.end=end_met;
            if display ==1
                  figure(1)
                  hold on
                  plot(f_vec_shifted(start_met),spectrum_ref_abs(start_met),'Xg')
                  plot(f_vec_shifted(end_met),spectrum_ref_abs(end_met),'Xg')
                   line([f_vec_shifted(start_wat) f_vec_shifted(start_wat)],[min(spectrum_ref) max(spectrum_ref_abs)],'LineWidth',2,'Color',[0 1 0]);
                  line([f_vec_shifted(start_met) f_vec_shifted(start_met)],[min(spectrum_ref) max(spectrum_ref_abs)],'LineWidth',2,'Color',[1 0 0]);
                  line([f_vec_shifted(end_met) f_vec_shifted(end_met)],[min(spectrum_ref) max(spectrum_ref_abs)],'LineWidth',2,'Color',[1 0 0])
                  hold off
            end
            
            phc = [0];
            lb = [-pi];
            ub = [pi];
            gamma = 5e-5;
            options = saoptimset('MaxIter',1500,'TimeLimit', 120);
            for i= 1:size(fid_raw,1)     
                phcor_entrop = simulannealbnd(@(phc) entropy_phase(phc,squeeze(fid_raw(i,[1:start_wat start_met:length(spectrum_ref)]))',f_vec_shifted([1:start_wat start_met:length(spectrum_ref)]),gamma), phc, lb, ub, options)
                mainhandles.datalist(dataidx).process.phasecorr0(i) = rad2deg(phcor_entrop);   
            end
            
end

guidata(findobj('Tag','mainmenu'),mainhandles);

function E=entropy_phase(phc,fid,f_vec_shifted,gamma)
    
    phc_cor=phc(1); %-f_vec_shifted.*phc(2)
    fid_phase = fid.*exp(-1i*phc_cor);
    spectrum = real(fftshift(fft(squeeze(fid_phase))));
    
    h = abs(spectrum)./sum(abs(spectrum));
    
    neg_idx=spectrum<0;
    
    P=gamma.*(sum(neg_idx.*spectrum.^2));
    
    E=-sum(h.*log(h))+P;
    
