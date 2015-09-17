matfn = "C:/Users/Hideyuki/Dropbox (Uchida Lab)/lab/FunInputome/rabies/allIdentified/jRPE.txt";
jRPE = read.table(matfn,header = TRUE)
library(reshape2)
library(plyr)
library(ggplot2)
library(scales)
theme_set(theme_classic())
RPE <- ddply(jRPE,"brainArea",summarize,posRPE=mean(CSposRPE),allRPE= mean(CSposNegRPE))
RPE.l <- melt(RPE,id.vars = "brainArea", variable.name = "RPEtype",value.name = "Response.Prop")

RPE.l$brainArea <- factor(RPE.l$brainArea,c("DA","VTA2","VTA3","St", "VP", "LH", "RMTg",'PPTg'))

ggplot(RPE.l[RPE.l$RPEtype=="posRPE",],aes(x = brainArea, y = Response.Prop,fill = RPEtype)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="RPE response(Cue and Reward)")+
  scale_y_continuous(labels  = percent,limits = c(0,1) ) + scale_fill_manual(values= cbPalette[1]) 

ggplot(RPE.l,aes(x = brainArea, y = Response.Prop,fill = RPEtype)) +
  geom_bar(stat = "identity",position = "identity") + labs(x="brain area", y= "", title="RPE response(Cue and Reward)")+
  scale_y_continuous(labels  = percent,limits = c(0,1) ) + scale_fill_manual(values= cbPalette[1:2]) 