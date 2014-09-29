function Temperature
mainhandles = guidata(findobj('Tag','mainmenu'));
cd([mainhandles.homedir]) %return to prog homedir to be able to call function in the provate directory later
%get data index
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx; %1?

params =mainhandles.datalist(dataidx).params;
temp =mainhandles.datalist(dataidx).data;
NFFT = size(temp.real,3)*4;
lsfid = params.lsfid;
display.peak = 1;

%% phasing
%%Apply on raw data, no zero-filling

fid_length=length(temp.real); %=mainhandles.datalist(dataidx).np/2;
t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx).spectralwidth;
t2=t_vec;
% calculation of x-axis for frequency-space
cut = round(fid_length/2);
df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

%%

ppmperpoint = params.sw/params.sfrq/NFFT;
shifttoNAA = round(2.6/ppmperpoint);
shiftinterv = round(0.1/ppmperpoint);


%% select data
%%set switch for postprocessing script
mainhandles.switch_bkp = mainhandles.switch;
mainhandles.datalist(dataidx).process.DCoffset=1;
mainhandles.switch.phasecorrection=1;
mainhandles.switch.apodization=1;
mainhandles.switch.transformsize=0;
mainhandles.switch.lsfid=1;
mainhandles.switch.dcoffset=1;
mainhandles.switch.b0=1;
mainhandles.switch.ECC=0;



%% Spectra to analyse
a=gui_dataselect('Temp',size(temp.real,1),'sel');
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
    delete(a)
    clear h
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end

%%REf spectrum for peak selection
a=gui_dataselect('Temp',length(sel_idx),'ref',sel_idx);
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


%% prepare spectra (phase/apod...)
cd([mainhandles.homedir filesep 'private']);
hh= waitbar(0,'Wait, preparing spectra,...');
for k =1:length(sel_idx)
    waitbar(k/size(temp.real,1));
    try
        phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(sel_idx(k));
        phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(sel_idx(k));
    catch
        phasecorr0 = mainhandles.datalist(dataidx).process.phasecorr0(1);
        phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(1);
    end
    
    data(k).real = squeeze(temp.real(sel_idx(k),1,:));
    data(k).imag = squeeze(temp.imag(sel_idx(k),1,:));
    
    guidata(findobj('Tag','mainmenu'),mainhandles);
    data(k) = postprocessing(squeeze(data(k)),dataidx,sel_idx(k));
    data(k) = phasing(squeeze(data(k)), f_vec_shifted, phasecorr0, phasecorr1);
    
    
    fid(k,:) = data(k).real+1i*data(k).imag;
    spectrum(k,:) = real(fftshift(fft(fid(k,:),NFFT)));
end

close(hh)

%% Peak selection
% 
figure(mainhandles.mainmenu)
% figure(1)

cla
[a frequ_water] = find(spectrum(ref_idx,:)==max(spectrum(ref_idx,100:NFFT-100)));
ppm_range= 4.6-[0:(shifttoNAA+10*shiftinterv)].*ppmperpoint;
plot(ppm_range,spectrum(ref_idx,[(frequ_water):(frequ_water+shifttoNAA+10*shiftinterv)]));
set(gca,'XDir','reverse')
ylim([min(spectrum(ref_idx,[(frequ_water+5*shiftinterv):(frequ_water+shifttoNAA+5*shiftinterv)])) 1.5*max(spectrum(ref_idx,[(frequ_water+5*shiftinterv):(frequ_water+shifttoNAA+5*shiftinterv)]))])

%%%%%%%%%%%%%%%% selection of a singlet
x=[];
    h=helpdlg({'Select 2 points around each of the following peak: tCho, Cr and NAA' '(Press Enter when finished)'},'Peak selection');

while size(x,1)~=6
    [x,y]=getpts(mainhandles.mainmenu);
%  [x,y]=getpts(gca);

end
if ishandle(h)
    close(h)
end
x=sort(x);
% x
shifttoCho=[0 0];
shifttoCr=[0 0];
shifttoNAA=[0 0];
for f=2:length(ppm_range)
        if ppm_range(f)==x(1) || (ppm_range(f)<x(1) && ppm_range(f-1)>x(1))
%         shifttoNAA(2)=length(ppm_range)-f+1;
            shifttoNAA(2)=f+1;
        end
        if ppm_range(f)==x(2) || (ppm_range(f)<x(2) && ppm_range(f-1)>x(2))
%         shifttoNAA(1)=length(ppm_range)-f+1;
        shifttoNAA(1)=f+1;
        end
        if ppm_range(f)==x(3) || (ppm_range(f)<x(3) && ppm_range(f-1)>x(3))
%         shifttoCr(2)=length(ppm_range)-f+1;
          shifttoCr(2)=f+1;
        end
        if ppm_range(f)==x(4) || (ppm_range(f)<x(4) && ppm_range(f-1)>x(4))
%         shifttoCr(1)=length(ppm_range)-f+1;
shifttoCr(1)=f+1;
        end
        if ppm_range(f)==x(5) || (ppm_range(f)<x(5) && ppm_range(f-1)>x(5))
%         shifttoCho(2)=length(ppm_range)-f+1;
shifttoCho(2)=f+1;
    end
    if ppm_range(f)==x(6) || (ppm_range(f)<x(6) && ppm_range(f-1)>x(6))
%         shifttoCho(1)=length(ppm_range)-f+1;
 shifttoCho(1)=f+1;
    end
end

% shifttoCho
% shifttoCr
% shifttoNAA
% 
% [4.6-shifttoCho*ppmperpoint]
% [4.6-shifttoCr*ppmperpoint]
% [4.6-shifttoNAA*ppmperpoint]
% return;
%% Temperature calculation
if display.peak==1
    figure(mainhandles.mainmenu)
%     cla
    sub=0;
    idx_mat=1:size(spectrum,1);
    idx_mat=reshape(idx_mat,[sqrt(size(spectrum,1)) sqrt(size(spectrum,1))]);
    idx_mat=idx_mat((size(idx_mat,1)/2-2):(size(idx_mat,1)/2+3),(size(idx_mat,1)/2-2):(size(idx_mat,1)/2+3));
end
hh=waitbar(0,'Wait, meausuring frequency,...');
for g=1:length(sel_idx)
    waitbar(g/length(sel_idx))
    [a frequ.water(g)] = find(spectrum(g,:)==max(spectrum(g,100:NFFT-100)));
    if frequ.water(g)>frequ_water+5*shiftinterv || frequ.water(g)<frequ_water-5*shiftinterv 
         frequ.water(g)=frequ_water;
    end
    %     frequ.water(g)=round(length(spectrum(g,:))/2);
    [a NAA(g)] =  find(spectrum(g,frequ.water(g)+[shifttoNAA(1):shifttoNAA(2)])==max(spectrum(g,frequ.water(g)+[shifttoNAA(1):shifttoNAA(2)])));
    [a Cho(g)] =   find(spectrum(g,frequ.water(g)+[shifttoCho(1):shifttoCho(2)])==max(spectrum(g,frequ.water(g)+[shifttoCho(1):shifttoCho(2)])));
    [a Cr(g)] =   find(spectrum(g,frequ.water(g)+[shifttoCr(1):shifttoCr(2)])==max(spectrum(g,frequ.water(g)+[shifttoCr(1):shifttoCr(2)])));
    
    frequ.NAA(g) = NAA(g)+frequ.water(g)+shifttoNAA(1)-1;
    frequ.Cho(g) = Cho(g)+frequ.water(g)+shifttoCho(1)-1;
    frequ.Cr(g) = Cr(g)+frequ.water(g)+shifttoCr(1)-1;
    
    if display.peak==1 && ismember(g,idx_mat)
        figure(3)
        sub=sub+1;
        subplot(6,6,sub)
        hold on
        plot(spectrum(g,:))
%         plot([frequ.Cho(g) shifttoCho+frequ.water(g)],spectrum(g,[ frequ.Cho(g) shifttoCho+frequ.water(g)]),'go')
%         plot([frequ.Cr(g) shifttoCr+frequ.water(g)],spectrum(g,[frequ.Cr(g) shifttoCr+frequ.water(g)]),'rx')
%         plot([frequ.NAA(g) shifttoNAA+frequ.water(g)],spectrum(g,[frequ.NAA(g) shifttoNAA+frequ.water(g)]),'bx')
        plot([frequ.Cho(g) ],spectrum(g,[ frequ.Cho(g) ]),'go')
        plot([frequ.Cr(g) ],spectrum(g,[frequ.Cr(g) ]),'rx')
        plot([frequ.NAA(g) ],spectrum(g,[frequ.NAA(g) ]),'bx')        
        
        
%         axis off
        xlim([(frequ.water(g)) (frequ.water(g)+shifttoNAA(2))])
        ylim([min(spectrum(g,[(frequ.water(g)+5*shiftinterv):(frequ.water(g)+shifttoNAA+1*shiftinterv)])) 1.2*max(spectrum(g,[frequ.NAA(g)+5*shiftinterv frequ.Cho(g)-5*shiftinterv]))])
        hold off
    end
    
end
close(hh)
gamma= -101.7;
F0Cr=-1.6585;   
alpha = -103.8;
F0NAA = -2.6759;
beta = -106.08;
F0Cho =-1.4755;
Temp.NAA =36+alpha*((frequ.water-frequ.NAA)*ppmperpoint-F0NAA);
Temp.Cho =36+beta*((frequ.water-frequ.Cho)*ppmperpoint-F0Cho);
Temp.Cr =36+gamma*((frequ.water-frequ.Cr)*ppmperpoint-F0Cr);

msh.NAA = zeros( size(temp.real,1),1);
msh.Cr = zeros( size(temp.real,1),1);
msh.Cho = zeros( size(temp.real,1),1);


msh.NAA(sel_idx)=Temp.NAA;
msh.Cho(sel_idx)=Temp.Cho;
msh.Cr(sel_idx)=Temp.Cr;

msh.NAA=reshape(msh.NAA,[sqrt(size(spectrum,1)) sqrt(size(spectrum,1))]);
msh.Cho=reshape(msh.Cho,[sqrt(size(spectrum,1)) sqrt(size(spectrum,1))]);
msh.Cr=reshape(msh.Cr,[sqrt(size(spectrum,1)) sqrt(size(spectrum,1))]);

figure
subplot(133)
imagesc(msh.NAA)
 title('Temp NAA')
subplot(132)
imagesc(msh.Cr)
 title('Temp Creatine')
subplot(131)
imagesc(msh.Cho)
 title('Temp Choline')



