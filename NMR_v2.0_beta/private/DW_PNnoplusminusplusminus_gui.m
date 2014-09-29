% this is the matlab script for Yohan's special DTI images. In the call you
% have to specify the size of the data as follows: [volumes phaseencode
% steps/interleaves slices interleaves readpoints];

function [imagefft] = DW_PNnoplusminusplusminus_gui(data,sizes,params,m0,n0)
global petable
imagej = data.real + 1i*data.imag;
clear data
size(imagej)
% params.image = [0 1 1 1 1 1 1 1]';
% imagej=squeeze(imagej([1 4 5 6 7 8 9 10],:,:,:,:));
% sizes(1)=sizes(1)-2;
imrsh=reshape(imagej,sizes);
clear imagj
dims = size(imrsh);

%% flippingalternate lines
% imrsh_flip=imrsh;
% imrsh_flip(:,1:2:dims(2),:,:,:)=flipdim(imrsh(:,1:2:dims(2),:,:,:),5);
% clear imrsh


imrsh_flip_temp=imrsh;
imrsh_flip_temp(:,1:2:dims(2),:,:,:)=flipdim(imrsh(:,1:2:dims(2),:,:,:),5);
clear imrsh

if strcmp(params.navigator{1},'y')==1
    navigator = imrsh_flip_temp(:,1:2,:,:,:);
    imrsh_flip = (imrsh_flip_temp(:,3:(size(imrsh_flip_temp,2)),:,:,:));
    dims(2)=dims(2)-2;
else
    imrsh_flip=imrsh_flip_temp;
end
clear imrsh_flip_temp



%% reordering interleaves

% imagereshapedinter=zeros(dims(1),sizes(3),dims(2)*dims(4),dims(5));

petable2=char(params.petable{1});

imagereshapedinter=reshape(permute(imrsh_flip,[1 3 2 4 5]),[dims(1) sizes(3) dims(2)*dims(4) dims(5)]);
% petable=petable-min(petable)+1;
[B, IX] = sort(petable);
imagereshapedinter = imagereshapedinter(:,:,IX,:);
%%
%
% figure(5)
% for k=1:10
%     subplot(2,5,k), imagesc(abs(squeeze(imagereshapedinter(2,k,:,:))))
%     colormap(gray)
% end
%
%
%
%% baseline correction

imagereshapedinter = bslcorr_diffnoplusminus(imagereshapedinter);


%% reference scans
zerophase = imagereshapedinter(1,:,:,:);   % reference scans positive readouts

imagereshapedinter = imagereshapedinter(2:dims(1),:,:,:);  % image data postive readouts

zerophase = repmat(zerophase,[size(imagereshapedinter,1) 1 1 1]);

zerophasefft = fftshift(fft(fftshift(zerophase,4),[],4),4);
imrsh_flip_fft = fftshift(fft(fftshift(imagereshapedinter,4),[],4),4);

imrsh_proj = imrsh_flip_fft.*exp(-i*angle(zerophasefft));
%         for av = 1: size(imrsh_proj,1)
%             for sl = 1: size(imrsh_proj,2)
%
%                 temp=squeeze(imrsh_proj(av,sl,:,:));
%                 minim=zeros(size(imrsh_proj,3));
%                 for k = 1:size(imrsh_proj,3)
%                     index=0;
%                     for m = (-pi()/4):(pi()/80):(pi()/4)
%                         index=index+1;
%                         temp(k,:)=imrsh_proj(av,sl,k,:).*exp(-sqrt(-1)*m);
%                         imageff = (fftshift(fft(fftshift(temp,1),[],1),1));
% %                         figure(1)
% %                         imagesc(abs(imageff),[0 1/3*max(max(imageff))])
% %                         colormap('gray')
%                         S(index) = entropy(imageff);
%                     end
%
%                     [a b] = min(S);
%                     minim(k) = b*pi()/80-pi()/4;
%                     temp(k,:)=imrsh_proj(av,sl,k,:).*exp(-sqrt(-1)*minim(k));
%                 end
%                 imrsh_proj(av,sl,:,:)=temp;
%                 temp=zeros(size(squeeze(imrsh_proj(av,sl,:,:))));
%             end
%
%         end
%
% end

%% FFT bit
%imagefft = abs(fftshift(fftshift(fft(fft(fftshift(fftshift(imagereshapedinter(:,:,1:4:128,:),3),4),[],3),[],4),3),4));
% above : fft in 2 dimensions. Not necessary after ghost correction with
% reference scans

% imrsh_proj=mean(imrsh_proj,1);
% imrsh_projN=mean(imrsh_projN,1);
imagefft = fftshift(fft(fftshift(imrsh_proj,3),[],3),3);

resultp = abs(imagefft);
resultp1 = abs(mean(imagefft,1));
for imagesn=1:size(imagefft,1)
    for slice=1:sizes(3)
        imagefft(imagesn,slice,:,:) = imagefft(imagesn,slice,:,:)*exp(-1i*(angle(mean(mean(squeeze(imagefft(imagesn,slice,:,:)))))));
    end;
end;

resultp2 = (mean(imagefft,1));
% figure(1)
% colormap('gray')
% for k=1:sizes(3)
%     subplot(2,ceil(sizes(3)/2),k)
%     imagesc(squeeze(abs(resultp2(1,k,:,:))),[0 1/2*max(max(squeeze(abs(imagefft(1,k,:,:)))))]);
%     axis off
% end;
