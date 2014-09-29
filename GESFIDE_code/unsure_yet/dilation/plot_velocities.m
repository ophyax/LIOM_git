% This script plot the temporal evolution of blood velocity for all
% vessels. Doing that will help us to see if the weird O2 results during
% dilation for certain animal is due to too high velocities in some
% segments. 
%
% 4/05/2013 by L. Gagnon

%load graph (for baseline diameters)
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120625/meshing/20120625_NCES_wMesh_low.mat

%load Flow-Volume traces
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120625/dilation/dilate_vessel_NCES_2PM.mat

%%
%compute velocities
nSeg=size(Vtime,1);
nT=length(tFlow);
Area=pi.*(im2.segDiam./2).^2; %in um^2
Area_time=(Area'*ones(1,nT)).*(Vtime./(Vtime(:,1)*ones(1,nT)));
FtimeAvg=(Ftime(1:nSeg,:)+Ftime(nSeg+1:2*nSeg,:))./2;
Vel_time=FtimeAvg./Area_time;
Vel_time=Vel_time./1000; %in mm/sec
figure;
plot(tFlow,Vel_time)
%ylim([-0.02 0.02])
%%
%compute velocities ver2
nSeg=size(Vtime,1);
nT=length(tFlow);
FtimeAvg=(Ftime(1:nSeg,:)+Ftime(nSeg+1:2*nSeg,:))./2;
Vel_time=(im2.segVel*ones(1,nT)).*(FtimeAvg./(FtimeAvg(:,1)*ones(1,nT))); %in um/sec
Vel_time=Vel_time./1000; %in mm/sec
figure;
plot(tFlow,Vel_time)



