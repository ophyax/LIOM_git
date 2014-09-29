%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%   BIAS CORRECTION USING HIGH PASS FILTERING
% 
%   Date:     2008/01/21 
%   Language: Matlab
% 
%   AUTHORS:  Xavier Peña Piña (http://people.epfl.ch/xavier.penya),
%             Meritxell Bach Cuadra, Nicolas Kunz and Jean-Philippe Thiran
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Bias_corrector(handles)
% cd('D:\Program Files\MATLAB704\work\NMR\private
% %%%%%%%%%%%%%%%[[[  INITIALIZATION PARAMETERS ]]]%%%%%%%%%%%%%%%%%%%%%%%
clc;
disp('+++++++++++++++++++++++++++++');
disp('Loading file...');

% ff=fopen(INPUT_FILENAME,'r',INPUT_FILETYPE); 
% RawImage = fread(ff, [X_DIMENSION*Y_DIMENSION,Z_DIMENSION], INPUT_DATATYPE); %with old Matlabs one must write 'unsigned short'
% fclose(ff);
% 
% for k=1:Z_DIMENSION
% 
%     stopBar= progressbar(k/Z_DIMENSION,0);    
%   
%     for j=1:Y_DIMENSION
%         Image(:,j,k)=RawImage(((j-1)*X_DIMENSION+1):(j*X_DIMENSION),k)';
%     end
% end
% 
% delete(gcf);

Image = squeeze(handles.data.data.image(:,:,:,1));
orientation = {handles.data.orientation{1,[2 3 1]}};
Image=permute(Image,[2 3 1]);

m=size(Image);

disp('...file loaded!');
    % Input and output filename for the raw files. 
    % Note: the output file is always saved as 'double'.    

%         INPUT_FILENAME = 'Image.raw';
%         INPUT_FILETYPE = 'ieee-be'; % 'ieee-be' for BIG ENDIAN (SUN)  ---  'ieee-le' for LITTLE ENDIAN (INTEL))
%         INPUT_DATATYPE = 'ushort';
% 
%         OUTPUT_FILENAME = 'Output';
%         OUTPUT_FILETYPE = 'ieee-be';       

    % Dimension of the raw file loaded:
        X_DIMENSION = size(Image,1);%512;
        Y_DIMENSION = size(Image,2);
        Z_DIMENSION = size(Image,3);
        
    % Center slice of the rat brain:
    %       Z_CENTER = 16;
    % Default value:
            Z_CENTER = round(Z_DIMENSION/2);
        
    % Element spacing:
        
        SP_X = handles.data.pix.(char(orientation{1,2})); %4.296875e-002; 
        SP_Y = handles.data.pix.(char(orientation{1,3})); %4.296875e-002;
        SP_Z = handles.data.pix.(char(orientation{1,1})); %8.000000e-001;
        
        
    % Note: the other elements of the .mhd file can be changed a few lines
    % below.
        
    % This structuring element will remove the residues from the mask
    % of the image. We suggest that STRUCT_ELEM_DETAIL rest set at 1 (the higher is the
    % value the more you mask the image).
        STRUCT_ELEM_DETAIL = 1;
        
%%

    % The following lines correspond to the format in which the .mhd file
    % will be saved.
% 
%     line1 = 'ObjectType = Image';
%     line2 = 'NDims = 3';
%     line3 = 'BinaryData = True';
% 
%     if INPUT_FILETYPE == 'ieee-be'
%         line4 =  'BinaryDataByteOrderMSB = True';
%     else
%         line4 =  'BinaryDataByteOrderMSB = False';
%     end
%     
%     line5 = 'TransformMatrix = 1 0 0 0 1 0 0 0 1 ';
%     line6 = 'Offset = 0 0 0';
%     line7 = 'CenterOfRotation = 0 0 0';
%     line8 = 'AnatomicalOrientation = RPI';
%     line9 = sprintf('ElementSpacing = %d %d %d',SP_X,SP_Y,SP_Z);
%     line10 = sprintf('DimSize = %d %d %d',X_DIMENSION,Y_DIMENSION,Z_DIMENSION);
%     line11 = 'ElementType = MET_DOUBLE';
%     line12 = sprintf('ElementDataFile = %s',OUTPUT_FILENAME);     
    
%%


    % RAD defines how 'hard' we want the contour to be for the
    % recovered image. Suggestion: value 8 for 512x512 pixel slices; value 4 for
    % 256x256 pixel slices.
                      
    % WINDOW defines the size of the gaussian filter used to filter each
    % slice. SIGMA defines the sigma value of this filter.

    switch lower(X_DIMENSION)

        case {64}

            RAD=1;

            WINDOW = 6;

            SIGMA = 2;

        case {128}

            RAD=2;

            WINDOW = 12;

            SIGMA = 4;

        case{256}

            RAD=4;

            WINDOW = 25;

            SIGMA = 8;

        case{512}

            RAD=8;

            WINDOW = 50;

            SIGMA = 16;

        case{1024}

            RAD=16;

            WINDOW = 100;

            SIGMA = 32;

    end
    
    
    
    
    
    
    
    
        
%% %%%%%%%%%%%%%%%%%%%%%%%%% Only code below %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Compute Gradients (4) %%%%%%%%%%%%%%%%%%%%%%%%%

disp('+++++++++++++++++++++++++++++');
disp('Computing SNR map and Gradient...');

%%%%%%%%%%%%%%%%%%%%%% DIFFERENCE GRADIENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ImageShL=circshift(Image,[0,RAD]);
ImageShT=circshift(Image,[RAD,0]);

DivL=abs(Image-ImageShL);
DivT=abs(Image-ImageShT);

DifMax=max(DivL,DivT);

clear ImageShL ImageShT ImageShU ImageShD DivL DivT DivU DivD MaskAux1L MaskAux1T MaskAux1U MaskAux1D;

%%

DifTotal=zeros(m);
Mean=Image;

for i=1:RAD
    stopBar= progressbar(i/RAD,0);   
    for j=1:RAD
        Shift=circshift(Image,[i,j]);
        Mean=Mean+Shift;
        Dif=abs(Image-Shift); 
        DifTotal=max(DifTotal,Dif);
    end
end

delete(gcf);

Mean=Mean/(RAD^2);
SNR=(Mean./DifTotal).^2;

disp('...process done!')

%%


scrsz = get(0,'ScreenSize');

 

DivAux=SNR(:,:,Z_CENTER);

 

MARGIN=2;

% DivAux(:,(Y_CENTER-MARGIN):(Y_CENTER+MARGIN))=0;

% DivAux((X_CENTER-MARGIN):(X_CENTER+MARGIN),:)=0;

 

    h=figure('Position',[1 1 scrsz(3) scrsz(4)]);

    figure(h);

    subplot(1,3,1);
    
    imagesc(Image(:,:,Z_CENTER));
    title('Please choose any pixel of the background with a click...' )

    colormap gray

    axis square

    [y,x]=ginput(1);                    %% get point localtion with a left click
    
    top=30*SNR(round(x),round(y),Z_CENTER);

    imagesc(Image(:,:,Z_CENTER));
    title('...now choose the anatomical center of the image with a click...' )

    colormap gray

    axis square

    [y,x]=ginput(1);                    %% get point localtion with a left click

    X_CENTER = round(x);

    Y_CENTER = round(y);

    DivAux(:,(Y_CENTER-MARGIN):(Y_CENTER+MARGIN))=0;

    DivAux((X_CENTER-MARGIN):(X_CENTER+MARGIN),:)=0;
  
    imshow(DivAux);

    subplot(1,3,2);

    plot(SNR(:,Y_CENTER,Z_CENTER));

    title('...finally: Separe noise and signal. Set threshold above the noise level by clicking with the lef button (please choose a value high enough: we recommend a value of 3 times the highest peak of the background noise).');
      
    axis([1 X_DIMENSION 0 top]);

    subplot(1,3,3);

    plot(SNR(X_CENTER,:,Z_CENTER));

    axis([1 X_DIMENSION 0 top]);
    
      
    [x,y]=ginput(1);                    %% get point localtion with a left click
         
%     close (h);
   
    disp('Separe noise and signal. Set threshold above the noise level.');
    
       
    thresU=y
    
   
    MaskSNR=SNR>thresU;
   

    Mask=MaskSNR;

   

    clear SNR DifTotal DifMax MaskSNR
    
    
%%
    
scrsz = get(0,'ScreenSize');

 

DifMax=abs(gradient(Image));



MARGIN=2;

% DivAux(:,(Y_CENTER-MARGIN):(Y_CENTER+MARGIN))=0;

% DivAux((X_CENTER-MARGIN):(X_CENTER+MARGIN),:)=0;

 

    h=figure('Position',[1 1 scrsz(3) scrsz(4)]);

    figure(h);

    subplot(1,3,1);

    DivAux=Image(:,:,Z_CENTER);

    DivAux(:,(Y_CENTER-MARGIN):(Y_CENTER+MARGIN))=0;

    DivAux((X_CENTER-MARGIN):(X_CENTER+MARGIN),:)=0;

    imagesc(DivAux);

    colormap gray

    axis square
    
    subplot(1,3,2);

    plot(DifMax(:,Y_CENTER,Z_CENTER));
    title('Cut the highest peaks of the profile. Please choose a high value.');

    axis([1 X_DIMENSION 0 max(max(DifMax(:,Y_CENTER,Z_CENTER)))]);

    subplot(1,3,3);

    plot(DifMax(X_CENTER,:,Z_CENTER));

    axis([1 X_DIMENSION 0 max(max(DifMax(:,Y_CENTER,Z_CENTER)))]);

    [x,y]=ginput(1);                    %% get point localtion with a left click
    
%     close (h);
    
    thresU=y
   
    MaskGrad=DifMax<thresU;
    
    clear DifMax

%%

Mask=Mask.*MaskGrad;

    
%%
    disp('+++++++++++++++++++++++++++++');
    disp('+++++++++++++++++++++++++++++');
    disp('+++++++++++++++++++++++++++++');
    disp('Work in progress, please wait.');   

%%

disp('+++++++++++++++++++++++++++++');
disp('Step 1 of 3:');
disp('Computing the mask...');

m=size(Image);

disp('...removing residues...');

m=size(Image);


%%

for k=1:Z_DIMENSION
    
    stopBar= progressbar(k/Z_DIMENSION,0);

    se = strel('disk',STRUCT_ELEM_DETAIL);
    Mask(:,:,k)=imopen(Mask(:,:,k),se);
end

delete(gcf);

%%

delete(gcf);

disp('...extracting largest element...');

con_param = 8;

for k=1:Z_DIMENSION
    
    stopBar= progressbar(k/Z_DIMENSION,0);
    
    [L,num_connected_objs] = bwlabel(Mask(:,:,k),con_param);
    if num_connected_objs>0
        a = hist(L(:),[0:num_connected_objs]);
        [v,ind] = max([a(2:end)]);
        Aux = imopen((L==ind),se);
        Aux1 = imclose(Aux,se);
        Aux2 = imfill(Aux, 'holes');
        
            MaskFilled(:,:,k)=Aux2;
            MaskGrad(:,:,k)=Aux1;
        
    else
        
        MaskFilled(:,:,k)=zeros(m(1), m(2));
        MaskGrad(:,:,k)=zeros(m(1), m(2));
        
    end
end

clear Aux Aux1 Aux2

delete(gcf);

disp('...step 1 of 3 done...');

for k=round(Z_DIMENSION/2-1):-1:1
    MaskFilled(:,:,k)=MaskFilled(:,:,k).*MaskFilled(:,:,k+1);
end

disp('...step 2 of 3 done...');

for k=round(Z_DIMENSION/2+1):1:Z_DIMENSION
    MaskFilled(:,:,k)=MaskFilled(:,:,k).*MaskFilled(:,:,k-1);
end

Mask=MaskFilled.*MaskGrad;

clear MaskFilled MaskGrad

disp('...step 3 of 3 done! Mask done!');


%%

disp('+++++++++++++++++++++++++++++');
disp('Step 2 of 3:');
disp('Expanding the image...');

Out3=Mask.*Image;
se = strel('disk',12);

for k=1:m(3)

    stopBar= progressbar(k/m(3),0);
    
    if sum(sum(Mask(:,:,k)))>0

        distance = bwdist(Mask(:,:,k));

        [X,Y]=gradient(distance);

        NewI=round(distance.*Y);
        NewJ=round(distance.*X);

        for i=1:m(1)
            for j=1:m(2)
                Out3(i,j,k)=Out3(i-NewI(i,j),j-NewJ(i,j),k);
            end
        end
        
    end
 
end

delete(gcf);

disp('...re-filling expansion...');

for k=1:m(3)
    stopBar= progressbar(k/m(3),0);
    if sum(sum(Mask(:,:,k)))
        for j=1:m(2)
             for i=1:m(1)
                if Out3(i,j,k)==0 && i<m(1)
                    i2=i+1;
                    while(Out3(i2,j,k)==0 && i2<m(1))
                        i2=i2+1;        
                    end
                    Out3(i,j,k)=Out3(i2,j,k);
                end
            end
        end
    end
end

delete(gcf);

disp('...expansion done!');


%%

disp('+++++++++++++++++++++++++++++');
disp('Step 3 of 3:');
disp('Low pass filter...');

filt = fspecial('gaussian',[WINDOW WINDOW], SIGMA);  % gaussian kernel

for k=1:m(3)
    
    stopBar= progressbar(k/m(3),0);
    
    filterImage1=conv2(Out3(:,:,k),filt);
    Filter(:,:,k)=filterImage1((WINDOW/2):(m(1)+WINDOW/2-1),(WINDOW/2):(m(2)+WINDOW/2-1));
    
end

delete(gcf);

for k=1:m(3)
    
    if sum(sum(Out3(:,:,k)))==0
   
        d=k;

        while d<(m(3)+1) && sum(sum(Out3(:,:,d)))==0
            d=d+1;
        end

        if d<(m(3)+1)
            Filter(:,:,k)=Filter(:,:,d);
        end
   
    end
    
end

for k=m(3):-1:1
    
    if sum(sum(Out3(:,:,k)))==0
   
        d=k;

        while d>0 && sum(sum(Out3(:,:,d)))==0
            d=d-1;
        end

        if d>0
            Filter(:,:,k)=Filter(:,:,d);
        end
   
    end
    
end

disp('...Low Pass Filter done!');

%%
Filter=permute(Filter,[3 1 2]);
handles.data.BiasFilter = Filter;
if length(size(handles.data.data.image))==3
    handles.data.data.image=handles.data.data.image./Filter;
elseif length(size(handles.data.data.image))==4
    for k = 1:size(handles.data.data.image,4)
    handles.data.data.image(:,:,:,k)=squeeze(handles.data.data.image(:,:,:,k))./Filter;
    end
end




disp('...file saved!');
disp('-> Note: the file has been saved as DOUBLE');
delete(gcf);
%%
% 
% disp('Do you want to display the results?');
% ANS=input(' ("y" for YES, Enter for NO): ','s');
% 
% if ANS == 'y'
%     
%     disp('-> Press any key to visualize the next slice.');
%     disp('-> If the brightness of the images is not visualized correctly, please change the visualization margins in the last lines of the code:');
%     disp('      ...imshow(Image,[min_val,max_val]');
% 
%     h=figure('Position',[1 1 scrsz(3) scrsz(4)]);
%     figure(h);
% 
%     for k=1:m(3)
% 
%         subplot(2,2,1);
%         imshow(Image(:,:,k),[0 max(max(max(Image)))]);
%         titl1 = sprintf('Original image (slice #%d):',k);
%         title(titl1)
% 
%         subplot(2,2,2);   
%         imshow(Corrected(:,:,k),[0 0.25*max(max(max(Corrected)))]);
%         titl2 = sprintf('Corrected image (slice #%d):',k);
%         title(titl2)       
% 
%         subplot(2,2,3);
%         imshow(Filter(:,:,k),[0 max(max(max(Filter)))]); 
%         titl3 = sprintf('Bias estimation (slice #%d):',k);
%         title(titl3)
% 
%         subplot(2,2,4);
%         imshow(Mask(:,:,k)>0);
%         titl4 = sprintf('Mask (slice #%d):',k);
%         title(titl4)
% 
%         pause;
%         
%     end
%     
% %     close(h);
%     
% end
% 
% disp('Do you want to save the mask?');
% ANS=input(' ("y" for YES, Enter for NO): ','s');
% 
% if ANS == 'y'
%     ff=fopen('Mask','w',OUTPUT_FILETYPE);
%     fwrite(ff,uint8((2^8-1)*Mask),'uchar');
%     fclose(ff);
% 
%     line11='ElementType = MET_UCHAR';
%     line12='ElementDataFile = Mask';
%     
%     file_id = fopen('Mask.mhd','w');
%     fprintf(file_id,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n', line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12);
%     fclose(file_id);  
% 
%     disp('...file saved!');
%     disp('-> Note: the file has been saved as UCHAR');
% end
% 
% disp('Do you want to save the bias estimation?');
% ANS=input(' ("y" for YES, Enter for NO): ','s');
% 
% if ANS == 'y'
%     ff=fopen('Bias','w',OUTPUT_FILETYPE);
%     fwrite(ff,Filter,'double');
%     fclose(ff);
%     
%     line11='ElementType = MET_DOUBLE';
%     line12='ElementDataFile = Bias';
%     file_id = fopen('Bias.mhd','w');
%     fprintf(file_id,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n', line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12);
%     fclose(file_id);
% 
%     disp('...file saved!');
%     disp('-> Note: the file has been saved as DOUBLE');
% end

clear Corrected Dif DivAux Filter INPUT_DATATYPE INPUT_FILENAME INPUT_FILETYPE Image L MARGIN Mask MaskGrad Mean NewI NewJ OUTPUT_FILENAME OUTPUT_FILETYPE Out3 RAD RawImage SIGMA SP_X SP_Y SP_Z STRUCT_ELEM_DETAIL Shift WINDOW SIGMA X X_CENTER X_DIMENSION Y Y_CENTER Y_DIMENSION Z_CENTER Z_DIMENSION a con_param d distance ff file_id filt filterImage1 h i i2 ind j k line1 line2 line3 line4 line5 line6 line7 line8 line9 line10 line11 line12 m num_connected_objs scrsz se stopBar thresU titl1 titl2 titl3 titl4 v x y ans ANS top

%%

disp('+++++++++++++++++++++++++++++');
disp('+++++++++++++++++++++++++++++');
disp('+++++++++++++++++++++++++++++');
disp('END OF PROGRAM.');
set(handles.process_checkbox_bias,'Value',1)
guidata(handles.GUI_ImageOrientation,handles);
end