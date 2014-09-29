load MCprotonA_Hybrid7_20120626_test_pO2_B0_7.0T_ori_[0_90]_TE48ms_Gx0_ROI_[0 530 280 725 0 600]_frame_2_volFrame_2.mat


hf=figure;
clf
set(gcf,'renderer','zbuffer')
set(gcf,'PaperPositionMode','auto')
dim_fig=get(hf,'Position');
dim_fig(3)=1.5*dim_fig(3); %horizontal
dim_fig(4)=1*dim_fig(4); %vertical
set(hf,'Position',dim_fig);
set(hf,'color','none');

subplot(1,2,1)
plot(tMCproton,signal_SE_EV_base,'r',tMCproton,signal_SE_EV,'b')
legend('baseline','activation')
xlabel('time (msec)')
ylabel('MR signal')

subplot(1,2,2)
plot(tMCproton,signal_SE_EV_base./signal_SE_EV,'k')
legend('ratio')
xlabel('time (msec)')

print -dtiff -r0 GESFIDE_test1.tiff

