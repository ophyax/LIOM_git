% baseline correction for 'five-dimensional' diffusion data. Assuming read
% and phase are in dimensions 5 and 2 respectively. 
%corrected by Jose 19/07/2007
%this baseline correction only works on the image data not on the initial
%projections correc
function result = bslcorr_diff(data)

dims = size(data);

temp = fftshift(fftshift(fft(fft(fftshift(fftshift(...
                data,3),4),[],3),[],4),3),4);
result=data(1:2,:,:,:);
clear data
            
temp(:,:,(dims(3)/2)+1,(dims(4)/2)+1) = mean(mean(abs(temp ...
    (:,:,dims(3)/2:(dims(3)/2)+2,[dims(4)/2 (dims(4)/2)+2])),3),4).*...
    exp(i*(mean(mean(angle(temp(:,:,dims(3)/2:(dims(3)/2)+2,...
    [dims(4)/2 (dims(4)/2)+2])),3),4))); 

result(3:dims(1),:,:,:) = ifftshift(ifftshift(ifft(ifft(ifftshift(ifftshift(...
                temp(3:dims(1),:,:,:),3),4),[],3),[],4),3),4);
         
    