%This script check for flow reversal at peak arterial dilation. We use the
%simulation with the sigmoidal arterial dilation profile to test that. We
%just check which part of the graph get a change in sign between baseline
%and steady-state activation.

%L. Gagnon 4/09/2012

%% load the sigmoidal simulation
load dilate_vessel_NCES_2PM_1seg.mat

load /autofs/cluster/bartman/2/users/lgagnon/2013/rat_20120523/meshing/20120523_NCES_wMesh_extended.mat

peakIdx=find(tFlow==2);

%plot flow reversal
nSegs=max(im2.nodeSegN);
Finitial=Ftime(1:nSegs,1);
Ffinal=Ftime(1:nSegs,peakIdx);
%Ffinal=Ftime(1:nSegs,15);
SignInitialFlow = sign(Finitial);
SignFinalFlow = sign(Ffinal);
diffSign=diff([SignInitialFlow SignFinalFlow],1,2);
nReversal=length(find(diffSign~=0));

SignInitialFlowExt(find(im2.nodeSegN~=0)) = SignInitialFlow(im2.nodeSegN(find(im2.nodeSegN~=0)));
SignFinalFlowExt(find(im2.nodeSegN~=0)) = SignFinalFlow(im2.nodeSegN(find(im2.nodeSegN~=0)));
diffSignExt=diff([SignInitialFlowExt' SignFinalFlowExt'],1,2);
%%
% %Flag to display a specific segment number
% segNumber=395;%403; %the one that explodes
% segFlag=zeros(nSegs,1);
% segFlag(segNumber)=1;
%segFlag2(find(im2.nodeSegN~=0)) = segFlag(im2.nodeSegN(find(im2.nodeSegN~=0)));

%plot
lstAll=find(im2.Mesh.boundary(:,end)==0); %all nodes
foo = zeros(size(im2.Mesh.node,1),1);
lst=find(im2.VesFlux.gfMap>0);
foo(im2.Mesh.vesWallnode) = diffSignExt(im2.VesFlux.gfMap(lst));
%foo(im2.Mesh.vesWallnode) = segFlag2(im2.VesFlux.gfMap(lst));
hf=figure(12);
set(hf,'color',[1 1 1]);
maxX=[0 725];
maxY=[0 725];
maxZ=[0 712]; %max is 330

% maxX=[250 380];
% maxY=[160 280];
% maxZ=[75 120]; %max is 330


% maxX=[380 420];
% maxY=[230 270];
% maxZ=[80 150]; %max is 330

% maxX=[320 360];
% maxY=[300 340];
% maxZ=[120 150]; %max is 330

% maxX=[280 330];
% maxY=[350 450];
% maxZ=[120 150]; %max is 330
lst = find(im2.Mesh.node(im2.Mesh.boundary(:,1),1)>=maxX(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),1)<maxX(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)>=maxY(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)<maxY(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)>=maxZ(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)<maxZ(2) & im2.Mesh.boundary(:,end)==0);
trisurf( im2.Mesh.boundary(lst,1:3), im2.Mesh.node(:,1), im2.Mesh.node(:,2), -im2.Mesh.node(:,3), foo, 'linestyle','none','facecolor','flat');
axis image
view(13,30)
title(sprintf('Flow reversal in %d out in %d segments (%2.2f %%)',nReversal,nSegs,nReversal/nSegs*100))

