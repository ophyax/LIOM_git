function answr=questdlg4(Question,Title,Btn1,Btn2,Btn3,Btn4,Default)
fig = figure('Name', Title,'Tag','questfig',...
            'Color',[0.9 0.9 0.9],...
            'NumberTitle','off',...
            'Resize','off',...
            'WindowStyle','modal',...
             'Units','normalized','Position',[0.4 0.3 0.25 0.15],...
            'HandleVisibility','callback','KeyPressFcn',{@keypress_callback},...
            'DeleteFcn',{@delete_callback});
questtext = uicontrol('Style','text','String',Question,'Tag','questtext',...
    'Parent',fig,'Units','normalized','HorizontalAlignment','center',...
    'FontSize',12,'Position',[0.1 0.5 0.8 0.3]);%,Default);

but1 = uicontrol('Style','pushbutton','String',Btn1,'Tag','Btn1',...
    'Parent',fig,'Units','normalized','HorizontalAlignment','center',...
    'FontSize',10,'Position',[0.025 0.1 0.2 0.2],'Callback',{@button_callback});
but2 = uicontrol('Style','pushbutton','String',Btn2,'Tag','Btn2',...
    'Parent',fig,'Units','normalized','HorizontalAlignment','center',...
    'FontSize',10,'Position',[0.275 0.1 0.2 0.2],'Callback',{@button_callback});
but3 = uicontrol('Style','pushbutton','String',Btn3,'Tag','Btn3',...
    'Parent',fig,'Units','normalized','HorizontalAlignment','center',...
    'FontSize',10,'Position',[0.525 0.1 0.2 0.2],'Callback',{@button_callback});
but4 = uicontrol('Style','pushbutton','String',Btn4,'Tag','Btn4',...
    'Parent',fig,'Units','normalized','HorizontalAlignment','center',...
    'FontSize',10,'Position',[0.775 0.1 0.2 0.2],'Callback',{@button_callback});
% fig = gcbf;
data.default = {Default};
data.answr = {''};
set(fig,'UserData',data);

uiwait(fig)
% fig = gcbf;$
try
data = get(fig,'UserData');
answr = data.answr{1};
delete(fig)
catch
    answr='';
end
    


function delete_callback(hObject,eventdata)
fig = gcbf;
% data = get(fig,'UserData');
data.answr = {''};
answr = data.answr{1};
set(fig,'UserData',data);
% uiresume(fig)

function keypress_callback(hObject,eventdata)
fig = gcbf;
% handles = guidata(findobj('Tag','questfig'));
    key = get(findobj('Tag','questfig'),'CurrentCharacter');
    if isempty(key)
        return
    end
    switch double(key)
        case {3,13} %return
        data = get(fig,'UserData');
        data.answr = data.default;
        set(fig,'UserData',data);
           uiresume(fig)
    end


function button_callback(hObject,eventdata)
fig = gcbf;
answr = get(hObject,'String');
data = get(fig,'UserData');
data.answr = {answr};
set(fig,'UserData',data);
uiresume(fig)
