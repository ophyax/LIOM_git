function sessionlog=write_sessionlog(handles)

sessionlog.startpath=handles.startpath;
% --- lcmodel
if isfield(handles,'lcmodel')
    sessionlog.lcmodel=handles.lcmodel;
end
%--- studyreport
if isfield(handles,'studyreport')
    sessionlog.studyreport = handles.studyreport;
end
if isfield(handles,'options')
    sessionlog.options = handles.options;
end

% [private_path, filename, extension, versn] = fileparts(which('close_exit.m'));
% save([private_path '\session_log.mat'],'sessionlog')
 if ~isdir([handles.homedir [filesep 'private' filesep]])
     mkdir([handles.homedir [filesep 'private' filesep]])
 end
save([handles.homedir [filesep 'private' filesep 'session_log.mat']],'sessionlog')