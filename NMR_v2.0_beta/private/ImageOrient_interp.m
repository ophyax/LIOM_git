function ImageOrient_interp
handles=guidata(findobj('Tag','GUI_ImageOrientation'));

old_dim=zeros([1 3]);
try
    orient = handles.data.orientation;
    for i = 1:length(orient)
        switch char(orient{i})
            case 'RO'
                old_dim(1) = size(handles.data.data.image,i);
                idx.orient(1)=i;
            case 'PE'
                old_dim(2) = size(handles.data.data.image,i);
                idx.orient(2)=i;
            case 'SS'
                old_dim(3) = size(handles.data.data.image,i);
                idx.orient(3)=i;
            otherwise
                dip('bbbbb')
                
        end
    end
catch
    dip('aaaaaa')
    old_dim=size(handles.data.data.image);
    idx.orient=[1 2 3];
end

new_dim(1) = str2double(get(handles.dims_edit_matrix_RO,'String'));
new_dim(2) = str2double(get(handles.dims_edit_matrix_PE,'String'));
new_dim(3) = str2double(get(handles.dims_edit_matrix_SS,'String'));

idx.interp = [old_dim~=new_dim];



if length(size(handles.data.data.image))==3
    % scale=64/double(max(max(max(handles.data.data.image(:,:,:)))));
    h=waitbar(0,'Wait, interpolating image,...');
    temp=handles.data.data.image;
    temp = permute(temp,idx.orient);
    button=[];
    switch sum(idx.interp)
        
        case 1
            x=find(idx.interp==1);
            z=find(idx.interp==0);
            order = [x z];
            temp = permute(temp,order);
            temp2=zeros(new_dim(order));
            
            for i = 1:size(temp,3)
                waitbar(i/size(temp,3))
                img(:,:)=squeeze(temp(:,:,i));
                temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(z(1)))',linspace(1,size(img,1),new_dim(x)),'spline');
            end
            
            clear temp img
            [a b]=sort(order);
            temp2=permute(temp2,b);
        case 2
            x=find(idx.interp==1);
            z=find(idx.interp==0);
            order = [x z];
            temp = permute(temp,order);
            
            temp2=zeros(new_dim(order));
            
            for i = 1:size(temp,3)
                waitbar(i/size(temp,3))
                img(:,:)=squeeze(temp(:,:,i));
                temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
            end
            
            clear temp img
            [a b]=sort(order);
            temp2=permute(temp2,b);
        case 3
            if isempty(button)
            button = questdlg('Do you want 2D or 3D (>>memory) interpolation','Interpolation','2D','3D','2D');
            end
            interp_ok=0;
            if ~isempty(button)
            while interp_ok==0
                switch button
                    case '2D'
                        %in plane interpolation
                        [dim order]= sort(size(temp)); %look for the smaller dim for the loop statment after
                        order = flipdim(order,2);
                        temp2=zeros([new_dim(order(1:2)) old_dim(order(3))]);
                        
                        for i = 1:size(temp,3)
                            waitbar(i/(size(temp,3)+size(temp,2)))
                            img(:,:)=squeeze(temp(:,:,i));
                            temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
                        end
                        
                        clear temp img order
                        % interpolation in the third dimension
                        smaller_dim = sort(size(temp2)); %look for the smaller dim for the loop statment after
                        order=[3 1 2];
                        temp=temp2;
                        clear temp2
                        temp = permute(temp,order);
                        temp2=zeros(new_dim(order));
                        
                        for i = 1:size(temp,3)
                            waitbar((i+size(temp,1))/(size(temp,3)+size(temp,1)))
                            img(:,:)=squeeze(temp(:,:,i));
                            temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
                        end
                        
                        clear temp img
                        [a b]=sort(order);
                        temp2=permute(temp2,b);
                        interp_ok=1;
                        
                    case '3D'
                        try
                            
                            order=[1 2 3];
                            temp2=zeros(new_dim);
                            temp2=interp3([1:size(temp,2)]',[1:size(temp,1)],[1:size(temp,3)],temp,linspace(1,size(temp,2),new_dim(order(2)))',linspace(1,size(temp,1),new_dim(order(1))),linspace(1,size(temp,3),new_dim(order(3))),'spline');
                            waitbar(1)
                            interp_ok=1;
                            
                        catch
                            disp('out of memory - switch to 2D interpolation');
                            interp_ok=0;
                            button='2D';
                        end
                end
            end
            end 
    end
    handles.data.data.image = permute(temp2,idx.orient);
    clear temp2
    close(h)
    
elseif length(size(handles.data.data.image))==4
    dime_wait =size(handles.data.data.image,4);
    button = [];
    h=waitbar(0,'Wait, interpolating image,...');
    for k=1:dime_wait
        
        %         scale=64/double(max(max(max(max(handles.data.data.image(:,:,:,:))))));
        temp=squeeze(handles.data.data.image(:,:,:,k));%.*scale;
        temp = permute(temp,idx.orient);
        
        switch sum(idx.interp)
            case 1
                x=find(idx.interp==1);
                z=find(idx.interp==0);
                order = [x z];
                temp = permute(temp,order);
                temp2=zeros(new_dim(order));
                
                for i = 1:size(temp,3)
                    waitbar((i+(k-1)*size(temp,3))/(size(temp,3)*dime_wait))
                    img(:,:)=squeeze(temp(:,:,i));
                    temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(z(1)))',linspace(1,size(img,1),new_dim(x)),'spline');
                end
               
                clear temp img
                [a b]=sort(order);
                temp2=permute(temp2,b);
            case 2
                x=find(idx.interp==1);
                z=find(idx.interp==0);
                order = [x z];
                temp = permute(temp,order);
                
                temp2=zeros(new_dim(order));
                
                for i = 1:size(temp,3)
                    waitbar((i+(k-1)*size(temp,3))/(size(temp,3)*dime_wait))
                    img(:,:)=squeeze(temp(:,:,i));
                    temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
                end
                
                clear temp img
                [a b]=sort(order);
                temp2=permute(temp2,b);
            case 3
                if isempty(button)
                button = questdlg('Do you want 2D or 3D (>>memory) interpolation','Interpolation','2D','3D','2D');
                end
                interp_ok=0;
                if ~isempty(button)
                while interp_ok==0
                    switch button
                        case '2D'
                            %in plane interpolation
                            [dim order]= sort(size(temp)); %look for the smaller dim for the loop statment after
                            order = flipdim(order,2);
                            temp2=zeros([new_dim(order(1:2)) old_dim(order(3))]);
                            
                            for i = 1:size(temp,3)
                                waitbar((i+(k-1)*size(temp,3))/((size(temp,3)+size(temp,2))*dime_wait))
                                img(:,:)=squeeze(temp(:,:,i));
                                temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
                            end
                           
                            clear temp img order
                            % interpolation in the third dimension
                            smaller_dim = sort(size(temp2)); %look for the smaller dim for the loop statment after
                            order=[3 1 2];
                            temp=temp2;
                            clear temp2
                            temp = permute(temp,order);
                            temp2=zeros(new_dim(order));
                            
                            for i = 1:size(temp,3)
                                waitbar((i+(k-1)*size(temp,3)+size(temp,1)*dime_wait)/((size(temp,1)+size(temp,2))*dime_wait))
                                img(:,:)=squeeze(temp(:,:,i));
                                temp2(:,:,i)=interp2([1:size(img,2)]',[1:size(img,1)],img,linspace(1,size(img,2),new_dim(order(2)))',linspace(1,size(img,1),new_dim(order(1))),'spline');
                            end
                           
                            clear temp img
                            [a b]=sort(order);
                            temp2=permute(temp2,b);
                            interp_ok=1;
                            
                        case '3D'
                            try
                                waitbar(1/k)
                                order=[1 2 3];
                                temp2=zeros(new_dim);
                                temp2=interp3([1:size(temp,2)]',[1:size(temp,1)],[1:size(temp,3)],temp,linspace(1,size(temp,2),new_dim(order(2)))',linspace(1,size(temp,1),new_dim(order(1))),linspace(1,size(temp,3),new_dim(order(3))),'spline');
                                
                                interp_ok=1;
                                
                            catch
                                disp('out of memory - switch to 2D interpolation')
                                interp_ok=0;
                                button='2D';
                            end
                    end
                end
                end
        end
        temp3(:,:,:,k)=permute(temp2,idx.orient);
        clear temp2
    end
    handles.data.data.image=temp3;
    clear temp3
    close(h)
end

dime=size(handles.data.data.image);

for k = 1:length(handles.data.orientation)
    switch char(handles.data.orientation{k})
        case 'RO'
            handles.data.params.np = 2*dime(k);
            set(handles.dims_edit_matrix_RO,'String',num2str(handles.data.params.np/2));
        case 'PE'
            handles.data.params.nv = dime(k);
            set(handles.dims_edit_matrix_PE,'String',num2str(handles.data.params.nv));
        case 'SS'
            handles.data.params.ns = dime(k);
            set(handles.dims_edit_matrix_SS,'String',num2str(handles.data.params.ns));
            set(handles.dims_edit_FOV_SS,'String',num2str(handles.data.params.thk/handles.data.params.ns*old_dim(3)));
    end
end


guidata(handles.GUI_ImageOrientation,handles)


