function out = login(cmd)
%LOGIN Creates login dialog box asking for userid and password.
%   LOGIN returns a cell array containing the userid and password
%   typed in by the user.  The current field is selected by pressing
%   the space bar or tab key.

% written by Douglas M. Schwarz
% Eastman Kodak Company
% douglas.schw...@kodak.com
% 17 January 2001
% 26 October 2009 Ruud van Heeswijk removed space bar field functionality

if nargin == 0
    cmd = 'init';
end
switch cmd
case 'init'
    pos = centerfig(200,120);
    fig = figure('Position',pos,...
            'Color',[0.7 0.7 0.7],...
            'NumberTitle','off',...
            'Resize','off',...
            'WindowStyle','modal',...
            'KeyPressFcn',[mfilename,' key']);
    uicontrol('Style','text',...
            'Position',[20 80 160 20],...
            'BackgroundColor',[0.7 0.7 0.7],...
            'String','Enter User ID:',...
            'HorizontalAlignment','left');
    info.disp(1) = uicontrol('Style','edit',...
            'Position',[20 60 160 20],...
            'BackgroundColor','w',...
            'Enable','inactive',...
            'HorizontalAlignment','left');
    uicontrol('Style','text',...
            'Position',[20 40 160 20],...
            'BackgroundColor',[0.7 0.7 0.7],...
            'String','Enter Password:',...
            'HorizontalAlignment','left');
    info.disp(2) = uicontrol('Style','edit',...
            'Position',[20 20 160 20],...
            'BackgroundColor',[0.7 0.7 0.7],...
            'Enable','inactive',...
            'HorizontalAlignment','left');
    info.str = {'',''};
    info.secret = [0 1];
    info.current = 1;
    if strncmpi(computer,'mac',3)
        info.bullet = char(165);
    else
        info.bullet = char(168);
        set(info.disp(2),'FontName','symbol')
    end
    curpos = get(0,'PointerLocation');
    set(0,'PointerLocation',[pos(1)+pos(3)/2,pos(2)+pos(4)])
    set(fig,'UserData',info,...
            'HandleVisibility','callback')
    uiwait(fig)
    info = get(fig,'UserData');
    out = info.str;
    set(0,'PointerLocation',curpos)
    delete(fig)
case 'key'
    fig = gcbf;
    info = get(fig,'UserData');
    key = get(fig,'CurrentCharacter');
    if isempty(key)
        return
    end
    switch double(key)
    case {9} % tab or space
        set(info.disp(info.current),'BackgroundColor',[0.7 0.7 0.7])
        info.current = rem(info.current,2) + 1;
        set(info.disp(info.current),'BackgroundColor','w')
    case 8 % delete
        if ~isempty(info.str{info.current})
            info.str{info.current}(end) = [];
        end
        if info.secret(info.current)
            set(info.disp(info.current),'String',...
                    repmat(info.bullet,1,length(info.str{info.current})))
        else
            set(info.disp(info.current),'String',info.str{info.current})
        end
    case {3,13} % return or enter (Macintosh)
        uiresume(fig)
    otherwise
        info.str{info.current} = [info.str{info.current},key];
        if info.secret(info.current)
            set(info.disp(info.current),'String',...
                    repmat(info.bullet,1,length(info.str{info.current})))
        else
            set(info.disp(info.current),'String',info.str{info.current})
        end
    end
    set(fig,'UserData',info)
end

function pos = centerfig(width,height)
%CENTERFIG calculates the Position vector to center figure on screen.
screen = get(0,'ScreenSize');
center = screen(3:4)/2;
pos = [center - [width,height]/2, width, height]; 