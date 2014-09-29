function [ECC_m_fid, ECC_corr] = ECC_correction(m_fid,w_fid,j_m,j_w)%,flag_ECC) %ECC_correction(dataidx,dataidx_ref)

% mainhandles=guidata(findobj('Tag','mainmenu'));

% w_fid = squeeze(mainhandles.datalist(dataidx_ref).data.real + 1i*mainhandles.datalist(dataidx_ref).data.imag);
% m_fid = (squeeze(mainhandles.datalist(dataidx).data.real + 1i*mainhandles.datalist(dataidx).data.imag));
% figure
% plot(real(m_fid))
j_m = j_w

phi_w =  angle(w_fid);
phi_m = angle(m_fid);


if j_m ~=j_w
    disp('not same lsfid for watter and met spectra: ERROR')
    return;
end

phi_w_ref = phi_w(j_w);
phi_m_ref = phi_m(j_m);
% if flag_ECC(2)==0
    phi_w = phi_w - phi_w_ref;
%     ECC_w_fid = abs(w_fid).*exp(1i*phi_w);
% else
%     ECC_w_fid = w_fid;
% end
% if flag_ECC(1)==0   
    phi_m = phi_m  - phi_m_ref - phi_w;
    ECC_corr = phi_m_ref + phi_w;
    ECC_m_fid = abs(m_fid).*exp(1i*phi_m);
% else
%     ECC_m_fid = m_fid;
% end




% figure
% plot(real(ECC_m_fid))

% ECC_m_fid=zeros(size(ECC_m_fid));

% disp(size(squeeze(real(ECC_fid))))
% 

% disp(size(mainhandles.datalist(dataidx).data.real))

