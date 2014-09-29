function liom_visualize_results_O2_NCES
%Taken from:
%This is the script used to generate 3D figures for the ISMRM abstract
% 11/06/2012 by L. Gagnon
%W:\MR_FP\DeLouisGagnon\fingerprint\mouse_20100203\meshingROI
% load data
%PP: next two lines: files are unidentified; need c and cg
%load 20110408_PC_wMesh.mat
%load 20110408_PC_SS_5000ms.mat


%load /autofs/cluster/bartman/2/users/lgagnon/2012/VAN/baseline_Flow/plugged_capillaries/baseline/Sava_Graph_NewLabel_Flow10_wMesh_plugged_capillaries.mat
%load 20110408_PC_SS_3000ms.mat
try
    %%
    %Selection of data
    path0 = 'W:\MR_FP\DeLouisGagnon\fingerprint';
    mouse0 = 'mouse_20100203';
    dilation0 = 10; %10, 20, 30; Dilation value in percentage
    %mouse_20100203, mouse_20110408, mouse_20111202, mouse_20120409, mouse_20120625, mouse_20120626
    cmrO2_path1 = 'advection_sigmoid';
    cmrO2_path2 = 'CMRO2_5dot7';
    sigmoid0 = ['sigmoid' int2str(dilation0)];
    idx1 = strfind(mouse0,'mouse');
    mouse_date = mouse0(idx1+6:end);
    cmrO2_change0 = 0; %0, 10, 20, 30; as a percentage
    duration0 = 2; %1,2,3,4,5,6 s
    data0 = [mouse_date '_NCES_Sigmoid_dOC_' int2str(cmrO2_change0) 'per_Avg_' int2str(duration0) '000ms'];
    fname0 = fullfile(path0,mouse0,cmrO2_path1,cmrO2_path2,sigmoid0,[data0 '.mat']);
    clear c cg cbg OCoutput
    load(fname0,'c','cg','cbg','OCoutput');
    mesh_path0 = 'meshingROI';
    mesh0 = [mouse_date '_NCES_v1_wMesh.mat'];
    fname_mesh = fullfile(path0,mouse0,mesh_path0,mesh0);
    clear im2
    load(fname_mesh,'im2')
    %%
    cg1=cg(:,end);
    c1=c(:,end);
    species=3; %2; %PP? should be 3 instead of 2 according to function so2_func
    Hvox=[1 1 1];
    %% baseline Flow
    h2=figure(2);
    clf
    set(gcf,'renderer','zbuffer')
    set(h2,'color','none');
    
    climFlow=[0 6]; %?
    
    Fseg=im2.segFlow;
    %Fnode(find(im2.nodeSegN~=0)) = abs(Fseg(im2.nodeSegN(find(im2.nodeSegN~=0))))/(1e6/60); %in nL/min
    Fnode(im2.nodeSegN~=0) = abs(Fseg(im2.nodeSegN(im2.nodeSegN~=0))); %in nL/min
    
    lstAll=find(im2.Mesh.boundary(:,end)==0); %all nodes
    foo = zeros(size(im2.Mesh.node,1),1);
    lst = find(im2.VesFlux.gfMap>0);
    boo = log10(Fnode);
    
    foo(im2.Mesh.vesWallnode) = boo(im2.VesFlux.gfMap(lst));
    hsurf = trisurf( im2.Mesh.boundary(lstAll,1:3), im2.Mesh.node(:,1)*im2.Hvox(1), -im2.Mesh.node(:,2)*im2.Hvox(2), -im2.Mesh.node(:,3)*im2.Hvox(3), foo, 'linestyle','none','facecolor','flat');
    set(gca,'clim',[climFlow(1) climFlow(2)])
    cbh=colorbar;
    set(cbh,'fontsize',18)
    set(cbh,'fontweight','bold')
    % set(gca,'fontsize',14)
    % set(gca,'fontweight','bold')
    % xlim([min(im2.Mesh.node(:,1)*im2.Hvox(1)) max(im2.Mesh.node(:,1)*im2.Hvox(1))])
    % ylim([min(-im2.Mesh.node(:,2)*im2.Hvox(2)) max(-im2.Mesh.node(:,2)*im2.Hvox(2))])
    % zlim([min(-im2.Mesh.node(:,3)*im2.Hvox(3)) max(-im2.Mesh.node(:,3)*im2.Hvox(3))])
    view(13,30)
    grid off
    axis image
    % set(gca,'XTick',[])
    % set(gca,'YTick',[])
    % set(gca,'ZTick',[])
    title('log(Flow [nL/min])','fontsize',20,'fontweight','bold')
    %lighting phong;
    %hlight=camlight;
    %saveas(h2,'flow.tiff','tif')
    
    %% PO2 graph node only
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    figure;
    cg1 = cg; %PP?
    maxVal=max(cg1./alpha);
    minVal=min(cg1./alpha);
    cm=jet(64);
    for iii=1:size(im2.nodePos,1)
        if im2.nodePos(iii,3)<500
            colorIdx=round(64*(cg1(iii)./alpha-minVal)/(maxVal-minVal));
            colorIdx=min(colorIdx,64);
            colorIdx=max(colorIdx,1);
            plot3(im2.nodePos(iii,1).*im2.Hvox(1),im2.nodePos(iii,2).*im2.Hvox(2),-im2.nodePos(iii,3).*im2.Hvox(3),'.','color',cm(colorIdx,:),'markersize',16);
            hold on;
        end
    end
    axis square;
    xlim([0 im2.nX.*im2.Hvox(1)])
    ylim([0 im2.nY.*im2.Hvox(2)])
    view(0,90)
    
    %% PO2 graph node value but using mesh node position
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    figure;
    maxVal=max(cg1(im2.VesFlux.gfMap(im2.Mesh.vesWallnode))./alpha);
    minVal=min(cg1(im2.VesFlux.gfMap(im2.Mesh.vesWallnode))./alpha);
    cm=jet(64);
    for iii=1:size(im2.Mesh.vesWallnode,1)
        if im2.Mesh.node(im2.Mesh.vesWallnode(iii),3)<100
            colorIdx=round(64*(cg1(im2.VesFlux.gfMap(im2.Mesh.vesWallnode(iii)))./alpha-minVal)/(maxVal-minVal));
            colorIdx=min(colorIdx,64);
            colorIdx=max(colorIdx,1);
            plot3(im2.Mesh.node(im2.Mesh.vesWallnode(iii),1).*im2.Hvox(1),im2.Mesh.node(im2.Mesh.vesWallnode(iii),2).*im2.Hvox(2),-im2.Mesh.node(im2.Mesh.vesWallnode(iii),3).*im2.Hvox(3),'.','color',cm(colorIdx,:),'markersize',4);
            hold on;
        end
    end
    axis square;
    xlim([0 im2.nX.*im2.Hvox(1)])
    ylim([0 im2.nY.*im2.Hvox(2)])
    view(0,90)
    %% PO2 mesh node only
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    figure;
    maxVal=max(c1(im2.Mesh.vesWallnode)./alpha);
    minVal=min(c1(im2.Mesh.vesWallnode)./alpha);
    cm=jet(64);
    for iii=1:size(im2.Mesh.vesWallnode,1)
        if im2.Mesh.node(im2.Mesh.vesWallnode(iii),3)<500
            colorIdx=round(64*(c1(im2.Mesh.vesWallnode(iii))./alpha-minVal)/(maxVal-minVal));
            colorIdx=min(colorIdx,64);
            colorIdx=max(colorIdx,1);
            plot3(im2.Mesh.node(im2.Mesh.vesWallnode(iii),1).*im2.Hvox(1),im2.Mesh.node(im2.Mesh.vesWallnode(iii),2).*im2.Hvox(2),-im2.Mesh.node(im2.Mesh.vesWallnode(iii),3).*im2.Hvox(3),'.','color',cm(colorIdx,:),'markersize',4);
            hold on;
        end
        
    end
    axis square;
    xlim([0 im2.nX.*im2.Hvox(1)])
    ylim([0 im2.nY.*im2.Hvox(2)])
    view(0,90)
    
    
    %% mesh nodes plus graph nodes superimposed
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    figure;
    maxDepth=40; %in voxel
    
    %mesh nodes
    maxVal=max(c1(im2.Mesh.vesWallnode)./alpha);
    minVal=min(c1(im2.Mesh.vesWallnode)./alpha);
    cm=jet(64);
    for iii=1:size(im2.Mesh.vesWallnode,1)
        if im2.Mesh.node(im2.Mesh.vesWallnode(iii),3)<maxDepth
            colorIdx=round(64*(c1(im2.Mesh.vesWallnode(iii))./alpha-minVal)/(maxVal-minVal));
            colorIdx=min(colorIdx,64);
            colorIdx=max(colorIdx,1);
            plot3(im2.Mesh.node(im2.Mesh.vesWallnode(iii),1).*im2.Hvox(1),im2.Mesh.node(im2.Mesh.vesWallnode(iii),2).*im2.Hvox(2),-im2.Mesh.node(im2.Mesh.vesWallnode(iii),3).*im2.Hvox(3),'.','color',cm(colorIdx,:),'markersize',4);
            hold on;
        end
        
    end
    
    %graph nodes
    maxVal=max(cg1./alpha);
    minVal=min(cg1./alpha);
    cm=jet(64);
    for iii=1:size(im2.nodePos,1)
        if im2.nodePos(iii,3)<maxDepth
            colorIdx=round(64*(cg1(iii)./alpha-minVal)/(maxVal-minVal));
            colorIdx=min(colorIdx,64);
            colorIdx=max(colorIdx,1);
            plot3(im2.nodePos(iii,1).*im2.Hvox(1),im2.nodePos(iii,2).*im2.Hvox(2),-im2.nodePos(iii,3).*im2.Hvox(3),'.','color',cm(colorIdx,:),'markersize',16);
            hold on;
        end
    end
    
    
    axis square;
    xlim([0 im2.nX.*im2.Hvox(1)])
    ylim([0 im2.nY.*im2.Hvox(2)])
    view(0,90)
    
    %% PO2
    h3=figure;
    clf
    set(gcf,'renderer','zbuffer')
    set(h3,'color',[1 1 1]);
    
    maxX=[0 725];
    maxY=[0 725];
    maxZ=[0 712];
    % maxX=[0 725];
    % maxY=[0 725];
    % maxZ=[0 712];
    
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    foo = zeros(size(im2.Mesh.node,1),1);
    lst = find(im2.VesFlux.gfMap>0);
    foo(im2.Mesh.vesWallnode) = cg1(im2.VesFlux.gfMap(lst))/alpha;
    lstAll = find(im2.Mesh.boundary(:,end)==0);%all vessel nodes
    lstROI = find(im2.Mesh.node(im2.Mesh.boundary(:,1),1)>=maxX(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),1)<maxX(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)>=maxY(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)<maxY(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)>=maxZ(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)<maxZ(2) & im2.Mesh.boundary(:,end)==0);
    trisurf( im2.Mesh.boundary(lstROI,1:3), im2.Mesh.node(:,1)*Hvox(1), im2.Mesh.node(:,2)*Hvox(2), -im2.Mesh.node(:,3)*Hvox(3), foo, 'linestyle','none','facecolor','flat');
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
    xlabel('X')
    ylabel('Y')
    
    %% PO2 movie
    frame_list=[1:5:size(c,2)];
    recorded_frame=1;
    
    for ii=1:length(frame_list)
        recorded_frame=recorded_frame+1;
        iframe=frame_list(ii);
        h3=figure(3);
        clf
        set(gcf,'renderer','zbuffer')
        set(h3,'color',[1 1 1]);
        
        alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
        foo = zeros(size(im2.Mesh.node,1),1);
        lst = find(im2.VesFlux.gfMap>0);
        foo(im2.Mesh.vesWallnode) = cg(im2.VesFlux.gfMap(lst),iframe)/alpha;
        lstAll = find(im2.Mesh.boundary(:,end)==0);%all vessel nodes
        trisurf( im2.Mesh.boundary(lstAll,1:3), im2.Mesh.node(:,1)*im2.Hvox(1), -im2.Mesh.node(:,2)*im2.Hvox(2), -im2.Mesh.node(:,3)*im2.Hvox(3), foo, 'linestyle','none','facecolor','flat');
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
        
        eval(sprintf('print -dtiff frames/pO2_%d.tiff',recorded_frame))
        
        close all
    end
    
    %% SatO2 (red-blue)
    h4=figure(4);
    clf
    set(gcf,'renderer','zbuffer')
    set(h4,'color',[1 1 1]);
    
    %colormap for saturation
    r = [1 0 0];       %# start
    w = [.9 .9 .9];    %# middle
    b = [0 0 1];       %# end
    %# colormap of size 64-by-3, ranging from red -> white -> blue
    cm1 = zeros(32,3); cm2 = zeros(32,3);
    for i=1:3
        cm1(:,i) = linspace(r(i), w(i), 32);
        cm2(:,i) = linspace(w(i), b(i), 32);
    end
    cm = [cm1(1:end-1,:);cm2];
    cm = cm(end:-1:1,:); %invert since I want red to be 100%
    
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    foo = zeros(size(im2.Mesh.node,1),1);
    lst = find(im2.VesFlux.gfMap>0);
    foo(im2.Mesh.vesWallnode) = 100.*so2_func(cg1(im2.VesFlux.gfMap(lst))/alpha,species);
    lstAll = find(im2.Mesh.boundary(:,end)==0);%all nodes
    trisurf( im2.Mesh.boundary(lstAll,1:3), im2.Mesh.node(:,1)*im2.Hvox(1), -im2.Mesh.node(:,2)*im2.Hvox(2), -im2.Mesh.node(:,3)*im2.Hvox(3), foo, 'linestyle','none','facecolor','flat');
    set(gca,'clim',[50 100])
    axis image
    grid off
    hc=colorbar;
    set(hc,'fontsize',18)
    set(hc,'fontweight','bold')
    % set(gca,'fontsize',14)
    % set(gca,'fontweight','bold')
    colormap(cm)
    % xlim([min(im2.Mesh.node(:,1)*im2.Hvox(1)) max(im2.Mesh.node(:,1)*im2.Hvox(1))])
    % ylim([min(-im2.Mesh.node(:,2)*im2.Hvox(2)) max(-im2.Mesh.node(:,2)*im2.Hvox(2))])
    % zlim([min(-im2.Mesh.node(:,3)*im2.Hvox(3)) max(-im2.Mesh.node(:,3)*im2.Hvox(3))])
    view(0,90)
    grid off
    % lighting phong;
    % hlight=camlight;
    title('SatO2 (%)','fontsize',20,'fontweight','bold')
    %saveas(h4,'SO2.tiff','tif')
    
    %% SatO2 (multicolor)
    h5=figure(5);
    clf
    set(gcf,'renderer','zbuffer')
    set(h5,'color',[1 1 1]);
    
    
    maxX=[0 725];
    maxY=[0 725];
    maxZ=[0 712];
    
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    foo = zeros(size(im2.Mesh.node,1),1);
    lst = find(im2.VesFlux.gfMap>0);
    foo(im2.Mesh.vesWallnode) = 100.*so2_func(cg1(im2.VesFlux.gfMap(lst))/alpha,species);
    lstAll = find(im2.Mesh.boundary(:,end)==0);%all vessel nodes
    lstROI = find(im2.Mesh.node(im2.Mesh.boundary(:,1),1)>=maxX(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),1)<maxX(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)>=maxY(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),2)<maxY(2) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)>=maxZ(1) & im2.Mesh.node(im2.Mesh.boundary(:,1),3)<maxZ(2) & im2.Mesh.boundary(:,end)==0);
    trisurf( im2.Mesh.boundary(lstROI,1:3), im2.Mesh.node(:,1)*Hvox(1), -im2.Mesh.node(:,2)*Hvox(2), -im2.Mesh.node(:,3)*Hvox(3), foo, 'linestyle','none','facecolor','flat');
    set(gca,'clim',[0 100])
    axis image
    grid off
    hc=colorbar;
    set(hc,'fontsize',18)
    set(hc,'fontweight','bold')
    % set(gca,'fontsize',14)
    % set(gca,'fontweight','bold')
    colormap(jet(64))
    % xlim([min(im2.Mesh.node(:,1)*im2.Hvox(1)) max(im2.Mesh.node(:,1)*im2.Hvox(1))])
    % ylim([min(-im2.Mesh.node(:,2)*im2.Hvox(2)) max(-im2.Mesh.node(:,2)*im2.Hvox(2))])
    % zlim([min(-im2.Mesh.node(:,3)*im2.Hvox(3)) max(-im2.Mesh.node(:,3)*im2.Hvox(3))])
    view(0,90)
    grid off
    % lighting phong;
    % hlight=camlight;
    title('SatO2 (%)','fontsize',20,'fontweight','bold')
    %saveas(h5,'SO2.tiff','tif')
    
    %% pO2 graph and tissue
    
    % Get a slice of the pO2 image
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    climvalue=[0 102];
    iZ = [300:100:600]; %in um
    
    h = 5;
    [xi,yi,zi]=meshgrid(1:(im2.nX*im2.Hvox(1)),(-im2.nY*im2.Hvox(2)):-1,-iZ); % this is for visualization
    lst = find(im2.Mesh.node(:,3)*im2.Hvox(3)>(min(iZ)-h) & im2.Mesh.node(:,3)*im2.Hvox(3)<(max(iZ)+h));
    PO2Interp=TriScatteredInterp(im2.Mesh.node(lst,1)*im2.Hvox(1),-im2.Mesh.node(lst,2)*im2.Hvox(2),-im2.Mesh.node(lst,3)*im2.Hvox(3),c1(lst));
    PO2grid=PO2Interp(xi,yi,zi)./alpha;
    
    h6=figure;
    clf
    set(gcf,'renderer','zbuffer')
    set(h6,'color',[1 1 1]);
    
    %combine graph and tissu
    slice(xi,yi,zi,PO2grid,[],[],-iZ)
    set(findobj(gca,'Type','Surface'),'EdgeColor','none');hold on;
    
    %%
    foo = zeros(size(im2.Mesh.node,1),1);
    lst = find(im2.VesFlux.gfMap>0);
    foo(im2.Mesh.vesWallnode) = cg1(im2.VesFlux.gfMap(lst))/alpha;
    lstAll = find(im2.Mesh.boundary(:,end)==0);%all nodes
    trisurf( im2.Mesh.boundary(lstAll,1:3), im2.Mesh.node(:,1)*im2.Hvox(1), -im2.Mesh.node(:,2)*im2.Hvox(2), -im2.Mesh.node(:,3)*im2.Hvox(3), foo, 'linestyle','none','facecolor','flat');
    set(gca,'clim',[climvalue(1) climvalue(2)])
    axis image
    grid off
    hc=colorbar;
    set(hc,'fontsize',18)
    set(hc,'fontweight','bold')
    title('pO2 (mmHg)','fontsize',20,'fontweight','bold')
    % lighting phong;
    % hlight=camlight;
    view(13,30)
    %saveas(h6,'pO2_tissue_slices.tiff','tif')
    
    %% compute OEF
    
    
    Hct = 0.3;
    Chb = 5.3e-12;
    im2.alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    
    nodeIn=find(im2.Adv.nodeIn==1);
    nodeOut=find(im2.Adv.nodeIn==-1);
    
    nodeIn_a=find(im2.Adv.nodeIn==1 & im2.nodeType'==1);
    nodeIn_c=find(im2.Adv.nodeIn==1 & im2.nodeType'==2);
    nodeIn_v=find(im2.Adv.nodeIn==1 & im2.nodeType'==3);
    
    nodeOut_a=find(im2.Adv.nodeIn==-1 & im2.nodeType'==1);
    nodeOut_c=find(im2.Adv.nodeIn==-1 & im2.nodeType'==2);
    nodeOut_v=find(im2.Adv.nodeIn==-1 & im2.nodeType'==3);
    
    
    %baseline
    species=2;
    totO2in=sum(abs(im2.Adv.Fnode(nodeIn)).*cg1(nodeIn)) + 4*Chb*Hct*( sum(abs(im2.Adv.Fnode(nodeIn)).*so2_func(cg1(nodeIn)/im2.alpha, species)) );
    totO2out=sum(abs(im2.Adv.Fnode(nodeOut)).*cg1(nodeOut)) + 4*Chb*Hct*( sum(abs(im2.Adv.Fnode(nodeOut)).*so2_func(cg1(nodeOut)/im2.alpha, species)) );
    totO2extracted=totO2in-totO2out;
    OEF=totO2extracted/totO2in;
    meanO2satIn=mean(so2_func(cg1(nodeIn)/im2.alpha, species));
    meanO2satOut=mean(so2_func(cg1(nodeOut)/im2.alpha, species));
    
    display(sprintf('OEF: %1.6f',OEF));
    display(sprintf('total O2 extracted from vessel: %1.6e',totO2extracted));
    display(sprintf('total O2 consumed by tissue: %1.6e',OCoutput(end,:)));
    display(sprintf('meanO2satIn baseline: %1.6f     ',100*meanO2satIn));
    display(sprintf('meanO2satOut baseline: %1.6f  \n',100*meanO2satOut));
    
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end