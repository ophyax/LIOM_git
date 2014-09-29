function data = read_siemens(inputfile)

[filepath,filename,ext] = fileparts(inputfile);
d			= dir(inputfile);
filesize	= d.bytes;
%% read header
switch ext
    case {'.dcm', '.DCM'}
        
        bytesPerSample  = 8;
        header_all = dicominfo(inputfile);
        
        
        try
            header_part = char(header_all.Private_0029_1120)';
        catch
            try
                
                % CHANGE
                % In this case, floating point values are stored as 'bytesPerSample' bytes
                %endofheader = filesize-2*8*str2double(header_all.VectorSize)
                if isfield(header_all,'VectorSize')
                    endofheader = filesize-2*bytesPerSample*str2double(header_all.VectorSize);
                elseif isfield(header_all,'DataPointColumns')
                    header_all.VectorSize = header_all.DataPointColumns;
                    endofheader = filesize-2*bytesPerSample*str2double(header_all.DataPointColumns);
                end
                
            catch
                errordlg('DCM could not read header')
            end
        end
        
    case {'.rda', '.RDA'}
        
        bytesPerSample  = 8;
        
        fid=fopen(inputfile);
        ct=0; % number of header lines succesfully read in
        while 1
            tline = fgetl(fid);
            if strcmp(tline,'>>> End of header <<<'),   break,   end
            ct=ct+1;
            if ct>=2
                sepidx = findstr(tline,':');
                newfield=tline(1:sepidx-1);
                newfield(strfind(newfield,'['))='';
                newfield = regexprep(newfield,'[[]]','');
                field_str=tline(sepidx+1:length(tline));
                if ~isempty(newfield)
                    header_all.(newfield)=field_str;
                end
            end
        end
        endofheader=ftell(fid);
        fclose(fid);
    case {'','.IMA','.ima'}
        bytesPerSample  = 4;
        
        header_all = dicominfo(inputfile);
        try
            if isfield(header_all,'Private_0029_1120')
                header_part = char(header_all.Private_0029_1120)';
            elseif isfield(header_all,'Private_0029_1020')
                header_part = char(header_all.Private_0029_1020)';
                %image
                return;
            else
                header_part = char(header_all.Private_0asdsadas20)'; %force to crash
                
            end
        catch
            try
                
                % CHANGE
                % In this case, floating point values are stored as 'bytesPerSample' bytes
                %endofheader = filesize-2*8*str2double(header_all.VectorSize)
                endofheader = filesize-2*bytesPerSample*str2double(header_all.VectorSize);
                
            catch
                errordlg('RAW could not read header')
            end
        end
end

if exist('header_part','var')
    searchstring_in = 'sSpecPara.lVectorSize                    =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    num_samples = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    params.np = num_samples*2;
    % CHANGE
    % In this case, floating point values are stored as 'bytesPerSample' bytes
    %endofheader=d.bytes-2*64/8*num_samples
    endofheader		= d.bytes-2*bytesPerSample*num_samples;
    
    searchstring_in = 'sRXSPEC.alDwellTime[0]                   =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    dwelltime = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    params.sw=1/(2*dwelltime/10^9);
    % CHANGE
    % Determine whether oversampling was removed or not
    removeOversampling		= 0;
    % Check for oversampling
    searchstring_in		= 'sSpecPara.ucRemoveOversampling           =';
    searchstring_start	= findstr(searchstring_in,header_part);
    if( ~isempty(searchstring_start) )
        searchstring_end	= searchstring_start+length(searchstring_in);
        searchstring_out	= findstr(char(10),header_part(searchstring_end:searchstring_end+100));
        removeOversampling	= (header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
        % Extract hexadecimal number (as string) from string including token '0x' and convert it
        % to decimal number
        str_len					= length(removeOversampling);
        % for i=1 : 1 : str_len
        % 	out_char	=	removeOversampling(i)
        % end
        startInd					= findstr('x', removeOversampling);
        % Remove any trailing white spaces from string for routine "hex2dec" to work
        if( isspace(removeOversampling(str_len)) )
            removeOversampling	= removeOversampling(startInd+1:str_len-1);
        else
            removeOversampling	= removeOversampling(startInd+1:str_len);
        end
        removeOversampling	= hex2dec(removeOversampling);
    end
    % 	disp('removeOversampling = ');
    % 	disp(removeOversampling);
    
    % Dwell time in header is real dwell time in ns including oversampling, i.e. if
    % oversampling was removed, the dwell time for the actual data that is in the file
    % has to be multiplied by a factor of 2
    samplerate_withOS		= dwelltime*1e-9;
    samplerate_withoutOS	= 2*dwelltime*1e-9;
    if(removeOversampling)
        t_step				= samplerate_withoutOS;
    else
        t_step				= samplerate_withOS;
    end
    t_vec					= t_step.*(0:num_samples-1);
    
    searchstring_in = 'sTXSPEC.asNucleusInfo[0].lFrequency      =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.sfrq = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    disp(params.sfrq)
    searchstring_in = 'alTE[0]                                  =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.te = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    searchstring_in = 'alTR[0]                                  =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.tr = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    % CHANGE
    % Obtain number of averages
    searchstring_in = 'lAverages                                =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.nt = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    searchstring_in = 'sSpecPara.sVoI.dThickness                =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.thk = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    searchstring_in = 'sSpecPara.sVoI.dPhaseFOV                 =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.lpe = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    searchstring_in = 'sSpecPara.sVoI.dReadoutFOV               =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    params.lro = str2double(header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    
    searchstring_in = 'sTXSPEC.asNucleusInfo[0].tNucleus        =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    nuclei = (header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    
    params.tn{1} = nuclei(4:(length(nuclei)-3));
    
    searchstring_in = 'tReferenceImage0                         =';
    searchstring_end = findstr(searchstring_in,header_part)+length(searchstring_in);
    searchstring_out = findstr(char(10),header_part(searchstring_end:searchstring_end+100));
    at = (header_part(searchstring_end:searchstring_end+searchstring_out(1)-1));
    
    at=at((length(at)-27):(length(at)-3));
    params.at = [at(1:8) 'T' at(9:14)];
    
    filesize	= header_all.FileSize;
    % data_start = header_all.StartOfPixelData
else
        num_samples = str2double(header_all.VectorSize);
    params.np =num_samples*2;
    params.acqtime=[header_all.StudyDate 'T' header_all.StudyTime(2:7)]
%     params.nt = num_samples;
	% Dwell time is given without oversampling and in us
%     header_all
%     dwelltime	= str2double(header_all.DwellTime);
    if isfield(header_all,'SpectralWidth')
        params.sw=str2double(header_all.SpectralWidth);
        params.dw = 1/params.sw;
    else
        params.dw =  str2double(header_all.DwellTime)*1e-6;
        params.sw = 1/params.dw;
    end
    params.at = str2double(header_all.VectorSize)*params.dw;
    dwelltime = params.dw;
    samplerate	= params.dw;
    t_step		= samplerate;
    t_vec		= t_step.*(0:num_samples-1);
    params.sfrq = str2double(header_all.MRFrequency)*1e6;
    aprams.te			= str2double(header_all.TE);
    params.tr			= str2double(header_all. TR);
    params.thk	= str2double(header_all.VOIThickness);
    params.lpe	= str2double(header_all.VOIPhaseFOV);
    
    % CHANGE
    % Fix to deal with typo in header 7T .rda data acquired under VB12H
    if( isfield(header_all, 'VOIReadoutFOV') )
        params.lro = str2double(header_all.VOIReadoutFOV);
    elseif( isfield(header_all, 'VOIReadoutVOV') )
        params.lro = str2double(header_all.VOIReadoutVOV);
    end
    % Obtain number of averages
    params.nt	= str2double(header_all.NumberOfAverages);
    if isfield(header_all,'CSIMatrixSize0')  %%CSI data
        num_samples = num_samples*str2double(header_all.CSIMatrixSize0)*str2double(header_all.CSIMatrixSize1)*str2double(header_all.CSIMatrixSize2);
        params.multiplicity = str2double(header_all.CSIMatrixSize0)*str2double(header_all.CSIMatrixSize1)*str2double(header_all.CSIMatrixSize2);
    end
end
fid = fopen(inputfile,'r');
if fid == -1
    errordlg('Can''t open input fid file')
    return
end


%% read data
% CHANGE
% Check on return value of fseek
if( fseek(fid,endofheader,'bof') == -1 )
    errordlg('Failure using fseek to reposition to end of header!');
end

precis	= ((d.bytes-endofheader)/(2*num_samples)*8)
if precis < 32
    datformat = ['uint' num2str(precis)];
else
    datformat = ['float' num2str(precis)];
end
filedata	= fread(fid,inf,datformat,'ieee-le');
position	= ftell(fid);
fclose(fid);

% CHANGE
s			= whos('filedata');
dataBytes   = 2*num_samples*bytesPerSample;
%if ~isequal((position-endofheader),s.bytes) || ...
if ~isequal((position-endofheader),dataBytes) || ...
        mod(length(filedata),2)==1 || ~isequal(filesize,position)
    herr=errordlg('Amount of read data does not match file size');
    waitfor(herr)
end
if length(filedata)==params.np/2
data.real(1,1,:) = filedata(1:2:length(filedata));
data.imag(1,1,:) = filedata(2:2:length(filedata));
else
    data.real(:,1,:) = permute(reshape(filedata(1:2:length(filedata)),[params.np/2 length(filedata)/params.np]),[2 1]);
    data.imag(:,1,:) = permute(reshape(filedata(2:2:length(filedata)),[params.np/2 length(filedata)/params.np]),[2 1]);;
end