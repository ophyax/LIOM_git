function ImageOrient_AdjustSliders(varargin)

handles=guidata(findobj('Tag','GUI_ImageOrientation'));

old_idx = [get(handles.slider_Axial,'Value')
    get(handles.slider_Coronal,'Value')
    get(handles.slider_Sagittal,'Value')];
new_idx = old_idx;

if ~isempty(varargin)
    disp(varargin{1})
    called=varargin{1};
    %    SET SLIDER VALUE TO VALUE ALWAYS OK
    set(handles.slider_Axial,'Value',1);
    set(handles.slider_Coronal,'Value',1);
    set(handles.slider_Sagittal,'Value',1);
    
    switch called
        case 'perm_AS'
            new_idx=old_idx([3 2 1]);
            handles.data.orientation={handles.data.orientation{1,[3 2 1]}};
        case 'perm_SC'
            new_idx=old_idx([1 3 2]);
            handles.data.orientation={handles.data.orientation{1,[1 3 2]}};
        case 'perm_CA'
            new_idx=old_idx([2 1 3]);
            handles.data.orientation={handles.data.orientation{1,[2 1 3]}};
        case 'A_rot90CW'
            new_idx=old_idx([1 3 2]);
            new_idx(3)=size(handles.data.data.image,3)-new_idx(3)+1;
            handles.data.orientation={handles.data.orientation{1,[1 3 2]}};
        case 'A_rot90CCW'
            new_idx=old_idx([1 3 2]);
            new_idx(2)=size(handles.data.data.image,2)-new_idx(2)+1;
            handles.data.orientation={handles.data.orientation{1,[1 3 2]}};
        case {'A_flipvert','C_flipvert'}
            new_idx(3)=size(handles.data.data.image,3)-old_idx(3)+1;
        case {'A_fliphoriz','S_fliphoriz'}
            new_idx(2)=size(handles.data.data.image,2)-old_idx(2)+1;
        case 'C_rot90CW'
            new_idx=old_idx([3 2 1]);
            new_idx(1)=size(handles.data.data.image,1)-new_idx(1)+1;
            handles.data.orientation={handles.data.orientation{1,[3 2 1]}};
        case 'C_rot90CCW'
            new_idx=old_idx([3 2 1]);
            new_idx(3)=size(handles.data.data.image,3)-new_idx(3)+1;
            handles.data.orientation={handles.data.orientation{1,[3 2 1]}};
        case {'C_fliphoriz','S_flipvert'}
            new_idx(1)=size(handles.data.data.image,1)-old_idx(1)+1;
        case 'S_rot90CCW'
            new_idx=old_idx([2 1 3]);
            new_idx(1)=size(handles.data.data.image,1)-new_idx(1)+1;
            handles.data.orientation={handles.data.orientation{1,[2 1 3]}};
        case 'S_rot90CW'
            new_idx=old_idx([2 1 3]);
            new_idx(2)=size(handles.data.data.image,2)-new_idx(2)+1;
            handles.data.orientation={handles.data.orientation{1,[2 1 3]}};
        otherwise
            new_idx = old_idx;
    end
    
    
%     if isfield(handles.data,'gradsheme')
%         switch called
%             
%             case 'perm_AS'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[3 2 1]);
%             case 'perm_SC'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[1 3 2]);
%             case 'perm_CA'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[2 1 3]);
%             case 'A_rot90CW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[1 3 2]);
%                 handles.data.gradsheme(:,3)=-handles.data.gradsheme(:,3);
%             case 'A_rot90CCW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[1 3 2]);
%                 handles.data.gradsheme(:,2)=-handles.data.gradsheme(:,2);              
%             case {'A_flipvert','C_flipvert'}
%                 handles.data.gradsheme(:,3)=-handles.data.gradsheme(:,3);
%             case {'A_fliphoriz','S_fliphoriz'}
%                 handles.data.gradsheme(:,2)=-handles.data.gradsheme(:,2);
%             case 'C_rot90CW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[3 2 1]);
%                 handles.data.gradsheme(:,1)=-handles.data.gradsheme(:,1); 
%             case 'C_rot90CCW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[3 2 1]);
%                 handles.data.gradsheme(:,3)=-handles.data.gradsheme(:,3); 
%             case {'C_fliphoriz','S_flipvert'}
%                 handles.data.gradsheme(:,1)=-handles.data.gradsheme(:,1);
%             case 'S_rot90CCW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[2 1 3]);
%                 handles.data.gradsheme(:,1)=-handles.data.gradsheme(:,1); 
%             case 'S_rot90CW'
%                 handles.data.gradsheme=handles.data.gradsheme(:,[2 1 3]);
%                 handles.data.gradsheme(:,2)=-handles.data.gradsheme(:,2); 
%         end
%     end
    
    
end
% disp('AdjustSliders')
% disp([handles.data.orientation{1,:}])
% disp(size(handles.data.data.image))
dime=size(handles.data.data.image);
% idx=find(dime==1);
% if ~isempty(idx)
%     
% end
new_idx=round(new_idx);
set(handles.slider_Axial,'Min',0.99)
set(handles.slider_Axial,'Max',dime(1))
set(handles.slider_Axial,'SliderStep',[(1/(get(handles.slider_Axial,'Max'))) 0.2])
set(handles.slider_edit_A_current,'String',new_idx(1))
set(handles.slider_text_A_end,'String',dime(1))
set(handles.slider_Axial,'Value',new_idx(1));

set(handles.slider_Coronal,'Min',0.99);
set(handles.slider_Coronal,'Max',dime(2));
set(handles.slider_Coronal,'SliderStep',[(1/(get(handles.slider_Coronal,'Max'))) 0.2]);
set(handles.slider_edit_C_current,'String',new_idx(2))
set(handles.slider_text_C_end,'String',dime(2))
set(handles.slider_Coronal,'Value',new_idx(2));

set(handles.slider_Sagittal,'Min',0.99);
set(handles.slider_Sagittal,'Max',dime(3));
set(handles.slider_Sagittal,'SliderStep',[(1/(get(handles.slider_Sagittal,'Max'))) 0.2]);
set(handles.slider_edit_S_current,'String',new_idx(3))
set(handles.slider_text_S_end,'String',dime(3))
set(handles.slider_Sagittal,'Value',new_idx(3));


set(handles.dims_text_curpos,'String',['Pos: ' num2str(new_idx(1)) 'x' num2str(new_idx(2)) 'x' num2str(new_idx(3))])

guidata(findobj('Tag','GUI_ImageOrientation'),handles);