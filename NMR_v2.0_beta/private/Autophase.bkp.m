function Autophase(varargin)
mainhandles=guidata(findobj('Tag','mainmenu'));
close(findobj('Tag','processfig'))
clc
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
    fid(k,:) = data(k).real+sqrt(-1)*data(k).imag;
    
end

%% select peak
if  length(varargin)==0
    
    %%select reference scan idx
    a=gui_dataselect('b0',n_spectra);
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
    spectrum = real(fftshift(fft(squeeze(fid_phase),NFFT)));

    
    
    
    
    figure(mainhandles.mainmenu)
cla
hold off
plot(f_vec_shifted,spectrum)

% plot(spectrum)
% % set(gca,'XDir','reverse')
x=[0 ;0];
y=0;
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
        plot(f_vec_shifted(x_min:x_max),spectrum(x_min:x_max))
%         plot(spectrum(x_min:x_max))
%         
%         set(gca,'XDir','reverse')

    end
    
else
    x_min = varargin{1}(1);
    x_max = varargin{1}(2);
    ref_idx = varargin{1}(3);
                phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(ref_idx);
        phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(ref_idx);
    
    data_phase = phasing(squeeze(data(ref_idx)), f_vec_shifted, phasecorr0, phasecorr1);
    fid_phase = data_phase.real+sqrt(-1)*data_phase.imag;
    spectrum = real(fftshift(fft(squeeze(fid_phase),NFFT)));

end



% [a x_mean]=find(spectrum(x_min:x_max)==max(spectrum(x_min:x_max)));
% x_mean=x_mean+x_min;
% x_min=x_mean-5;
% x_max=x_mean+5;
% x_min=NFFT-x_min;
% a=NFFT-x_max;
% x_max=x_min;
% x_min=a;
%% create ref spectra
ref_fid = squeeze(fid(1,:))';
ph_ref(1) = deg2rad(mainhandles.datalist(dataidx).process.phasecorr0(ref_idx));
ph_ref(2) = (mainhandles.datalist(dataidx).process.phasecorr1(ref_idx))/1000;
phase_ref = (ph_ref(1)+ph_ref(2).*f_vec_shifted);
ref_fid_ph = ref_fid.*exp(phase_ref.*sqrt(-1));

%% autophase
% for i= 2:10%size(data,2)
%     phc=[0 0];
% %     lb = [-pi -100/1000];
% %     ub = [pi 100/1000];
%     lb = [-pi 0];
%     ub = [pi 0];
% %         options = saoptimset('PlotFcns',{@saplotbestx,@saplotbestf,@saplotx,@saplotf},'MaxIter',4000,'TimeLimit', 120);
%     options = saoptimset('MaxIter',5000,'TimeLimit', 240);
%     phcor = simulannealbnd(@(phc) myfunNMR2(phc,ref_fid_ph,squeeze(fid(i,:))',NFFT,f_vec_shifted), [0 0], lb, ub, options)
%
%     mainhandles.datalist(dataidx).process(i).phasecorr0 = rad2deg(phcor(1));
%     mainhandles.datalist(dataidx).process(i).phasecorr1 = phcor(2)*1000;
%
%
% end


%
h=waitbar(0,'Wait, zero order phase correction (peak maximaziation),...');
for i= 1:size(fid,1)
waitbar(i/size(fid,1));
%     phc=[0 0];
        phc=[deg2rad(mainhandles.datalist(dataidx).process.phasecorr0(i));];
%     lb = [-pi -5/1000];
%     ub = [pi 5/1000];
    lb=-pi;
    ub=pi;
    %     options = saoptimset('PlotFcns',{@saplotbestx,@saplotbestf,@saplotx,@saplotf},'MaxIter',1000,'TimeLimit', 120);
    options = saoptimset('MaxIter',1500,'TimeLimit', 120);
%     phcor = simulannealbnd(@(phc) myfunNMR(phc,squeeze(fid(i,x_min:x_max))',f_vec_shifted(x_min:x_max)), phc, lb, ub, options)
    phcor = fminsearch(@(phc) myfunNMR(phc,squeeze(fid(i,x_min:x_max))',f_vec_shifted(x_min:x_max)), phc);
%     phcor = simulannealbnd(@(phc) myfunNMR(phc,squeeze(fid(i,x_min:x_max))',f_vec_shifted(x_min:x_max)), phc,lb,ub,options);

    if rad2deg(phcor(1))>180
        phcor(1)=phcor(1)-2*pi();
    elseif rad2deg(phcor(1))<-180
        phcor(1)=phcor(1)+2*pi();
    end
    
%     phcor(1)=-phcor(1);
%     rad2deg(phcor(1))
    mainhandles.datalist(dataidx).process.phasecorr0(i) = rad2deg(phcor(1));
%     mainhandles.datalist(dataidx).process.phasecorr1(i) = phcor(2)*1000;
    guidata(findobj('Tag','mainmenu'),mainhandles)
    x_min=NFFT-x_min;
a=NFFT-x_max;
x_max=x_min;
x_min=a;
    
    pp=-180:1:180;
    for p=1:length(pp)
        fid_ph=real((squeeze(fid(i,:))').*exp(-1i*deg2rad(pp(p))));
        spetrum= (fftshift(fft(squeeze(fid_ph))));
        peak_max(p) = max(real(spetrum(x_min:x_max)));
        
       
        if i==1 && mod(p,3)==1
             figure(3)
        hold on
        plot(f_vec_shifted,abs(spectrum),'k')
%         xlim([x_min-100 x_max+100])
        plot(f_vec_shifted(x_min:x_max),real(spetrum(x_min:x_max)),'r')
        hold off
        end
        
    end
    [a max_idx]=find(peak_max==max(peak_max));
    phcor_manual(1) = pp(max_idx);
%     rad2deg(phcor_manual(1))
    %%display result
%     lsfid=params.lsfid+1;
% %     phase_corr = (phcor(1)-phcor(2).*f_vec_shifted);
    phase_corr = phcor(1);
    fid_real =(squeeze(fid(i,:))').*exp(-1i*phcor);
    fid_manuel = (squeeze(fid(i,:))').*exp(-1i*phcor_manual);
    spetrum=(fftshift(fft(squeeze(fid(i,:))')));
    spetrum_real=real(fftshift(fft(fid_real)));
    spetrum_manuel=real(fftshift(fft(fid_manuel)));
    spetrum_abs=abs(spetrum);
    if i<17
        figure(1)
        subplot(4,4,i)
        cla;
        hold on
        plot(f_vec_shifted,spetrum_real,'r')
        plot(f_vec_shifted,spetrum_abs,'b')
        plot(f_vec_shifted,spetrum_manuel,'g')
%         set(gca,'XDir','reverse')
        hold off
        
                figure(2)
        subplot(4,4,i)
        cla;
        hold on
        plot(f_vec_shifted(x_min:x_max),spetrum_real(x_min:x_max),'r')
        plot(f_vec_shifted(x_min:x_max),spetrum_abs(x_min:x_max),'b')
        plot(f_vec_shifted(x_min:x_max),spetrum_manuel(x_min:x_max),'g')
%         set(gca,'XDir','reverse')
        hold off
    end
    [i x_min x_max] 
    [rad2deg(phcor(1)) rad2deg(phcor_manual(1))]
    
    % waitbar(i/size(data,2))
end
close(h)

GUI_Process
prochandles=guidata(findobj('Tag','processfig'));
set(prochandles.processfig_togglebutton_appltoarray1,'Value',0);
mainhandles.datalist(dataidx).process.appltoarray1=0;
guidata(findobj('Tag','processfig'),prochandles);


%% display result
% figure(1)
% hold on
% for i= 1:10%size(data,2)
%     phc(1)=0%deg2rad(mainhandles.datalist(dataidx).process(i).phasecorr0);
%     phc(2)=0%(mainhandles.datalist(dataidx).process(i).phasecorr1)/1000;
%     phase_corr = (phc(1)+phc(2).*f_vec_shifted);
% % phase_corr = (phc(1)+2*pi*phc(2).*f_vec_shifted);
%
%     fid_ph=squeeze(fid(i,:))'.*exp(phase_corr.*sqrt(-1));
%     spectra_ph=real(fftshift(fft(fid_ph(:),NFFT)));
%     plot(spectra_ph)
%     clear phc phase_corr fid_ph spectra_ph
% end
% hold off
% figure(2)
% hold on
% for i= 1:10%size(data,2)
%     phc(1)=deg2rad(mainhandles.datalist(dataidx).process(i).phasecorr0);
%     phc(2)=(mainhandles.datalist(dataidx).process(i).phasecorr1)/1000;
%     phase_corr = (phc(1)+phc(2).*f_vec_shifted);
% % phase_corr = (phc(1)+2*pi*phc(2).*f_vec_shifted);
%
%     fid_ph=squeeze(fid(i,:))'.*exp(phase_corr.*sqrt(-1));
%     spectra_ph=real(fftshift(fft(fid_ph(:),NFFT)));
%     plot(spectra_ph)
%     clear phc phase_corr fid_ph spectra_ph
% end
% hold off






% for k=1:size(data,2)
% mainhandles.datalist(dataidx).process.apodizefct = apodizefct;
% mainhandles.datalist(dataidx).process.apodparam1 = apodparam1;
% mainhandles.datalist(dataidx).process.apodparam2 = apodparam2;
% end
disp('**************** Autophase completed ****************')
guidata(findobj('Tag','mainmenu'),mainhandles)


function E = myfunNMR(phc,fid,f_vec_shifted)

% phase_corr = (phc(1)-phc(2).*f_vec_shifted);
% %         phase_corr = (phc(1)+2*pi*phc(2).*f_vec_shifted);
        phase_corr =phc(1);

%         spectra=fftshift(fft(fid_ph(1:NFFT),NFFT));
fid = fid.*exp(-1i.*phase_corr);
spectra=fftshift(fft(fid(:)));
spectra_abs=abs(spectra);
spectra_ph = real(spectra);
E=-sum(spectra_ph);

figure(5)
hold on
plot(f_vec_shifted,spectra_ph,'b')
plot(f_vec_shifted,spectra_abs,'r')
plot(f_vec_shifted(round(length(f_vec_shifted)/2)),E,'xg')
hold off



%         R = real(spectra_ph([500 2500])); % 2200:NFFT
% R = real(spectra_ph);%./max(abs(spectra_ph));
% 
% h=abs(R.^m)./sum(abs(R.^m));
% 
% P=gamm*(sum((R(R<0).^2)));
% 
% e = h.*log(h);
% for j=1:size(e,1)
%     if isnan(e(j))==1
%         e(j)=0;
%     end
% end
% %         sum(e)
% E=-sum(e)+P;


