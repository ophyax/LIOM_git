% this is the matlab script for Yohan's special DTI images. In the call you
% have to specify the size of the data as follows: [volumes phaseencode
% steps/interleaves slices interleaves readpoints];

% function [corrected_mean, correctp, correctn] = DW_PNplusminusplusminus(data,sizes,params,m0,n0)
function [corrected_mean] = DW_PNplusminusplusminus(data,sizes,params,m0,n0)

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

petable=char(params.petable{1});
if strcmp(petable((size(petable,2)-3):(size(petable,2)-1)),'lin')==1
    for interl=1:dims(4)
        for slice=1:sizes(3)
            imagereshapedinter(:,slice,interl:dims(4):(dims(2)*dims(4)),:)=squeeze(imrsh_flip(:,:,slice,interl,:));
        end;
    end;
elseif strcmp(petable((size(petable,2)-3):(size(petable,2)-1)),'cen')==1
    'centric'
%     t1 = [2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31 0 -2 -4 -6 -8 -10 -12 -14 -16 -18 -20 -22 -24 -26 -28 -30 -1 -3 -5 -7 -9 -11 -13 -15 -17 -19 -21 -23 -25 -27 -29 -31];
    t1=petable;
    for interl=1:dims(4)
        for pe_step=1:dims(2)
            for slice=1:sizes(3)
                t1((pe_step)+(interl-1)*dims(2))-min(t1)+1
                imagereshapedinter(:,slice,t1((pe_step)+(interl-1)*dims(2))-min(t1)+1,:)=squeeze(imrsh_flip(:,pe_step,slice,interl,:));
            end;
        end;
    end;

end
%% baseline correction

imagereshapedinter = bslcorr_diff(imagereshapedinter);


%% reference scans
zph_idx=find(params.image==0);
zphN_idx=find(params.image==-2);
img_idx=find(params.image==1);
imgN_idx=find(params.image==-1);

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
size(zerophasefft)
%% correction 

imrsh_proj = imrsh_flip_fft.*exp(-i*angle(zerophasefft));
imrsh_projN = imrsh_flip_fftN.*exp(-i*angle(zerophasefftN));



%% FFT bit
%imagefft = abs(fftshift(fftshift(fft(fft(fftshift(fftshift(imagereshapedinter(:,:,1:4:128,:),3),4),[],3),[],4),3),4));
% above : fft in 2 dimensions. Not necessary after ghost correction with
% reference scans


imagefft = fftshift(fft(fftshift(imrsh_proj,3),[],3),3);
imrsh_projN = flipdim(imrsh_projN,4);
imageNfft = fftshift(fft(fftshift(imrsh_projN,3),[],3),3);


sumproj = (imrsh_proj + imrsh_projN);
thres = 0.02*(mean(mean(mean(mean(abs(sumproj))))));

corp = abs(imrsh_proj).*exp(i*angle(sumproj));
corp(find(abs(sumproj)<thres)) = imrsh_proj(find(abs(sumproj)<thres));
correctp = fftshift(fft(fftshift(corp,3),[],3),3);

corn = abs(imrsh_projN).*exp(i*angle(sumproj));
corn(find(abs(sumproj)<thres)) = imrsh_projN(find(abs(sumproj)<thres));
correctn = fftshift(fft(fftshift(corn,3),[],3),3);


corrected = (correctp+correctn);



for imagesn=1:size(corrected,1)
    for slice=1:sizes(3)
        corrected_mean(imagesn,slice,:,:) = abs(corrected(imagesn,slice,:,:))*exp(-sqrt(-1)*(angle(mean(mean(squeeze(corrected(imagesn,slice,:,:)))))));

    end;
end;
corrected_mean = mean(corrected_mean,1); %removes phase abs(mean(corrected_mean,1))


disp('fin')




