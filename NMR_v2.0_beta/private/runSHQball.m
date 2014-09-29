function runSHQball
handles = guidata(findobj('Tag','GUI_ImageOrientation'));

data = handles.data.data.image;
grad = handles.data.gradsheme;
orientation = handles.data.orientation;



Nx = size(data,1);
Ny = size(data,2);
Nz = size(data,3);
Nt = size(data,4);
n_s=Nt;








if Nt < 15
    disp('*************************************************************')
    disp('not enough gradient direction to perform qball reconstruction');
    return;
elseif Nt>=15 && Nt<28
    rankSH = 15;
    order = 4;
elseif Nt>=28 && Nt<45
    rankSH = 28;
    order = 6;
elseif Nt >=45
    ranksH = 45;
    order = 8;
end

%inputs
% if ~exist('grad')         gradfile = input('Enter file containing gradients > '); end 




% getting the DWI
TASK = 2; SH;
TASK = 3; SH; 

outputfile = 'odf.ima';
fid = fopen(outputfile,'w');
fwrite(fid,data_SH,'uint16');
fclose(fid);

handles.data.data.qball.ODF = data_SH;
handles.data.data.qball.GFA = GFA;
handles.data.data.qball.rankSH = rankSH;
handles.data.data.qball.order = order;

DWI_string = get(handles.display_popupmenu_DWI,'String');
if isempty(cell2mat(strfind(DWI_string,'ODF')))
    DWI_string{length(DWI_string)+1}='GFA';
    DWI_string{length(DWI_string)+1}='ODF';
end
set(handles.display_popupmenu_DWI,'String',DWI_string);
guidata(findobj('Tag','GUI_ImageOrientation'),handles);

% create odf.dim with the correct Nt dimension
% Transform to Analyze format
% /i2bm/research/Fedora-4-i686/i2bm_pack-stable/bin/AimsFileConvert odf.ima odf.hdr
% Convert to modified SH basis used in brainVizu for ODF visualization
% max2tournier -i odf.hdr -o odfForBrainVizu.hdr 
% brainVizu -hardi odfForBrainVizu.hdr -hardic 0 -el -90 -az 180 -hscale 0.5
