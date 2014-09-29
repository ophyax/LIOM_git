#!/bin/bash

Bfield=7;

#Echo time
TE=48; #in msec

#Gradients
Gx=0; #to be able read several TEs

#B-field orientation angle
phi_angle=0;
omega_angle_list=(90);

#timing activation 
O2idx=2;
Flowidx=2;

#timing baseline
O2baseidx=1
Flowbaseidx=1;

#ROI
ROIx1=0;
ROIx2=530;
ROIy1=280;
ROIy2=725;
ROIz1=0;
ROIz2=600;
                  
for (( i=0; i<=(${#omega_angle_list[@]}-1); i=i+1 ))

do
    
    
   
    eval $(printf "pbsubmit -q max200 -n 8 -c \'./run_MCprotonA_Hybrid7.sh /usr/pubsw/common/matlab/7.11/ %1.1f %d %d %d %d %d %d %d %d %d %d /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120626/test_angular_dependence/20120626_test_pO2.mat        %d      /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120626/test_angular_dependence/20120626_test_vol.mat    %d    /autofs/cluster/bartman/2/users/lgagnon/2013/mouse_20120626/test_angular_dependence/20120626_test_pO2.mat        %d     %d'\n " $Bfield $phi_angle ${omega_angle_list[i]} $TE $Gx $ROIx1 $ROIx2 $ROIy1 $ROIy2 $ROIz1 $ROIz2 $O2idx $Flowidx $O2baseidx $Flowbaseidx)  
    sleep 2
    
    
    
    

done








