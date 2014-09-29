function B0_calc
%get mainhandles
mainhandles=guidata(findobj('Tag','mainmenu'));

%get data index
dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx; %1?

%get current diplayed data
temp.real = squeeze(mainhandles.datalist(dataidx).data.real);
temp.imag = squeeze(mainhandles.datalist(dataidx).data.imag);
params=mainhandles.datalist(mainhandles.dispopts.dataidx).params;
lsfid = mainhandles.datalist(dataidx).process.lsfid;


% NFFT=2^nextpow2((params.np/2));
NFFT = size(temp.real,2);
% t=0:params.at/(params.np/2-1):params.at;
% f = ((params.np/2)/params.at)/2*linspace(-1,1,NFFT);


% t=0:params.at/(NFFT-1):params.at;
% f = ((NFFT)/params.at)/2*linspace(-1,1,NFFT);

x=[0 ;0];
y=0;

%% apodization

% %store previsous apod
% if isfield(mainhandles.datalist(dataidx).process,'apodizefct')
% % for k=1:size(temp.real,1)
%     apodizefct = (mainhandles.datalist(dataidx).process.apodizefct);
%     apodparam1 = mainhandles.datalist(dataidx).process.apodparam1;
%     apodparam2 = mainhandles.datalist(dataidx).process.apodparam2;
% % end
% end

%% phasing
% disp(params.lsfid)
fid_length=length(temp.real); %=mainhandles.datalist(dataidx).np/2;
t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx).spectralwidth;
t2=t_vec;
% calculation of x-axis for frequency-space
cut = round(fid_length/2);
df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

% t=t_vec;
% f = f_vec_shifted
% save temp t f t_vec df_vec f_vec_shifted
% return

%     mainhandles.datalist(dataidx).process.apodizefct = 'exponential';
%     mainhandles.datalist(dataidx).process.apodparam1 = 15;
%     mainhandles.datalist(dataidx).process.apodparam2 = 0;

%% set switch for postprocessing script
mainhandles.switch_bkp = mainhandles.switch;
    mainhandles.datalist(dataidx).process.DCoffset=1;
    mainhandles.switch.phasecorrection=1;
    mainhandles.switch.apodization=1;
    mainhandles.switch.transformsize=0;
    mainhandles.switch.lsfid=1;
    mainhandles.switch.dcoffset=1;
    mainhandles.switch.b0=0;
    mainhandles.switch.ECC=0;


% clear temp
% ref_log = select_ref(size(temp.real,1));

%% select referecen scan
a=gui_dataselect('b0',size(temp.real,1));
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




    hh= waitbar(0,'Wait, preparing spectra,...');
for k =1:size(temp.real,1)
waitbar(k/size(temp.real,1));
    try
    phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(k);
    phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(k);
    catch
        phasecorr0 = mainhandles.datalist(dataidx).process.phasecorr0(1);
        phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(1);
    end

    data(k).real = squeeze(temp.real(k,:))';
    data(k).imag = squeeze(temp.imag(k,:))';
    
    guidata(findobj('Tag','mainmenu'),mainhandles);
    data(k) = postprocessing(squeeze(data(k)),dataidx,arrayidx);
    data(k) = phasing(squeeze(data(k)), f_vec_shifted, phasecorr0, phasecorr1);


    fid(k,:) = data(k).real+sqrt(-1)*data(k).imag;
    spectrum(k,:) = real(fftshift(fft(fid(k,:),NFFT)));
end
close(hh)



clear temp

figure(mainhandles.mainmenu)
cla
hold off
plot(f_vec_shifted,spectrum(ref_idx,:))

%%%%%%%%%%%%%%%% selection of a singlet
while size(x,1)>1
    [x,y]=getpts(mainhandles.mainmenu);
    if size(x,1)<2
        break
    end
    for i=1:length(f_vec_shifted)
        if f_vec_shifted(i)==x(1) || (f_vec_shifted(i)<x(1) && f_vec_shifted(i+1)>x(1))
            index(1)=i;
        end
        if f_vec_shifted(i)==x(2) || (f_vec_shifted(i)<x(2) && f_vec_shifted(i+1)>x(2))
            index(2)=i;
        end
    end
    figure(mainhandles.mainmenu)
    plot(f_vec_shifted(index(1):index(2)),spectrum(ref_idx,index(1):index(2)))
end


figure(mainhandles.mainmenu)
hold on             %Show data before correction
for k = 1:size(data,2)
    plot(f_vec_shifted(index(1):index(2)),(spectrum(k,index(1):index(2))),'k')
end
hold off
%%%%%%%%%%% search for the position of the maximum of the singlet
m=zeros(size(data,2),1);
f1=zeros(size(data,2),1);
i1=zeros(size(data,2),1);


search_max = abs((spectrum(ref_idx,index(1)))-max((spectrum(ref_idx,index(1):index(2)))));
search_min = abs((spectrum(ref_idx,index(1)))-min((spectrum(ref_idx,index(1):index(2)))));

interp_fact = 20;
% t_interp = linspace(t(index(1)),t(index(2)),length(index(1):index(2))*interp_fact);
% f_interp = linspace(f_vec_shifted(index(1)),f_vec_shifted(index(2)),length(index(1):index(2))*interp_fact);
t_interp = interp(t2(index(1):index(2)),interp_fact);
f_interp = interp(f_vec_shifted(index(1):index(2)),interp_fact);

figure(mainhandles.mainmenu)
cla
hold on  
for i = 1:size(data,2)
%     figure(h)
%     waitbar(i/size(data,2)) ;
    if search_max > search_min
%         t_interp = squeeze(t(index(1):index(2)));
        spect_interp = interp1(f_vec_shifted(index(1):index(2)),squeeze(spectrum(i,index(1):index(2))),f_interp,'spline');
        [m(i) index_max(i)]=max(real(spect_interp));
%         [pks(i),locs(i)] = findpeaks(real(spect_interp));

        %         [m(i) index_max(i)]=max(real(interp(squeeze(spectrum(i,index(1):index(2))),interp_fact)));
%         [m2(i) index_max2(i)] = max(real((squeeze(spectrum(i,index(1):index(2))))));

    elseif search_max < search_min
        [m(i) index_max(i)] = min(real(interp(squeeze(spectrum(i,index(1):index(2))),interp_fact)));
    end
%     index_max_final(i) = find((abs(f_interp(index_max(i))-f_vec_shifted)<df_vec/2)==1);
%     
% 
%    index_rev(i) = find((f_interp-(f_interp(index_max(1))+df(i)))>0,1,'first');

plot(f_interp,spect_interp,'-b')
plot(f_interp(index_max(i))',m(i),'rx')


end
hold off

% close(h);
% index_max
% index_max_plot=round((index_max+interp_fact-1)./interp_fact)+index(1)-1;

% plot(f_vec_shifted(index_max_final)',m2,'go')
% plot(f_vec_shifted(index_max2+index(1)-1)',m2,'rx')
% plot(f_interp(index_rev)',m,'rx')
% plot(f_interp(index_max(1))'+df,m,'rx')
% disp((abs(f_interp(index_max)-f_vec_shifted(index_max2+index(1)-1))<df_vec/2))

pause(1)
% return
% index_max = index_max./(interp_fact);
% index_max2
% f_ref=f(index_max(1));
% df1=f_vec_shifted(index_max_final)-f_vec_shifted(index_max_final(1));
% df=(index_max-index_max(1)-interp_fact-1).*(df_vec)./interp_fact;
% df2=(index_max2-index_max2(1)).*(df_vec);
df3 = f_interp(index_max)-f_interp(index_max(ref_idx));
% df4 = f_interp(locs)-f_interp(locs(1));
% disp('df')
% disp(isequal(df,df2'))
% % disp([df df3 df4])
% index_max2 = index_max2+index(1)-1;
% disp(isequal(index_max_final,index_max2))

% [index_max' index_max2' df' df2']
% [df' df2']
% df_vec
% df_vec_interp = 1./(interp_fact.*fid_length.*(t_interp(2)-t_interp(1)))
% df = (index_max-index_max(1)).*(df_vec_interp)
% df = 1./(fid_length.*(t_interp(index_max)-t_interp(index_max(1))))
% return
figure(mainhandles.mainmenu)
cla
hold on
mainhandles.datalist(dataidx).process.B0 = zeros([size(data,2) fid_length]);
for i = 1:size(data,2)
    realval = squeeze(data(i).real);
    imagval = squeeze(data(i).imag);
    %     data.param.lsfid=0;
%     phi1 = angle(realval+1i*imagval);

  %% replace by the variable t 
   phi = -t2.*(df3(i)*2*pi());
% phi=flipdim(phi',1);
phi=phi';
   %     phi = ((fid_length:-1:1)'-params .lsfid).*df(i).*(2*pi/params.sw);
    mainhandles.datalist(dataidx).process.B0(i,:)=phi;
%     phi1=phi1+phi;
%     phi=flipdim(phi,1);
    fidecc = (realval+imagval.*sqrt(-1)).*exp(phi.*sqrt(-1));
%     data(i).real=real(fidecc);
%     data(i).imag=imag(fidecc);
    %
    %     fideccb = fidecc.*LB';
    Ieccb = fftshift(fft(fidecc(:),NFFT));
    plot(f_vec_shifted(index(1):index(2)),real(Ieccb(index(1):index(2))),'r')
% asdsda(i,:) = phi(3030:3040); 
end
% asdsda

hold off
pause(1)

% % for k=1:size(data,2)
%     mainhandles.datalist(dataidx).process.apodizefct = apodizefct;
%     mainhandles.datalist(dataidx).process.apodparam1 = apodparam1;
%     mainhandles.datalist(dataidx).process.apodparam2 = apodparam2;
% % end
% B0 =  mainhandles.datalist(dataidx).process.B0;
% save matlab_4 spectrum data temp df3 index_max spect_interp f_interp t B0 f_vec_shifted index



mainhandles.switch=mainhandles.switch_bkp;
mainhandles.switch.b0=1;
guidata(findobj('Tag','mainmenu'),mainhandles)

autophase_but = questdlg('Do yo want to apply zero order phase correction?','Autophasing');
if strcmp(autophase_but,'Yes')
    Autophase([index(1) index(2) ref_idx]);
end

function ref_idx = select_ref(multiplicity)
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

title = 'Select reference scan:';
selectfid_fig = figure('Name',title,'NumberTitle','off',...
    'Tag','selectfid_fig','MenuBar','none','Units','pixel',...
    'Position',[200 300 fig_w+10 fig_h+but_h+10]);
selectfid_panel = uibuttongroup('Parent',selectfid_fig,...
    'Tag','select_panel','Units','pixel',...
    'Position',[0 but_h+10 fig_w+10 fig_h+10]);
for k=1:n_fid
    posx = 5+(mod(k-1,ncul))*but_w;
    posy = fig_h - (floor((k-1)/8)+1)*but_h;
    tag = ['sel_' num2str(k)];
    button(k).sel = uicontrol('Style','togglebutton','Units','pixel','Parent',selectfid_panel,...
    'String',num2str(k),'Position',[posx posy but_w but_h],...
    'Tag',tag);
end

% button_all = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
%     'String','All','Position',[5 5 but_w but_h],...
%     'Tag','applytoall_button','Callback',{@button_all_callback});
% button_none = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel',...
%     'String','None','Position',[60 5 50 30],...
%     'Tag','none_button','Callback',{@button_none_callback});
button_apply = uicontrol('Style','pushbutton','Parent',selectfid_fig,'Units','pixel','Parent',selectfid_fig,...
    'String','Apply','Position',[fig_w-but_w-5 5 50 30],...
    'Tag','apply','Callback',{@button_apply_callback});

% button_all_callback;
uiwait(findobj('Tag','selectfid_fig'))
sel_h = get(findobj('Tag','select_panel'),'Children');
ref_idx = flipdim(get(sel_h,'Value'),1);
delete(findobj('Tag','selectfid_fig'));
% function button_sel_callback(hObject,eventdata)
% % handles = guidata(findobj('Tag','selectfid_panel'));
% % sel = get(findobj('Tag','select_panel'),'Children');
% cur_val = get(hObject,'Value');
% 
% function button_all_callback(hObject,eventdata)
% % handles = guidata(findobj('Tag','selectfid_panel'));
% sel = get(findobj('Tag','select_panel'),'Children');
% set(sel,'Value',1);
% function button_none_callback(hObject,eventdata)
% % handles = guidata(finobj,'Tag','selectfid_fig');
% sel = get(findobj('Tag','select_panel'),'Children');
% set(sel,'Value' ,0);
function button_apply_callback(hObject,eventdata)
% sel_h = get(findobj('Tag','select_panel'),'Children');
% sel_log = get(sel_h,'Value');
uiresume(findobj('Tag','selectfid_fig'))
% delete(findobj('Tag','selectfid_fig'));
% return;






