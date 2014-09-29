function liom_MCproton2
% (B0,phi_angle,omega_angle,TE,Gx,ROIx1,ROIx2,...
%     ROIy1,ROIy2,ROIz1,ROIz2,volume_and_mesh_file,...
%     ref_file,ref_iFrame,vol_ref_iFrame)
try
    %%%%% MC parameters %%%%%%%%
    nprotons=1e4;
    dt=0.2;     %msec
    MaxCross = 100; %number of times to check for protons to...
    %masking parameters (this allows a mask with no gap)
    maskSphereSpacing = 0.05; %in um
    maxR = 90; %in um

    %Selection of data
    path0 = 'W:\MR_FP\DeLouisGagnon\fingerprint';
    mouse0 = 'mouse_20100203';
    %mouse0 = 'mouse_20120626';
    %mouse_20100203, mouse_20110408, mouse_20111202, mouse_20120409, mouse_20120625, mouse_20120626
    dilation0 = 10; %10, 20, 30; Dilation value as a percentage
    cmrO2_path1 = 'advection_sigmoid';
    cmrO2_path2 = 'CMRO2_5dot7';
    sigmoid0 = ['sigmoid' int2str(dilation0)];
    idx1 = strfind(mouse0,'mouse');
    mouse_date = mouse0(idx1+6:end);
    cmrO2_change0 = 10; %0, 10, 20, 30; as a percentage
    cmrO2_sigmoid0 = ['sigmoid' int2str(cmrO2_change0)];
    %duration0 = 2; %1,2,3,4,5,6 s
    %data0 = [mouse_date '_NCES_Sigmoid_dOC_' int2str(cmrO2_change0) 'per_Avg_' int2str(duration0) '000ms'];
    %fname0 = fullfile(path0,mouse0,cmrO2_path1,cmrO2_path2,sigmoid0,[data0 '.mat']);
    mesh_path0 = 'meshingROI';
    mesh0 = [mouse_date '_NCES_v1_wMesh.mat'];
    fname_mesh = fullfile(path0,mouse0,mesh_path0,mesh0);
    pathMC = fullfile(path0,mouse0,'BOLD_sigmoid',cmrO2_sigmoid0);
    %file_name = fname0;
    data_ref0 = [mouse_date '_NCES_Sigmoid_dOC_0per_Avg_1000ms'];
    ref_file = fullfile(path0,mouse0,cmrO2_path1,cmrO2_path2,sigmoid0,[data_ref0 '.mat']);
    volume_and_mesh_file = fname_mesh;
    %Load Vtime from dilation file
    Vfile0 = ['dilate_vessel_NCES_' sigmoid0 '.mat'];
    Vtime_file = fullfile(path0,mouse0,'dilation',Vfile0);
    load(Vtime_file,'Vtime');
    % #timing baseline
    O2baseidx=1;
    Flowbaseidx=1;
    % #ROI
    ROIx1=0;
    ROIx2=725;
    ROIy1=0;
    ROIy2=725;
    ROIz1=0;
    ROIz2=400;
    % #Echo time
    TE=67; %in msec
    % #Gradients
    Gx=0; %to be able read several TEs
    % #B-field orientation angle
    phi_angle=0;
    omega_angle=90; 
    % for mouse_20120626
    % #timing baseline
    % O2baseidx=1
    % Flowbaseidx=1;
    % #ROI
    % ROIx1=0;
    % ROIx2=530;
    % ROIy1=280;
    % ROIy2=725;
    % ROIz1=0;
    % ROIz2=600;
    ref_iFrame = O2baseidx;
    vol_ref_iFrame = Flowbaseidx;
    
    ntime_step=ceil(TE/dt);
    ROIx=[ROIx1 ROIx2];    %um
    ROIy=[ROIy1 ROIy2];    %um
    ROIz=[ROIz1 ROIz2];    %um
    
    %Volume size and voxel size (anisotropic)
    Hvox=1; %in um (isotropic because the Fourier kernel assumes a sphere!)
    
    % %%%%%% Some constants %%%%%%%%%%%%%%%%
    B0=7; % main Field (Tesla) now as an input parameter
    dChi0 = 4*pi*0.264e-6; % suceptibility of deoxygenated blood (from  Christen et al 2011)
    gamma=2.675e5; % rad/Tesla/msec
    %Gx=20; % Gradient for readout in mT/m
    Gxum=Gx*1e-6*1e-3; % Now in T/um
    Dcoeff=1; %Proton (water) diffusion coefficient(um2/msec)
    a=Hvox(1)/2; %radius of the sphere contained in a voxel (that's why we need isotropic voxels)
    Dvox=Dcoeff/(Hvox(1).^2);
    
    %Hematocrit
    alpha = 1.27e-15;  % Bunsen solubility coefficient umol / um^3 / Torr
    Hct_A = 0.44; %arteries (from Griffeth et al 2011)
    Hct_C = 0.33; %capillaries
    Hct_V = 0.44; %veins
    Hct = [Hct_A Hct_C Hct_V];
    
    %T2 constants
    T2_tissu=1000.*(1.74*B0+7.77)^(-1); %in msec (from Uludag 2009)
    T2star_tissu=1000.*(3.74*B0+9.77)^(-1); %in msec (from Uludag 2009)    
    %T2_blood = 1000.*(1./( (2.74.*B0-0.6)+(12.67.*B0^2.*(1-SatO2).^2) )); %in msec (from Uludag 2009)
    
    %%%%%%% load everything %%%%%%%%%%%%%%%
    %load the mesh and volume changes time course
    load(volume_and_mesh_file);
    
    if ~isfield(im2,'species')
        species=1; %set to human pO2-sO2 curve otherwise specified
    else
        species=im2.species;
    end
    if ~exist('Vtime','var')
        if isfield(im2,'Vitme')
            Vtime=im2.Vtime;
        else
            error('Can''t find Vtime variable')
        end
    end
    RelVol_ref = Vtime(:,vol_ref_iFrame) ./ Vtime(:,1);
    %load pO2 baseline file
    load(ref_file); %This contains c, cg, cbg
    %c:?
    %cg: PO2 concentration graph
    %cbg: bounded hemoglobin     
    cg1=cg(:,ref_iFrame);
    clear c cg cbg
    
    %mask dimension
    nx=ceil(im2.nX.*im2.Hvox(1));
    ny=ceil(im2.nY.*im2.Hvox(2));
    nz=ceil(im2.nZ.*im2.Hvox(3));
    
    %%%%%%% Generate SatO2 and T2 volumes %%%%%%%%%%%%%%%    
    % pO2 values are on graph nodes so I will generate a mask with a given voxel
    % specifications.    
        
    nEdges = size(im2.nodeEdges,1);
    nNodes = size(im2.nodePos_um,1);
    nodePos_um = im2.nodePos_um;
    
    SatO2mask_ini = zeros(ny,nx,nz);    
    Hctmask_ini = zeros(ny,nx,nz);
    Vm_base = zeros(ny,nx,nz);
    
    nodeMasked_ref = zeros(nNodes,1);
    
    lstEdges = 1:nEdges;
    tic
    for iiE=1:length(lstEdges)
        
        if(mod(iiE,floor(length(lstEdges)/10))==0)
            display(sprintf('Mask %d %%completed',round(100*iiE/length(lstEdges))))
        end
        iE = lstEdges(iiE);
        i1 = im2.nodeEdges(iE,1); %PP?
        i2 = im2.nodeEdges(iE,2);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % reference volume size and O2 sat
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if (nodeMasked_ref(i1)==0 || nodeMasked_ref(i2)==0)
            if ~im2.maskUseSegDiam
                r1 = im2.nodeDiam(i1)/2.*RelVol_ref(im2.nodeSegN(i1)).^(1/2);
                r1 = min(max(r1,1),maxR);
                r2 = im2.nodeDiam(i2)/2.*RelVol_ref(im2.nodeSegN(i2)).^(1/2);
                r2 = min(max(r2,1),maxR);               
            else
                foo = max( im2.segDiam(im2.nodeSegN(i1)).*RelVol_ref(im2.nodeSegN(i1)).^(1/2) , im2.segDiam(im2.nodeSegN(i2)).*RelVol_ref(im2.nodeSegN(i2)).^(1/2) )/2;
                foo = min(max(foo,1),maxR);
                r1 = foo;
                r2 = foo;
            end
            p1 = round(nodePos_um(i1,:)./Hvox); %in voxels (Hvox in the specified voxel size, not the native voxel size)
            p2 = round(nodePos_um(i2,:)./Hvox);
            d12 = norm(p2-p1);
            dxyz = (p2-p1);%/d12;
            rd = (r2-r1);%/d12;
            nSteps = 1;
            stepLen = max(r1*maskSphereSpacing,1);
            if stepLen<d12
                dxyz = (p2-p1)*stepLen/d12;
                rd = (r2-r1)*stepLen/d12;
                nSteps = floor(d12/stepLen)+1;
            end
            
            %lst = find(sum((nodePos_um-ones(nNodes,1)*p1).^2,2).^0.5<(r1*maskSphereSpacing) );
            nodeMasked_ref(sum((nodePos_um-ones(nNodes,1)*p1).^2,2).^0.5<(r1*maskSphereSpacing)) = 1;
            %lst = find(sum((nodePos_um-ones(nNodes,1)*p2).^2,2).^0.5<(r2*maskSphereSpacing) );
            nodeMasked_ref(sum((nodePos_um-ones(nNodes,1)*p2).^2,2).^0.5<(r2*maskSphereSpacing) ) = 1;
            
            p = p1; %in voxels
            r = r1; %in um
            flag = 1;
            while flag %PP looks like a long thing
                if norm(round(p)-p2)==0
                    flag = 0;
                end
                pr = round(p);
                rTmp = min(r,maxR);
                rx = ceil(rTmp/Hvox); %in voxels
                ry = ceil(rTmp/Hvox);
                rz = ceil(rTmp/Hvox);
                if im2.maskCircleFlag
                    rz = 0;
                end
                
                if d12~=0                    
                    %the satO2 value is constant for each voxel so compute it only
                    %one time
                    SatO2_value_ref = norm(p-p1)/d12.*so2_func(cg1(i2)./alpha,species) + ...
                        norm(p-p2)/d12.*so2_func(cg1(i1)./alpha,species);%weighted average
                    
                    for iX = -rx:+rx
                        for iY = -ry:+ry
                            for iZ = -rz:+rz
                                if norm([iX*Hvox iY*Hvox iZ*Hvox])<=r %all in um
                                    iix = min(max(pr(1)+iX,1),nx);
                                    iiy = min(max(pr(2)+iY,1),ny);
                                    iiz = min(max(pr(3)+iZ,1),nz);
                                    
                                    SatO2mask_ini(iiy,iix,iiz) = SatO2_value_ref;
                                    Hctmask_ini(iiy,iix,iiz) = Hct(im2.segVesType(im2.edgeSegN(iiE)));
                                    Vm_base(iiy,iix,iiz) = 1;                                    
                                end
                            end
                        end
                    end
                end
                
                if flag
                    p = p + dxyz;
                    r = r + rd;
                end
                nSteps = nSteps - 1;
                if nSteps==0
                    flag = 0;
                end
                if norm(round(p)-p2)==0
                    flag = 0;
                end
                
            end
        end % end of check if node type updated
    end
    toc
    
    %T2 volume (in msec)
    T2mask_ini = T2_tissu.*ones(ny,nx,nz);
    T2mask_ini(Hctmask_ini~=0) = 1000.*(1./( (2.74.*B0-0.6)+(12.67.*B0^2.*(1-SatO2mask_ini(Hctmask_ini~=0)).^2) ));
    
    %T2* volume (in msec)
    %intravascular relaxation rate
    %from Zhao 2007 and Silverstein 2003
    if B0<=1.5
        As=6.5;
        Cs=25;
    elseif (B0>1.5 && B0<=3)
        As=13.8;
        Cs=181;
    elseif (B0>3 && B0<=4)
        As=30.4;
        Cs=262;
    elseif (B0>4 && B0<=4.7)
        As=41;
        Cs=319;
    elseif B0>4.7
        As=100;
        Cs=500; %very large number so that decays faster than TE
    end
    
    T2starmask_ini = T2star_tissu.*ones(ny,nx,nz);
    T2starmask_ini(Hctmask_ini~=0) = 1000.*(1./(As+Cs.*(1-SatO2mask_ini(Hctmask_ini~=0)).^2));
    
    %dChi volume
    dChimask_ini = dChi0.*Hctmask_ini.*(1-SatO2mask_ini);
    clear  Hctmask_ini 
    
    %crop volumes to keep only ROI (x and y are inverted)
    xidx1=max(round(ROIy(1)),1);
    xidx2=min(round(ROIy(2)),nx);
    yidx1=max(round(ROIx(1)),1);
    yidx2=min(round(ROIx(2)),ny);
    zidx1=max(round(ROIz(1)),1);
    zidx2=min(round(ROIz(2)),nz);
    xidx2=floor((xidx2-xidx1+1)/2)*2+(xidx1-1);
    yidx2=floor((yidx2-yidx1+1)/2)*2+(yidx1-1);
    zidx2=floor((zidx2-zidx1+1)/2)*2+(zidx1-1);
    
    dChimask_ini = dChimask_ini(xidx1:xidx2,yidx1:yidx2,zidx1:zidx2);
    
    T2starmask_ini = T2starmask_ini(xidx1:xidx2,yidx1:yidx2,zidx1:zidx2);
    
    T2mask_ini = T2mask_ini(xidx1:xidx2,yidx1:yidx2,zidx1:zidx2);
    
    Vm_base = Vm_base(xidx1:xidx2,yidx1:yidx2,zidx1:zidx2);
    %Redfine nx, ny, nz
    [nx ny nz]=size(dChimask_ini);
        
    %%%%%%%%% Construct delta_B map %%%%%%%%%%%%%%
    %(we assume cube is repeated periodically in space, no padding in FFT)
    
    fft_succep_volume_ini=fftshift(fftn(fftshift(dChimask_ini)));
    clear dChimask_ini
    
    origin=[nx/2-0.5,ny/2-0.5,nz/2-0.5].*Hvox(1); %in um
    pert_B=zeros(nx,ny,nz);
    r0 = [ cos(phi_angle*pi/180)*sin(omega_angle*pi/180) ...
        sin(phi_angle*pi/180)*sin(omega_angle*pi/180) cos(omega_angle*pi/180) ]; %unit vector oriented along the B-field
    r0_norm=norm(r0); %should be one
    for ii=1:size(pert_B,1)
        for jj=1:size(pert_B,2)
            for kk=1:size(pert_B,3)
                r=[ii,jj,kk].*Hvox(1)-origin; %in um
                r_norm=norm(r); %in um
                if r_norm==0
                    pert_B(ii,jj,kk)=0;
                else
                    costheta=dot(r,r0)./(r_norm.*r0_norm);
                    pert_B(ii,jj,kk)=B0*2/pi*a^3/(r_norm)^3*(3*costheta^2-1);
                end
            end
        end
    end
    fft_pert_B=fftshift(fftn(fftshift(pert_B)));
    clear pert_B
    delta_B_ini=real(ifftshift(ifftn(ifftshift(fft_pert_B.*fft_succep_volume_ini))));
    clear fft_succep_volume_ini 
    
    %%%%%%%%% Run proton Monte Carlo %%%%%%%%%%%%    
    phase_GE_base=zeros(nprotons,1);
    phase_SE_base=zeros(nprotons,1);
    signal_GE_base=zeros(1,ntime_step);
    signal_SE_base=zeros(1,ntime_step);
    signal_GE_IV_base=zeros(1,ntime_step);
    signal_SE_IV_base=zeros(1,ntime_step);
    signal_GE_EV_base=zeros(1,ntime_step);
    signal_SE_EV_base=zeros(1,ntime_step);  
    
    % Generate initial position for protons inside the ROI
    %protons_pos=floor(nx*rand(nprotons,3))+0.5;
    protons_pos_x=floor(nx*rand(nprotons,1))+0.5;  %this is in microns
    protons_pos_y=floor(ny*rand(nprotons,1))+0.5;  %this is in microns
    protons_pos_z=floor(nz*rand(nprotons,1))+0.5;  %this is in microns
    protons_pos_base=[protons_pos_x protons_pos_y protons_pos_z];    %need this because proton must stay inside vessel at baseline too
    
    %Spin Echo params
    half_echo_index=round(TE/(2*dt));
    start1_se_index=round(TE/(4*dt)-TE/(8*dt));
    stop1_se_index=round(TE/(4*dt)+TE/(8*dt));
    start2_se_index=round(TE/(dt)-TE/(4*dt));
    stop2_se_index=round(TE/dt+TE/(4*dt));
    
    %Gradient Echo params
    start_ge_index=round(TE/(3*dt));
    flip_ge_index=round(2*TE/(3*dt));
    stop_ge_index=round(4*TE/(3*dt));
    
    ge_gradient_weight=0;
    se_gradient_weight=0;
    tic
    for i=1:ntime_step
        if(mod(i,(ntime_step/10))==0)
            display(sprintf('MCproton %d %%completed',round(100*i/ntime_step)))
        end
        
        %Gradient in readout for GE
        if(start_ge_index==i)
            ge_gradient_weight=1;
        elseif (flip_ge_index==i)
            ge_gradient_weight=-1;
        elseif (stop_ge_index==i)
            ge_gradient_weight=0;
        end
        
        %Gradient in readout for SE
        if(start1_se_index==i)
            se_gradient_weight=1;
        elseif (stop1_se_index==i)
            se_gradient_weight=0;
        elseif (start2_se_index==i)
            se_gradient_weight=1;
        elseif (stop2_se_index==i)
            se_gradient_weight=0;
        end
        
        %%%%%%%%%%%%%%%%%%%%
        % baseline state
        
        %identify extravascular proton
        indices_base=ceil(protons_pos_base/Hvox(1));
        indices_base(:,1)=max(min(indices_base(:,1),nx),1);
        indices_base(:,2)=max(min(indices_base(:,2),ny),1);
        indices_base(:,3)=max(min(indices_base(:,3),nz),1);
        proton_Vm_base=Vm_base(sub2ind(size(Vm_base),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        
        %move proton temporarily
        sigma=sqrt(2*Dvox*dt);
        rnum_base=sigma*randn(nprotons,3);
        protons_pos_base_new_temp=protons_pos_base+rnum_base;
        
        %(make sure IV stays IV and EV stays EV)
        indices_base=ceil(protons_pos_base_new_temp/Hvox(1));
        indices_base(:,1)=max(min(indices_base(:,1),nx),1);
        indices_base(:,2)=max(min(indices_base(:,2),ny),1);
        indices_base(:,3)=max(min(indices_base(:,3),nz),1);
        proton_Vm_base_new=Vm_base(sub2ind(size(Vm_base),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        
        %find the ones who crossed vessel boundary (try 100 times otherwise let it go cross the boundary)
        crossing_list=find(proton_Vm_base~=proton_Vm_base_new);
        flag_cpt=0;
        while ( ~isempty(crossing_list) && flag_cpt<=MaxCross )
            
            rnum_base(crossing_list,:)=sigma*randn(length(crossing_list),3);
            protons_pos_base_new_temp=protons_pos_base+rnum_base;
            
            indices_base=ceil(protons_pos_base_new_temp/Hvox(1));
            indices_base(:,1)=max(min(indices_base(:,1),nx),1);
            indices_base(:,2)=max(min(indices_base(:,2),ny),1);
            indices_base(:,3)=max(min(indices_base(:,3),nz),1);
            proton_Vm_base_new=Vm_base(sub2ind(size(Vm_base),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
            crossing_list=find(proton_Vm_base~=proton_Vm_base_new);
            
            flag_cpt=flag_cpt+1;
            
        end
        
        %move proton accordingly
        protons_pos_base=protons_pos_base+rnum_base;
        indices_base=ceil(protons_pos_base/Hvox(1));
        indices_base(:,1)=max(min(indices_base(:,1),nx),1);
        indices_base(:,2)=max(min(indices_base(:,2),ny),1);
        indices_base(:,3)=max(min(indices_base(:,3),nz),1);
        
        %update IV and EV lists
        proton_Vm_base=Vm_base(sub2ind(size(Vm_base),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        IV_list_base=find(proton_Vm_base==1);
        EV_list_base=find(proton_Vm_base~=1);
        display(sprintf('%1.4f percent of protons were intravascular at baseline',100.*length(IV_list_base)./nprotons))
        
        protons_B_base=delta_B_ini(sub2ind(size(delta_B_ini),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        
        protons_T2_base=T2mask_ini(sub2ind(size(delta_B_ini),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        
        protons_T2star_base=T2starmask_ini(sub2ind(size(delta_B_ini),indices_base(:,1),indices_base(:,2),indices_base(:,3)));
        
        protons_gradient_GE_base=ge_gradient_weight*(protons_pos_base(:,1)-(nx/2)*Hvox(1))*Gxum;
        protons_gradient_SE_base=se_gradient_weight*(protons_pos_base(:,1)-(nx/2)*Hvox(1))*Gxum;
        
        % Spin echo, 180 degrees phase shift
        if i==half_echo_index
            phase_SE_base=conj(phase_SE_base);
        end
        
        %%%%%%%%%%%%%%%
        % baseline signal (all vessels)
        
        %signal GE
        phase_GE_base(EV_list_base)=phase_GE_base(EV_list_base)+1i*gamma*(protons_B_base(EV_list_base)+protons_gradient_GE_base(EV_list_base))*dt-(1./protons_T2_base(EV_list_base))*dt;
        phase_GE_base(IV_list_base)=phase_GE_base(IV_list_base)-(1./protons_T2star_base(IV_list_base))*dt;
        signal_GE_base(i)=abs(sum(exp(phase_GE_base))/nprotons);
        signal_GE_IV_base(i)=abs(sum(exp(phase_GE_base(IV_list_base)))/length(IV_list_base));
        signal_GE_EV_base(i)=abs(sum(exp(phase_GE_base(EV_list_base)))/length(EV_list_base));
        
        %signal SE
        phase_SE_base(EV_list_base)=phase_SE_base(EV_list_base)+1i*gamma*(protons_B_base(EV_list_base)+protons_gradient_SE_base(EV_list_base))*dt-(1./protons_T2_base(EV_list_base))*dt;
        phase_SE_base(IV_list_base)=phase_SE_base(IV_list_base)-(1./protons_T2_base(IV_list_base))*dt;
        signal_SE_base(i)=abs(sum(exp(phase_SE_base))/nprotons);
        signal_SE_IV_base(i)=abs(sum(exp(phase_SE_base(IV_list_base)))/length(IV_list_base));
        signal_SE_EV_base(i)=abs(sum(exp(phase_SE_base(EV_list_base)))/length(EV_list_base));                    
    end
    toc    

        %generate names for files to be saved
%     [file_path,save_name_str] = fileparts(file_name);
%     save_name=['MCproton_' save_name_str sprintf(...
%         '_B0_%2.1fT_ori_[%d_%d]_TE%dms_Gx%d_ROI_[%d %d %d %d %d %d]_frame_%d_volFrame_%d',...
%         B0,phi_angle,omega_angle,TE,Gx,ROIx1,ROIx2,ROIy1,ROIy2,ROIz1,ROIz2,ref_iFrame,vol_ref_iFrame) '.mat'];

    tMCproton=(1:ntime_step)*dt;
    S.tMCproton = tMCproton;
    S.phase_GE_base = phase_GE_base;
    S.phase_SE_base = phase_SE_base;
    
    S.signal_GE_base = signal_GE_base;
    S.signal_SE_base = signal_SE_base;
   
    S.signal_GE_IV_base = signal_GE_IV_base;
    S.signal_SE_IV_base = signal_SE_IV_base;
    S.signal_GE_EV_base = signal_GE_EV_base;
    S.signal_SE_EV_base = signal_SE_EV_base;
    S.s = S.signal_SE_EV_base; %GESFIDE signal?
           
    %save
    save(fullfile(pathMC,'S.mat'),'S');
    
    A.delta_B_ini = delta_B_ini;
    A.SatO2mask_ini = SatO2mask_ini;
    A.T2mask_ini = T2mask_ini;
    %A.Hctmask_ini= Hctmask_ini;
    save(fullfile(pathMC,'A.mat'),'A','-v7.3');  %this gives huge files! (~1GB)
catch exception
    disp(exception.identifier);
    disp(exception.stack(1));
end