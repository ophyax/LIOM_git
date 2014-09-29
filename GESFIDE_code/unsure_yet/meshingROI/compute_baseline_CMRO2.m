% This function compute baseline CMRO2 required to get the desired OEF
% given the speed, diameter and pO2 of the incoming arteries
% 
% 3/10/2012 by L. Gagnon

function [CMRO2_umol_ml_min]=compute_baseline_CMRO2(speed,diameter,pO2,OEF,volume, species)

alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
Hct = 0.3;
Chb = 5.3e-12;            % 5.3e3 uM  red cell hemoglobin content (Beard2001)
% 5.3e3 umol/L = 5.3e-12 umol/um^3

%compute blood inflow
CBF = sum(speed.*1000*pi.*(diameter./2).^2,2); %um^3_blood/sec

%compute O2 inflow
O2_flow = CBF.*pO2.*alpha + 4.*Hct.*Chb.*CBF.*so2_func(pO2,species);

%compute O2 consummed
O2_consummed = O2_flow.*OEF; %umol_O2/sec

%compute CMRO2
CMRO2 = O2_consummed/volume; %umol_O2/um^3/sec
CMRO2_umol_ml_min=CMRO2*1e12*60; %umol_O2/ml_tissu/min


return
