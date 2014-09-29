% We just load the advection results and save the relative changes in CMRO2
% for each simulation. The real value of the parameter simulated can differ
% from the value expected from the simulation because some regions with
% lower pO2 can start consuming more oxygen as we increase the flow.
%
% 8/15/2014 by L. Gagnon

load 20100203_NCES_Sigmoid_dOC_0per_Avg_1000ms.mat
OC_base=OCoutput(1);
load 20100203_NCES_Sigmoid_dOC_0per_Avg_6000ms.mat
OC_act=OCoutput(end);
rCMRO2_10_0=OC_act/OC_base;

load 20100203_NCES_Sigmoid_dOC_10per_Avg_1000ms.mat
OC_base=OCoutput(1);
load 20100203_NCES_Sigmoid_dOC_10per_Avg_6000ms.mat
OC_act=OCoutput(end);
rCMRO2_10_10=OC_act/OC_base;

load 20100203_NCES_Sigmoid_dOC_20per_Avg_1000ms.mat
OC_base=OCoutput(1);
load 20100203_NCES_Sigmoid_dOC_20per_Avg_6000ms.mat
OC_act=OCoutput(end);
rCMRO2_10_20=OC_act/OC_base;

load 20100203_NCES_Sigmoid_dOC_30per_Avg_1000ms.mat
OC_base=OCoutput(1);
load 20100203_NCES_Sigmoid_dOC_30per_Avg_6000ms.mat
OC_act=OCoutput(end);
rCMRO2_10_30=OC_act/OC_base;

save rCMRO2_sigmoid10.mat rCMRO2_10_0 rCMRO2_10_10 rCMRO2_10_20 rCMRO2_10_30

