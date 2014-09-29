% This script compute the volume of the tissu (overall - vessel) to use for
% the baseline CMRO2 computation.
%
% 3/10/2013 by L. Gagnon


load 20100203_NCES_v1_wMesh.mat

%%
% using elements of the mesh
total_vol=sum(im2.Mesh.nodevol);
vessel_vol=sum(im2.Adv.volg);
tissue_vol=total_vol-vessel_vol;

display(sprintf('tissu volume is: %1.2e um^3',tissue_vol))


%%
%using the graph 
ROIx=[0 635];    %um
ROIy=[0 635];    %um
ROIz=[0 604];    %um


%segment inside the ROI
lstSegIn=find( im2.segPos(:,1)*im2.Hvox(1)>=ROIx(1) & im2.segPos(:,1)*im2.Hvox(1)<=ROIx(2) & im2.segPos(:,2)*im2.Hvox(2)>=ROIy(1) & im2.segPos(:,2)*im2.Hvox(2)<=ROIy(2) & im2.segPos(:,3)*im2.Hvox(3)>=ROIz(1) & im2.segPos(:,3)*im2.Hvox(3)<=ROIz(2) );

total_vol=(ROIx(2)-ROIx(1))*(ROIy(2)-ROIy(1))*(ROIz(2)-ROIz(1));
vessel_vol=sum(im2.segLen_um(lstSegIn).*pi.*( im2.segDiam(lstSegIn)./2 ).^2);

tissue_vol=total_vol-vessel_vol;
 
display(sprintf('tissu volume is: %1.2e um^3',tissue_vol))




