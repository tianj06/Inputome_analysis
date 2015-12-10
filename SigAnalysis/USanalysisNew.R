rm(list = ls())
matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/us_nonlight.txt";
us = read.table(matfn,header = TRUE,sep = ",")

library(tidyr)
us.long <- gather(us,ResponseType, sig,-brainArea)

library(plyr)
us.perR <- ddply(us.long,.(ResponseType,brainArea),summarise,
                       ResponseValue.PROP = mean(sig))

library("ggplot2")
library("scales")
library(export)
savefile = 'USsig_nonlight.pptx'
theme_set(theme_classic(base_size = 18))
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
AreaNames <- c('Ventral striatum','Dorsal striatum','Ventral pallidum',
  'Subthalamic','Lateral hypothalamus','RMTg','PPTg','VTA type3','VTA type2','Dopamine',
  'r VTA Type3', 'rVTA Type2','rdopamine')
AreaNames <- rev(AreaNames)
us.perR$brainArea <- factor(us.perR$brainArea, AreaNames) 

# plot percent of reward responsive neurons
ggplot(us.perR[which(us.perR$ResponseType== "sig50Rvs50OM"),] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1])+
  coord_flip()+theme(legend.position="top",legend.title=element_blank())

graph2ppt(file=savefile, append=TRUE,aspectr=1.33)
# plot percent of reward responsive neurons and pure reward neurons

us.reward = us.perR[us.perR$ResponseType== "sig50Rvs50OM"|us.perR$ResponseType== "pureReward",]
ggplot(us.reward , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + 
  labs(x="", y= "", title="Reward Response")+scale_y_continuous(labels  = percent) + 
  scale_fill_manual(values= cbPalette[1:2])+coord_flip()+theme(legend.position="top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE,aspectr=1.33)

# plot percent of reward responsive neurons and pure us reward neurons and pure reward no cs response

us.reward = us.perR[us.perR$ResponseType== "sig50Rvs50OM"|us.perR$ResponseType== "pureReward"|
                      us.perR$ResponseType== "pureRewardWithCue",]
ggplot(us.reward , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + 
  labs(x="", y= "", title="Reward Response")+scale_y_continuous(labels  = percent) + 
  scale_fill_manual(values= cbPalette[1:3])+coord_flip()+theme(legend.position="top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE)

