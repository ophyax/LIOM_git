% createlcmodelbasis.m
%
% prepare .IN file for MakeBasis
%
% pgh Oct 2001

function y=createlcmodelbasis(files,acqparam)

disp('***** CREATING BASIS FILE FOR LCMODEL *****'); disp(' ');

tau=0.0055; % delay for 13C-13C J-evolution

% define metabolites to include in analysis

clear metabolite;
metabolite=struct('name',0,'cs',0,'ampl',0,'phase',0);

metabolite(1).name='lacC3';
metabolite(1).cs=21;
metabolite(1).ampl=1;
metabolite(1).phase=0;

metabolite(2).name='gluC4';
metabolite(2).cs=34.37;
metabolite(2).ampl=1;
metabolite(2).phase=0;

metabolite(3).name='gluC43';
metabolite(3).cs=[34.36-34.6/2/acqparam.hzpppm 34.36+34.6/2/acqparam.hzpppm'];
metabolite(3).ampl=[0.5 0.5];
metabolite(3).phase=[pi*34.6*tau -pi*34.6*tau];

metabolite(4).name='gluC3';
metabolite(4).cs=27.86;
metabolite(4).ampl=1;
metabolite(4).phase=0;

metabolite(5).name='gluC34';
metabolite(5).cs=[27.85-34.6/2/acqparam.hzpppm 27.85+34.6/2/acqparam.hzpppm'];
metabolite(5).ampl=[0.5 0.5];
metabolite(5).phase=[pi*34.6*tau -pi*34.6*tau];

metabolite(6).name='gluC2';
metabolite(6).cs=55.71;
metabolite(6).ampl=1;
metabolite(6).phase=0;

metabolite(7).name='gluC23';
metabolite(7).cs=[55.70-34.6/2/acqparam.hzpppm 55.70+34.6/2/acqparam.hzpppm'];
metabolite(7).ampl=[0.5 0.5];
metabolite(7).phase=[pi*34.6*tau -pi*34.6*tau];

metabolite(8).name='glnC4';
metabolite(8).cs=31.79;
metabolite(8).ampl=1;
metabolite(8).phase=0;

metabolite(9).name='glnC43';
metabolite(9).cs=[31.78-34.9/2/acqparam.hzpppm 31.78+34.9/2/acqparam.hzpppm'];
metabolite(9).ampl=[0.5 0.5];
metabolite(9).phase=[pi*34.9*tau -pi*34.9*tau];

metabolite(10).name='glnC3';
metabolite(10).cs=27.2;
metabolite(10).ampl=1;
metabolite(10).phase=0;

metabolite(11).name='glnC34';
metabolite(11).cs=[27.19-34.9/2/acqparam.hzpppm 27.19+34.9/2/acqparam.hzpppm'];
metabolite(11).ampl=[0.5 0.5];
metabolite(11).phase=[pi*34.9*tau -pi*34.9*tau];

metabolite(12).name='glnC2';
metabolite(12).cs=55.2;
metabolite(12).ampl=1;
metabolite(12).phase=0;

metabolite(13).name='glnC23';
metabolite(13).cs=[55.2-34.9/2/acqparam.hzpppm 55.2+34.9/2/acqparam.hzpppm'];
metabolite(13).ampl=[0.5 0.5];
metabolite(13).phase=[pi*34.9*tau -pi*34.9*tau];

metabolite(14).name='aspC2';
metabolite(14).cs=53.24;
metabolite(14).ampl=1;
metabolite(14).phase=0;

metabolite(15).name='aspC23';
metabolite(15).cs=[53.24-36.5/2/acqparam.hzpppm 53.24+36.5/2/acqparam.hzpppm'];
metabolite(15).ampl=[0.5 0.5];
metabolite(15).phase=[pi*36.5*tau -pi*36.5*tau];

metabolite(16).name='aspC3';
metabolite(16).cs=37.48;
metabolite(16).ampl=1;
metabolite(16).phase=0;

metabolite(17).name='aspC32';
metabolite(17).cs=[37.46-36.5/2/acqparam.hzpppm 37.46+36.5/2/acqparam.hzpppm'];
metabolite(17).ampl=[0.5 0.5];
metabolite(17).phase=[pi*36.5*tau -pi*36.5*tau];

metabolite(18).name='alaC3';
metabolite(18).cs=17.13;
metabolite(18).ampl=1;
metabolite(18).phase=0;

metabolite(19).name='naaC6';
metabolite(19).cs=22.92;
metabolite(19).ampl=1;
metabolite(19).phase=0;

metabolite(20).name='naaC3';
metabolite(20).cs=40.57;
metabolite(20).ampl=1;
metabolite(20).phase=0;

metabolite(21).name='naaC2';
metabolite(21).cs=54.11;
metabolite(21).ampl=1;
metabolite(21).phase=0;

metabolite(22).name='gabaC4';
metabolite(22).cs=40.44;
metabolite(22).ampl=1;
metabolite(22).phase=0;

metabolite(23).name='gabaC2';
metabolite(23).cs=35.24;
metabolite(23).ampl=1;
metabolite(23).phase=0;

metabolite(24).name='glcC1a';
metabolite(24).cs=[93-3.3/2/acqparam.hzpppm 93+3.3/2/acqparam.hzpppm];
metabolite(24).ampl=[0.5 0.5];
metabolite(24).phase=[0 0];

metabolite(25).name='glcC1b';
metabolite(25).cs=[96.81-4.1/2/acqparam.hzpppm 96.81+4.1/2/acqparam.hzpppm];
metabolite(25).ampl=[0.5 0.5];
metabolite(25).phase=[0 0];

metabolite(26).name='glcC6a';
metabolite(26).cs=[61.57-3.3/2/acqparam.hzpppm 61.57+3.3/2/acqparam.hzpppm];
metabolite(26).ampl=[0.5 0.5];
metabolite(26).phase=[0 0];

metabolite(27).name='glcC6b';
metabolite(27).cs=[61.71-4.1/2/acqparam.hzpppm 61.71+4.1/2/acqparam.hzpppm];
metabolite(27).ampl=[0.5 0.5];
metabolite(27).phase=[0 0];

metabolite(28).name='glu324';
metabolite(28).cs=[27.84-34.6/acqparam.hzpppm 27.84 27.84+34.6/acqparam.hzpppm'];
metabolite(28).ampl=[0.25 0.5 0.25];
metabolite(28).phase=[2*pi*34.6*tau 0 -2*pi*34.6*tau];

metabolite(29).name='ser';
metabolite(29).cs=61.25;
metabolite(29).ampl=1;
metabolite(29).phase=0;

metabolite(30).name='myoIns';
metabolite(30).cs=[72.08 73.13 73.38 75.29];
metabolite(30).ampl=[2/6 1/6 2/6 1/6];
metabolite(30).phase=[0 0 0 0];

metabolite(31).name='gln324';
metabolite(31).cs=[27.18-34.9/acqparam.hzpppm 27.18 27.18+34.9/acqparam.hzpppm'];
metabolite(31).ampl=[0.25 0.5 0.25];
metabolite(31).phase=[2*pi*34.9*tau 0 -2*pi*34.9*tau];

metabolite(32).name='glu213';
metabolite(32).cs=[55.69-53.4/2/acqparam.hzpppm-34.6/2/acqparam.hzpppm 55.69+53.4/2/acqparam.hzpppm-34.6/2/acqparam.hzpppm 55.69-53.4/2/acqparam.hzpppm+34.6/2/acqparam.hzpppm 55.69+53.4/2/acqparam.hzpppm+34.6/2/acqparam.hzpppm];
metabolite(32).ampl=[0.25 0.25 0.25 0.25];
%metabolite(32).phase=[-pi*(-53.4-34.6)*tau -pi*(53.4-34.6)*tau -pi*(-53.4+34.6)*tau -pi*(53.4+34.6)*tau];
metabolite(32).phase=[-pi*(-0-34.6)*tau -pi*(0-34.6)*tau -pi*(-0+34.6)*tau -pi*(0+34.6)*tau]; % C1 is not excited

metabolite(33).name='gln213';
metabolite(33).cs=[55.19-53.4/2/acqparam.hzpppm-34.9/2/acqparam.hzpppm 55.19+53.4/2/acqparam.hzpppm-34.9/2/acqparam.hzpppm 55.19-53.4/2/acqparam.hzpppm+34.9/2/acqparam.hzpppm 55.19+53.4/2/acqparam.hzpppm+34.9/2/acqparam.hzpppm];
metabolite(33).ampl=[0.25 0.25 0.25 0.25];
%metabolite(33).phase=[-pi*(-53.4-34.9)*tau -pi*(53.4-34.9)*tau -pi*(-53.4+34.9)*tau -pi*(53.4+34.9)*tau];
metabolite(33).phase=[-pi*(-0-34.9)*tau -pi*(0-34.9)*tau -pi*(-0+34.9)*tau -pi*(0+34.9)*tau];

metabolite(34).name='gluC21';
metabolite(34).cs=[55.70-53.4/2/acqparam.hzpppm 55.70+53.4/2/acqparam.hzpppm'];
metabolite(34).ampl=[0.5 0.5];
%metabolite(34).phase=[pi*53.4*tau -pi*53.4*tau];
metabolite(34).phase=[pi*0*tau -pi*0*tau];

metabolite(35).name='glnC21';
metabolite(35).cs=[55.19-53.4/2/acqparam.hzpppm 55.19+53.4/2/acqparam.hzpppm'];
metabolite(35).ampl=[0.5 0.5];
% metabolite(35).phase=[pi*53.4*tau -pi*53.4*tau];
metabolite(35).phase=[pi*0*tau -pi*0*tau];

metabolite(36).name='naaC32';
metabolite(36).cs=[40.56-36.3/2/acqparam.hzpppm 40.56+36.3/2/acqparam.hzpppm];
metabolite(36).ampl=[0.5 0.5];
metabolite(36).phase=[pi*36.3*tau -pi*36.3*tau];

metabolite(37).name='naaC23';
metabolite(37).cs=[54.11-36.3/2/acqparam.hzpppm 54.11+36.3/2/acqparam.hzpppm];
metabolite(37).ampl=[0.5 0.5];
metabolite(37).phase=[pi*36.3*tau -pi*36.3*tau];

metabolite(38).name='gabC43';
metabolite(38).cs=[40.43-35/2/acqparam.hzpppm 40.43+35/2/acqparam.hzpppm];
metabolite(38).ampl=[0.5 0.5];
metabolite(38).phase=[pi*35*tau -pi*35*tau];

metabolite(39).name='gabC23';
metabolite(39).cs=[35.23-35/2/acqparam.hzpppm 35.23+35/2/acqparam.hzpppm];
metabolite(39).ampl=[0.5 0.5];
metabolite(39).phase=[pi*35*tau -pi*35*tau];

metabolite(40).name='gabaC3';
metabolite(40).cs=24.53;
metabolite(40).ampl=1;
metabolite(40).phase=0;

metabolite(41).name='gabC34';
metabolite(41).cs=[24.52-35/2/acqparam.hzpppm 24.52+35/2/acqparam.hzpppm];
metabolite(41).ampl=[0.5 0.5];
metabolite(41).phase=[pi*35*tau -pi*35*tau];

metabolite(42).name='gab324';
metabolite(42).cs=[24.51-35/acqparam.hzpppm 24.51 24.51+35/acqparam.hzpppm];
metabolite(42).ampl=[0.25 0.5 0.25];
metabolite(42).phase=[2*pi*35*tau 0 -2*pi*35*tau];

metabolite(43).name='FrucC6';
metabolite(43).cs=63.8;
metabolite(43).ampl=1;
metabolite(43).phase=0;

metabolite(44).name='Gl3PC3';
metabolite(44).cs=64.9;
metabolite(44).ampl=1;
metabolite(44).phase=0;

metabolite(45).name='gluC45';
metabolite(45).cs=[34.37-51.3/2/acqparam.hzpppm 34.37+51.3/2/acqparam.hzpppm'];
metabolite(45).ampl=[0.5 0.5];
% metabolite(45).phase=[pi*51.3*tau -pi*51.3*tau];
metabolite(45).phase=[pi*0*tau -pi*0*tau];

metabolite(46).name='glu435';
metabolite(46).cs=[34.37-51.3/2/acqparam.hzpppm-34.6/2/acqparam.hzpppm 34.37+51.3/2/acqparam.hzpppm-34.6/2/acqparam.hzpppm 34.37-51.3/2/acqparam.hzpppm+34.6/2/acqparam.hzpppm 34.37+51.3/2/acqparam.hzpppm+34.6/2/acqparam.hzpppm];
metabolite(46).ampl=[0.25 0.25 0.25 0.25];
% metabolite(46).phase=[-pi*(-51.3-34.6)*tau -pi*(51.3-34.6)*tau -pi*(-51.3+34.6)*tau -pi*(51.3+34.6)*tau];
metabolite(46).phase=[-pi*(-0-34.6)*tau -pi*(0-34.6)*tau -pi*(-0+34.6)*tau -pi*(0+34.6)*tau];

metabolite(47).name='aspC34';
metabolite(47).cs=[37.47-50.6/2/acqparam.hzpppm 37.47+50.6/2/acqparam.hzpppm'];
metabolite(47).ampl=[0.5 0.5];
% metabolite(47).phase=[pi*50.6*tau -pi*50.6*tau];
metabolite(47).phase=[pi*0*tau -pi*0*tau];

metabolite(48).name='asp324';
metabolite(48).cs=[37.46-50.6/2/acqparam.hzpppm-36.5/2/acqparam.hzpppm 37.46+50.6/2/acqparam.hzpppm-36.5/2/acqparam.hzpppm 37.46-50.6/2/acqparam.hzpppm+36.5/2/acqparam.hzpppm 37.46+50.6/2/acqparam.hzpppm+36.5/2/acqparam.hzpppm];
metabolite(48).ampl=[0.25 0.25 0.25 0.25];
% metabolite(48).phase=[-pi*(-50.6-36.5)*tau -pi*(50.6-36.5)*tau -pi*(-50.6+36.5)*tau -pi*(50.6+36.5)*tau];
metabolite(48).phase=[-pi*(-0-36.5)*tau -pi*(0-36.5)*tau -pi*(-0+36.5)*tau -pi*(0+36.5)*tau];

metabolite(49).name='aspC21';
metabolite(49).cs=[53.24-53.8/2/acqparam.hzpppm 53.24+53.8/2/acqparam.hzpppm'];
metabolite(49).ampl=[0.5 0.5];
metabolite(49).phase=[pi*0*tau -pi*0*tau];
% metabolite(49).phase=[pi*53.8*tau -pi*53.8*tau];

metabolite(50).name='asp213';
metabolite(50).cs=[53.23-53.8/2/acqparam.hzpppm-36.5/2/acqparam.hzpppm 53.23+53.8/2/acqparam.hzpppm-36.5/2/acqparam.hzpppm 53.23-53.8/2/acqparam.hzpppm+36.5/2/acqparam.hzpppm 53.23+53.8/2/acqparam.hzpppm+36.5/2/acqparam.hzpppm];
metabolite(50).ampl=[0.25 0.25 0.25 0.25];
% metabolite(50).phase=[-pi*(-53.8-36.5)*tau -pi*(53.8-36.5)*tau -pi*(-53.8+36.5)*tau -pi*(53.8+36.5)*tau];
metabolite(50).phase=[-pi*(-0-36.5)*tau -pi*(0-36.5)*tau -pi*(-0+36.5)*tau -pi*(0+36.5)*tau];

metabolite(51).name='CrCH2';
metabolite(51).cs=54.75;
metabolite(51).ampl=1;
metabolite(51).phase=0;

metabolite(52).name='CrCH3';
metabolite(52).cs=37.81;
metabolite(52).ampl=1;
metabolite(52).phase=0;

metabolite(53).name='gab435';
metabolite(53).cs=[40.43-53.5/2/acqparam.hzpppm-35/2/acqparam.hzpppm 40.43+53.5/2/acqparam.hzpppm-35/2/acqparam.hzpppm 40.43-53.5/2/acqparam.hzpppm+35/2/acqparam.hzpppm 40.43+53.5/2/acqparam.hzpppm+35/2/acqparam.hzpppm];
metabolite(53).ampl=[0.25 0.25 0.25 0.25];
% metabolite(53).phase=[-pi*(-53.5-35)*tau -pi*(53.5-35)*tau -pi*(-53.5+35)*tau -pi*(53.5+35)*tau];
metabolite(53).phase=[-pi*(-0-35)*tau -pi*(0-35)*tau -pi*(-0+35)*tau -pi*(0+35)*tau];

metabolite(54).name='gabC45';
metabolite(54).cs=[40.43-53.5/2/acqparam.hzpppm 40.43+53.5/2/acqparam.hzpppm'];
metabolite(54).ampl=[0.5 0.5];
% metabolite(54).phase=[pi*53.5*tau -pi*53.5*tau];
metabolite(54).phase=[pi*0*tau -pi*0*tau];

% disp('**** added metabolites for degraded extract ****')

% metabolite(55).name='sglnC4';
% metabolite(55).cs=30.58;
%metabolite(55).ampl=1;
% metabolite(55).phase=0;

% metabolite(56).name='sglnC43';
% metabolite(56).cs=[30.58-34.9/2/acqparam.hzpppm 30.58+34.9/2/acqparam.hzpppm'];
% metabolite(56).ampl=[0.5 0.5];
% metabolite(56).phase=[pi*34.9*tau -pi*34.9*tau];

% metabolite(57).name='sglnC3';
% metabolite(57).cs=26.23;
% metabolite(57).ampl=1;
% metabolite(57).phase=0;

% metabolite(58).name='sglnC34';
% metabolite(58).cs=[26.23-34.9/2/acqparam.hzpppm 26.23+34.9/2/acqparam.hzpppm'];
% metabolite(58).ampl=[0.5 0.5];
% metabolite(58).phase=[pi*34.9*tau -pi*34.9*tau];

% metabolite(59).name='sglnC2';
% metabolite(59).cs=59.32;
% metabolite(59).ampl=1;
% metabolite(59).phase=0;

% metabolite(60).name='sglnC23';
% metabolite(60).cs=[59.32-34.9/2/acqparam.hzpppm 59.32+34.9/2/acqparam.hzpppm'];
% metabolite(60).ampl=[0.5 0.5];
% metabolite(60).phase=[pi*34.9*tau -pi*34.9*tau];

% create model spectra

noiselevel=0;
lb=4;
nbmetabolites=length(metabolite);
for i=1:nbmetabolites
    createspectrum([metabolite(i).cs 0],[metabolite(i).ampl 0.1],[metabolite(i).phase 0],lb,noiselevel,files.lcmodelbasisdir,metabolite(i).name,acqparam);
end

% create .IN file for MakeBasis

disp(['Writing ' files.lcmodelbasisdir files.lcmodelbasisfilename '.IN file for MakeBasis.'])

fileid=fopen([files.lcmodelbasisdir files.lcmodelbasisfilename '.IN'],'w');

fprintf(fileid,' $NMALL\n');
fprintf(fileid,[' HZPPPM=' num2str(acqparam.hzpppm) '\n']);
fprintf(fileid,[' NUNFIL=' num2str(acqparam.nbpoints) '\n']);
fprintf(fileid,[' DELTAT=' num2str(1/acqparam.sw_hz) '\n']);
fprintf(fileid,[' FILBAS=''' files.lcmodelbasisfilename '.BASIS''\n']);
fprintf(fileid,[' FILPS=''' files.lcmodelbasisfilename '.PS''\n']);
fprintf(fileid,' AUTOSC=.FALSE.\n');
fprintf(fileid,' AUTOPH=.FALSE.\n');
fprintf(fileid,' PPMST=110.\n');
fprintf(fileid,' PPMEND=0.\n');
fprintf(fileid,' $END\n\n');

for i=1:nbmetabolites
    fprintf(fileid,' $NMEACH\n');
    fprintf(fileid,[' FILRAW=''' metabolite(i).name '.RAW''\n']);
    fprintf(fileid,[' METABO=''' metabolite(i).name '''\n']);
    fprintf(fileid,' DEGZER=0.\n');
    fprintf(fileid,' DEGPPM=0.\n');
    fprintf(fileid,' CONC=1.\n');
    fprintf(fileid,' PPMAPP=1.,-1.\n');
    fprintf(fileid,' $END\n\n');
end

fclose(fileid);

disp(' ')
