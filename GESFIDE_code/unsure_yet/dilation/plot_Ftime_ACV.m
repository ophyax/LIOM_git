% I just plot the time course of mean pO2 and SO2 and Flow for arteries,
% capillaries and veins during activation.
%
% 01/10/2013 by L. Gagnon
%


maxTime=17;


%load Flow-Volume
% load dilate_vessel_NCES_2PM_constVol.mat
% 
% %load graph
% load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120404/mesh/20120404_NCES_wMesh.mat
load dilate_vessel_NCES_2PM.mat
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/meshing/20100203_NCES_v2_wMesh.mat


%restricted ROI (because of plugged capillaries at the edges)
ROIx=[180 550];    %um
ROIy=[50   500];    %um
ROIz=[0   700];    %um
lstNodeROI=find( im2.Hvox(1).*im2.nodePos(:,1)>ROIx(1) & im2.Hvox(1).*im2.nodePos(:,1)<ROIx(2) & im2.Hvox(2).*im2.nodePos(:,2)>ROIy(1) & im2.Hvox(2).*im2.nodePos(:,2)<ROIy(2) & im2.Hvox(3).*im2.nodePos(:,3)>ROIz(1) & im2.Hvox(3).*im2.nodePos(:,3)<ROIz(2) );
lstSegROI=find( im2.Hvox(1).*im2.segPos(:,1)>ROIx(1) & im2.Hvox(1).*im2.segPos(:,1)<ROIx(2) & im2.Hvox(2).*im2.segPos(:,2)>ROIy(1) & im2.Hvox(2).*im2.segPos(:,2)<ROIy(2) & im2.Hvox(3).*im2.segPos(:,3)>ROIz(1) & im2.Hvox(3).*im2.segPos(:,3)<ROIz(2) );


species=2;

%useful lists
lstSeg_A=find(im2.segVesType(lstSegROI)==1);
lstSeg_C=find(im2.segVesType(lstSegROI)==2);
lstSeg_V=find(im2.segVesType(lstSegROI)==3);
lstSeg_A=lstSegROI(lstSeg_A);
lstSeg_C=lstSegROI(lstSeg_C);
lstSeg_V=lstSegROI(lstSeg_V);


lstNode_A=find(im2.segVesType(im2.nodeSegN(lstNodeROI))==1);
lstNode_C=find(im2.segVesType(im2.nodeSegN(lstNodeROI))==2);
lstNode_V=find(im2.segVesType(im2.nodeSegN(lstNodeROI))==3);
lstNode_A=lstNodeROI(lstNode_A);
lstNode_C=lstNodeROI(lstNode_C);
lstNode_V=lstNodeROI(lstNode_V);


idx_max=find(tFlow>=maxTime);
idx_max=idx_max(1);
tDyn_plot=tFlow(1:idx_max);
flow_a=mean(abs(Ftime(lstSeg_A,1:idx_max)),1);
flow_c=mean(abs(Ftime(lstSeg_C,1:idx_max)),1);
flow_v=mean(abs(Ftime(lstSeg_V,1:idx_max)),1);
vol_a=mean(abs(Vtime(lstSeg_A,1:idx_max)),1);
vol_c=mean(abs(Vtime(lstSeg_C,1:idx_max)),1);
vol_v=mean(abs(Vtime(lstSeg_V,1:idx_max)),1);





%% plot everything


%delta flow in percent
flow_a_n=100*(flow_a./flow_a(1)-1);
flow_c_n=100*(flow_c./flow_c(1)-1);
flow_v_n=100*(flow_v./flow_v(1)-1);
vol_a_n=100*(vol_a./vol_a(1)-1);
vol_c_n=100*(vol_c./vol_c(1)-1);
vol_v_n=100*(vol_v./vol_v(1)-1);

hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(tDyn_plot,flow_a_n,'r',tDyn_plot,flow_c_n,'g',tDyn_plot,flow_v_n,'b','linewidth',3)
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ Flow (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('Flow (%)','fontsize',18,'fontweight','bold')
%print -dtiff -r0 flow_ACV.tiff


hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(tDyn_plot,vol_a_n,'r',tDyn_plot,vol_c_n,'g',tDyn_plot,vol_v_n,'b','linewidth',3)
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ Flow (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('Volume (%)','fontsize',18,'fontweight','bold')
%print -dtiff -r0 Vol_ACV.tiff






