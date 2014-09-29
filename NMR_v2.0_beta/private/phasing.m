
function data = phasing(data, f_vec_shifted, phasecorr0, phasecorr1)
% phasing of spectrum
if nargin<3
    disp('not enough arguments to perform phase correction')
    return
end

if exist('phasecorr0','var') && isnumeric(phasecorr0) && ~isempty(phasecorr0)
    phase0 = deg2rad(phasecorr0); %+pi/2;
else
    phase0 = 0;
end
if exist('phasecorr1','var') && isnumeric(phasecorr1) && ~isempty(phasecorr1)
    phase1 = phasecorr1/1000;
else
    phase1 = 0;
end
%Nico
% fid=squeeze(data.real)+sqrt(-1)*squeeze(data.imag);
fid=(data.real)+sqrt(-1)*(data.imag);

spect = (squeeze(fft(fid))); %1/length(data.real)*
% max(f_vec_shifted);
phase_corr = (phase0-phase1.*f_vec_shifted);
% phase_corr = (phase0+2*pi*phase1.*f_vec_shifted);

% phase_corr = (phase0+f_vec_shifted.*phase1/4096)';

spect_phased = spect.*exp(-phase_corr.*sqrt(-1));
% fid_phased = 1/length(data.real)*(squeeze(ifft(spect_phased)));
fid_phased = (squeeze(ifft(spect_phased)));
data.real = real(fid_phased);
data.imag = imag(fid_phased);

% with +pi/2 in phase0 the following rotation will performed in the other direction

% % !!! needs a loop if data is not only one spectrum
% data.real = data.real.*sin(phase_corr)-data.imag.*cos(phase_corr);
% data.imag = data.real.*cos(phase_corr)+data.imag.*sin(phase_corr);
% data_real = data_real.*cos(phase0)-data_imag.*sin(phase0);
% data_imag = data_real.*sin(phase0)-data_imag.*cos(phase0);
% data_real = data_real.*cos(phase1)-data_imag.*sin(phase1);
% data_imag =
% data_real.*sin(phase1)-data_imag.*cos(phase1);


% % %% update the Gui_process figure with current values of phase correction parameters
% % if isempty(findobj('Tag','processfig'))==0
% %     process_fig = guidata(findobj('Tag','processfig'));
% %     set(process_fig.processfig_edit_phasecorr0,'String',num2str(phasecorr0))
% %     set(process_fig.processfig_slider_phasecorr0,'Value',phasecorr0)
% %     set(process_fig.processfig_edit_phasecorr1,'String',num2str(phasecorr1))
% %     set(process_fig.processfig_slider_phasecorr1,'Value',phasecorr1)
% % end