function data = multiplicity_varian(data, params, filename, file_ext)
% resort data according to FID, MRI or CSI data

global petable
% params.seqcon{1}
% params.apptype{1}
data.multiplicity=0;
data.acqtype='';
if isfield(params,'nv')==0
    params.nv=0;
end
disp([params.seqfil{1} params.time_run{1}])

switch lower(file_ext)
    case{'fid'}
        if isfield(params,'nv') && params.acqdim==1
               if params.nv>1
                   params.acqdim=2;
               end
        end
        % 1. determine mulitplictiy & acqtype
        if params.acqdim==1  % FID
            data.acqtype='MRS';
%             data.multiplicity=1;
            data.multiplicity = params.arraydim;%size(params.nt,1);
%             if data.multiplicity ~= data.header.file.ntraces
%                 data.multiplicity = data.header.file.ntraces;
%             end
        elseif params.acqdim==2
            if params.nv==0 % apptype='prescan_ex' & seqfil='prescanfreq'
                data.multiplicity=1;
                if params.ns==0
                    data.acqtype='MRS: fastmap';
                elseif params.ns==1
                    data.acqtype='MRS: prescan_ex (mems)';
                else
                    data.acqtype='MRS: prescan w/o PE';
                end
            elseif params.nv==1 % (apptype='prescan_ex' OR 'imFM') & (seqfil='mems' OR 'fastestmap')
                data.multiplicity=1;
                if params.ns==1
                    data.acqtype='prescan_ex: mems';
                else
                    data.acqtype='prescanfreq with PE';
                end
                if data.header.file.ntraces<=1 && data.header.file.nblocks>1
                    data.multiplictiy=data.header.file.nblocks;
                end
            elseif params.nv>=2 % images=MRI
                data.acqtype='MRI';
                if params.nv~=data.header.file.ntraces
                    data.multiplicity=data.header.file.ntraces/params.nv;
%                     if ~isempty((strcmp(data.pslabel,'sems')))||~isempty((strcmp(data.pslabel,'mems')))||~isempty((strcmp(data.pslabel,'ck_diff')))
                    if (~isempty(cell2mat(strfind(data.pslabel,'sems')))||~isempty(cell2mat(strfind(data.pslabel,'mems')))||~isempty(cell2mat(strfind(data.pslabel,'ck_diff'))))...
                            &&isempty(cell2mat(strfind(data.pslabel,'fsems')))
                        data.multiplicity = data.header.file.ntraces;
                    elseif ~isempty(cell2mat(strfind(data.pslabel,'scout')))
                        data.multiplicity=data.multiplicity*params.arraydim;
                    end
                else
                    data.multiplicity = data.header.file.nblocks;
                    if ~isempty(cell2mat(strfind(data.pslabel,'epi')))
                        data.multiplicity = params.ns;
                    end
                end
            else
                disp('!!! resorting of data fails: acqtype and multiplicity could not be determined !!!')
            end
        elseif params.acqdim >= 3 % spectroscopic imaging = CSI
            if params.nv >= 2 % CSI
                data.acqtype='CSI';
                data.multiplicity = data.header.file.nblocks*params.nv;
            else
                if params.nv==0
                    data.acqtype='CSI';
                    data.multiplicity = data.header.file.nblocks*1;
                else
                    disp('resorting of data fails: appropriate acquistion mode not defined')
                end
            end
        end
        if data.multiplicity==0
            disp({'resorting of data failed: appropriate multiplictiy could not be determined';...
                ['file : ' filename]});
            return
        elseif strcmp(data.acqtype,'')==1
            disp('resorting of data failed: appropriate acquistion mode could not be determined')
            return
        end
       %% case fdf
    case {'fdf'}
        data.acqtype='MRI';
        data.multiplicity=1;
end