function filename_str = read_philips(inputfile,plotswitch)
% reading data of MR spectra of Philips machines
% 1st inputarg = filename, 2nd inputarg = plot ON/OFF = 1/0 

if nargin < 1
    plotswitch = 1;
elseif nargin == 1 & isnumeric(inputfile) == 1
    plotswitch = inputfile;
    clear inputfile;
    if plotswitch < 0 | plotswitch > 1
        plotswitch = 1;
    end
elseif nargin > 1 
    if isnumeric(plotswitch) == 0 | plotswitch < 0 | plotswitch > 1
        disp('Second Inputparameter not correct')
        plotswitch == 1;
    end
end

if exist('inputfile')==0 | ischar(inputfile) == 0
    [filename filepath] = uigetfile('*.SPAR');
%     filename = filename(1:(findstr('.SPAR', filename)-1));
    file_path_name = [filepath filename];
else
    [filepath,filename,ext] = fileparts(inputfile);
    if strcmp(ext,'.SDAT') == 1
        filename = [filename '.SPAR'];
    end
    k = 1;
    while strcmp(filepath,'') == 1        
        switch k
            case 1
                [filepath,filename,ext] = fileparts(filename);
                filename = [filename ext];
            case 2
                file_path_name = which(filename);
                filepath = file_path_name(1:max(findstr(filesep,file_path_name))-1);
                filename = filename;
            case 3
                filename = filename;
                s = dir(filename);
                if isempty(s) == 0
                    filepath = pwd;
                end                
            case 4
                filename = filename;
                filepath = uigetdir(pwd,['Locate File ', filename]);
        end        
        k = k+1;
    end
    file_path_name = [filepath filesep filename];
end

%--- open file for reading
fid = fopen(file_path_name,'rt');
if fid == -1 
    errordlg('Can''t open input fid file')
    return
end
[file_path_name, mode, machineformat] = fopen(fid);
header = char(fread(fid))';
fseek(fid, 0, 'eof');
headersize = ftell(fid);
fclose(fid);

%--- acquisition parameters
searchstring_in = 'scan_date :';
searchstring_out = 'patient_name :';
date_time = ...
    header(findstr(searchstring_in,header)+length(searchstring_in)+1:...
    findstr(searchstring_out,header)-1);
date = datestr([str2num(date_time(1:4)) str2num(date_time(6:7)) str2num(date_time(9:10))...
    str2num(date_time(12:13)) str2num(date_time(15:16)) str2num(date_time(18:19))],0);

searchstring_in = 'samples :';
searchstring_out = 'rows :';
num_samples = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'spec_col_lower_val :';
searchstring_out = 'spec_col_upper_val :';
t_lower_val = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'spec_col_upper_val :';
searchstring_out = 'spec_col_extension :';
t_upper_val = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'SUN_dim1_step :';
searchstring_out = 'SUN_dim1_direction :';
t_step = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

t_vec = t_lower_val:t_step:(t_upper_val-t_step);
% t_vec = t_vec - t_lower_val;

searchstring_in = 'synthesizer_frequency :';
searchstring_out = 'offset_frequency :';
imagingfreq = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'echo_time :';
searchstring_out = 'repetition_time :';
TE = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'repetition_time :';
searchstring_out = 'averages :';
TR = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'ap_size :';
searchstring_out = 'lr_size :';
height = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'lr_size :';
searchstring_out = 'cc_size :';
width = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

searchstring_in = 'cc_size :';
searchstring_out = 'ap_off_center :';
length = ...
    str2num(header(findstr(searchstring_in,header)+length(searchstring_in):...
    findstr(searchstring_out,header)-1));

%--- reading data
filename_data = [file_path_name(1:length(file_path_name)-5) '.SDAT'];
try,
    if isempty(findstr('dataformat: VAX CPX floats', header)) == 0
        fid = fopen(filename_data,'rb','vaxd');
    else
        fid = fopen(filename_data);
    end
    [filename_data, mode, machineformat] = fopen(fid);
    data = fread(fid,inf,'*float32','vaxd');
    fseek(fid, 0, 'eof');
    datasize = ftell(fid);
    fclose(fid);
catch
%     lasterr
    errordlg(['According data file ' filename '.SDAT either does not exist, or cannot be read'],'File Error');
    return
end

data_real = data(1:2:length(data));
data_imag = data(2:2:length(data));

% Exponential or Gaussian multiplication
% Hz_per_points = 


%--- calculate FFT
num_zeros = 0; % num_samples; % numbers of zeros for zero filling
num_samples_fft = num_samples+num_zeros;
data_real = [data_real zeros(1,num_zeros)];
data_imag = [data_imag zeros(1,num_zeros)];

fft_data = fft(data_real+i*data_imag);
cut = num_samples_fft/2;
fft_data_shifted = [fft_data(cut+1:num_samples_fft); fft_data(1:cut)];

df_vec = 1/(t_step*num_samples_fft);
f_vec_shifted = df_vec.*((0:num_samples_fft-1)-cut);
ppm_vec = f_vec_shifted/(imagingfreq*1e-6);

%--- output structure
name_begin = max(findstr(filesep,filename));
filename = filename(name_begin+1:length(filename)); 

filename_str.file = filename;
filename_str.date = date;
filename_str.Scanner = 'Philips';
filename_str.filesize = datasize;
filename_str.headersize = headersize;
filename_str.datasize = datasize;
filename_str.num_samples = num_samples;
filename_str.samplefreq = 1/(t_step);
filename_str.imagingfreq = imagingfreq;
filename_str.TE = TE;
filename_str.TR = TR;
filename_str.data.real = data_real;
filename_str.data.imag = data_imag;
filename_str.data.spectrum_real = real(fft_data_shifted);
filename_str.data.spectrum_imag = imag(fft_data_shifted);
filename_str.t_vec = t_vec;
filename_str.ppm_vec = ppm_vec;
filename_str.volume.height = height;
filename_str.volume.width = width;
filename_str.volume.length = length;

annotation_str = ...
    {'filename: ', ['     ' filename],...
     'date: ', ['     ' date],...
     'Scanner:', ['     ' filename_str.Scanner],...
     'filesize:', ['     ' num2str(filename_str.datasize)],...
     'headersize:', ['     ' num2str(filename_str.headersize)],...
     'datasize:', ['     ' num2str(filename_str.datasize)],...
     '#samples:', ['     ' num2str(filename_str.num_samples)],...
     'samplefreq:', ['     ' num2str(filename_str.samplefreq)],...
     'imagingfreq:', ['     ' num2str(filename_str.imagingfreq)],...
     'TE:', ['     ' num2str(filename_str.TE)],...
     'TR:', ['     ' num2str(filename_str.TR)]};
 
%--- save data
data_all = [data_real data_imag (real(fft_data_shifted)) (imag(fft_data_shifted))];
% eval(['spectrum_' filename '= data_all;'])
% save(['all_' filename], 'data_all')

%--- PLOTS
if plotswitch == 1
    figure1 = figure; set(gcf,'Name',['FID (' filename ')'], 'Position', [360 500 680 420]);
    subplot('Position',[0.08 0.6 0.67 0.34]),...
        plot(1000.*t_vec,data_all(:,1)), grid on, title('real part of signal'), xlabel('Time [ms]'), ylabel('Amplitude')
    subplot('Position',[0.08 0.1 0.67 0.34]),...
        plot(1000.*t_vec,data_all(:,2)), grid on, title('imaginary part of signal'), xlabel('Time [ms]'), ylabel('Amplitude')
    %% Create textbox
    annotation(figure1,'textbox','Position',[0.76 0.15 0.3 0.80],'Interpreter','none',...
        'LineStyle','none','FitHeightToText','off','String', annotation_str);

    figure2 = figure; set(gcf,'Name',['spectrum of data (' filename ')'], 'Position', [360 500 680 420]);
    subplot('Position',[0.08 0.6 0.67 0.34]),...
        plot(ppm_vec,data_all(:,3)), set(gca,'XDir','reverse'), grid on, title('real part of FFT(signal)'), xlabel('Frequency [ppm]'), ylabel('Amplitude')
    subplot('Position',[0.08 0.1 0.67 0.34]),...
        plot(ppm_vec,data_all(:,4)), set(gca,'XDir','reverse'), grid on, title('imaginary part of FFT(signal)'), xlabel('Frequency [ppm]'), ylabel('Amplitude')
    %% Create textbox
    annotation(figure2,'textbox','Position',[0.76 0.15 0.3 0.800],'Interpreter','none',...
        'LineStyle','none','FitHeightToText','off','String', annotation_str);


    figure3 = figure; set(gcf,'Name',['magnitude and phase of spectrum (' filename ')'], 'Position', [360 502 680 420]);
    subplot('Position',[0.08 0.6 0.67 0.34]),...
        plot(ppm_vec,sqrt(data_all(:,3).^2+data_all(:,4).^2)), grid on, title('magnitude of the spectrum'), pixval on
    subplot('Position',[0.08 0.1 0.67 0.34]),...
        plot(ppm_vec,unwrap(atan2(data_all(:,4),data_all(:,3)))), grid on, title('phase of the spectrum [rad]'), pixval on
    %% Create textbox
    annotation(figure3,'textbox','Position',[0.76 0.15 0.3 0.80],'Interpreter','none',...
        'LineStyle','none','FitHeightToText','off','String', annotation_str);
end

% % %--- comparison with external data
% % load ([filename '.mat'])
% % disp('---')
% % real_signal_resnorm = norm(data(:,1)-data_real)
% % imag_signal_resnorm = norm(data(:,2)-data_imag)
% % 
% % real_fft_data = real(fft_data_real)-imag(fft_data_imag);
% % imag_fft_data = imag(fft_data_real)+real(fft_data_imag);
% % real_fft_data_shifted = [real_fft_data(cut+1:1024); real_fft_data(1:cut)];
% % imag_fft_data_shifted = [imag_fft_data(cut+1:1024); imag_fft_data(1:cut)];
% % 
% % real_fftsignal1_resnorm = norm(data(:,3)-real_fft_data_shifted)
% % imag_fftsignal1_resnorm = norm(data(:,4)-imag_fft_data_shifted)
% % real_fftsignal2_resnorm = norm(data(:,3)-real(fft_data_shifted))
% % imag_fftsignal2_resnorm = norm(data(:,4)-imag(fft_data_shifted))
% % disp('---')
% % PLOTS
% % figure(100), ...
% %     subplot(2,1,1),plot(1:1024,real(fft_data_shifted),'k',1:1024,data(:,3),':r'), grid on,...
% %     subplot(2,1,2),plot(1:1024,imag(fft_data_shifted),'k',1:1024,data(:,4),':r'), grid on
% % 
% % figure(5), ...
% %     subplot(2,1,1), plot(1:1024,real_fft_data_shifted,'k',1:1024,data(:,3),':r'),grid on, ...
% %     subplot(2,1,2), plot(1:1024,imag_fft_data_shifted,'k',1:1024,data(:,4),':r'),grid on




