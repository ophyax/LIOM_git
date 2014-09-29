function initialize_dataselect(hObject,varargin)

handles = guidata(hObject);
mainhandles = guidata(findobj('Tag','mainmenu'));
%% debugging
% mainhandles.switch.phasecorrection=1;
% mainhandles.switch.apodization=1;
% mainhandles.switch.transformsize=0;
% mainhandles.switch.lsfid=1;
% mainhandles.switch.dcoffset=1;
% mainhandles.switch.b0=0;
% mainhandles.switch.ECC=0;

%% --- get varargin
%% variable----------------------------------------------------------------
%% --
if ~isempty(varargin)
    if size(varargin{1},2)==2
    handles.called = varargin{1}{1};  %keep trace from which function it was called
    handles.multiplicity = varargin{1}{2}; %number of spectra in the array
    elseif size(varargin{1},2)==3
     handles.called = varargin{1}{1};  %keep trace from which function it was called
     handles.multiplicity = varargin{1}{2}; %number of spectra in the array
    handles.called2 = varargin{1}{3}; %keep trace from which function it was called
        elseif size(varargin{1},2)==4
     handles.called = varargin{1}{1};  %keep trace from which function it was called
     handles.multiplicity = varargin{1}{2}; %number of spectra in the array
    handles.called2 = varargin{1}{3}; %keep trace from which function it was called
    handles.old_sel = varargin{1}{4}; %keep trace from which function it was called
    else
        close(hObject)
        return;
        
    end
else
        close(hObject)
        return;  
end


% bachup switches
handles.switch=mainhandles.switch;

%% --- prepare text of the listbox---------------------------------------

string_listbox=num2str([1:handles.multiplicity]');
set(handles.listbox,'String',string_listbox);


if strcmp(handles.called,'b0')
   set(handles.listbox,'Max',1); %only one spectra selected
   set(handles.pushbutton_all,'Visible','off');

   set(get(handles.uipanel2,'Children'),'Enable','off')
   
   set(handles.checkbox_norm,'Visible','off');
   set(handles.checkbox_lsfid,'Enable','off');
%    set(handles.axes1,'Visible','on');
 if isfield(handles,'called2')
     switch handles.called2
         case 'autophase'
             method = {'Peak max' 'Comp to  abs' 'Entropy'};
             set(handles.popupmenu_method,'String',method)
             set(handles.popupmenu_method,'Visible','on')
     end
 end

elseif strcmp(handles.called,'add')
    set(handles.uipanel_timecourse,'Visible','on');
    handles.switch.normalization=0;
    handles.switch.timecourse=handles.multiplicity;
   set(handles.checkbox_norm,'Visible','on');
    set(handles.listbox,'Max',handles.multiplicity);
    set(handles.listbox,'Value',1:handles.multiplicity);
elseif strcmp(handles.called,'raw')
    set(handles.uipanel_timecourse,'Visible','off');
%     handles.switch.normalization=0;
   set(handles.checkbox_norm,'Visible','off');
    set(handles.listbox,'Max',handles.multiplicity);
    set(handles.listbox,'Value',1:handles.multiplicity);
elseif strcmp(handles.called,'fid2RAW')
    set(handles.uipanel_timecourse,'Visible','off');
    handles.switch.lsfid=1;
    handles.switch.normalization = mainhandles.switch.normalization;
   set(handles.checkbox_norm,'Visible','on');
   set(handles.listbox,'String','All spectra');
   set(handles.listbox,'Enable','off');
   set(get(handles.uipanel2,'Children'),'Enable','off')
   set(handles.checkbox_norm,'Value',handles.switch.normalization);
    set(handles.listbox,'Max',handles.multiplicity);
elseif strcmp(handles.called,'Temp')
    set(handles.uipanel_timecourse,'Visible','off');
    if strcmp(handles.called2,'sel')
        set(handles.text_title,'String','Select data to process')
    handles.switch.normalization=0;
   set(handles.checkbox_norm,'Visible','on');
    set(handles.listbox,'Max',handles.multiplicity);
    set(handles.listbox,'Value',1:handles.multiplicity);    
    elseif strcmp(handles.called2,'ref')
         string_listbox=num2str(handles.old_sel');
        set(handles.listbox,'String',string_listbox);
        set(handles.text_title,'String','Select reference spectra for peak selction')
        set(handles.listbox,'Max',1); %only one spectra selected
        set(handles.listbox,'Value',ceil(handles.multiplicity/2));
        set(handles.pushbutton_all,'Visible','off');
         set(get(handles.uipanel2,'Children'),'Enable','off')
        set(handles.checkbox_norm,'Visible','off');
        set(handles.checkbox_lsfid,'Enable','off');
    end
elseif strcmp(handles.called,'BISEP')
    set(handles.uipanel_timecourse,'Visible','on');
    set(handles.uipanel_timecourse,'Visible','on');
    set(handles.checkbox_norm,'Visible','on');
    set(handles.listbox,'Max',handles.multiplicity);
    if strcmp(handles.called2,'pos')
        set(handles.text_title,'String','Select positive spectra')
        handles.switch.normalization=1;
        handles.switch.timecourse=1;
        set(handles.listbox,'Value',1:2:handles.multiplicity);  
    elseif strcmp(handles.called2,'neg')
       set(handles.text_title,'String','Select negative spectra')
       set(handles.listbox,'Value',2:2:handles.multiplicity);  
    end
    
else
    set(handles.checkbox_norm,'Visible','off');
    set(handles.listbox,'Max',handles.multiplicity);
end

if handles.multiplicity==1
%     set(handles.listbox,'Enable','off')
    set(get(handles.uipanel2,'Children'),'Enable','off')
    set(handles.pushbutton_all,'Visible','off');
end

%% ----- initialize siwtch----------------------------------
%  mainhandles.switch
if mainhandles.switch.phasecorrection==1;
        set(handles.checkbox_phase,'Value',1)
else
    set(handles.checkbox_phase,'Value',0);
end

if mainhandles.switch.apodization==1;
        set(handles.checkbox_apodization,'Value',1)
else
    set(handles.checkbox_apodization,'Value',0);
end

if mainhandles.switch.transformsize==1;
    
            set(handles.checkbox_transfromize,'Value',1)
else
    set(handles.checkbox_transfromize,'Value',0);
end

if mainhandles.switch.lsfid==1;
        set(handles.checkbox_lsfid,'Value',1)
else
    set(handles.checkbox_lsfid,'Value',0);
end

if mainhandles.switch.dcoffset==1;
        set(handles.checkbox_dcoffset,'Value',1)
else
    set(handles.checkbox_dcoffset,'Value',0);
end

if mainhandles.switch.b0==1;
        set(handles.checkbox_b0,'Value',1)
else
    set(handles.checkbox_b0,'Value',0);
end

if isfield(mainhandles.switch,'timecourse')
    set(handles.edit_timecourse,'String',num2str(mainhandles.switch.timecourse))
end

if isfield(mainhandles.switch,'method')
   method=cellstr(get(handles.popupmenu_method,'String'));
    if sum(strcmp(method,mainhandles.switch.method))==1
        
        method_idx = find(strcmp(method,mainhandles.switch.method)==1);
    else
        method_idx=1;
    end
    set(handles.popupmenu_method,'Value',method_idx)
end


%% Disable display

set(handles.axes1,'Visible','off');



guidata(hObject, handles);