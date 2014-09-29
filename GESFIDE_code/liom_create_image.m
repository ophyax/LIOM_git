path0 = 'D:\Users\Philippe Pouliot\Dropbox\GESFIDE_code\unsure_yet\test1';
file0 = 'MCproton_output.mat';
fname = fullfile(path0,file0);

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

print(hf,'-dtiff','-r0',fullfile(path0,'GESFIDE_test1.tiff'));

