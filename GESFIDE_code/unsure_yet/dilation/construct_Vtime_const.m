% We just create a file with constant volume to run the advection. Then
% we will use dynamic volume for BOLD simulation.
%
% L. Gagnon 7/09/2014


clear all
load dilate_vessel_NCES_Sigmoid10.mat

VtimeNEW=Vtime(:,1)*ones(size(tFlow'));
Vtime=VtimeNEW;


save dilate_vessel_NCES_Sigmoid10_constVol.mat Fedges Ftime Vtime Ptime tFlow
