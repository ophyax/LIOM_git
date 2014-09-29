function status=createlcmcontrolfile(controlfilename,nucleus)
% create .CONTROL file for LCModel

status=0;
mainhandles=guidata(findobj('Tag','mainfig'));

[pathstr, name, ext] = fileparts(controlfilename);
[a b c] = fileparts(pathstr);
fidname = [b c];

% title = [fidname '/' name];
title = name;

% create filenames on server to be written to *.CONTROL
targetfolder_str=get(findobj('Tag','lcmodelfig_edit_targetfolder'),'String');
if strcmp(targetfolder_str(length(targetfolder_str)),'/')
    targetfolder=[targetfolder_str fidname '/'];
else
    targetfolder=[targetfolder_str '/' fidname '/'];
end
controlfile = [targetfolder '/' name '.CONTROL'];
rawfile = [targetfolder '/' name '.RAW'];
psfile = [targetfolder '/' name '.PS'];
coordfile = [targetfolder '/' name '.COORD'];

if exist(mainhandles.lcmodel.basisfile,'file')
    [basisfilepath, basisfilename, basisfileext] = fileparts(mainhandles.lcmodel.basisfile);
    basisfile = [targetfolder basisfilename basisfileext];
else
    errordlg('Basisfile does not exist or no basisfile selected!')
    return
end

% printfile =fullfile(pathstr,[name, '.PRINT']);
% ----------------------------------------------------------------------
fid=fopen(controlfilename,'w','b');
if nargin>=2
    if exist('nucleus','var') && strcmp(char(nucleus),'H1') % Waterreference file
        if exist(mainhandles.lcmodel.reffile,'file')
            [reffilepath, reffilename, reffileext] = fileparts(mainhandles.lcmodel.reffile);
            reffile = [targetfolder reffilename reffileext];
        else
%             disp('Referencefile does not exist or no referencefile selected!')
%             errordlg('Referencefile does not exist or no referencefile selected!')
            reffile='';
        end
    end
    switch char(nucleus)
        case 'H1' % control file for proton spectra
            fprintf(fid,' $LCMODL\n');
            fprintf(fid,' ATTH2O= 1.0\n');
            fprintf(fid,' NCOMBI= 4\n');
            fprintf(fid,' CHCOMB(1)=\''NAA+NAAG\''\n');
            fprintf(fid,' CHCOMB(2)=\''Glu+Gln\''\n');
            fprintf(fid,' CHCOMB(3)=\''GPC+PCho\''\n');
            fprintf(fid,' CHCOMB(4)=\''Cr+PCr\''\n');
            fprintf(fid,' NOMIT= 7\n');
            fprintf(fid,' CHOMIT(1)=\''-CrCH2\''\n');
            fprintf(fid,' CHOMIT(2)=\''Gua\''\n');
            fprintf(fid,' CHOMIT(3)=\''Ser\''\n');
            fprintf(fid,' CHOMIT(4)=\''Lip13a\''\n');
            fprintf(fid,' CHOMIT(5)=\''Lip13b\''\n');
            fprintf(fid,' CHOMIT(6)=\''Lip09\''\n');
            fprintf(fid,' CHOMIT(7)=\''Lip20\''\n');
            fprintf(fid,' NUSE1= 6\n');
            fprintf(fid,' CHUSE1(1)=\''Cr\''\n');
            fprintf(fid,' CHUSE1(2)=\''PCr\''\n');
            fprintf(fid,' CHUSE1(3)=\''Tau\''\n');
            fprintf(fid,' CHUSE1(4)=\''PE\''\n');
            fprintf(fid,' CHUSE1(5)=\''Glu\''\n');
            fprintf(fid,' CHUSE1(6)=\''PCho\''\n');
            fprintf(fid,' CONREL= 8.00\n');
            % fprintf(fid,' DEGPPM= 0\n');
            % fprintf(fid,' DEGZER= 0\n');
            fprintf(fid,' DELTAT= 1.9975e-04\n');
            fprintf(fid,' DKNTMN= 0.25\n');
            fprintf(fid,' DOECC= F\n');
            fprintf(fid,' DOWS= T\n');
            fprintf(fid,' FWHMBA= 0.0050\n');
            fprintf(fid,' HZPPPM= 400.273\n');
            fprintf(fid,' LCOORD=9\n');
            fprintf(fid,' NAMREL= \''Cr+PCr\''\n');
            fprintf(fid,' NCALIB= 0\n');
            fprintf(fid,' NSIMUL= 0\n');
            fprintf(fid,' NUNFIL= 2048\n');
            fprintf(fid,' PGNORM= \''US\''\n');
            fprintf(fid,' PPMEND= 0.2\n');
            fprintf(fid,' PPMST= 4.5\n');
            fprintf(fid,' RFWHM= 1.8\n');
            % fprintf(fid,' SDDEGP= 0\n');
            % fprintf(fid,' SDDEGZ= 0\n');
            fprintf(fid,' VITRO= F\n');
            fprintf(fid,' WCONC= 48777.3\n');
            fprintf(fid,' SHIFMN=-0.2,-0.1\n');
            fprintf(fid,' SHIFMX=0.3,0.3\n');
            fprintf(fid,' KEY=101697430\n');
            fprintf(fid,' OWNER=\''Center for Biomedical Imaging, Lausanne\''\n');
            fprintf(fid,' TITLE=\''%s\''\n',title);
            fprintf(fid,' FILPS=\''%s\''\n',psfile);
            fprintf(fid,' FILCOO=\''%s\''\n',coordfile);
            fprintf(fid,' FILRAW=\''%s\''\n',rawfile);
            fprintf(fid,' FILBAS=\''%s\''\n',basisfile);
            if strcmp(reffile,'')==0
                fprintf(fid,' FILH2O=\''%s/%s\''\n',reffile);
            end
            fprintf(fid,' DOREFS= T\n');
            fprintf(fid,'$END\n');
        case 'C13' % control file for carbon spectra
            fprintf(fid,' $LCMODL\n');
            fprintf(fid,' DKNTMN=2*99\n');
            fprintf(fid,' RFWHM=1.8\n');
            fprintf(fid,' XSTEP=5.\n');
            fprintf(fid,' FWHMBA=0.049\n');
            fprintf(fid,' NSIDMN=2\n');
            fprintf(fid,' ALPBMN=108\n');
            fprintf(fid,' ALPBMX=54000\n');
            fprintf(fid,' ALPBPN=135\n');
            fprintf(fid,' ALPBST=162\n');
            fprintf(fid,' DESDSH=0.01\n');
            fprintf(fid,' NCOMBI=15\n');
            fprintf(fid,' CHCOMB(1)=''gluC3+gluC34+glu324''\n');
            fprintf(fid,' CHCOMB(2)=''gluC4+gluC43''\n');
            fprintf(fid,' CHCOMB(3)=''gluC2+gluC23+glu213+gluC21''\n');
            fprintf(fid,' CHCOMB(4)=''glnC3+glnC34+gln324''\n');
            fprintf(fid,' CHCOMB(5)=''glnC4+glnC43''\n');
            fprintf(fid,' CHCOMB(6)=''glnC2+glnC23+gln213+glnC21''\n');
            fprintf(fid,' CHCOMB(7)=''aspC3+aspC32+asp324+aspC34''\n');
            fprintf(fid,' CHCOMB(8)=''aspC2+aspC23+asp213+aspC21''\n');
            fprintf(fid,' CHCOMB(9)=''gabaC3+gabC34+gab324''\n');
            fprintf(fid,' CHCOMB(10)=''gabaC4+gabC43+gab435+gabC45''\n');
            fprintf(fid,' CHCOMB(11)=''gabaC2+gabC23''\n');
            fprintf(fid,' CHCOMB(12)=''naaC3+naaC32''\n');
            fprintf(fid,' CHCOMB(13)=''naaC2+naaC23''\n');
            fprintf(fid,' CHCOMB(14)=''glu213+gluC21''\n');
            fprintf(fid,' CHCOMB(15)=''glu213+gluC23''\n');
            fprintf(fid,' NOMIT=2\n');
            fprintf(fid,' CHOMIT(1)=''glu435''\n');
            fprintf(fid,' CHOMIT(2)=''gluC45''\n');
            fprintf(fid,' NUSE1=7\n');
            fprintf(fid,' CHUSE1(1)=''gluC4''\n');
            fprintf(fid,' CHUSE1(2)=''naaC6''\n');
            fprintf(fid,' CHUSE1(3)=''glnC4''\n');
            fprintf(fid,' CHUSE1(4)=''glcC6a''\n');
            fprintf(fid,' CHUSE1(5)=''glcC6b''\n');
            fprintf(fid,' CHUSE1(6)=''glcC1b''\n');
            fprintf(fid,' CHUSE1(6)=''glcC1a''\n');
            fprintf(fid,' DOREFS(1)=F\n');
            fprintf(fid,' DOREFS(2)=T\n');
            fprintf(fid,' NREFPK(2)=1\n');
            fprintf(fid,' PPMREF(1,2)=34.37\n');
            fprintf(fid,' HZREF(1,2)=2*0.\n');
            % % fprintf(fid,' ECCDON=.FALSE.\n');
            fprintf(fid,' CONREL= 1.00\n');
            % fprintf(fid,' DEGPPM= 0\n');
            % fprintf(fid,' DEGZER= 0\n');
            fprintf(fid,' DELTAT= 1.9975e-04\n');
            fprintf(fid,' HZPPPM= 100.65\n');
            fprintf(fid,' LCOORD=9\n');
            % fprintf(fid,' NAMREL= \''FA\''\n');
            fprintf(fid,' NUNFIL= 8192\n');
            fprintf(fid,' PGNORM= \''US\''\n');
            fprintf(fid,' PPMEND= 10\n');
            fprintf(fid,' PPMST= 100\n');
            % fprintf(fid,' RFWHM= 1.8\n');
            % fprintf(fid,' SDDEGP= 0\n');
            % fprintf(fid,' SDDEGZ= 0\n');
            fprintf(fid,' VITRO= F\n');
            % fprintf(fid,' WCONC= 48777.3\n');
            % fprintf(fid,' SHIFMN=-0.2,-0.1\n');
            % fprintf(fid,' SHIFMX=0.3,0.3\n');
            fprintf(fid,' KEY=101697430\n');
            fprintf(fid,' OWNER=\''Center for Biomedical Imaging, Lausanne\''\n');
            fprintf(fid,' TITLE=\''%s\''\n',title);
            fprintf(fid,' FILPS=\''%s\''\n',psfile);
            fprintf(fid,' FILCOO=\''%s\''\n',coordfile);
            fprintf(fid,' FILRAW=\''%s\''\n',rawfile);
            fprintf(fid,' FILBAS=\''%s\''\n',basisfile);
            % fprintf(fid,' FILH2O=\''%s/%s\''\n',directory,h2ofile);
            % fprintf(fid,' DOREFS= T\n')
            fprintf(fid,'$END\n');
        otherwise
            disp('nucleus is other than H1 & 13C');
    end
else
    if isempty(mainhandles.lcmodel.orig_controlfile)==0
        % use control file as origignal and just adapt file directories
        fid_orig = fopen(mainhandles.lcmodel.orig_controlfile,'r');
        while 1
            nextline=fgets(fid_orig);
            if ~ischar(nextline),   break,   end
            if findstr(char(nextline),'TITLE')
                fprintf(fid,' TITLE=\''%s\''\n',title);
            elseif findstr(char(nextline),'FILPS')
                fprintf(fid,' FILPS=\''%s\''\n',psfile);
            elseif findstr(char(nextline),'FILCOO')
                fprintf(fid,' FILCOO=\''%s\''\n',coordfile);
            elseif findstr(char(nextline),'FILRAW')
                fprintf(fid,' FILRAW=\''%s\''\n',rawfile);
            elseif findstr(char(nextline),'FILBAS')
                fprintf(fid,' FILBAS=\''%s\''\n',basisfile);
            elseif findstr(char(nextline),'FILH2O')
                if strcmp(reffile,'')==0
                    fprintf(fid,' FILH2O=\''%s/%s\''\n',reffile);
                end
            else
                fprintf(fid,'%s',char(nextline));
            end
        end
        fclose(fid_orig);
    else
        errordlg('No Controlfile selected or resonance nucleus not known');
        return
    end
end
fclose(fid);

guidata(findobj('Tag','mainfig'),mainhandles);
disp(['finished writing ' controlfilename])
status=1;
