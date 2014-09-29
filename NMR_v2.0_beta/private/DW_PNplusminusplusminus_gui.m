% this is the matlab script for Yohan's special DTI images. In the call you
% have to specify the size of the data as follows: [volumes phaseencode
% steps/interleaves slices interleaves readpoints];

% function [corrected_mean, correctp, correctn] = DW_PNplusminusplusminus(data,sizes,params,m0,n0)
function [corrected_mean] = DW_PNplusminusplusminus_gui(data,sizes,params,m0,n0)

global petable
imagej = data.real + sqrt(-1)*data.imag;
clear data
imrsh=reshape(imagej,sizes);
clear imagj
dims = size(imrsh);



%% flippingalternate lines
imrsh_flip_temp=imrsh;
imrsh_flip_temp(:,1:2:dims(2),:,:,:)=flipdim(imrsh(:,1:2:dims(2),:,:,:),5);
clear imrsh

imrsh_flip=imrsh_flip_temp;

clear imrsh_flip_temp
%% reordering interleaves
imagereshapedinter=zeros(dims(1),sizes(3),dims(2)*dims(4),dims(5));

petable2=char(params.petable{1});

imagereshapedinter=reshape(permute(imrsh_flip,[1 3 2 4 5]),[dims(1) sizes(3) dims(2)*dims(4) dims(5)]);
% petable=petable-min(petable)+1;
[B, IX] = sort(petable);
imagereshapedinter = imagereshapedinter(:,:,IX,:);

%% baseline correction

imagereshapedinter = bslcorr_diff(imagereshapedinter);


%% reference scans
% params.image=[0 -2 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 1]';
zph_idx= params.image==0;
zphN_idx= params.image==-2;
img_idx= params.image==1;
imgN_idx= params.image==-1;

zerophase = mean(imagereshapedinter(zph_idx,:,:,:),1);   % reference scans positive readouts
zerophaseN = mean(imagereshapedinter(zphN_idx,:,:,:),1);   % reference scans negative readouts


imagereshapedinterN = imagereshapedinter(imgN_idx,:,:,:);  % image data negative readouts
imagereshapedinter = imagereshapedinter(img_idx,:,:,:);  % image data postive readouts

zerophase = repmat(zerophase,[size(imagereshapedinter,1) 1 1 1]);
zerophaseN = repmat(zerophaseN,[size(imagereshapedinterN,1) 1 1 1]);

zerophasefft = fftshift(fft(fftshift(zerophase,4),[],4),4);
imrsh_flip_fft = fftshift(fft(fftshift(imagereshapedinter,4),[],4),4);

zerophasefftN = fftshift(fft(fftshift(zerophaseN,4),[],4),4);
imrsh_flip_fftN = fftshift(fft(fftshift(imagereshapedinterN,4),[],4),4);
% size(zerophasefft)
%% correction 

imrsh_proj = imrsh_flip_fft.*exp(-1i*angle(zerophasefft));
imrsh_projN = imrsh_flip_fftN.*exp(-1i*angle(zerophasefftN));



%% FFT bit
%imagefft = abs(fftshift(fftshift(fft(fft(fftshift(fftshift(imagereshapedinter(:,:,1:4:128,:),3),4),[],3),[],4),3),4));
% above : fft in 2 dimensions. Not necessary after ghost correction with
% reference scans


% imagefft = fftshift(fft(fftshift(imrsh_proj,3),[],3),3);

% imageNfft = fftshift(fft(fftshift(imrsh_projN,3),[],3),3);


% sumproj = (imrsh_proj + imrsh_projN);
% thres = 0.02*(mean(mean(mean(mean(abs(sumproj))))));

% corp = abs(imrsh_proj).*exp(1i*angle(sumproj));
% corp(find(abs(sumproj)<thres)) = imrsh_proj(find(abs(sumproj)<thres));

correctp = fftshift(fft(fftshift(imrsh_proj,3),[],3),3);
% correctp=imrsh_proj;
% corn = abs(imrsh_projN).*exp(1i*angle(sumproj));
% corn(find(abs(sumproj)<thres)) = imrsh_projN(find(abs(sumproj)<thres));

correctn = fftshift(fft(fftshift(imrsh_projN,3),[],3),3);

correctn = flipdim(correctn,4);

%% shit in RO by I dont know why
correctn = circshift(correctn,[0 0 0 1]);

% correctn=imrsh_projN;
corrected = (correctp+correctn);

% corrected_mean=zeroes(size(correctn));

% for imagesn=1:size(corrected,1)
%     for slice=1:sizes(3)
%         corrected(imagesn,slice,:,:) = abs(corrected(imagesn,slice,:,:))*exp(-sqrt(-1)*(angle(mean(mean(squeeze(corrected(imagesn,slice,:,:)))))));
% 
%     end;
% end;
corrected_mean = corrected;
% corrected_mean = mean(corrected,1); %removes phase abs(mean(corrected_mean,1))


% disp('fin')




