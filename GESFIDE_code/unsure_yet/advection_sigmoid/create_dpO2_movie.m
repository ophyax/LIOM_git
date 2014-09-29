% We create a pO2 movie from the simulation results.
%
% by L. Gagnon 2/05/2013


% load mesh
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/meshing/20100203_NCES_v2_wMesh.mat

pO2_file_list={...

'20100203_NCES_2PM_dOC_0per_Avg_1000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_2000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_3000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_4000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_5000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_6000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_7000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_8000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_9000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_10000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_11000ms.mat';
'20100203_NCES_2PM_dOC_0per_Avg_12000ms.mat';


};


climvaluedPO2 = [-10 10];

im2.alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr


frame_id=0;

%loop around pO2 files
for iFile=1:length(pO2_file_list)

    %load file
    file_name=char(pO2_file_list(iFile));
    display(sprintf('processing %s',file_name))
    load(file_name,'-mat');
    
if iFile==1
    frame_list=1:20:200;
    cg0=cg(:,1);
else
    frame_list=20:20:200;
end

%loop around frame list
for iFrame=1:length(frame_list)

frame_id=frame_id+1;
    
cg1=cg(:,frame_list(iFrame));

% PO2
h3=figure;
clf
set(gcf,'renderer','zbuffer')
dim_fig=get(h3,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(h3,'Position',dim_fig);
set(gcf,'PaperPositionMode','auto')
set(h3,'color',[1 1 1]);




%ROI
maxX=[0 725];
maxY=[0 725];
maxZ=[0 712];

Hvox=[1 1 1]; %mesh voxels are 1x1x1 um

foo = zeros(size(im2.Mesh.node,1),1);
lst = find(im2.VesFlux.gfMap>0);
foo(im2.Mesh.vesWallnode) = cg1(im2.VesFlux.gfMap(lst))./im2.alpha-cg0(im2.VesFlux.gfMap(lst))./im2.alpha;
lstAll = find(im2.Mesh.boundary(:,end)==0);%all vessel nodes
lstROI = find(im2.Mesh.node(im2.Mesh.boundary(:,1),1)>=maxX(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),1)<maxX(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)>=maxY(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)<maxY(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)>=maxZ(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)<maxZ(2) & im2.Mesh.boundary(:,end)==0);
trisurf( im2.Mesh.boundary(lstROI,1:3), im2.Mesh.node(:,1)*Hvox(1), im2.Mesh.node(:,2)*Hvox(2), -im2.Mesh.node(:,3)*Hvox(3), foo, 'linestyle','none','facecolor','flat');
set(gca,'clim',climvaluedPO2)

axis image
grid off
cbh=colorbar;
set(cbh,'fontsize',18)
set(cbh,'fontweight','bold')
% set(gca,'fontsize',14)
% set(gca,'fontweight','bold')
colormap(jet(64))
% xlim([min(im2.Mesh.node(:,1)*im2.Hvox(1)) max(im2.Mesh.node(:,1)*im2.Hvox(1))])
% ylim([min(-im2.Mesh.node(:,2)*im2.Hvox(2)) max(-im2.Mesh.node(:,2)*im2.Hvox(2))])
% zlim([min(-im2.Mesh.node(:,3)*im2.Hvox(3)) max(-im2.Mesh.node(:,3)*im2.Hvox(3))])
view(0,90)
grid off
% set(gca,'XTick',[])
% set(gca,'YTick',[])
% set(gca,'ZTick',[])
%title('Baseline PO_2 (mmHg)','fontsize',16,'fontweight','bold')
title('pO2 (mmHg)','fontsize',20,'fontweight','bold')
%saveas(h3,'pO2.tiff','tif')

set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])
set(gca,'ZTickLabel',[])

set(gca,'XTick',[])
set(gca,'YTick',[])
set(gca,'ZTick',[])


eval(sprintf('print -dtiff -r0 frames/dpO2_graph_%d.tiff',frame_id))
close all


end %frames
end %files

