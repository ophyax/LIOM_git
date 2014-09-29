#!/bin/bash

Bfield=3;

#Echo time
TE=30; #in msec

#Gradients
Gx=50;

#B-field orientation angle
phi_angle=90;
omega_angle=45;

#timing activation 
O2idx=1;
Flowidx=240;

#timing baseline
O2baseidx=1
Flowbaseidx=1;

#ROI
ROIx1=0;
ROIx2=725;
ROIy1=0;
ROIy2=725;
ROIz1=0;
ROIz2=400;
                  
#for (( i=0; i<=(${#omega_angle_list[@]}-1); i=i+1 ))

#do
    
    
   
    eval $(printf "pbsubmit -q max200 -n 8 -c \'./run_MCprotonA_Hybrid7.sh /usr/pubsw/common/matlab/7.11/ %1.1f %d %d %d %d %d %d %d %d %d %d /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/advection_sigmoid/CMRO2_5dot7/sigmoid10/20100203_NCES_Sigmoid_Full_Oxygenated.mat        %d      /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/dilation/dilate_vessel_NCES_Sigmoid10.mat    %d    /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20100203/advection_sigmoid/CMRO2_5dot7/sigmoid10/20100203_NCES_Sigmoid_dOC_0per_Avg_1000ms.mat        %d     %d'\n " $Bfield $phi_angle $omega_angle $TE $Gx $ROIx1 $ROIx2 $ROIy1 $ROIy2 $ROIz1 $ROIz2 $O2idx $Flowidx $O2baseidx $Flowbaseidx)  
    sleep 2
    
    
   

#done








