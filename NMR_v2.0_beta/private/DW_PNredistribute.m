% this is the matlab script for Yohan's special DTI images. In the call you
% have to specify the size of the data as follows:
%[NumberofAverages NDiffusion numberofimages phaseencode steps/interleaves slices interleaves readpoints];

% function [corrected_mean, correctp, correctn] = DW_PNredistribute(data,sizes,params)
function [corrected_mean] = DW_PNredistribute_gui(data,sizes,params)
global petable
for n=1:sizes(1) %NumberofAverages
    for m=1:sizes(2) %NDiffusion
%         h = waitbar((m+(n-1)*sizes(2))/(sizes(2)*sizes(1)),'resitribute') 
        start=(n-1)*sizes(2)*sizes(3)+(m-1)*sizes(3);
        datasmall.real=squeeze(data.real(start+1:start+sizes(3),:,:));
        datasmall.imag=squeeze(data.imag(start+1:start+sizes(3),:,:));

       if  find(params.image==-2)>=1
            display('2grora');
           [corrected_mean(n,m,:,:,:,:)] =...
                DW_PNplusminusplusminus(datasmall,sizes(3:7),params,m,n);
       else
            display('normal epi');
            [corrected_mean(n,m,:,:,:,:)] =...
                DW_PNnoplusminusplusminus(datasmall,sizes(3:7),params,m,n);       
       end

    end;
   
end;
% close(h)
        

    