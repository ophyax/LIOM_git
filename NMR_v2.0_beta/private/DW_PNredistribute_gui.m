% this is the matlab script for Yohan's special DTI images. In the call you
% have to specify the size of the data as follows:
%[NumberofAverages NDiffusion numberofimages phaseencode steps/interleaves slices interleaves readpoints];

% function [corrected_mean, correctp, correctn] = DW_PNredistribute(data,sizes,params)
function [corrected_mean] = DW_PNredistribute_gui(data,sizes,params)
global petable
for n=1:sizes(1) %NumberofAverages
    disp(['Reconstructing Average: ' num2str(n) '/' num2str(sizes(1))]);
    for m=1:sizes(2) %NDiffusion
        disp([' Diffusion direction: ' num2str(m) '/' num2str(sizes(2))]);
%         h = waitbar((m+(n-1)*sizes(2))/(sizes(2)*sizes(1)),'resitribute') 
        start=(n-1)*sizes(2)*sizes(3)+(m-1)*sizes(3);
        datasmall.real=squeeze(data.real(start+1:start+sizes(3),:,:));
        datasmall.imag=squeeze(data.imag(start+1:start+sizes(3),:,:));

       if  find(params.image==-1)>=1
%             display('2grora');
           [corrected_mean(n,m,:,:,:,:)] =...
                DW_PNplusminusplusminus_gui(datasmall,sizes(3:7),params,m,n);
       else
%             display('normal epi');
            [corrected_mean(n,m,:,:,:,:)] =...
                DW_PNnoplusminusplusminus_gui(datasmall,sizes(3:7),params,m,n);       
       end

    end;
   
end;
% close(h)
        

    