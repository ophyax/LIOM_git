function coord
mainhandles=guidata(findobj('Tag','mainmenu'));
% handles=guidata(findobj('Tag','lcmodelfig'));
filelist = mainhandles.lcmodel.cur_controlfile;
disp('')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('Writing concentrations to Excel........')
for i =1:length(filelist);

    [pathname, file, ext] = fileparts(filelist{1,i});
    filename = strrep([file ext],'CONTROL','COORD');
    % cd('D:\Program Files\MATLAB704\work\lcmodel\NewFolder1')
    try
    lcmresult = readcoord(filename,pathname);
    
    if i == 1;
        excel_data = zeros(size(lcmresult.metabconc,2)+3,size(filelist,1)*2);
        met = cell(size(lcmresult.metabconc,2),1);
    end
    for j =1:size(lcmresult.metabconc,2)
        excel_data(j,2*i-1)=lcmresult.metabconc(1,j).absconc;
        excel_data(j,2*i)=lcmresult.metabconc(1,j).SD;
        met{j,1} = lcmresult.metabconc(1,j).name;
    end
    excel_data(j+1,2*i-1)=lcmresult.SN;
    met{j+1,1}='SNR';
    excel_data(j+2,2*i-1)=lcmresult.linewidth;
    met{j+2,1}='LW';
    excel_data(j+3,2*i-1)=lcmresult.Ph0;
    excel_data(j+3,2*i)=lcmresult.Ph1;
    met{j+3,1}='Phase';
    catch
        disp('COORD file invalid')
        disp(filename)
    end

    name{1,2*i-1}=[pathname filename];
    name2{1,i}=[pathname filename];
    disp([i length(filelist)])

end
conc = excel_data(:,1:2:size(excel_data,2));
crlb = excel_data(:,2:2:size(excel_data,2));
%% Initialisation of POI Libs
% Add Java POI Libs to matlab javapath
cwd = pwd;
chdir('D:\Users\Philippe Pouliot\Dropbox\NMR_v2.0_beta\20130227_xlwrite')
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');
chdir(cwd);
%%
[FileName,PathName,FilterIndex] = uiputfile('*.xls','Save COORD file to excel:');
excel_name = [PathName FileName];
sheet='lcmodel';
xlwrite(excel_name,name,sheet,'B1');
xlwrite(excel_name, met,sheet,'A2');
xlwrite(excel_name, excel_data,sheet,'B2');
sheet='conc';
xlwrite(excel_name,name2,sheet,'B1');
xlwrite(excel_name, met,sheet,'A2');
xlwrite(excel_name, conc,sheet,'B2');
sheet='CRLB';
xlwrite(excel_name,name2,sheet,'B1');
xlwrite(excel_name, met,sheet,'A2');
xlwrite(excel_name, crlb,sheet,'B2');

% xlswrite(excel_name,name,sheet,'B1')
% xlswrite(excel_name, met,sheet,'A2')
% xlswrite(excel_name, excel_data,sheet,'B2')
% sheet='conc';
% xlswrite(excel_name,name2,sheet,'B1')
% xlswrite(excel_name, met,sheet,'A2')
% xlswrite(excel_name, conc,sheet,'B2')
% sheet='CRLB';
% xlswrite(excel_name,name2,sheet,'B1')
% xlswrite(excel_name, met,sheet,'A2')
% xlswrite(excel_name, crlb,sheet,'B2')
disp('')
disp('.............Finish to Write concentrations to Excel')
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
