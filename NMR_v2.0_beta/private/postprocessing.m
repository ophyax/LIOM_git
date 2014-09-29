function data = postprocessing(data,dataidx,arrayidx)
% apodization function, implemented are 'exponential','gaussian','doubleexp','lorentzian','TRAF'
% Parameter1 for apodization function like 'exponential','gaussian'
% Parameter2 for apodization function like 'doubleexp','lorentzian','gaussian/lorentzian'

global samplerate
%% --- get data ------------------------------------------------------
% get and prepare data
% display('nico')
mainhandles=guidata(findobj('Tag','mainmenu'));
if nargin<2
    dataidx = mainhandles.dispopts.dataidx;
    arrayidx = mainhandles.dispopts.arrayidx;
end

if nargin<1 || isfield(data,'real')==0 || isfield(data,'imag')==0 
    data.real=squeeze(mainhandles.datalist(mainhandles.dispopts.dataidx).data.real(mainhandles.dispopts.arrayidx,:,:));
    data.imag=squeeze(mainhandles.datalist(mainhandles.dispopts.dataidx).data.imag(mainhandles.dispopts.arrayidx,:,:));
end

%% --- get parameters & check format------------------------------------------------------
% get apodization function & parameters 
% fid_length, samplerate, np
np=mainhandles.datalist(dataidx).np;
fid_length=np/2; % without zerofilling
samplerate=1./mainhandles.datalist(dataidx).spectralwidth;

if (exist('fid_length','var') && isnumeric(fid_length) && ...
        exist('samplerate','var') && isnumeric(samplerate)) == 0
    disp('unknown parameters: samplerate and / or length of fid')
    return
end

% apodization function (parameters: 'apodizefct', 'apodparam1', 'apodparam1')
if mainhandles.switch.apodization==1
if isfield(mainhandles.datalist(dataidx).process,'apodizefct')%% && mainhandles.flag.apodization==1
%     disp(mainhandles.datalist(dataidx).process.apodizefct)
    
if isfield(mainhandles.datalist(dataidx).process,'apodizefct') && ...
        isfield(mainhandles.datalist(dataidx).process,'apodparam1') && ...
        isfield(mainhandles.datalist(dataidx).process,'apodparam2') && ...
        ischar(mainhandles.datalist(dataidx).process.apodizefct) && ...
        isnumeric(mainhandles.datalist(dataidx).process.apodparam1) && ...
        isnumeric(mainhandles.datalist(dataidx).process.apodparam2)
    apod_flag = 1;
    apodizefct=mainhandles.datalist(dataidx).process.apodizefct;
    apodparam1=mainhandles.datalist(dataidx).process.apodparam1(arrayidx);
    apodparam2=mainhandles.datalist(dataidx).process.apodparam2(arrayidx);
    if apodparam1==0 && apodparam2==0
        apod_flag = 0;
    end
else
    apod_flag = 0;
end
else
    apod_flag = 0;
end
else
    apod_flag = 0;
end
% dips(apod_flag)

% transformsize
if mainhandles.switch.transformsize==1
if isfield(mainhandles.datalist(dataidx).process,'transfsize')
if isfield(mainhandles.datalist(dataidx).process,'transfsize') && ...
        isnumeric(mainhandles.datalist(dataidx).process.transfsize) && ...
        ~isempty(mainhandles.datalist(dataidx).process.transfsize) && ...
        mainhandles.datalist(dataidx).process.transfsize>0
    transformsize=mainhandles.datalist(dataidx).process.transfsize;
else
    transformsize = 0;
end
else
  transformsize = 0;  
end
else
  transformsize = 0;  
end

% left shift of FID (lsfid)
% disp('postprocessing')
% disp(mainhandles.datalist(dataidx).process.lsfid)
if mainhandles.switch.lsfid==1
if isfield(mainhandles.datalist(dataidx).process,'lsfid')
    try
        isfield(mainhandles.datalist(dataidx).process,'lsfid') && ...
            isnumeric(mainhandles.datalist(dataidx).process.lsfid) && ...
            ~isnumeric(mainhandles.datalist(dataidx).process.lsfid) && ...
            mainhandles.datalist(dataidx).process.lsfid>0;
        lsfid=mainhandles.datalist(dataidx).process.lsfid;
    catch
        lsfid = mainhandles.datalist(dataidx).process.lsfid;
    end

else
    lsfid = 0;
end
else
    lsfid = 0;
end
% disp(lsfid)

%% --- DC offset correction ----------------------------------------------
% remove dc offset (linear fit of fid)
if mainhandles.switch.dcoffset==1
if isfield(mainhandles.datalist(dataidx).process,'DCoffset') % DCoffsetCorr==1
    if mainhandles.datalist(dataidx).process.DCoffset==1
%         disp('DO DC offset correction')
        data=DCoffset_corr(data,np);
    end
end
end

%%b0
if mainhandles.switch.b0==1
if isfield(mainhandles.datalist(dataidx).process,'B0')
    fid = (data.real+sqrt(-1).*data.imag);
    phi = mainhandles.datalist(dataidx).process.B0(arrayidx,:)';
    fid_b0 = fid.*exp(phi.*sqrt(-1));
    data.real=real(fid_b0);
    data.imag=imag(fid_b0);
    
%         phi = angle(data.real+sqrt(-1).*data.imag);
%     abs_data = sqrt(data.real.^2+data.imag.^2);
%     phi = phi + mainhandles.datalist(dataidx).process.B0(arrayidx,:)';
%     data.real=abs_data.*cos(phi);
%     data.imag=abs_data.*sin(phi);
    
end
end
if mainhandles.switch.ECC==1
if isfield(mainhandles.datalist(dataidx).process,'ECC')
%     disp('ECC Correction')
    fid = (data.real+sqrt(-1).*data.imag);
    phi = mainhandles.datalist(dataidx).process.ECC;
    fid_ECC = fid.*exp(-phi.*sqrt(-1));
    data.real=real(fid_ECC);
    data.imag=imag(fid_ECC);
end
end


%% --- B0 calc ----------------------------------------------
% remove dc offset (linear fit of fid)
% % if get(findobj('Tag','processfig_togglebutton_B0driftcorr'),'Value') % DCoffsetCorr==1
% if isfield(mainhandles.datalist(dataidx).process,'B0')
%     fid = (data.real+sqrt(-1).*data.imag);
%     phi = mainhandles.datalist(dataidx).process.B0(arrayidx,:)';
%     fid_b0 = fid.*exp(phi.*sqrt(-1));
%     data.real=real(fid_b0);
%     data.imag=imag(fid_b0);
%     
% %         phi = angle(data.real+sqrt(-1).*data.imag);
% %     abs_data = sqrt(data.real.^2+data.imag.^2);
% %     phi = phi + mainhandles.datalist(dataidx).process.B0(arrayidx,:)';
% %     data.real=abs_data.*cos(phi);
% %     data.imag=abs_data.*sin(phi);
%     
% end

%% --- shift receiver offset (in time domain) ----------------------------
% complexfid=data.real-1i*data.imag;
% t_vec = (0:(fid_length-1)).*samplerate;
% complexfid=complexfid.*...
%     exp(1i*2*pi*mainhandles.datalist(dataidx).params.lsfrq*t_vec');
% data.real=real(complexfid);
% data.imag=-imag(complexfid);

%% --- transform size -------------------------------------------------

% --- lsfid -----------------------------------------------------------
if lsfid<0
    data.real=[zeros(1,lsfid)'
               data.real(1:(length(data.real)-lsfid-1))];
    data.imag=[zeros(1,lsfid) 
    (1:(length(data.real)-lsfid-1))];
elseif lsfid>0
    data.real=[data.real(lsfid:length(data.real)) 
               zeros(1,lsfid-1)'];
    data.imag=[data.imag(lsfid:length(data.imag)) 
                zeros(1,lsfid-1)'];
end
if isempty(findobj('Tag','processfig'))==0
    process_fig = guidata(findobj('Tag','processfig'));
    set(process_fig.processfig_edit_lsfid,'Value',lsfid)
end



%% --- apodization --------------------------------------------------------
% ??? sequence of postprocessing: apodization first or at last ???
% apodization function, implemented are 'exponential','gaussian','doubleexp','lorentzian','TRAF'
% Parameter1 for apodization function like 'exponential','gaussian'
% Parameter2 for apodization function like
% 'doubleexp','lorentzian','gaussian/lorentzian'
if apod_flag == 1
%     disp(['apodparam1: ' num2str(apodparam1)])
    
    data=apodization(data,apodizefct,apodparam1,apodparam2);
% % see below "muell"
end

% --- zero filling
if transformsize ~= 0
    if np/2<transformsize && transformsize>0
        data.real = [data.real; zeros(transformsize-np/2,1)];
        data.imag = [data.imag; zeros(transformsize-np/2,1)];
        %     handles.num_zeros = get(get(handles.zerofilling_panel,'SelectedObject'),'Max')*handles.inputstruct.num_samples-handles.inputstruct.num_samples;
    elseif np/2>transformsize && transformsize>0
        data.real=data.real(1:transformsize);
        data.imag=data.imag(1:transformsize);
    end
end


