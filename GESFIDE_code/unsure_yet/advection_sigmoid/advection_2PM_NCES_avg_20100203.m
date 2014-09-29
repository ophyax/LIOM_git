function advection_2PM_NCES_avg_20100203(CMRO2_base,CMRO2changes,duration_simulation)

%convert string input to numbers
CMRO2_base=str2num(CMRO2_base);
CMRO2changes=str2num(CMRO2changes);
duration_simulation=str2num(duration_simulation);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Qianqian's code for O2 advection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load mesh
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/meshingROI/20100203_NCES_v1_wMesh.mat    


%load Flow-Volume dynamics
load dilate_vessel_NCES_Sigmoid_constVol.mat

%load CMRO2 profile
load dCMRO2_avg_dilation.mat

im2.species=2;

im2.nIter = 200;
im2.nIterPerTrecord = 1;
im2.nAdvIterPerIter = 40;

im2.dt  = 5e-3;  % units of seconds
im2.Hct = 0.3;

im2.Do2 = 2.4e3;    % 2.4e-3 mm^2/s = 2.4e3 um^2/s

im2.hwall = 1;    % vessel wall thickness um
im2.Kves  = 2.23e-12; % Kves = 5e-8 uL mm^-1 s^-1 mmHg^-1 Popel1989
    % 1 L = 1000 cm^3 = 1e6 mm^3 = 1e15 um^3 = 1e6 uL
    % Kves = 5e-2 um^3 um^-1 s^-1 mmHg^-1
    % need to convert from vol of O2 to moles of O2
    % multiply by Pstandard / (R T)
    %     = 1 / (8.21e13 * 273)
    %     = 4.46e-17 mol / um^3
    % Pstandard = 1 atm
    % R = .0821 L atm K^-1 mol^-1
    %   = 8.21e13 um^3 atm K^-1 mol^-1
    % T = 273 K
    % Kves = 2.23e-18 mol um^-1 s^-1 mmHg^-1
    % Kves = 2.23e-12 umol um^-1 s^-1 mmHg^-1
im2.KvesArtFact=1;

% im2.po2a = 90;      % Torr at the arteriole side Input
im2.po2t = 10;      % initial conditions for po2 everywhere

%CMRO2 (trace shape is average of active dilation)
im2.OCo_umol_per_mL_per_min = CMRO2_base; % umol / cm^3 / min
im2.OCo = im2.OCo_umol_per_mL_per_min/1e12/60; % umol / um^3 / sec
tCMRO2=tCMRO2-tCMRO2(1);
im2.tOC = tCMRO2';
CMRO2trace=1+CMRO2changes./100.*dCMRO2'./max(dCMRO2); %must be 1-by-nT
im2.OCo = im2.OCo.*CMRO2trace;

%This is for tissue or blood???, Michele found that it wasn't the same
im2.alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr

im2.Chb = 5.3e-12;            % 5.3e3 uM  red cell hemoglobin content (Beard2001)
% 5.3e3 umol/L = 5.3e-12 umol/um^3


%FLOW
tFlow=tFlow-tFlow(1);
im2.tFlow = tFlow';
im2.Fedges = Fedges;
im2.segRelVol = Vtime ./ (Vtime(:,1)*ones(1,length(tFlow)));
im2.Ftime = Ftime;

%add one point for the last itteration
dtFlow=mean(diff(tFlow));
im2.tFlow(end+1)=im2.tFlow(end)+dtFlow;
im2.Fedges(:,end+1)=im2.Fedges(:,end);
im2.segRelVol(:,end+1)=im2.segRelVol(:,end);
im2.Ftime(:,end+1)=im2.Ftime(:,end);

%display
nIterPerPlot = im2.nIter+1; %never display



% % % BCs on inflowing nodes
% % Use branching order now. For artery use artery and for vein use vein. For
% % capillary, use vessel type corresponding to lowest branching order.
% % 5/11/2012
% 
% %                            Arteries          Veins
% %              br. order      pO2               pO2
% %
% TableFromSava = [ 0           102               45; %pial
%                   1            89               40;                                      
%                   2            78               36;
%                   3            72               33;
%                   4            70               32;
%                   5            58               30;
%                   6            47               30;
%                   7            38               30;
%                   8            35               30;
%                   9            35               30;
%                   10           35               30;
%                   ];
 
lstBC = find(im2.Adv.nodeIn==1);
nBC = length(lstBC);
BCvec=zeros(nBC,2);
for iBC=1:nBC
    BCvec(iBC,1)=lstBC(iBC);
    
    % set inflowing artery only and put the rest to 0
    if im2.nodeType(lstBC(iBC))==1 %artery
        BCvec(iBC,2)=102;
    else
        BCvec(iBC,2)=0; %otherwise zeros because flow is zero anyway!
    end
    
%     edgeIdx=find(im2.nodeEdges(:,1)==lstBC(iBC) | im2.nodeEdges(:,2)==lstBC(iBC));
%     brOrderArt=im2.edgeBRorderArt(edgeIdx);
%     brOrderVeins=im2.edgeBRorderVeins(edgeIdx);
%     
%     if im2.nodeType(lstBC(iBC))==1 %artery
%         BCvec(iBC,2)=TableFromSava(min(brOrderArt+1,11),2);
%     elseif im2.nodeType(lstBC(iBC))==3 %veins
%         BCvec(iBC,2)=TableFromSava(min(brOrderVeins+1,11),3);
%     elseif im2.nodeType(lstBC(iBC))==2 %capillary, take minimum br. Order
%         BCvec(iBC,2)=TableFromSava(min(min(brOrderArt,brOrderVeins)+1,11),3);
%     end
       
end

%load SS O2 distribution
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/advection_baseline_ROI/CMRO2_5dot7/20100203_NCES_SS_OC_5.7_18000ms.mat



%load the flux matrices
load /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/advection_baseline_ROI/CMRO2_5dot7/FluxMatrices.mat

%######################################
% Run the simulation
%######################################
for iSim=1:duration_simulation
    
    c1=c(:,end);
    cg1=cg(:,end);
    cbg1=cbg(:,end);

    tStart=iSim-1;
    [c,cg,cbg,t,AmatFlux,BmatFlux,OCoutput] = sim_VANfem_Run_LG_reversal_OC_output_IN_PROGRESS( im2, im2.nIter, nIterPerPlot, AmatFlux, BmatFlux, c1, cg1, cbg1, tStart, BCvec );

    eval(sprintf('save 20100203_NCES_Sigmoid_dOC_%dper_Avg_%dms.mat c cg cbg OCoutput',CMRO2changes,iSim*1000))
end

return


% %%
% % Visualize the VAN and rotate
% boundary = im2.Mesh.boundary;
% node = im2.Mesh.node;
% 
% foo = zeros(size(im2.Mesh.node,1),1);
% lst = find(im2.VesFlux.gfMap>0);
% % plot vessel Oxy Conc
% foo(im2.Mesh.vesWallnode) = cg(im2.VesFlux.gfMap(lst),end)/im2.alpha;
% 
% hf=figure(10);
% set(hf,'color',[1 1 1]);
% 
% maxX=512;
% maxY=512;
% maxZ=332;
% %lst = find(node(boundary(:,1),3)<maxZ & boundary(:,end)==0);
% lst = find(node(boundary(:,1),1)<maxX & node(boundary(:,1),2)<maxY & node(boundary(:,1),3)<maxZ & boundary(:,end)==0);
% 
% trisurf( boundary(lst,1:3), node(:,1), node(:,2), -node(:,3), foo, 'linestyle','none','facecolor','flat');
% axis image
% view(0.90);
% grid off
% colorbar
