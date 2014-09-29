% This script computes the velocity required in the inflowing artery to
% give the desired perfusion.
%
% 3/11/2013 by L. Gagnon

function [velocity]=compute_inflowing_velocity(perfusion,volume,diameter,fraction)

%perfusion is in ml_blood/100g_tissu/min
%volume is in um^3
%diameter is in um

volume_ml=volume/1e12; %ml_tissu
perfusion_ml_per_ml_per_s=perfusion/100/60/1.04; % ml_blood/ml_tissu/sec

blood_flow=perfusion_ml_per_ml_per_s*volume_ml; %ml_blood/sec

blood_flow_um3=blood_flow*1e12; %um^3_blood/sec

nVes=length(diameter);
velocity=zeros(1,nVes);
for ii=1:nVes
    velocity(1,ii)=fraction(ii)*blood_flow_um3/(pi*(diameter(ii)/2).^2)/1000; %in mm/s
end

return