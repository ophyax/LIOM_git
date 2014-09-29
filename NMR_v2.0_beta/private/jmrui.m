function jmrui(dataidx,arrayidx,called)

mainhandles=guidata(findobj('Tag','mainmenu'));

params = mainhandles.datalist(dataidx).params;
current_path = mainhandles.homedir;

if strcmp(called,'filelistfig')
%     lcmodelidx = find(((mainhandles.lcmodel.dataidx == dataidx)&&(mainhandles.lcmodel.arrayidx == arrayidx))==1);
%     cur_controlfile = mainhandles.lcmodel.cur_controlfile{lcmodelidx};
%     separetor = strfind(cur_controlfile,'\');
%     output_path = cur_controlfile(1:separetor(length(separetor)));
%     filename = cur_controlfile((separetor(length(separetor))+1):length(cur_controlfile));
%     filename=[regexprep(filename,'.CONTROL','') '.txt'];
%     gain_corr = 1;
% elseif strcmp(called,'lcmodelfig_reffile')
%     lcmodelidx = find(((mainhandles.lcmodel.dataidx_ref == dataidx)&&(mainhandles.lcmodel.arrayidx_ref == arrayidx))==1);
%     cur_controlfile = mainhandles.lcmodel.cur_controlfile{lcmodelidx};
%     separetor = strfind(cur_controlfile,'\');
%     output_path = cur_controlfile(1:separetor(length(separetor)));
%     filename = cur_controlfile((separetor(length(separetor))+1):length(cur_controlfile));
%     filename=[regexprep(filename,'.CONTROL','') '.h2o'];
%     gain_RAW = mainhandles.datalist(mainhandles.lcmodel.dataidx(lcmodelidx)).params.gain;
%     gain_corr = exp((gain_RAW-params.gain)*log(10)/20); %normailze data to a gain of 60
elseif strcmp(called,'processfig')
    output_path = [mainhandles.datalist(dataidx).path filesep];
    separetor = strfind(output_path,filesep);
    filename = output_path((separetor(length(separetor)-1)+1):(length(output_path)-1));
    filename=[regexprep(filename,'.fid',['_' num2str(arrayidx)]) '.txt'];
    gain_corr = exp((60-params.gain)*log(10)/20); %normailze data to a gain of 60
end


% params.lsfid = 0 %% TO BE DOUBLE-CHECKED ???

%% Post-processing
i=1; %% to be modify to accept multiple file for i = dataidx / arrayidx

            %store postprocess param
%             try
%             apodizefct{i,:} = mainhandles.datalist(dataidx(i)).process(i).apodizefct;
%             apodparam1(i) = mainhandles.datalist(dataidx(i)).process(i).apodparam1;
%             apodparam2(i) = mainhandles.datalist(dataidx(i)).process(i).apodparam2;
%             end
            try
            phasecorr0(i) = mainhandles.datalist(dataidx(i)).process.phasecorr0(i);
            phasecorr1(i) = mainhandles.datalist(dataidx(i)).process.phasecorr1(i);
            catch
     phasecorr0(i) =0;
      phasecorr1(i) =0;
end
            try
            lsfid(i) = mainhandles.datalist(dataidx(i)).process(i).lsfid;
            catch
                lsfid(i)=0;
            end
% %% TO BE DOUBLE-CHECKED ???
%             %replace with param for summation: no apod, no phase, no lsfid
%             mainhandles.datalist(dataidx(i)).process(i).apodizefct = 'exponential';
%             mainhandles.datalist(dataidx(i)).process(i).apodparam1 = 0;
%             mainhandles.datalist(dataidx(i)).process(i).apodparam2 = 0;
%             mainhandles.datalist(dataidx(i)).process(i).phasecorr = 0; %% WARNING if phase is applied need to call the phasing function (c.f. B0_calc)
%             mainhandles.datalist(dataidx(i)).process(i).phasecorr1 = 0;
%             mainhandles.datalist(dataidx(i)).process(i).lsfid = mainhandles.datalist(dataidx(i)).process(i).lsfid+1;
            guidata(findobj('Tag','mainmenu'),mainhandles)
            
            
            
            
            data(i).real =  squeeze(mainhandles.datalist(dataidx(i)).data.real(arrayidx(i),:,:));
            data(i).imag =  squeeze(mainhandles.datalist(dataidx(i)).data.imag(arrayidx(i),:,:));
            
            
            if mainhandles.switch.phasecorrection==1
                fid_length=length(data(i).real); %=mainhandles.datalist(dataidx).np/2;
                t_vec = ((1:(fid_length))-lsfid)./mainhandles.datalist(dataidx(i)).spectralwidth;
%                 t=t_vec;
                % calculation of x-axis for frequency-space
                cut = round(fid_length/2);
                df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
                f_vec_shifted = df_vec.*((0:fid_length-1)'-cut); % needed for phasing

                data(i) = phasing(squeeze(data(i)), f_vec_shifted, phasecorr0(i), phasecorr1(i));
            %      mainhandles.datalist(data_idx(i)).process.phasecorr0=0;
            %       mainhandles.datalist(data_idx(i)).process.phasecorr1=0;
            end
            
            
            data(i) = postprocessing(squeeze(data(i)),dataidx(i),arrayidx(i));
            RAW.real(1,:,:)= data(i).real(1,:,:);
            RAW.imag(1,:,:)= data(i).imag(1,:,:);
            
            
            if mainhandles.switch.lsfid==1
                lsfid(i)=0;
            end
            
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



cd(output_path)

% Check if several files choosen and ask for batch processing
if mainhandles.switch.normalization==1;
if size(params.nt,1)>1 %arrayed data
    norm_factor = sum(params.nt);
elseif size(params.nt,2) == 1
    norm_factor = params.nt;
end

else
    norm_factor=1;
end
RAW.real=squeeze(data.real)./norm_factor;
RAW.imag=squeeze(data.imag)./norm_factor;

%----------------------------------------

volume = params.vox1*params.vox2*params.vox3;  %% TO BE DOUBLE-CHECKED ???
ID=char(params.name{1,1});

rawfile=filename;
nucleus =char(params.tn{1,1});
%header raw file
fid = fopen(rawfile, 'w','b');
fprintf(fid,'jMRUI Data Textfile\n');
fprintf(fid,'\n');
fprintf(fid,'%s\n',rawfile);
fprintf(fid,'\n');
fprintf(fid,'PointsInDataset: %u  \n',(params.np/2-lsfid(i)));    
fprintf(fid,'DatasetsInFile: 1\n');      
fprintf(fid,'SamplingInterval: %E\n',(2*params.at/params.np*1000));   
fprintf(fid,'ZeroOrderPhase: 0E0\n');       
fprintf(fid,'BeginTime: 0E0\n');       
fprintf(fid,'TransmitterFrequency: %E\n',params.sfrq*10^6);  
fprintf(fid,'MagneticField: %E\n',params.B0/10000);    
fprintf(fid,'TypeOfNucleus: %s\n',nucleus(1));       
fprintf(fid,'NameOfPatient: \n');
fprintf(fid,'DateOfExperiment: %s\n',char(params.date{1,1}));   
fprintf(fid,'Spectrometer: \n');
fprintf(fid,'AdditionalInfo: \n');
fprintf(fid,'\n');
fprintf(fid,'Signal and FFT\n');
fprintf(fid,'sig(real)	sig(imag)\n');
fprintf(fid,'Signal 1 out of 1 in file\n');

for i = (params.np/2):-1:1
    fprintf(fid,'%14.5E %14.5E\n',RAW.real(i), RAW.imag(i));
end
fclose(fid);
cd(current_path);


