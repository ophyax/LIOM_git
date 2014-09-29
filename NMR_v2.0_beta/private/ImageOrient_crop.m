function  [img, crop_dim] = ImageOrient_crop(handles)
clc
disp_debug=0;
img = handles.data.data.image;
dime=size(img);



slider(1) = round(get(handles.slider_Coronal,'Value'));
slider(2) = round(get(handles.slider_Sagittal,'Value'));
slider(3) = round(get(handles.slider_Axial,'Value'));


hc = imrect(handles.axes_coronal,[round(dime(3)*0.1) round(dime(1)*0.1) round(dime(3)*0.8) round(dime(1)*0.8)]);
fcnc = makeConstrainToRectFcn('imrect',[0.4 dime(3)+0.6],[0.4 dime(1)+0.6]);
setPositionConstraintFcn(hc,fcnc);

hs = imrect(handles.axes_sagittal,[round(dime(2)*0.1) round(dime(1)*0.1) round(dime(2)*0.8) round(dime(1)*0.8)]);
fcns = makeConstrainToRectFcn('imrect',[0.4 dime(2)+0.6],[0.4 dime(1)+0.6]);
setPositionConstraintFcn(hs,fcns);

ha = imrect(handles.axes_axial,[round(dime(3)*0.1) round(dime(2)*0.1) round(dime(3)*0.8) round(dime(2)*0.8)]);
fcna = makeConstrainToRectFcn('imrect',[0.4 dime(3)+0.6],[0.4 dime(2)+0.6]);
setPositionConstraintFcn(ha,fcna);


addNewPositionCallback(hc,@(p) crop_move(hc,[hc hs ha],handles.dims_text_crop));
addNewPositionCallback(hs,@(p) crop_move(hs,[hc hs ha],handles.dims_text_crop));
addNewPositionCallback(ha,@(p) crop_move(ha,[hc hs ha],handles.dims_text_crop));

%% wait double click on coronal axes
poshc = wait(hc);
poshs = getPosition(hs);
posha = getPosition(ha);

delete(hc); delete(hs); delete(ha);

poshc(1:2)=ceil(poshc(1:2));
poshs(1:2)=ceil(poshs(1:2));
posha(1:2)=ceil(posha(1:2));

if sum(poshc(1:2)==0)>0
    idx = find(poshc(1:2)==0);
    poshc(idx)=ones(size(idx));
end
if sum(poshs(1:2)==0)>0
    idx = find(poshs(1:2)==0);
    poshs(idx)=ones(size(idx));
end
if sum(posha(1:2)==0)>0
    idx = find(posha(1:2)==0);
    posha(idx)=ones(size(idx));
end

if length(dime)==3
img = img(poshc(2):floor(poshc(2)+poshc(4))-1,...
            poshs(1):floor(poshs(1)+poshs(3))-1,...
            poshc(1):floor(poshc(1)+poshc(3))-1);
elseif length(dime)==4
img = img(poshc(2):floor(poshc(2)+poshc(4))-1,...
            poshs(1):floor(poshs(1)+poshs(3))-1,...
            poshc(1):floor(poshc(1)+poshc(3))-1,:);    
end
crop_dim = [[poshc(2) floor(poshc(2)+poshc(4))-1];...
            [poshs(1) floor(poshs(1)+poshs(3))-1];...
            [poshc(1) floor(poshc(1)+poshc(3))-1]];
dime_new=size(img);

slider_new(1) = slider(1)-poshs(1)+1;
slider_new(2) = slider(2)-poshc(1)+1;
slider_new(3) = slider(3)-poshc(2)+1;

if slider_new(1)>dime_new(2)
    slider_new(1)=dime_new(2);
elseif slider_new(1)<1
    slider_new(1)=1;
end
if slider_new(2)>dime_new(3)
    slider_new(2)=dime_new(3);
elseif slider_new(2)<1
    slider_new(2)=1;
end
if slider_new(3)>dime_new(1)
    slider_new(3)=dime_new(1);
elseif slider_new(3)<1
    slider_new(3)=1;
end
    

set(handles.slider_Coronal,'Value',slider_new(1))
set(handles.slider_Sagittal,'Value',slider_new(2))
set(handles.slider_Axial,'Value',slider_new(3))

if disp_debug==1
display(['old slider: ' num2str(slider)])
display(['new slider: ' num2str(slider_new)])
display(['old dim: ' num2str(dime)])
display(['new dim: ' num2str(size(img))])
display(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'])
display(['hc pos: ' num2str(poshc)])
display(['hs pos: ' num2str(poshs)])
display(['ha pos: ' num2str(posha)])
end
% figure(1)
% imagesc(squeeze(img(:,1,:)));


function crop_move(h,h_crop,h_text)

h_move = find(h==h_crop);
c_pos = (getPosition(h_crop(1)));
s_pos = (getPosition(h_crop(2)));
a_pos = (getPosition(h_crop(3)));

%% adjust box on pixel
c_pos(1:2) = ceil(c_pos(1:2))-1/2;
s_pos(1:2) = ceil(s_pos(1:2))-1/2;
a_pos(1:2) = ceil(a_pos(1:2))-1/2;

c_pos(3:4) = floor(c_pos(3:4));
s_pos(3:4) = floor(s_pos(3:4));
a_pos(3:4) = floor(a_pos(3:4));

t_pos = [c_pos(2) s_pos(1) c_pos(1)];
t_dim= [c_pos(4) s_pos(3) c_pos(3)];
set(h_text,'String',{['Crop: Pos: ' num2str(t_pos(1)+0.5) 'x' num2str(t_pos(2)+0.5) 'x' num2str(t_pos(3)+0.5)]...
                     ['          Dim: ' num2str(t_dim(1)) 'x' num2str(t_dim(2)) 'x' num2str(t_dim(3))]});

switch h_move
    case 1 % coronal
        setPosition(h_crop(1),c_pos)
        setPosition(h_crop(2),[s_pos(1) c_pos(2) s_pos(3) c_pos(4)])
        setPosition(h_crop(3),[c_pos(1) a_pos(2) c_pos(3) a_pos(4)])
    case 2 %sagittal
        setPosition(h_crop(2),s_pos)
        setPosition(h_crop(1),[c_pos(1) s_pos(2) c_pos(3) s_pos(4)])
        setPosition(h_crop(3),[a_pos(1) s_pos(1) a_pos(3) s_pos(3)])
    case 3 % axial
        setPosition(h_crop(3),a_pos)
        setPosition(h_crop(1),[a_pos(1) c_pos(2) a_pos(3) c_pos(4)])
        setPosition(h_crop(2),[a_pos(2) s_pos(2) a_pos(4) s_pos(4)])
        
end
function set_dim(h_crop)
display('set dimension !!!')

% function crop_posConst(h,h_crop,dime)
% h_move = find(h==h_crop);
% switch h_move
%     case 1 % coronal
%         c_pos = round(getPosition(h_crop(1)))
%         if c_pos(1)<0
%             c_pos(1) = 0;
%         end
%         if c_pos(2)<0
%             c_pos(2)=0;
%         end
%         if c_pos(1)+c_pos(3)>dime(3)
%             c_pos(1)=dime(3)-c_pos(3);
%         end
%          if c_pos(2)+c_pos(4)>dime(3)
%             c_pos(2)=dime(3)-c_pos(4);
%         end
%
%         setPosition(h_crop(1),c_pos)
%
%     case 2 %sagittal
%         s_pos = round(getPosition(h_crop(2)))
%         setPosition(h_crop(2),s_pos)
%         setPosition(h_crop(1),[c_pos(1) s_pos(2) c_pos(3) s_pos(4)])
%         setPosition(h_crop(3),[a_pos(1) s_pos(1) a_pos(3) s_pos(3)])
%     case 3 % axial
%         a_pos = round(getPosition(h_crop(3)))
%         setPosition(h_crop(3),a_pos)
%         setPosition(h_crop(1),[a_pos(1) c_pos(2) a_pos(3) c_pos(4)])
%         setPosition(h_crop(2),[a_pos(2) s_pos(2) a_pos(4) s_pos(4)])
%
% end

