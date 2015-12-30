savePath = 'C:\Users\uchidalab\Dropbox (Uchida Lab)\lab\FunInputome\writing\Figures\tempSVGfigures\';
plot_pop_summary_fromAnalyzedPanel_USplus(fl(clustLabel==4&strcmp(brainArea,'VTA type2')'),savePath,'a',6)
plot_pop_summary_fromAnalyzedPanel_USplus(fl(clustLabel==4&strcmp(brainArea,'Ventral pallidum')'),savePath,'a')


plot_pop_summary_fromAnalyzedPanel_USplus(fl(clustLabel==4&strcmp(brainArea,'Lateral hypothalamus')'),savePath,'a',6)

plot_pop_summary_fromAnalyzedPanel_USplus(fl(clustLabel==4&strcmp(brainArea,'Dorsal striatum')'),savePath,'a',6)



plot_pop_summary_fromAnalyzedPanel_USplus(fl(lightLabel&AAVlabel'),savePath,'a',6)
