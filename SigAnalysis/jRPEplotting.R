matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/jRPE2.txt";
jRPE = read.table(matfn,header = TRUE,sep = ",")
library(reshape2)
library(plyr)
library(ggplot2)
library(scales)
savefile = "USsig.pptx"
theme_set(theme_classic(base_size = 18))
RPE <- ddply(jRPE,"brainArea",summarize,posRPE=mean(CSposRPE),allRPE= mean(CSposNegRPE))
RPE.l <- melt(RPE,id.vars = "brainArea", variable.name = "RPEtype",value.name = "Response.Prop")
AreaNames <- c('Dorsal striatum','Ventral striatum','Ventral pallidum',
               'Subthalamic','Lateral hypothalamus','RMTg','PPTg','VTA type3','VTA type2','Dopamine')
RPE.l$brainArea <- factor(RPE.l$brainArea,AreaNames)

ggplot(RPE.l[RPE.l$RPEtype=="posRPE",],aes(x = brainArea, y = Response.Prop,fill = RPEtype)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="RPE response(Cue and Reward)")+
  scale_y_continuous(labels  = percent,limits = c(0,1) ) + scale_fill_manual(values= cbPalette[1])+
  coord_flip()+theme(legend.position="top",legend.title=element_blank()) 
graph2ppt(file=savefile, append=TRUE)

ggplot(RPE.l,aes(x = brainArea, y = Response.Prop,fill = RPEtype)) +
  geom_bar(stat = "identity",position = "identity") + labs(x="", y= "", title="RPE response(Cue and Reward)")+
  scale_y_continuous(labels  = percent,limits = c(0,1) ) + scale_fill_manual(values= cbPalette[1:2]) +
  coord_flip()+theme(legend.position="top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE)

