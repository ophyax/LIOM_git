% We construct a Flow vector for segments and for edges that increase the
% flow everywhere the same percentage. All edges increase the same for a
% given segment which assume constant volume. This will be use in the O2
% advection during dilation to see if it prevents early pO2 decreases in
% arteries. This is simpler that going back to concentration in the code.
% If it is working then we can think of going back to concentration.
%
% L. Gagnon 4/18/2013

load dCMRO2.mat

FlowChangePeak=30; %in percent
rFlow=FlowChangePeak./100.*dCMRO2./max(dCMRO2);

%make sure we start at 0%
rFlow=rFlow-rFlow(1);
rFlow=rFlow+1;

%figure;plot(tCMRO2,rFlow)


load dilate_vessel_NCES_2PM.mat

FedgesNEW=Fedges(:,1)*rFlow';
FtimeNEW=Ftime(:,1)*rFlow';
VtimeNEW=Vtime(:,1)*ones(size(rFlow'));

Fedges=FedgesNEW;
Ftime=FtimeNEW;
Vtime=VtimeNEW;


save dilate_vessel_NCES_2PM_constVol.mat Fedges Ftime Vtime Ptime tFlow im2
