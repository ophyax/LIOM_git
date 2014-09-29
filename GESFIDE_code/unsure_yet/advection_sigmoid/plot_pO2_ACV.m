% I just plot the time course of mean pO2 and SO2 and Flow for arteries,
% capillaries and veins during activation.
%
% 01/10/2013 by L. Gagnon
%


pO2_file_list={...

'20100203_NCES_Sigmoid_dOC_0per_Avg_1000ms.mat';
'20100203_NCES_Sigmoid_dOC_0per_Avg_2000ms.mat';
'20100203_NCES_Sigmoid_dOC_0per_Avg_3000ms.mat';
'20100203_NCES_Sigmoid_dOC_0per_Avg_4000ms.mat';
'20100203_NCES_Sigmoid_dOC_0per_Avg_5000ms.mat';
'20100203_NCES_Sigmoid_dOC_0per_Avg_6000ms.mat';


};
nPO2=length(pO2_file_list);

maxTime=6;

%load Mesh
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/meshingROI/20100203_NCES_v1_wMesh.mat    



%load Flow-Volume
load dilate_vessel_NCES_Sigmoid_constVol.mat



%restricted ROI (because of plugged capillaries at the edges)
ROIx=[0 725];    %um
ROIy=[0 725];    %um
ROIz=[0 400];    %um
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


alpha=1.27e-15;

pO2_a=[];
pO2_c=[];
pO2_v=[];

sO2_a=[];
sO2_c=[];
sO2_v=[];

sO2std_a=[];
sO2std_c=[];
sO2std_v=[];

OC=[];

idx_max=find(tFlow>=maxTime);
idx_max=idx_max(1);
tDyn_plot=tFlow(1:idx_max);
flow_a=mean(abs(Ftime(lstSeg_A,1:idx_max)),1);
flow_c=mean(abs(Ftime(lstSeg_C,1:idx_max)),1);
flow_v=mean(abs(Ftime(lstSeg_V,1:idx_max)),1);

for iFile=1:nPO2
   
    %load file
    file_name=char(pO2_file_list(iFile));
    display(sprintf('processing %s',file_name))
    load(file_name,'-mat');  
    
    % 10Hz
    if iFile==1
        iFrame=1:20:200;
    else
        iFrame=21:20:200;
    end
    
    %CMRO2
    OC=[OC; OCoutput];
    
    %pO2
    pO2_a_i=mean(cg(lstNode_A,iFrame)./alpha,1);
    pO2_c_i=mean(cg(lstNode_C,iFrame)./alpha,1);
    pO2_v_i=mean(cg(lstNode_V,iFrame)./alpha,1);
    
    pO2_a=[pO2_a pO2_a_i];
    pO2_c=[pO2_c pO2_c_i];
    pO2_v=[pO2_v pO2_v_i];
    
    %sO2
    
    sO2_a_i=mean(so2_func(cg(lstNode_A,iFrame)./alpha,species),1);
    sO2_c_i=mean(so2_func(cg(lstNode_C,iFrame)./alpha,species),1);
    sO2_v_i=mean(so2_func(cg(lstNode_V,iFrame)./alpha,species),1);
    sO2std_a_i=std(so2_func(cg(lstNode_A,iFrame)./alpha,species),1);
    sO2std_c_i=std(so2_func(cg(lstNode_C,iFrame)./alpha,species),1);
    sO2std_v_i=std(so2_func(cg(lstNode_V,iFrame)./alpha,species),1);
    
    sO2_a=[sO2_a sO2_a_i];
    sO2_c=[sO2_c sO2_c_i];
    sO2_v=[sO2_v sO2_v_i];
    sO2std_a=[sO2std_a sO2std_a_i];
    sO2std_c=[sO2std_c sO2std_c_i];
    sO2std_v=[sO2std_v sO2std_v_i];
    
    
    
end
%save pO2_ACV_NCES_CMRO2_0per_Avg.mat


%% plot everything

tPO2=linspace(0,tDyn_plot(end),length(pO2_a));

%delta pO2 in percent
pO2_a_n=100*(pO2_a./pO2_a(1)-1);
pO2_c_n=100*(pO2_c./pO2_c(1)-1);
pO2_v_n=100*(pO2_v./pO2_v(1)-1);

%relative sO2 changes in percent
sO2_a_n=100*(sO2_a./sO2_a(1)-1);
sO2_c_n=100*(sO2_c./sO2_c(1)-1);
sO2_v_n=100*(sO2_v./sO2_v(1)-1);

%delta sO2 in percent
sO2_a_p=100*(sO2_a-sO2_a(1));
sO2_c_p=100*(sO2_c-sO2_c(1));
sO2_v_p=100*(sO2_v-sO2_v(1));


%delta pO2 in mmHg
pO2_a_mm=pO2_a-pO2_a(1);
pO2_c_mm=pO2_c-pO2_c(1);
pO2_v_mm=pO2_v-pO2_v(1);


%delta flow in percent
flow_a_n=100*(flow_a./flow_a(1)-1);
flow_c_n=100*(flow_c./flow_c(1)-1);
flow_v_n=100*(flow_v./flow_v(1)-1);


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
plot(tPO2,pO2_a_n,'r',tPO2,pO2_c_n,'g',tPO2,pO2_v_n,'b','linewidth',3);
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ pO2 (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('Relative pO2 changes (%)','fontsize',18,'fontweight','bold')
title('Relative pO2 changes','fontsize',18,'fontweight','bold')
%print -dtiff -r0 rpO2_ACV.tiff

hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(tPO2,pO2_a_mm,'r',tPO2,pO2_c_mm,'g',tPO2,pO2_v_mm,'b','linewidth',3);
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ pO2 (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('pO2 changes (mmHg)','fontsize',18,'fontweight','bold')
title('Absolute pO2 changes','fontsize',18,'fontweight','bold')
%print -dtiff -r0 apO2_ACV.tiff



hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1.5*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
subplot(1,3,1)
plot(tPO2,sO2_a,'r','linewidth',3);axis square;hold on;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
ylabel('sO2 (%)','fontsize',18,'fontweight','bold')
title('sO2','fontsize',18,'fontweight','bold')
subplot(1,3,2)
plot(tPO2,sO2_c,'g','linewidth',3);axis square;hold on;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
title('sO2','fontsize',18,'fontweight','bold')
subplot(1,3,3)
plot(tPO2,sO2_v,'b','linewidth',3);axis square;hold on;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
title('sO2','fontsize',18,'fontweight','bold')

% print -dtiff -r0 sO2_ACV_sep.tiff
% 
% trace_a=[tPO2' 100.*sO2_a'];
% save('trace_A.txt','trace_a','-ascii');
% 
% trace_c=[tPO2' 8+100.*sO2_c'];
% save('trace_C.txt','trace_c','-ascii');
% 
% trace_v=[tPO2' 100.*sO2_v'];
% save('trace_V.txt','trace_v','-ascii');


hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(tPO2,sO2_a_n,'r',tPO2,sO2_c_n,'g',tPO2,sO2_v_n,'b','linewidth',3);
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ pO2 (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('Relative sO2 change (%)','fontsize',18,'fontweight','bold')
title('Relative sO2 change','fontsize',18,'fontweight','bold')
%print -dtiff -r0 rsO2_ACV.tiff



hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(tPO2,sO2_a_p,'r',tPO2,sO2_c_p,'g',tPO2,sO2_v_p,'b','linewidth',3);
axis square;
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
hl=legend('Arteries','Capillaries','Veins');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')
xlabel('time (s)','fontsize',18,'fontweight','bold')
%ylabel('$\Delta$ pO2 (\%)','fontsize',14,'fontweight','bold','interpreter','latex')
ylabel('sO2 change (%)','fontsize',18,'fontweight','bold')
title('Absolute sO2 change','fontsize',18,'fontweight','bold')
%print -dtiff -r0 asO2_ACV.tiff



hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');

rsO2_abbas=[3 8];
rsO2std_abbas=[1 4];
data_bar=[rsO2_abbas(1) max(sO2_a_n); rsO2_abbas(2) max(sO2_v_n)];

h=bar(data_bar);
legend('Yassen 2011','Simulations','location','northwest')
set(h(1),'facecolor',[.5 .5 .5])
set(h(2),'facecolor','k')
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
set(gca,'XTickLabel',{'Arteries','Veins'})
title('Comparison with experimental data','fontsize',18,'fontweight','bold')
axis square;
ylim([0 10])
ylabel('Relative sO2 change (%)','fontsize',18,'fontweight','bold')
%print -dtiff -r0 comp_sO2_AV.tiff

% hist_value=[rsO2_abbas(1) max(sO2_a_n); rsO2_abbas(2) max(sO2_v_n)];
% save('hist_value.txt','hist_value','-ascii');


%h=barweb(data_bar,zeros(2,2),0.8,[],'Comparison with experimental data',[],[],[],'y',[],1,'plot');
% aa=jet(64);
% for ii=1:nWays
%    set(h.bars(ii),'facecolor',aa(round(ii/nWays*64),:));
% end
% set(gca,'fontsize',thefontsize,'fontweight','bold')
% barwebpairs(h, [], groupHbOR2)
% xlim([.5 1.5])

hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');
plot(0.005:0.005:max(tPO2),OC./OC(1),'k','linewidth',3)
set(gca,'fontsize',18)
set(gca,'fontweight','bold')
axis square;
xlabel('time (s)','fontsize',18,'fontweight','bold')
ylabel('rCMRO2','fontsize',18,'fontweight','bold')
hl=legend('rCMRO2');
set(hl,'fontsize',18)
set(hl,'fontweight','bold')