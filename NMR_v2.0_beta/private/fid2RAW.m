function fid2RAW(dataidx,arrayidx,called)
% function fid2RAW(outputfile,data,params)
mainhandles=guidata(findobj('Tag','mainmenu'));

% mainhandles.lcmodel.fid2raw.zerofill
params = mainhandles.datalist(dataidx).params;
current_path = mainhandles.homedir;
switch lower(called)   
    case{'lcmodelfig'}
        handles = guidata(findobj('Tag','lcmodelfig'));
        dat_idx = find(mainhandles.lcmodel.dataidx == dataidx);
        arr_idx = find(mainhandles.lcmodel.arrayidx{dat_idx} == arrayidx);
        if dat_idx>1
        lcmodelidx = mainhandles.lcmodel.lcmidx(dat_idx-1)+arr_idx;
        else
            lcmodelidx = arr_idx;
        end
        
%         lcmodelidx = find(((mainhandles.lcmodel.dataidx == dataidx)&(mainhandles.lcmodel.arrayidx == arrayidx))==1);
        cur_controlfile = mainhandles.lcmodel.cur_controlfile{lcmodelidx};
        separetor = strfind(cur_controlfile,filesep);
        output_path = [cur_controlfile(1:separetor(length(separetor))) filesep];
        filename = cur_controlfile((separetor(length(separetor))+1):length(cur_controlfile));
        filename=[regexprep(filename,'.CONTROL','') '.RAW'];
        gain_corr = 1;
    case{'lcmodelfig_reffile'}
        handles = guidata(findobj('Tag','lcmodelfig'));
        dat_idx = find(mainhandles.lcmodel.dataidx == dataidx);
        arr_idx = find(mainhandles.lcmodel.arrayidx{dat_idx} == arrayidx);
        if dat_idx>1
        lcmodelidx = mainhandles.lcmodel.lcmidx(dat_idx-1)+arr_idx;
        else
            lcmodelidx = arr_idx;
        end
%         lcmodelidx
%         return
%         lcmodelidx = find(((mainhandles.lcmodel.dataidx == dataidx)&(mainhandles.lcmodel.arrayidx == arrayidx))==1);
        cur_controlfile = mainhandles.lcmodel.cur_controlfile{lcmodelidx};
        separetor = strfind(cur_controlfile,filesep);
        output_path = [cur_controlfile(1:separetor(length(separetor))) filesep];
        filename = cur_controlfile((separetor(length(separetor))+1):length(cur_controlfile));
        filename=[regexprep(filename,'.CONTROL','') '.h2o'];
        gain_RAW = params.gain;
        clear params dataidx arrayidx
        dataidx=mainhandles.lcmodel.dataidx_ref(lcmodelidx);
        arrayidx=1; %%DOUBLE-CHECK
        params = mainhandles.datalist(dataidx).params;
        gain_corr = exp((gain_RAW-params.gain)*log(10)/20); %normailze data to a gain of 60
    case{'processfig'}
        dat_idx = dataidx;
        arr_idx = arrayidx;
        output_path = [mainhandles.datalist(dataidx).path filesep];
        separetor = strfind(output_path,filesep);
        filename = output_path((separetor(length(separetor)-1)+1):(length(output_path)-1));
        filename=[regexprep(filename,'.fid',['_' num2str(arrayidx)]) '.RAW'];
        gain_corr = exp((60-params.gain)*log(10)/20); %normailze data to a gain of 60
end
% mainhandles.lcmodel.fid2raw.zerofill
% disp(lcmodelidx)
% params.lsfid = 0 %% TO BE DOUBLE-CHECKED ???

%% Post-processing
i=1; %% to be modify to accept multiple file for i = dataidx / arrayidx

%store postprocess param
% try
%     apodizefct{i,:} = mainhandles.datalist(dataidx(i)).process.apodizefct;
%     apodparam1(i) = mainhandles.datalist(dataidx(i)).process.apodparam1;
%     apodparam2(i) = mainhandles.datalist(dataidx(i)).process.apodparam2;
% end
try
    phasecorr0(i) = mainhandles.datalist(dataidx(i)).process.phasecorr0(i);
    phasecorr1(i) = mainhandles.datalist(dataidx(i)).process.phasecorr1(i);
catch
     phasecorr0(i) =0;
      phasecorr1(i) =0;
end
hzpppm=mainhandles.datalist(dataidx(i)).params.sfrq*10^6;
sw_hz= mainhandles.datalist(dataidx(i)).params.sw;
display([' DEGZER=' num2str(-(rad2deg(phasecorr0(i))+0.5*rad2deg(phasecorr1(i)))) '\n']);
display([' DEGPPM=' num2str(-(rad2deg(phasecorr1(i)))/(sw_hz/hzpppm)) '\n']);



% mainhandles.datalist(dataidx(i)).process.lsfid=mainhandles.datalist(dataidx(i)).process.lsfid-1;
% guidata(findobj('Tag','mainmenu'),mainhandles);
% try
%     lsfid(i) = mainhandles.datalist(dataidx(i)).process.lsfid;
% end
% mainhandles.lcmodel.fid2raw.zerofill
% % %% TO BE DOUBLE-CHECKED ???
% % %replace with param for summation: no apod, no phase, no lsfid
% % mainhandles.datalist(dataidx(i)).process.apodizefct = 'exponential';
% % mainhandles.datalist(dataidx(i)).process.apodparam1 = 0;
% % mainhandles.datalist(dataidx(i)).process.apodparam2 = 0;
% % mainhandles.datalist(dataidx(i)).process.phasecorr0(i) = 0; %% WARNING if phase is applied need to call the phasing function (c.f. B0_calc)
% % mainhandles.datalist(dataidx(i)).process.phasecorr1(i) = 0;
% % %             mainhandles.datalist(dataidx(i)).process(i).lsfid = 0;
% % guidata(findobj('Tag','mainmenu'),mainhandles);


data(i).real =  squeeze(mainhandles.datalist(dataidx(i)).data.real(arrayidx,:,:));
data(i).imag =  squeeze(mainhandles.datalist(dataidx(i)).data.imag(arrayidx,:,:));

if mainhandles.switch.phasecorrection==1
    lsfid=mainhandles.datalist(dataidx(i)).process.lsfid;
    fid_length=length(data(i).real); %=mainhandles.datalist(dataidx).np/2;
    t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx(i)).spectralwidth;
%     t=t_vec;
    % calculation of x-axis for frequency-space
    cut = round(fid_length/2);
    df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
    f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

    data(i) = phasing(squeeze(data(i)), f_vec_shifted, phasecorr0(i), phasecorr1(i));
%      mainhandles.datalist(data_idx(i)).process.phasecorr0=0;
%       mainhandles.datalist(data_idx(i)).process.phasecorr1=0;
end


data(i) = postprocessing(squeeze(data(i)),dataidx(i),arrayidx(i));

% shift receiver offset (in time domain)
if strcmp(mainhandles.datalist(dataidx(i)).nucleus,'C13')
    
    lsfrq = -mainhandles.datalist(dataidx).params.tof-11250;%mainhandles.datalist(dataidx).params.rfp
    fid = data(i).real + 1i.*data(i).imag;
    fid_length = length(fid);
    lsfid = mainhandles.datalist(dataidx).params.lsfid;
    t = (((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx).spectralwidth)';

%     t=(0:mainhandles.datalist(dataidx(i)).params.sw:(length(fid)-1)/mainhandles.datalist(dataidx(i)).params.sw)'; 
    fid=fid.*exp(1i.*2*pi.*lsfrq.*t);
    data(i).real=real(fid);
    data(i).imag=imag(fid);
    clear fid
end

% RAW.real(1,:,:)= data(i).real(1,:,:);
% RAW.imag(1,:,:)= data(i).imag(1,:,:);

% % %   KAI
% % % % %       %% --- data preparation --------------------------------------------------
% % % % %% remove dc offset (linear fit of fid)
% % % % x=(1:length(data.real))';
% % % % p=polyfit(x,data.real,1);
% % % % linearfit=polyval(p,x);
% % % % data.real=data.real-linearfit;
% % % % data.imag=data.imag-linearfit;
% % % %
% % % % %% shift receiver offset (in time domain)
% % % % % PGH: lsfrq=4457; hzpppm=100.65; receiveroffset_ppm=4.65
% % % % lsfrq=(49.3-4.65)*100.65; % 4457; % params.lsfrq;
% % % % complexfid=data.real-1i*data.imag;
% % % % t=((0:1:(length(complexfid)-1))./params.sw)';
% % % % complexfid=complexfid.*exp(1i*2*pi*lsfrq*t);
% % % % data.real=real(complexfid);
% % % % data.imag=-imag(complexfid);

% mainhandles.lcmodel.fid2raw.zerofill

cd(output_path)

% Check if several files choosen and ask for batch processing
if mainhandles.switch.normalization==1;
if size(params.nt,1)>1 %arrayed data
    norm_factor = params.nt(arr_idx);
elseif size(params.nt,2) == 1
    norm_factor = params.nt;
end
else
norm_factor=1;
end
disp('Normalisation factor FID2RAW:')
disp(norm_factor)
tmp.real=squeeze(data(i).real)./norm_factor;
tmp.imag=squeeze(data(i).imag)./norm_factor;

%% lsfid
% sdata=length(tmp.real);
% tmp.real = tmp.real((lsfid+1):sdata);
% tmp.imag = tmp.imag((lsfid+1):sdata);
% 
%     tmp.real=[tmp.real(lsfid:length(tmp.real)) zeros(1,lsfid-1)'];
%     tmp.imag=[tmp.imag(lsfid:length(tmp.imag)) zeros(1,lsfid-1)'];
% 
% 
% sdata=sdata-lsfid;
%% reofill to the next power of 2
sdata=length(tmp.real);
NFFT=2^nextpow2((sdata));
% mainhandles.lcmodel
% mainhandles.lcmodel.fid2raw.zerofill
if NFFT~=sdata
%     ~isfield(mainhandles.lcmodel,'fid2raw')
    if isempty(handles.yesall.fid2raw.zerofill)
        answr = questdlg4(['Do you want to zerofill your data to ' num2str(NFFT) ':'],...
            'Zerofilling','Yes','Yes to all','No','No to all','Yes to all');
    else

            answr = handles.yesall.fid2raw.zerofill;
    end
    if strcmp(answr,'Yes to all')==1 || strcmp(answr,'No to all')==1
        handles.yesall.fid2raw.zerofill = answr;
    else
        handles.yesall.fid2raw.zerofill = '';
    end
    if strcmp(answr,'Yes')==1 || strcmp(answr,'Yes to all')==1
        RAW.real = zeros([NFFT 1]);
        RAW.imag = zeros([NFFT 1]);
        RAW.real(1:sdata)=tmp.real;
        RAW.imag(1:sdata)=tmp.imag;
    else
        RAW.real=tmp.real;
        RAW.imag=tmp.imag;
    end
else
        RAW.real=tmp.real;
        RAW.imag=tmp.imag;
    
end
guidata(findobj('Tag','mainmenu'),mainhandles);
if ~isempty(findobj('Tag','lcmodelfig'))
guidata(findobj('Tag','lcmodelfig'),handles);
end
%----------------------------------------

volume = params.vox1*params.vox2*params.vox3;  %% TO BE DOUBLE-CHECKED ???
% ID=char(params.name{1,1}); %% TO BE DOUBLE-CHECKED ???
ID='';
rawfile=filename;

%header raw file
fid = fopen(rawfile, 'w','b');
fprintf(fid,' \n $NMID\n');
fprintf(fid,' ID=\''%s\''\n',ID);
fprintf(fid,' FMTDAT=\''(2E13.5)\''\n');
datastring=strrep(sprintf(' TRAMP= % 13.5E\n', gain_corr), 'E+0', 'E+');
datastring=strrep(datastring, 'E-0', 'E-');
fprintf(fid,datastring);
datastring=strrep(sprintf(' VOLUME= % 13.5E\n', volume), 'E+0', 'E+');
datastring=strrep(datastring, 'E-0', 'E-');
fprintf(fid,datastring);

% fprintf(fid,' TRAMP=%14.5E\n',gain_corr);
% fprintf(fid,' VOLUME=%14.5E\n',volume);
fprintf(fid,' $END\n');
%data
for i = 1:1:length(RAW.real)
    datastring = sprintf(' % 13.5E % 13.5E\n',RAW.real(i), RAW.imag(i));
    datastring = strrep(datastring, 'E+0', 'E+');
    datastring = strrep(datastring, 'E-0', 'E-');
    fprintf(fid,datastring); % see help fprintf
    
end
fclose(fid);
cd(current_path);

display(['Raw file written: ' rawfile])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Original file from I. Tcak %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% /***************************************************************************/
% /****      PROGRAM NAME:  lcm_fid2RAW                                   ****/
% /****      Function: convert binary VNMR file to ASCII file for LCMOdel ****/
% /****      Takes into account ct counter in the FID header              ****/
% /****      Last update: Feb 10, 2003                                    ****/
% /***************************************************************************/
%
% /**[1] INCLUDE FILES **************************************/
% #include <math.h>
% #include <stdio.h>
%
%
% /**[2] GENEREL DECLERATIONS *******************************/
%
% struct {
% /* Used at start of each data file (FIDs, spectra, 2D) */
% 	long  nblocks;     /* number of blocks in file */
% 	long  ntraces;     /* number of traces per block */
% 	long  np;          /* number of elements per trace */
% 	long  ebytes;      /* number of bytes per element */
% 	long  tbytes;      /* number of bytes per trace */
% 	long  bbytes;      /* number of bytes per block */
% 	short vers_id;     /* software version, file_id status bits */
% 	short status;      /* status of whole file */
% 	long  nbheaders;   /* number of block headers per block */
%        } datafilehead;
%
% struct {
% /* Each file block contains the following header */
% 	short scale;       /* scaling factor */
% 	short status;      /* status of data in block */
% 	short index;       /* block index */
% 	short mode;        /* mode of data in block */
% 	long  ctcount;     /* ct value for FID */
% 	float lpval;       /* f2 (2D-f1) left phase in phasefile */
% 	float rpval;       /* f2 (2D-f1) right phase in phasefile */
% 	float lvl;         /* left drift correction */
% 	float tlt;         /* tilt drift correction */
%        } datablockhead;
%
%
% /*** PROGRAM BEGIN *************************************/
% main(argc,argv)
%
%      int   argc;
%      char *argv[];
% {
% /*** VARIABLE DECLARATION ******************************/
%      FILE *in_file,*out_file;
%      float data_float,volume,ampl;
%      double real,imag;
%      int j,l,stat_file,no_bytes,lsfid,ct1,np,nunfil,no_column,ct_fidheader,ct_counter;
%      long data_long;
%      char id_raw[50];
%
% /*** CONTROL OF INPUT PARAMETERS ***********************/
%      if (argc < 2)
%          {
%          printf("\nName of input file did not passed!\n");
%          exit (3);
%          }
%
%      if (argc < 3)
%          {
%          printf("\nName of output file did not passed!\n");
%          exit (3);
%          }
%
%      if (argc < 4)
%          {
%          printf("\nLeft shift od the FID lsfid_lcm was not read!\n");
%          exit (3);
%          }
%
%      if (argc < 5)
%          {
%          printf("\nCounter of transients ct1 was not read!\n");
%          exit (3);
%          }
%
%      if (argc < 6)
%         {
%         printf("\nVolume was not read\n");
%         exit (3);
%         }
%
%      if (argc < 7)
%         {
%         printf("\nScaling factor ampl was not read\n");
%         exit (3);
%         }
%
%      if (argc < 8)
%         {
%         printf("\nID of the RAW file was not read\n");
%         exit (3);
%         }
%
%      if (argc < 9)
%         {
%         printf("\nNumber of columns was not read\n");
%         exit (3);
%         }
%
%      if (argc < 10)
%         {
%         printf("\nNumber of points in ASCII file was not read\n");
%         exit (3);
%         }
%
% /*** OPENING THE FILES AND READING THE HEADER ****************/
%
%      if ((in_file=fopen(argv[1],"rb"))==NULL)
%         {
%         printf("\nCan not open input file (FID)\n");
%         exit (3);
%         }
%
%      rewind(in_file);
%      fprintf (stderr, "\nINPUT FILE: \n%s\n",argv[1]);
%
%      if (fread(&datafilehead,sizeof(datafilehead),1,in_file) != 1)
%          {
%          fprintf (stderr, "Error in reading FID (datafilehead)\n");
%          exit (3);
%          }
%
%      if ((out_file=fopen(argv[2],"wb"))==NULL)
%         {
%         printf("\nCan not open output file (lcm.RAW)");
%         exit (3);
%         }
%
%      rewind(out_file);
%      fprintf (stderr, "OUTPUT FILE: \n%s\n",argv[2]);
%
%      if (fread(&datablockhead,sizeof(datablockhead),1,in_file) != 1)
%          {
%          fprintf (stderr, "Error in reading input data (datablockhead)\n");
%          exit (3);
%          }
%
%      stat_file = datablockhead.status;
%      no_bytes = datafilehead.ebytes;
%      ct_fidheader = datablockhead.ctcount;
%
%      if ((stat_file != 69) && (stat_file != 25) && (stat_file != 2073) && (stat_file != 281) && (stat_file != 73))
%         {
%         fprintf (stderr, "\nStatus = %8d",datablockhead.status);
%         fprintf (stderr, "\nERROR: Not standard format of data!\n");
%         exit (3);
%         }
%
%
% /*** FORMATING THE INPUT PARAMETERS *********************/
%
%      lsfid = atof(argv[3]);
%      ct1 = atof(argv[4]);
%      volume = atof(argv[5]);
%      ampl = atof(argv[6]);
%      strcpy(id_raw,argv[7]);
%      no_column = atoi(argv[8]);
%      nunfil = atoi(argv[9]);
%
%
% /*** WRITING THE FILE HEADER ****************************/
%
%      fprintf(out_file,"\n $NMID\n");
%      fprintf(out_file," ID='%s'\n",id_raw);
%      fprintf(out_file," FMTDAT='(8E13.5)'\n");
%      fprintf(out_file," TRAMP= %12.5E\n",ampl);
%      fprintf(out_file," VOLUME= %12.5E\n",volume);
%      fprintf(out_file," $END\n");
%
%
% /*** GENERATING THE ASCII FILE ******************/
%
%      np = datafilehead.np;
%
%      fprintf(stderr,"Status of the file: %i\n",stat_file);
%
%      if (ct_fidheader > 0)
%         {
%         ct_counter = ct_fidheader;
%         }
%      else
%         {
%         ct_counter = ct1;
%         }
%
%      if ((ct1 == 0) && (ct_fidheader == 0))
%         {
%         fprintf(stderr,"\nCT(FID header) = 0 and ct1(procpar) = 0, program aborted!");
%         exit (3);
%         }
%      else
%         {
%         fprintf(stderr,"Scaling factor CT = %i",ct_counter);
%         }
%
%      l = 1;
%      fseek(in_file,sizeof(datafilehead)+sizeof(datablockhead)+2*lsfid*no_bytes,0);
%      for (j=0;j<nunfil;++j)
%          {
%          if (j < np/2 - lsfid)
%             {
%             if ((stat_file == 25) || (stat_file == 2073) || (stat_file == 281) || (stat_file == 73))
%                {
%                if (fread(&data_float,datafilehead.ebytes,1,in_file) != 1)
%                   {
%                   fprintf (stderr, "Error in reading FID real data (float)\n");
%                   exit (3);
%                   }
%                real=(double)data_float/(double)ct_counter;
%
%                if (fread(&data_float,datafilehead.ebytes,1,in_file) != 1)
%                   {
%                   fprintf (stderr, "Error in reading FID imag data (float)\n");
%                   exit (3);
%                   }
%                imag=(double)data_float/(double)ct_counter;
%                }
%
%             if (stat_file == 69)
%                {
%                if (fread(&data_long,datafilehead.ebytes,1,in_file) != 1)
%                   {
%                   fprintf (stderr, "Error in reading FID real data (integer)\n");
%                   exit (3);
%                   }
%                real=(double)data_long/(double)ct_counter;
%
%                if (fread(&data_long,datafilehead.ebytes,1,in_file) != 1)
%                   {
%                   fprintf (stderr, "Error in reading FID imag data (integer)\n");
%                   exit (3);
%                   }
%                imag=(double)data_long/(double)ct_counter;
%                }
%             }
%          else
%             {
%             real = 0.0;
%             imag = 0.0;
%             }
%
%          fprintf(out_file," %12.5E %12.5E",real, imag);
%          if ((l++ % no_column) == 0 )  fprintf(out_file,"\n");
%          }
%      fclose(in_file);
%      fclose(out_file);
%      fprintf (stderr, "\nlcm.RAW input file was created!\n\n");
% }

