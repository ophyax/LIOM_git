function close_exit(handles)

% eventually save some settings or whatever
disp('Please wait: .... closing ....')
% ---
write_sessionlog(handles);

%% delete created LCModel files
% % if isfield(handles,'lcmodel') && isfield(handles.lcmodel,'cur_controlfile') && ...
% %         isempty(handles.lcmodel.cur_controlfile)==0 && ...
% %         (length(handles.lcmodel.cur_controlfile)==1 && strcmp(handles.lcmodel.cur_controlfile{1},'Control file')==1)==0
% % %     if length(handles.lcmodel.cur_controlfile)==1 && strcmp(handles.lcmodel.cur_controlfile{1},'Control file')==1
% % %         break
% % %     end
% %     answer=questdlg({'There were LC Model files created.';'Should they be deleted?'},'Delete files?','No','Yes','No');
% %     if strcmp(answer,'Yes')
% %         for i=1:length(handles.lcmodel.cur_controlfile)
% %             [path fname ext]=fileparts(handles.lcmodel.cur_controlfile{i});
% %             if strcmp(path(length(path)),'\')==0
% %                 path=[path '\'];
% %             end
% %             if exist([path fname ext],'file')
% %                 delete([path fname ext])
% %             end
% %             if exist([path fname '.RAW'],'file')
% %                 delete([path fname '.RAW'])
% %             end
% %             if exist([path fname '.PLOTIN'],'file')
% %                 delete([path fname '.PLOTIN'])
% %             end
% %         end
% %         d=dir(path);
% %         if strcmp([d.name],'...')
% %             rmdir(path);
% %         end
% %     end
% % end


%% find all other GUI related to NMR_eval and
delete(findobj('Tag','GUI_Combine'))
delete(findobj('Tag','lcmodelfig'))
if isfield(handles.switch,'close')
    if ~strcmp(handles.switch.close,'ImageOrientation')
        delete(findobj('Tag','GUI_ImageOrientation'))
    end
else
    delete(findobj('Tag','GUI_ImageOrientation'))
end
delete(findobj('Tag','dataselect'))
delete(findobj('Tag','GUI_options_fig'))
delete(findobj('Tag','GUI_Combine'))
delete(findobj('Tag','ROI_manager'))
delete(findobj('Tag','Save_gui'))
delete(findobj('Tag','Parameterlistfig'))
delete(findobj('Tag','processfig'))
delete(findobj('Tag','filelistfig'))
delete(findobj('Tag','lcmodelfig'))

delete(findobj('Tag','mainmenu')) % closes the figure

disp('.... good bye')