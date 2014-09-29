% read .COORD file and plot data
% PGH Oct 2001

function lcmodelresults=readcoord(filename,pathname)

% define output structure for results
cd (pathname)
lcmodelresults=struct('spectrumppm',0,'spectrumdata',0,'spectrumfit',0,'spectrumbasl',0,'metabconc',0,'linewidth',0,'SN',0);
lcmodelresults.metabconc=struct('name',0,'relconc',0,'absconc',0,'SD',0);

% open .COORD file

fprintf('**** READING LCMODEL RESULTS IN .COORD FILE *****\n\n');
fprintf(['Opening file ' filename '\n']); 
fileid=fopen(filename);

% discard text until beginning of concentrations table (preceded by word 'Metab.')

s=[];
while strcmp(s,'Metabolite')==0 
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end

% read concentration values

index=1;
endtable=0;
while (endtable==0) 
       lcmodelresults.metabconc(index).absconc=fscanf(fileid,'%f',1);
       lcmodelresults.metabconc(index).SD=fscanf(fileid,'%f',1);
       temp=fscanf(fileid,'%s',1);                  % read and discard '%' character
       if (temp=='lines') endtable=1; end   % if word 'lines' found then concentration table has been completely read
       lcmodelresults.metabconc(index).relconc=fscanf(fileid,'%f',1);
       lcmodelresults.metabconc(index).name=fscanf(fileid,'%s',1);
       index=index+1;
       if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end

lcmodelresults.metabconc=lcmodelresults.metabconc(1:length(lcmodelresults.metabconc)-1); % discard last line of table
fprintf([num2str(length(lcmodelresults.metabconc)) ' metabolite concentrations values have been read\n'])

% discard text until linewidth (preceded by word 'FWHM')

s=[];
while strcmp(s,'FWHM')==0 
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end

% read linewidth

s=fscanf(fileid,'%s',1); % discard '='
lcmodelresults.linewidth=fscanf(fileid,'%f',1);

% discard text until S/N (preceded by word 'S/N=')

s=[];
while strcmp(s,'S/N')==0 
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end
c=[];
while strcmp(c,'=')==0 
    c=fscanf(fileid,'%c',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end

% read S/N

lcmodelresults.SN=fscanf(fileid,'%f',1);

s=[];
while isempty(strfind(s,'Ph:')) 
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end
% read pahse
if (isempty(strfind(s,'Ph:'))==0) && (strcmp(s,'Ph:')==0)
    s=strrep(s,'Ph:','');
    lcmodelresults.Ph0 = str2num(s);
else
lcmodelresults.Ph0=fscanf(fileid,'%f',1);
end
fscanf(fileid,'%s',1); %discard deg
lcmodelresults.Ph1=fscanf(fileid,'%f',1);
% discard text until number of data points (preceded by word 'extrema')

s=[];
while isempty(findstr(s,'extr')) 
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        return
    end
end

% read number of points

nbpoints=fscanf(fileid,'%d',1);

% read and discard text 'points on ppm-axis = NY'

s=fscanf(fileid,'%s',5);

% read ppm values

lcmodelresults.spectrumppm=fscanf(fileid,'%f',nbpoints);
% fprintf([num2str(length(lcmodelresults.spectrumppm)) ' ppm values have been read\n'])

% read and discard text 'NY phased data points follow'

s=fscanf(fileid,'%s',5);

% read data values

lcmodelresults.spectrumdata=fscanf(fileid,'%f',nbpoints);
% fprintf([num2str(length(lcmodelresults.spectrumdata)) ' data values have been read\n'])

% read and discard text 'NY points of the fit to the follow'

s=fscanf(fileid,'%s',9);

% read fit values

lcmodelresults.spectrumfit=fscanf(fileid,'%f',nbpoints);
% fprintf([num2str(length(lcmodelresults.spectrumfit)) ' fit values have been read\n'])
    
% read and discard text 'NY background values follow'

s=fscanf(fileid,'%s',4);

% read baseline values

lcmodelresults.spectrumbasl=fscanf(fileid,'%f',nbpoints);
% fprintf([num2str(length(lcmodelresults.spectrumbasl)) ' baseline values have been read\n\n'])


s=[];
while strcmp(s,'HZPPPM')==0
    s=fscanf(fileid,'%s',1);
    if feof(fileid)
        disp('COORD file not conform')
        fclose(fileid);
        lcmodelresults.sfrq=1;
        return
    end
end
s=fscanf(fileid,'%s',1);
lcmodelresults.sfrq=fscanf(fileid,'%f',1);

lcmodelresults.linewidth = lcmodelresults.linewidth*lcmodelresults.sfrq;

% close .COORD file

fclose(fileid);

