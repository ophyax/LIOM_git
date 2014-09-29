function data = DCoffset_corr(data,np)
% remove DC offset

if exist('np','var') %nargin==2
    % np=data.param.np;
    np=floor(np/2);
%     np = length(data);
    np_dc=floor(2*(np/16));
    np_start=np-np_dc;
%     for i=1:size(data.real)
        sum_real=sum(squeeze(data.real(np_start:np)));
        sum_imag=sum(squeeze(data.imag(np_start:np)));
        dc_real = (sum_real/np_dc);
        dc_imag = (sum_imag/np_dc);
        data.real=data.real-dc_real;
        data.imag=data.imag-dc_imag;
%     end
else
    % from pgh
    % remove dc offset (linear fit of fid)
    x=(1:length(data.real))';
    p=polyfit(x,data.real,1);
    linearfit=polyval(p,x);
    data.real=data.real-linearfit;
%      x=(1:length(data.imag))'; NICO
%     p=polyfit(x,data.imag,1);
%     linearfit=polyval(p,x);
    
    data.imag=data.imag-linearfit;

%     % shift receiver offset (in time domain)
%     complexfid=fid(:,1)-1i*fid(:,2);
%     t=(0:1/acqparam.sw_hz:(length(complexfid)-1)/acqparam.sw_hz)';
%     complexfid=complexfid.*exp(1i*2*pi*procparam.lsfrq*t);
%     fid(:,1)=real(complexfid);
%     fid(:,2)=-imag(complexfid);
end
