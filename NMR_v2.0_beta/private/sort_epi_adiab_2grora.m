function [data,params] = sort_epi_adiab_2grora(d,params)

global petable
% params.image
% size(d.real)
% params.image = [0 1 1 1 1 1 1 1 1 1]';

NumberofAverages = size(params.nt,1);
if strcmp(params.diff{1},'y')
    NDiffusion = size(params.dro,1);
else
    NDiffusion = 1;
end
numberofimages = size(params.image,1); %repetition
phaseencode = params.nv/params.nseg; %phaseencode steps/interleaves
slices = params.ns;
interleaves =params.nseg;
readpoints =params.np/2;
sizes=[NumberofAverages NDiffusion numberofimages phaseencode slices interleaves readpoints];

[corrected_mean] = DW_PNredistribute_gui(d, sizes, params);
% size(corrected_mean)
% params.ns
temp = corrected_mean(:,:,:,:,:,:);
temp = mean(temp,3);
im_average = squeeze(mean(temp,1));
% im_average = squeeze(mean(corrected_mean,1));
% size(im_average)
if length(size(im_average))==2 %1 slice and no diffusion
    temp=im_average;
    clear im_average
    im_average=zeros([1 1 size(temp)]);
    im_average(1,1,:,:)=temp;
    clear temp
elseif length(size(im_average))==3 %1 slice or 1 diffusion
    temp=im_average;
    clear im_average
    dime = size(temp);
    if NDiffusion==1
        im_average=zeros([1 dime]);
        im_average(1,:,:,:)=temp;
    else
        im_average=zeros([dime(1) 1 dime(2:3)]);
        im_average(:,1,:,:)=temp;
    end
    clear temp
end
disp('stop')
% figure(1)
% imagesc(abs(squeeze(im_average(1,2,:,:))))
% im_average = ifftshift(ifft(ifftshift(im_average,3),[],3),3);
% im_average = ifftshift(ifft(ifftshift(im_average,4),[],4),4);
% 

if strcmp(params.diff{1},'y')
    grad_dir = [params.dro params.dpe params.dsl];
    
    if size(grad_dir,1)==1
        grad_idx=1;
    else
        grad_idx=2;
    end
    norm = (sqrt(sum(grad_dir(grad_idx,:).^2)));
    if norm~=0
        grad_dir = grad_dir./norm;
    else
        norm = round(sqrt(sum(grad_dir(3,:).^2)));
        grad_dir = grad_dir./norm;
    end
    bvalue = [params.bvalue];
    count=0;
    temp=[];
    for k=1:size(grad_dir,1)
        for l = 1:size(grad_dir,1)
            if k~=l
                test1 = sum(grad_dir(k,:).*grad_dir(l,:));
                if mod(test1,1)<0.01 || mod(test1,1)>0.99
                    test1 = round(test1);
                end

                if test1 == 0 && isequal(grad_dir(k,:),[0 0 0]) && isequal(grad_dir(l,:),[0 0 0])
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -1 && sum(grad_dir(k,:)==0) == sum(grad_dir(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -2 && sum(grad_dir(k,:)==0) == sum(grad_dir(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -3 && sum(grad_dir(k,:)==0) == sum(grad_dir(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                end
            end            
        end
    end
    
    if length(temp)==length(grad_dir) %opposite scheme apply
        button = questdlg('Do you want to average opposite directions?','Opposite shceme','Yes','No','Yes') ;
        if strcmp(button,'Yes')
            temp = unique(sort(temp,2),'rows');
            for k=1:length(temp)
                im_average_2(k,:,:,:)=sqrt(im_average(temp(k,1),:,:,:).*im_average(temp(k,2),:,:,:));
                grad_dir_2(k,:) = grad_dir(temp(k,1),:);
                bvalue_2(k) = (bvalue(temp(k,1))+bvalue(temp(k,2)))/2;
            end
            clear im_average params.bvalue
            im_average = im_average_2;
            params.bvalue = bvalue_2';
            params.dro = grad_dir_2(:,1);
            params.dpe = grad_dir_2(:,2);
            params.dsl = grad_dir_2(:,3);
        end
        
    else
        disp('not opposite diffsuion gradient scheme: unable to average along drad directions')
    end
    
    
    
end
% A=squeeze(im_average(temp(k,1),1,:,:).*im_average(temp(k,2),1,:,:));

%%
% disp('params.ppe')
% disp(params.ppe)
% if params.ppe ~= 0
%    shift = -round(params.ppe / (params.lpe/params.nv));
%    disp(shift)
%    dimToShift = length(size(im_average))-1;
%    shiftsize = zeros(size(size(im_average)));
%    shiftsize(dimToShift) = shift;
%    test = im_average;
%    im_average = circshift(im_average,shiftsize);
%    params.ppe=0;
%    disp(isequal(test,im_average))
% end

%% interleaved slice
% [slice order] = sort(params.pss);
% % slide_order=zeros(size(order));
% im_average_sort=zeros(size(im_average));
% if strcmp(params.diff{1}, 'y')==1
%     for i=1:slices
%         im_average_sort(:,i,:,:)=im_average(:,order(i),:,:);
%     end
% elseif strcmp(params.diff{1}, 'n')==1
%     for i=1:slices
%         im_average_sort(1,i,:,:)=im_average(1,order(i),:,:);
%     end
% end
% im_average = im_average_sort;
% parmas.pss = slice;

im_average = ifftshift(ifft(ifftshift(im_average,3),[],3),3);
im_average = ifftshift(ifft(ifftshift(im_average,4),[],4),4);



%%
% if NDiffusion>1
% im_average = squeeze(im_average);
if length(size(im_average))== 4
    data.real=flipdim(real(permute(im_average,[2 3 4 1])),3);
    data.imag=flipdim(imag(permute(im_average,[2 3 4 1])),3);
elseif length(size(im_average))== 3
    data.real=flipdim(real(im_average),3);
    data.imag=flipdim(imag(im_average),3);
elseif length(size(im_average))== 2
    data.real(1,:,:)=flipdim(real(im_average),2);
    data.imag(1,:,:)=flipdim(imag(im_average),2);
end



