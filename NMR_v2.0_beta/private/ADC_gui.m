% function ADC_gui

%handles=guidata(findobj('Tag','GUI_ImageOrientation'));



handles.data.params = param;%%%%%
handles.data.image = image;%%%%



%% define b-values and grad scheme

bval=[handles.data.params.bvalue];

%bval(2:7)=handles.data.params.max_bval;
if ~isequal(length(bval),size(handles.data.image,4))
    if length(bval)==1
        bval = repmat(bval, [1 size(handles.data.image,4)]);
    else
    disp('#b-value ~= #DWI images')
%     return;
    end
end

try
    bmat=[[handles.data.params.dpe] [handles.data.params.dro] [handles.data.params.dsl]];
    b0_idx = find(sum(abs(bmat),2)==0);
    B0=mean(handles.data.image(:,:,:,b0_idx),4);
    bval0=mean(bval(b0_idx));
    %if averages need to average also the opposite gradient direction
    count=0;
    
    
    norm = (sqrt(sum(bmat(2,:).^2)));
    if norm~=0
        bmat = bmat./norm;
    else
        norm = round(sqrt(sum(bmat(3,:).^2)));
        bmat = bmat./norm;
    end
    
    count=0;
    for k=1:length(bmat)
        for l = 1:length(bmat)
            if k~=l
                test1 = sum(bmat(k,:).*bmat(l,:));
                if mod(test1,1)<0.01 || mod(test1,1)>0.99
                    test1 = round(test1);
                end

                if test1 == 0 && isequal(bmat(k,:),[0 0 0]) && isequal(bmat(l,:),[0 0 0])
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -1 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -2 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                elseif test1 == -3 && sum(bmat(k,:)==0) == sum(bmat(l,:)==0)
                    count=count+1;
                    temp(count,:)=[k l];
                end
            end            
        end
    end
      
    
    
    if length(temp)==length(bmat) %opposite scheme apply
        temp = unique(sort(temp,2),'rows');
%         B0 = handles.data.image(:,:,:,b0_idx(1));
        [x,y]=find(temp==b0_idx(1))
        temp = temp(setxor([1:length(temp)],x),:)

        for k=1:length(temp)
            B1(:,:,:,k)=(handles.data.image(:,:,:,temp(k,1))+handles.data.image(:,:,:,temp(k,2)))./2;
            bval_tmp(k)=(bval(temp(k,1))+bval(temp(k,1)))/2;
        end
        bval=bval_tmp-bval0;
    else
        disp('not opposite diffsuion gradient scheme: unable to average along drad directions')
        if length(b0_idx)==1
            B1=handles.data.image(:,:,:,2:size(handles.data.image,4));

        else
            B0 = handles.data.image(:,:,:,b0_idx(1));
            DW_idx =setxor([b0_idx],[1:size(handles.data.image,4)]);
            B1 =  handles.data.image(:,:,:,DW_idx);
            bval = bval(DW_idx)-bval(b0_idx(1));
            
        end
           if size(bval,1)>size(bval,2)
                bval=bval';
            end
        
    end
    
catch
    disp('catch')
    B0=squeeze(handles.data.image(:,:,:,1));
    bval=bval(2:length(bval))-bval(1);
      if size(bval,1)>size(bval,2)
                bval=bval';
      end
%     bval0=0;
    B1=handles.data.image(:,:,:,2:size(handles.data.image,4));
end



%% ADC MAP computing

bval=permute(repmat(bval',[1 size(B0)]),[2 3 4 1]);
% bval=bval(:,:,:,1:size(B1,4));
B0=repmat(B0,[1 1 1 size(B1,4)]);

THRES=mean(B0(:))+0*std(B0(:));
MAP= B0>=THRES;

ADC= zeros(size(B1));
ADC = (log(B0./B1)./bval); %B0 should be greater than B1
ADC=ADC.*MAP;
ADC_mean = mean(ADC(:,:,:,:),4);






% % ImageOrient_display;
%  m = make_nii(ADC_mean,[1 1 5]);
%          m.hdr.dime.datatype = 16;
%          m.img=int16(m.img);
%          save_nii(m,['ADC.hdr']);
% 
% 
%  save adc.mat ADC_mean




