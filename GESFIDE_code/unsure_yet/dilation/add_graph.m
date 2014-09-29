% We just add graph to the flow volume file for MCproton.
%
% L. Gagnon 7/26/2014


clear all
load dilate_vessel_NCES_Sigmoid10.mat
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/baseline_flow_new/20100203_NCES_v1_wFlow.seed -mat
save dilate_vessel_NCES_Sigmoid10.mat

clear all
load dilate_vessel_NCES_Sigmoid20.mat
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/baseline_flow_new/20100203_NCES_v1_wFlow.seed -mat
save dilate_vessel_NCES_Sigmoid20.mat

clear all
load dilate_vessel_NCES_Sigmoid30.mat
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/baseline_flow_new/20100203_NCES_v1_wFlow.seed -mat
save dilate_vessel_NCES_Sigmoid30.mat

