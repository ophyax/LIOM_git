% This script is just putting pO2 to 102 mmHg everywhere in the stack to
% simulate a fully oxygenated voxel. We will use it to directly compute the
% constant M in the Davis model. It corresponds to the maximal BOLD
% response obtained when all the deoxyhemoglobin is washed out.
%
% 08/01/2014 by L. Gagnon

%load any stack
load 20100203_NCES_Sigmoid_dOC_0per_Avg_1000ms.mat

%set O2 to 102 mmHg
c=c(:,1);
cg=cg(:,1);
cbg=cbg(:,1);

%computing corresponding concentration c=alpha*pO2
alpha=1.27e-15;
cg(:,1)=alpha.*102;

save 20100203_NCES_Sigmoid_Full_Oxygenated.mat c cbg cg



