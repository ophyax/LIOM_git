function data = apodization(data,apodizefct,apodparam1,apodparam2)
% apodization function, implemented are 'exponential','gaussian','doubleexp','lorentzian','TRAF'
% Parameter1 for apodization function like 'exponential','gaussian'
% Parameter2 for apodization function like 'doubleexp','lorentzian','gaussian/lorentzian'

global samplerate

if isfield(data,'real') && isfield(data,'imag')
    fid_length=length(data.real);
else
    errordlg('Apodization: data has to be a structure with a field "real" and "imag"')
    return
end

%% --- apodization --------------------------------------------------------

switch char(apodizefct)
    case 'exponential'
        apodization = ...
            exp(-apodparam1*pi*samplerate.*(0:fid_length-1));
        %             title(handles.fidaxes,'exp(-par1 \cdot \pi \cdot t)','Interpreter','tex');
    case 'gaussian'
        %         equation [9], p543, in G.A.Pearson, "Optimization of Gaussian
        %         Resolution Enhancement", J.Mag.Res. 74, 541-545 (1987).
        apodization = ...
            exp(-(apodparam1*pi.*samplerate*((0:fid_length-1))+apodparam2).^2/(4*log(2)));
        %             title(handles.fidaxes,'exp(-(par1 \cdot \pi \cdot t)^2/(4\cdot ln(2))','Interpreter','tex');
    case 'doubleexp'
        apodization = ...
            exp(-(apodparam1*pi.*samplerate*(0:fid_length-1)-...
            apodparam2*samplerate*fid_length).^2);
        %             title(handles.fidaxes,'exp(-(par1 \cdot \pi \cdot t - par2 \cdot AcqTime)^2)','Interpreter','tex');
    case 'lorentzian'
        if apodparam2==0
            disp('Attention: apodparam2 ~=0')
            return;
        end
        apodization = ...
            exp(-(apodparam1*pi.*samplerate.*(0:fid_length-1))+...
            (pi*apodparam1*(samplerate*(0:fid_length-1)).^2)./(2*apodparam2*samplerate*fid_length) );
        %             title(handles.fidaxes,...
        %                 'exp(-par1 \cdot \pi \cdot t + (par1 \cdot \pi \cdot t^2) / (2 \cdot par2 \cdot AcqTime) )','Interpreter','tex');
    case 'TRAF'
        apodization = ...
            (exp(-apodparam1*pi*samplerate.*(0:fid_length-1))).^2./...
            ( (exp(-apodparam1*pi*samplerate.*(0:fid_length-1))).^3 + ...
            (exp(-apodparam1*samplerate*fid_length)).^3 );
        %             title(handles.fidaxes,'(exp(-par1 \cdot \pi \cdot t))^2 / (exp(-par1 \cdot \pi \cdot t)^3 + exp(-par1 \cdot AcqTime)^3)','Interpreter','tex');
    otherwise
        disp('*** no apodization applied: string does not match any available apodization function ***')
        disp('par2_slider settings: none')
        apodization = ones(1,fid_length);
        %             title(handles.fidaxes,' --- ','Interpreter','tex');
end
data.real = data.real.*apodization';
data.imag = data.imag.*apodization';


