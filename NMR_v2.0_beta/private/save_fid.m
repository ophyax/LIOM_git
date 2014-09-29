function save_fid

mainhandles=guidata(findobj('Tag','mainmenu'));

dataidx = mainhandles.dispopts.dataidx;
arrayidx = mainhandles.dispopts.arrayidx; %1?

%% get current diplayed data
temp.real = (mainhandles.datalist(dataidx).data.real);
temp.imag = (mainhandles.datalist(dataidx).data.imag);

data_sum.real =zeros(size(temp.real));
data_sum.imag =zeros(size(temp.real));

%% store and set to zero apodizazion
%% set switch for postprocessing script
mainhandles.switch_bkp = mainhandles.switch;


% clear temp
% ref_log = select_ref(size(temp.real,1));

%% select referecen scan
a=gui_dataselect('fid2RAW',size(temp.real,1));
uiwait(a);
if ~isempty(findobj('Tag','dataselect'))
    h=guidata(a);
    ref_idx = get(h.listbox,'Value');
    
    
    mainhandles.switch.phasecorrection=h.switch.phasecorrection;
    mainhandles.switch.apodization=h.switch.apodization;
    mainhandles.switch.transformsize=h.switch.transformsize;
    mainhandles.switch.lsfid=h.switch.lsfid;
    mainhandles.switch.dcoffset=h.switch.dcoffset;
    mainhandles.switch.b0=h.switch.b0;
    delete(a)
    clear h
else
    mainhandles.switch = mainhandles.switch_bkp;
    guidata(findobj('Tag','mainmenu'),mainhandles);
    return;
end


%% compute phase parameter
fid_length=length(squeeze(temp.real(1,:))'); %=mainhandles.datalist(dataidx).np/2;
t_vec = (0:(fid_length-1))./mainhandles.datalist(dataidx).spectralwidth;
cut = round(fid_length/2);
df_vec = 1/((t_vec(2)-t_vec(1))*fid_length);
f_vec_shifted = df_vec.*((0:fid_length-1)'-cut);
size(f_vec_shifted)
fid_length

%% apply phase and posprocessing
for k =1:mainhandles.datalist(dataidx).multiplicity
    data(k).real = squeeze(temp.real(k,1,:));
    data(k).imag = squeeze(temp.imag(k,1,:));
    phasecorr0=mainhandles.datalist(dataidx).process.phasecorr0(k);
    phasecorr1=mainhandles.datalist(dataidx).process.phasecorr1(k);
    data(k) = phasing(data(k),f_vec_shifted,phasecorr0,phasecorr1);
    data(k) = postprocessing(squeeze(data(k)),dataidx,arrayidx);
    data_sum.real(k,1,1:size(data(k).real,1))=data(k).real;
    data_sum.imag(k,1,1:size(data(k).imag,1))=data(k).imag
end

%% create new fid file
datadir_temp = mainhandles.datalist(dataidx).path;
delimit = findstr(datadir_temp,filesep);
last_delimt = delimit(size(delimit,2))
datadir=datadir_temp(1:last_delimt)

prompt={'Enter your new experiment name:'};
name='VnmrJ experiment name';
numlines=1;
defaultanswer={'name','hsv'};
newfilename=inputdlg(prompt,name,numlines,defaultanswer);
newfilename=char(newfilename);
[path name ext] = fileparts(newfilename);
if isempty(ext) || strcmp(ext,'.fid')==0
    newfilename=[name '.fid'];
end
    
comparams = mainhandles.datalist(dataidx).params;


mkdir([datadir filesep newfilename filesep])
copyfile([mainhandles.datalist(dataidx).path filesep 'procpar'],[datadir filesep newfilename]);
copyfile([mainhandles.datalist(dataidx).path filesep 'text'],[datadir filesep newfilename]);

new_file = write_varian(comparams,data_sum,newfilename,datadir);


