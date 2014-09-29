function Autophase
mainhandles=guidata(findobj('Tag','mainmenu'));
clc
%get data index
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx; %1?

%get current diplayed data
temp.real = squeeze(mainhandles.datalist(dataidx).data.real);
temp.imag = squeeze(mainhandles.datalist(dataidx).data.imag);
params=mainhandles.datalist(mainhandles.dispopts.dataidx).params;

%% apodization
if mainhandles.datalist(dataidx).multiplicity==1
    temp.real=temp.real';
    temp.imag=temp.imag';
end

%store previsous apod
% for k=1:mainhandles.datalist(dataidx).multiplicity
    apodizefct = mainhandles.datalist(dataidx).process.apodizefct;
    apodparam1 = mainhandles.datalist(dataidx).process.apodparam1;
    apodparam2 = mainhandles.datalist(dataidx).process.apodparam2;
% end

    mainhandles.datalist(dataidx).process.apodizefct = 'exponential';
    mainhandles.datalist(dataidx).process.apodparam1 = 5;
    mainhandles.datalist(dataidx).process.apodparam2 = 0;
    guidata(findobj('Tag','mainmenu'),mainhandles)

for k =1:mainhandles.datalist(dataidx).multiplicity

    data(k).real = squeeze(temp.real(k,:))';
    data(k).imag = squeeze(temp.imag(k,:))';
    data(k) = postprocessing(squeeze(data(k)),dataidx,k);

    fid(k,:) = data(k).real+sqrt(-1)*data(k).imag;
    
%     NFFT = 2^nextpow2((params.np/2));
%         spectrum(k,:) = real(fftshift(fft(fid(k,:),NFFT)));
%         figure
%         plot(squeeze(spectrum(1,:)))
end
clear temp

NFFT = 2^nextpow2((params.np/2));

fid_length=length(data(1).real); %=mainhandles.datalist(dataidx).np/2;
t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
cut = round(fid_length/2);
df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
f_vec_shifted = df_vec.*((0:fid_length-1)'-cut);
% f_vec_shifted = ([(fid_length-1):-1:0]./fid_length)';
% h = waitbar(0,'Please wait... Autophasing in progression');

%%reset display
mainhandles.dispopts.ppmhz=0; % instead of hz
mainhandles.dispopts.mode = 'absval';
set(mainhandles.dispopts_togglebutton_format_ppmhz,'Value',1,'String','Hz');
set(mainhandles.dispopts_togglebutton_format_rawfft,'Value',0,'String','FFT / raw');
set(mainhandles.dispopts_radiobutton_format_absval,'Value',1);
% set(mainhandles.dispopts_togglebutton_format_fdf,'Value',0)
set(mainhandles.dispopt_radiobutton_grid,'Value',0);

mainhandles.dispopts.resetdisp=1;
mainhandles.dispopts.axesscaling.switch = 0;
mainhandles.dispopts.axesscaling.x=zeros(2,2);
mainhandles.dispopts.axesscaling.y=zeros(2,5,2);
% dispopt_radiobutton_axislim_Callback(hObject, eventdata, mainhandles);
guidata(mainhandles.mainmenu,mainhandles)
displaycontrol

h1 = helpdlg('Delimite signal area:');
set(mainhandles.mainmenu,'Visible','on')
[ys,xs]=ginput(2);
close(h1)

h2 = helpdlg('Thresold noise level:');
set(mainhandles.mainmenu,'Visible','on')
[yn,xn]=ginput(1);
close(h2)

% data=get(mainhandles.axes1,'UserData');
% size(data)
% xdata=get(mainhandles.currentplot,'XData');

dpoints_1 = find(((ys(1)+df_vec)>f_vec_shifted)&(f_vec_shifted>(ys(1)-df_vec)));
dpoints_2 = find(((ys(2)+df_vec)>f_vec_shifted)&(f_vec_shifted>(ys(2)-df_vec)));

dpoints = [dpoints_1(1) dpoints_2(1)];
dpoints = sort(dpoints);

for i= 1:size(fid,1)
    phc=[0 0];
    lb = [-pi -10/1000];
    ub = [pi 10/1000];
%     options = saoptimset('PlotFcns',{@saplotbestx,@saplotbestf,@saplotx,@saplotf},'MaxIter',1000,'TimeLimit', 120);

    options = saoptimset('MaxIter',2500,'TimeLimit', 120);
    phcor = simulannealbnd(@(phc) myfunownphase(phc,squeeze(fid(i,:))',xn,dpoints,f_vec_shifted), phc, lb, ub, options)

    mainhandles.datalist(dataidx).process.phasecorr0(i) = rad2deg(phcor(1));
    mainhandles.datalist(dataidx).process.phasecorr1(i) = phcor(2)*1000;
    guidata(findobj('Tag','mainmenu'),mainhandles)
    lsfid=params.lsfid+1;
    phase_corr = (phcor(1)-phcor(2).*f_vec_shifted);
%     fid_phased=squeeze(fid(i,:))'
    spetrum_phased=real(fftshift(fft(squeeze(fid(i,:))')).*exp(-phase_corr.*sqrt(-1)));
    spetrum=real((fftshift(fft(squeeze(fid(i,:))'))));
    figure(2)
    cla;
    hold on
    plot(spetrum_phased,'r')
    plot(spetrum)
    set(gca,'XDir','reverse')
    hold off



% waitbar(i/size(data,2))
end
% close(h)


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
    mainhandles.datalist(dataidx).process.apodizefct = apodizefct;
    mainhandles.datalist(dataidx).process.apodparam1 = apodparam1;
    mainhandles.datalist(dataidx).process.apodparam2 = apodparam2;
% end
disp('**************** Autophase completed ****************')
disp([rad2deg(phcor(1)) phcor(2)*1000])
guidata(findobj('Tag','mainmenu'),mainhandles)

function E = myfunownphase(phc,fid,xn,dpoints,f_vec_shifted)

        phase_corr = (phc(1)-phc(2).*f_vec_shifted);
%         phase_corr = (phc(1)+2*pi*phc(2).*f_vec_shifted);
%         phase_corr =phc(1);

%         spectra=fftshift(fft(fid_ph(1:NFFT),NFFT));
        spectra=fftshift(fft(fid(:)));
        spectra_ph = spectra.*exp(-phase_corr.*sqrt(-1));

%         R = real(spectra_ph([500 2500])); % 2200:NFFT
        R = real(spectra_ph(dpoints(1):dpoints(2)))./max(abs(spectra_ph));
        N = real(spectra_ph([1:dpoints(1) dpoints(2):length(spectra_ph)]))./max(abs(spectra_ph(1:round(dpoints(1)/3))));
%         figure(1)
%         subplot(121)
%         plot(R)
%         subplot(122)
%         plot(N)
%         pause(0.5)
        [Pn, S] =polyfit(1:length(N),N',0);
        [y,delta] = polyval(Pn,1:length(N),S);
%         Pn2 = sum(N);
        Pn2=sum(delta);
        Pr=(sum((R(R<0).^2)));

        E=Pn2+Pr;


