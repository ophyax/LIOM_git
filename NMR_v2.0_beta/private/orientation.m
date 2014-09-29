function img_orient = orientation(img,called)
h = waitbar(0,'Wait performing rotation,...');
if length(size(img))==2
    temp(1,:,:)=img;
    img=temp;
    clear temp
end
img_orient=zeros(size(img));
temp=zeros(size(img));
if length(size(img))==3
    switch called
        case 'perm_AS'
            img_orient = permute(img,[3 2 1]);
        case 'A_rot90CW' 
%             img_orient=permute(img_orient,[1 3 2]);
            temp=permute(temp,[1 3 2]);
            for i = 1:size(img,1)
                waitbar(i/size(img,1))
                temp(i,:,:) = rot90(squeeze(img(i,:,:)),-1);
            end
            img_orient = temp;
        case 'A_rot90CCW'
%             img_orient=permute(img_orient,[1 3 2]);
            temp=permute(temp,[1 3 2]);
            for i = 1:size(img,1)
                waitbar(i/size(img,1))
                temp(i,:,:) = rot90(squeeze(img(i,:,:)),1);
            end
            img_orient = temp;
        case 'A_flipvert'
            img_orient = flipdim(img,3);
        case 'A_fliphoriz'
            img_orient = flipdim(img,2);
        case 'perm_SC'
            img_orient = permute(img,[1 3 2]);
        case 'C_rot90CW'
%             img_orient=permute(img_orient,[3 2 1]);
            temp=permute(temp,[3 2 1]);
            for i = 1:size(img,2)
                waitbar(i/size(img,2))
                temp(:,i,:) = rot90(squeeze(img(:,i,:)),-1);
            end
            img_orient = temp;
        case 'C_rot90CCW'
%             img_orient=permute(img_orient,[3 2 1]);
            temp=permute(temp,[3 2 1]);
            for i = 1:size(img,2)
                            
                waitbar(i/size(img,2))
                temp(:,i,:) = rot90(squeeze(img(:,i,:)),1);
            end
            img_orient = temp;
        case 'C_flipvert'
            img_orient = flipdim(img,3);
        case 'C_fliphoriz'
            img_orient = flipdim(img,1);
        case 'perm_CA'
            img_orient = permute(img,[2 1 3]);
        case 'S_rot90CCW'
%             img_orient=permute(img_orient,[2 1 3]);
            temp=permute(temp,[2 1 3]);
            for i = 1:size(img,3)
                            
                waitbar(i/size(img,3))
                temp(:,:,i) = rot90(squeeze(img(:,:,i)),-1);
            end
            img_orient = temp;
        case 'S_rot90CW'
%             img_orient=permute(img_orient,[2 1 3]);
            temp=permute(temp,[2 1 3]);
            for i = 1:size(img,3)
                waitbar(i/size(img,3))
                temp(:,:,i) = rot90(squeeze(img(:,:,i)),1);
            end
            img_orient = temp;
        case 'S_flipvert'
            img_orient = flipdim(img,1);
        case 'S_fliphoriz'
            img_orient = flipdim(img,2);
    end
elseif length(size(img))==4
    switch called
        case 'perm_AS'
            img_orient = permute(img,[3 2 1 4 ]);
        case 'A_rot90CW'
%             img_orient=permute(img_orient,[1 3 2 4]);
            temp=permute(temp,[1 3 2 4]);
            for k=1:size(img,4)
                for i = 1:size(img,1)
                    waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,1)))
                    temp(i,:,:,k) = rot90(squeeze(img(i,:,:,k)),-1);
                end
            end
            img_orient = temp;        
        case 'A_rot90CCW'
%             img_orient=permute(img_orient,[1 3 2 4]);
            temp=permute(temp,[1 3 2 4]);  
            for k=1:size(img,4)
                for i = 1:size(img,1)
                    waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,1)))
                    temp(i,:,:,k) = rot90(squeeze(img(i,:,:,k)),1);
                end
            end
            img_orient = temp;
        case 'A_flipvert'
            img_orient = flipdim(img,3);
        case 'A_fliphoriz'
            img_orient = flipdim(img,2);
        case 'perm_SC'
            img_orient = permute(img,[1 3 2 4]);
        case 'C_rot90CW'
%             img_orient=permute(img_orient,[3 2 1 4]);
            temp=permute(temp,[3 2 1 4]);
            for k=1:size(img,4)
                for i = 1:size(img,2)
                    waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,2)))
                    temp(:,i,:,k) = rot90(squeeze(img(:,i,:,k)),-1);
                end
            end
            img_orient = temp;
        case 'C_rot90CCW'  
%             img_orient=permute(img_orient,[3 2 1 4]);
            temp=permute(temp,[3 2 1 4]);
            for k=1:size(img,4)
                for i = 1:size(img,2)
                    waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,2)))
                    temp(:,i,:,k) = rot90(squeeze(img(:,i,:,k)),1);
                end
            end
            img_orient = temp;
        case 'C_flipvert'
            img_orient = flipdim(img,3);
        case 'C_fliphoriz'
            img_orient = flipdim(img,1);
        case 'perm_CA'
            img_orient = permute(img,[2 1 3 4]);
        case 'S_rot90CCW'  
%             img_orient=permute(img_orient,[2 1 3 4]);
            temp=permute(temp,[2 1 3 4]);
            for k=1:size(img,4)
                for i = 1:size(img,3)
                    waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,3)))
                    temp(:,:,i,k) = rot90(squeeze(img(:,:,i,k)),-1);
                end
            end
            img_orient = temp;
        case 'S_rot90CW'
%             img_orient=permute(img_orient,[2 1 3 4]);
            temp=permute(temp,[2 1 3 4]);
            for k=1:size(img,4)
            for i = 1:size(img,3)
                waitbar((i+(k-1)*size(img,4))/(size(img,4)*size(img,3)))
                temp(:,:,i,k) = rot90(squeeze(img(:,:,i,k)),1);
            end
            end
            img_orient = temp;
        case 'S_flipvert'
            img_orient = flipdim(img,1);
        case 'S_fliphoriz'
            img_orient = flipdim(img,2);
            
    end
end
close (h)
clear temp img

