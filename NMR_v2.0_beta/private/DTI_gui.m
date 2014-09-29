function DTI_gui


handles=guidata(findobj('Tag','GUI_ImageOrientation'));
data= handles.data.data.image;

if isfield(handles.data,'BiasFilter') && get(handles.process_checkbox_bias,'Value')==1
    data = data./repmat(handles.data.BiasFilter,[1 1 1 size(data,4)]);
end
% fact_masq=0.05;

%% Prepare b-values and gradscheme
%% gradient scheme
gradsheme = handles.data.gradsheme;
gradsheme(:,1)= -gradsheme(:,1);

%% bvalue
if isfield(handles.data.params,'bvalue')
    bval=[handles.data.bvalue];
else
    bval = 1000;
end
if ~isequal(length(bval),size(handles.data.data.image,4))
    if length(bval)==1
        bval = repmat(bval, [1 size(handles.data.data.image,4)]);
    else
        disp('#b-value ~= #DWI images')
    end
end
% if length(bval)==length(gradsheme);
if size(bval,1)<size(bval,2)
    bval=bval';
end
    gradtab = [bval gradsheme];
    title ='b-values and gradient directions';
    cnames = {'b-values', 'X-Data','Y-Data','Z-Data'};
    width=0.3;
    height = 0.03*length(bval);
    if height >0.7
        height=0.7;
    end
    columneditable = [true true true];
% else
%     gradtab=bval;
%     title = 'b-values';
%     cnames = {'b-values'};
%     width=120;
%     height = 25*length(bval);
%     columneditable = [true];
%     
% end
but_h =0.1;
bvaluelistfig = figure('Name',title,'NumberTitle','off',...
    'Tag','bvaluelistfig','MenuBar','none','Units','normalized',...
    'Position',[0.5 0.9-height width height]);

bvalue_table = uitable('Data',gradtab,'ColumnName',cnames,'Parent',bvaluelistfig,'Units','normalized',...
    'Position',[0 but_h 1 1-but_h],'ColumnEditable',columneditable,...
    'Tag','bvalue_table');%,'CellEditCallback',{@bvalue_table_celleditcallback});

accept_button = uicontrol('Style','pushbutton','Parent',bvaluelistfig,'Units','normalized',...
    'String','Accept','Position',[0.5 0 0.5 but_h],...
    'Tag','accept_button','Callback',{@accept_button_callback});

applytoall_button = uicontrol('Style','pushbutton','Parent',bvaluelistfig,'Units','normalized',...
    'String','Apply to all','Position',[0 0 0.5 but_h/2],...
    'Tag','applytoall_button','Callback',{@applytoall_button_callback});

inbval_edit = uicontrol('Style','edit','Parent',bvaluelistfig,'Units','normalized',...
    'HorizontalAlignment','right','BackgroundColor','w',...
    'Position',[0 but_h/2 0.5 but_h/2],'String','Input_b-value',...
    'Tag','inbval_editbox');%,'Callback',{@paramsel_edit_callback});



%%


%%

function Tens = calc_Tens(bval,gradsheme,data)

prompt = {'Enter fact_masq:'};
dlg_title = 'fact_masq:';
num_lines = 1;
def = {'0.05'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
fact_masq = str2num(char(answer{:}));
% fact_masq=0.05;
b0_idx = find(sum(abs(gradsheme),2)==0);
if isempty(b0_idx)
    b0_idx = find(bval==min(bval));
end
dime = size(data);
DWI_idx = setxor([b0_idx],[1:dime(4)]);
gradsheme = gradsheme(DWI_idx,:);
bval = bval(DWI_idx);

dime(4)=dime(4)-length(b0_idx);
if length(b0_idx)>1
    disp('error multiple B0 images')
    b0_idx = squeeze(b0_idx(1));
end

Tens_att=zeros([size(gradsheme,1) 6]);

max_anat = max(max(max(data(:,:,:,b0_idx(1)))));
max_anat=max_anat*fact_masq;
for j = 1:size(gradsheme,1)
    Tens_att(j,1:3) = (gradsheme(j,:).^2).*bval(j);
    Tens_att(j,4) = 2*gradsheme(j,1)*gradsheme(j,2)*bval(j);
    Tens_att(j,5) = 2*gradsheme(j,1)*gradsheme(j,3)*bval(j);
    Tens_att(j,6) = 2*gradsheme(j,2)*gradsheme(j,3)*bval(j);
end


% save('Tens_att.mat','Tens_att','dime');

ln_rap = zeros(dime);

ln_rap =log(abs(repmat(data(:,:,:,b0_idx(1)),[1 1 1 dime(4)]))./abs(data(:,:,:,DWI_idx)));

% clear data

disp('calcul de D par resolution de systeme lineaire. ');



for j=1:dime(2)
    disp(['Coupe = ', num2str(j)]);disp(' ');
    for i=1:dime(1)
        for k=1:dime(3)
            
            
            
            Rap_sign = squeeze([ln_rap(i,j,k,:)]);
            
            %Resolution du systeme pour un systeme de Cramer
            %d_var=Tens_att^(-1)*Rap_sign;
            
            %Resolution par la methode des moindres carres
            [d_var,flag]=lsqr(Tens_att,Rap_sign);
            
            Tens_diff_temp(i,j,k,:)=d_var(:);
            
            if data(i,j,k,b0_idx(1))< max_anat
                Dxx(i,j,k)=0;
                Dyy(i,j,k)=0;
                Dzz(i,j,k)=0;
                Dxy(i,j,k)=0;
                Dxz(i,j,k)=0;
                Dyz(i,j,k)=0;
            else
                Dxx(i,j,k)=Tens_diff_temp(i,j,k,1);
                Dyy(i,j,k)=Tens_diff_temp(i,j,k,2);
                Dzz(i,j,k)=Tens_diff_temp(i,j,k,3);
                Dxy(i,j,k)=Tens_diff_temp(i,j,k,4);
                Dxz(i,j,k)=Tens_diff_temp(i,j,k,5);
                Dyz(i,j,k)=Tens_diff_temp(i,j,k,6);
            end;
            
            
            
            Tens_Diff_var(i,j,k,:,:)=[Dxx(i,j,k),Dxy(i,j,k),Dxz(i,j,k);...
                Dxy(i,j,k),Dyy(i,j,k),Dyz(i,j,k);...
                Dxz(i,j,k),Dyz(i,j,k),Dzz(i,j,k)];
            
            Tens_Diff(:,:)=Tens_Diff_var( i,j,k,:,:);
            
            
            
            
            %-------------------------------
            %Diagonalisation de la matrice D
            %Determination des valeurs propres et des vecteurs propres associes
            %calcul de la Trace de D
            %-------------------------------
            
            try
                [vec_pr,val_pr]=eig(Tens_Diff);
            catch
                disp('end')
            end
            
            Tens.vap1(i,j,k)=abs(val_pr(1,1));
            Tens.vap2(i,j,k)=abs(val_pr(2,2));
            Tens.vap3(i,j,k)=abs(val_pr(3,3));
            
            
            
            %TEST Masque image
            %             if data(i,j,k,b0_idx(1))< max_anat
            %                 Tens.Anat(i,j,k) = 0;
            %                 Tens.vap1(i,j,k) = 0;
            %                 Tens.vap2(i,j,k) = 0;
            %                 Tens.vap3(i,j,k) = 0;
            %             end
            %/TEST
            
            Tens.Trace(i,j,k)=(Tens.vap1(i,j,k)+Tens.vap2(i,j,k)+Tens.vap3(i,j,k))/3;
            Tens.Dparr(i,j,k)=Tens.vap3(i,j,k);
            Tens.Dorth(i,j,k)=(Tens.vap1(i,j,k)+Tens.vap2(i,j,k))/2;
            Tens.vepr_princ(i,j,k,:)=vec_pr(:,3);
            
        end
    end
end
disp('Calculs du tenseur de diffusion enfin termines...');


disp('Calcul des indices d anisotropie...');
for i=1:dime(1)
    for j=1:dime(2)
        for c=1:dime(3)
            %-----------------------Fraction d'anisotropie----------------------------
            %TEST masque image => divide by zero!
            if (Tens.vap1(i,j,c)==0) | (Tens.vap2(i,j,c)==0) | (Tens.vap3(i,j,c)==0)
                Tens.FA(i,j,c)= 0;
            else
                %/ TEST
                
                Tens.FA(i,j,c)=   sqrt((((Tens.vap1(i,j,c)-Tens.vap2(i,j,c))^2)+...
                    ((Tens.vap2(i,j,c)-Tens.vap3(i,j,c))^2)+...
                    ((Tens.vap3(i,j,c)-Tens.vap1(i,j,c))^2))/...
                    (2*(Tens.vap1(i,j,c)^2+Tens.vap2(i,j,c)^2+Tens.vap3(i,j,c)^2)));
                
            end
            %-----------------------Anisotropie relative------------------------------
            %TEST masque image => divide by zero!
            if (Tens.vap1(i,j,c)==0) | (Tens.vap2(i,j,c)==0) | (Tens.vap3(i,j,c)==0)
                Tens.RA(i,j,c)= 0;
            else
                %/ TEST
                
                Tens.RA(i,j,c)= sqrt(((Tens.vap1(i,j,c)-Tens.vap2(i,j,c))^2)+...
                    ((Tens.vap2(i,j,c)-Tens.vap3(i,j,c))^2)+...
                    ((Tens.vap3(i,j,c)-Tens.vap1(i,j,c))^2))/...
                    (sqrt(2)*(Tens.vap1(i,j,c)+Tens.vap2(i,j,c)+Tens.vap3(i,j,c)));
            end
            %------------------------Rapport de volume-------------------------------
            %TEST masque image => divide by zero!
            if (Tens.vap1(i,j,c)==0) | (Tens.vap2(i,j,c)==0) | (Tens.vap3(i,j,c)==0)
                Tens.VR(i,j,c)= 0;
            else
                %/ TEST
                Tens.VR(i,j,c) = 1-27*(Tens.vap1(i,j,c)*Tens.vap2(i,j,c)*Tens.vap3(i,j,c))/...
                    ((Tens.vap1(i,j,c)+Tens.vap2(i,j,c)+Tens.vap3(i,j,c))^3);
            end
            
        end
    end
end


%------------------------Segmentation anisotropique-------------------------------


% for i=1:Imax
% 	for j=1:Jmax
%         for c=1:Cmax
%
%  if ((Tens.ra_vol(i,j,c)<=0.2)&(Tens.ra_vol(i,j,c)>0))
%  Tens.basse_anis(i,j,c)=Tens.ra_vol(i,j,c);
%  else
%  Tens.basse_anis(i,j,c)=0;
%  end
%
%
%  if ((Tens.ra_vol(i,j,c)<=0.4)&(Tens.ra_vol(i,j,c)>0.2))
%  Tens.moy_anis(i,j,c)=Tens.ra_vol(i,j,c);
%  else
%  Tens.moy_anis(i,j,c)=0;
%  end
%
%  if ((Tens.ra_vol(i,j,c)<=1)&(Tens.ra_vol(i,j,c)>0.4))
%  Tens.haute_anis(i,j,c)=Tens.ra_vol(i,j,c);
%  else
%  Tens.haute_anis(i,j,c)=0;
%  end
%
%         end
% 	end
% end

disp('Calculs des indices anisotropiques enfin termines...');disp(' ');
disp('Creation des cartes de couleurs...');

Tens.colormap=zeros(dime(1),dime(2),dime(3),3);
% valmascinf = input('Valeur du masqueinf en FA = ');

valmascinf = 0;
x = zeros(dime(2),dime(3),3);
m = max(max(max(data(:,:,:,b0_idx(1)))));
for c=1:dime(1)
    % for c=20:20
    
    for i=1:dime(2)
        for j=1:dime(3)
            
            a = data(c,i,j,b0_idx(1));
            def = a/m;
            faw = 1.1*Tens.FA(c,i,j);
            
            if (Tens.FA(c,i,j)<=valmascinf)
                Tens.colormap(c,i,j,1) = def;
                Tens.colormap(c,i,j,2) = def;
                Tens.colormap(c,i,j,3) = def;
            else
                Tens.colormap(c,i,j,1) = faw*abs(Tens.vepr_princ(c,i,j,1));
                Tens.colormap(c,i,j,2) = faw*abs(Tens.vepr_princ(c,i,j,2));
                Tens.colormap(c,i,j,3) = faw*abs(Tens.vepr_princ(c,i,j,3));
            end;
            
        end;
    end;
    
end;

disp('Fin de carte de couleurs...');disp(' ');

% set(handles.display_popupmenu_DWI,'Value',length(DWI_string));


function bvalue_table_celleditcallback(hObject,eventdata)



function applytoall_button_callback(hObject,eventdata)
bval=str2num(get(findobj('Tag','inbval_editbox'),'String'));
gradtab = get(findobj('Tag','bvalue_table'),'Data');
gradtab(:,1)=repmat(bval,[size(gradtab,1),1]);
set(findobj('Tag','bvalue_table'),'Data',gradtab);


function accept_button_callback(hObject,eventdata)
handles=guidata(findobj('Tag','GUI_ImageOrientation'));
gradtab = get(findobj('Tag','bvalue_table'),'Data');
close(findobj('Tag','bvaluelistfig'));
data= handles.data.data.image;
bval=squeeze(gradtab(:,1));
gradsheme = squeeze(gradtab(:,2:4));
Tens = calc_Tens(bval,gradsheme,data);
handles.data.data.Tens = Tens;
DWI_string = get(handles.display_popupmenu_DWI,'String');
if isempty(cell2mat(strfind(DWI_string,'colormap')))
    DWI_string{length(DWI_string)+1}='colormap';
    DWI_string{length(DWI_string)+1}='Trace';
    DWI_string{length(DWI_string)+1}='FA';
    DWI_string{length(DWI_string)+1}='RA';
    DWI_string{length(DWI_string)+1}='VR';
    DWI_string{length(DWI_string)+1}='vap1';
    DWI_string{length(DWI_string)+1}='vap2';
    DWI_string{length(DWI_string)+1}='vap3';
    DWI_string{length(DWI_string)+1}='Dparr';
    DWI_string{length(DWI_string)+1}='Dorth';
    set(handles.display_popupmenu_DWI,'String',DWI_string);
end
guidata(findobj('Tag','GUI_ImageOrientation'),handles);


