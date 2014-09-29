function save_open_mainhandles(varargin)

mainhandles=guidata(findobj('Tag','mainmenu'));

if length(varargin)==1
    fun = varargin{1}; %save / load
    study_path=[];
elseif length(varargin)==2
    fun = varargin{1}; %save / load
    study_path = varargin{2}; % study path
elseif length(varargin)==3
end



switch fun
    case 'save'
        
        s_mainhandles.lcmodel = mainhandles.lcmodel;
        s_mainhandles.dispopts = mainhandles.dispopts;
        s_mainhandles.switch = mainhandles.switch;
        s_mainhandles.options = mainhandles.options;
        s_mainhandles.process = mainhandles.process;
        s_mainhandles.datapath = mainhandles.datapath;
        s_mainhandles.datalist = mainhandles.datalist;
        s_mainhandles.liststr_expanded = mainhandles.liststr_expanded;
        if ~ischar(study_path)
            [study_name study_path] = uiputfile('.mat');
        else
            [study_path study_name  ext] = fileparts(study_path);
            study_name = [study_name ext];
        end
            
        save([study_path filesep study_name], 's_mainhandles') 
           
    case 'load'
        if ~ischar(study_path)
            [study_name study_path] = uigetfile('.mat','MultiSelect','on');
            if ~iscell(study_name)
                study_name={study_name};
            end
        else
            [study_path st_name  ext] = fileparts(study_path);
            study_name={[st_name ext]};
        end

      
        for i=1:length(study_name)
                load([study_path filesep study_name{i}]);
            if ~isfield(mainhandles,'datalist')
                mainhandles.lcmodel = s_mainhandles.lcmodel;
                mainhandles.dispopts = s_mainhandles.dispopts;
                mainhandles.switch = s_mainhandles.switch;
                mainhandles.options = s_mainhandles.options;
                mainhandles.process = s_mainhandles.process;
                mainhandles.datapath = s_mainhandles.datapath;
                mainhandles.datalist = s_mainhandles.datalist;
                mainhandles.liststr_expanded = s_mainhandles.liststr_expanded;
            else
                mainhandles.datapath = [mainhandles.datapath pathsep s_mainhandles.datapath];
                s_datal=length(s_mainhandles.datalist);
                datal=length(mainhandles.datalist);
                mainhandles.datalist((datal+1):(datal+s_datal)) = s_mainhandles.datalist(:);
                mainhandles.liststr_expanded = [mainhandles.datapath pathsep s_mainhandles.liststr_expanded]; 
            end
        
        guidata(findobj('Tag','mainmenu'),mainhandles);
        end
end