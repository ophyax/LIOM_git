function liom_GenerateBOLD_Time_Course
try
    % UNITS: start with usual units, but aim to express them in
    % ms, um, Tesla and radians during the computations
    %
    % We generate the BOLD time courses from the delta_B volume by calculating
    % the phase acrual of diffusing protons.
    % Adapted from: 10/01/2012 by L. Gagnon adapted from F. Lesage code
    sp = 1; %Species: 1: mouse, 2: rat
    ROOT_folder = 'W:\MR_FP'; 
    TPH_folder = fullfile(ROOT_folder,'TPH');
    info = load(fullfile(TPH_folder,'info.mat'));
    TPH_info = info.info; 
    clear info;
    Y0 = read_tiff_stack(fullfile(TPH_folder,'scaledvolume_backgroundless_NI.tif'));
    %[nx0 ny0 nz0] = size(Y0);
    SF = TPH_info.scalingFactor; %Microns per pixel
    %Large voxel of good data:
    Y = Y0(100:600,100:350,100:300);
    [nx ny nz] = size(Y);
    Lx = nx*SF; Ly = ny*SF; Lz = nz*SF; %voxel sizes
    V = nx*ny*nz*SF^3; %in cubic microns
    %V_uL = V/1e9; %0.037, in microL or mm^3
    %a typical small voxel for rat BOLD fMRI: 0.5 x 0.5 x 1 mm^3, or 0.25 uL
    %a typical small voxel for mouse BOLD fMRI: 0.25 x 0.25 x 1 mm^3, or 0.06 uL
    %Threshold on Y -- create binary mask for vessels
    th = 3e3; %Vfrac = 23%; calculated over whole volume though
    Yth = Y;
    Yth(Y>th) = 1;
    Yth(Y<=th) = 0;
    Vfrac = sum(Yth(:))/(nx*ny*nz);
    Y = double(Yth);
    
    T2_GE=[];
    T2_SE=[];
    BOLD_GE=0;
    BOLD_SE=0;
    
    T2_blood = 200; %ms at 7T, very approximate
    T2_GM = 60;
    T2vol = Y*T2_blood+(1-Y)*T2_GM; 
    %B0=7; % Tesla
    B0f = 299.46; %MHz
    gamma=2.67513e5; % rad/Tesla/ms
    gammab = 42.576; %MHz/T
    B0 = B0f/gammab; %7.0335 T
    
    % Gradient for readout in mT/m
    Gx= [360 180]; %[mouse, rat] %PP, approximate, multiplied by 10 (read dephase is 320 mT/m for rat, 470 for mice)
    Gxr = [470 320]; %[mouse, rat]: read out dephase
    Gxum=Gx(sp)*1e-6*1e-3; % Now in T/um
    
    %Diffusion
    D=2.30; %(um2/ms, \pm 1.5%) Krinicki 1978 from Spyrou 2009 thesis
    %vox_size=2.4;    % Voxel size in um -- very small -- why?
    
    %%%%%%%%%%%%%%%%%%%%
    % Monte Carlo
    np=1e1; %Number of protons
    nts=100; %Number of time steps
    dt=0.2; %In milliseconds 0.2ms
    
    phase_GE=zeros(np,1);
    phase_SE=zeros(np,1);
    
    signal_GE=zeros(1,nts);
    signal_SE=zeros(1,nts);
    
    [s1,s2,s3,s4,s5,s6] = RandStream.create('mrg32k3a','NumStreams',6);
    seed = 1;
    r1 = rand(s1,np,seed);
    r2 = rand(s2,np,seed);
    r3 = rand(s3,np,seed);
    
    % Generate random numbers, launch nprotons at a time
    ppos=floor([nx*r1 ny*r2 nz*r3])+0.5; %proton positions
    
    %Spin Echo params
    TE=20; %20 ms
    half_echo_index=floor(TE/(2*dt));
    echo_index=floor(TE/dt);
    
    %Gradient Echo params -- not clear what this is
    start_ge=10;
    flip_ge=20;
    stop_ge=40;
    start_ge_index=floor(start_ge/dt);
    flip_ge_index=floor(flip_ge/dt);
    stop_ge_index=floor(stop_ge/dt);
    
    GE_SE=1; %1: GE and SE (no gradient)
    %2: GE with gradient in readout
    %3: GE and SE with constant gradient
    
    gw=0; %gradient weight
    %Loop over time steps
    for nts0=1:nts
        if(mod(nts0,(nts/10))==0)
            display(sprintf('%d %%completed',round(100*nts0/nts)))
        end
        switch GE_SE
            case {1,3} %Gradient-Echo and Spin-Echo
                
                % Spin echo, 180 degrees phase shift
                if nts0==half_echo_index
                    phase_SE=conj(phase_SE);
                end
                if GE_SE == 3
                    gw = 1;
                end
            case 2
                %Gradient in readout
                if(start_ge_index==nts0)
                    gw=1;
                elseif (flip_ge_index==nts0)
                    gw=-1;
                elseif (stop_ge_index==nts0)
                    gw=0;
                end
        end
        
        r4 = randn(s4,np,seed);
        r5 = randn(s5,np,seed);
        r6 = randn(s6,np,seed);
        
        %move protons
        sigma=sqrt(2*D*dt); %Isotropic diffusion -- Brownian motion -- average distance travelled in dt
        rnum=sigma*[r4 r5 r6];
        ppos=ppos+rnum; %updated proton positions
        
        ix=max(min(ceil(ppos(:,1)/Lx),nx),1);
        iy=max(min(ceil(ppos(:,2)/Ly),ny),1);
        iz=max(min(ceil(ppos(:,3)/Lz),nz),1);
        pB=Y(sub2ind(size(Y),ix,iy,iz));
        pT2=T2vol(sub2ind(size(Y),ix,iy,iz));
        pg=gw*(ix*Lx-nx/2)*Gxum; %gradient experienced by protons
        %signal GE
        phase_GE=phase_GE+1j*gamma*(pB+pg)*dt-(1./pT2)*dt;
        signal_GE(nts0)=abs(sum(exp(phase_GE))/np);
        switch GE_SE
            case {1,3} %Gradient-Echo and Spin-Echo
                %signal SE
                phase_SE=phase_SE+1j*gamma*(pB+pg)*dt-(1./pT2)*dt;
                signal_SE(nts0)=abs(sum(exp(phase_SE))/np);
                
        end
    end
    
    
    % figure;
    % t=(1:ntime_step)*dt;
    % plot(t,signal_GE,'b',t,signal_SE,'r')
    % legend('GE','SE')
    
    R.BOLD_GE=signal_GE(echo_index);
    R.BOLD_SE=signal_SE(echo_index);
    R.T2_GE=signal_GE;
    R.T2_SE=signal_SE;
    %R.t = t;
    
    save(fullfile(ROOT_folder,'BOLD_simus','BOLD_TC.mat'),'R'); 
catch exception
    disp(exception.identifier)
    disp(exception.stack(1))
end