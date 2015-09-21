rm(list = ls())
matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/us.txt";
us = read.table(matfn,header = TRUE,sep = ",")

library(tidyr)
us.long <- gather(us,ResponseType, sig,-brainArea)

library(plyr)
us.perR <- ddply(us.long,.(ResponseType,brainArea),summarise,
                       ResponseValue.PROP = mean(sig))

library("ggplot2")
library("scales")
library(export)
theme_set(theme_classic(base_size = 18))
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
AreaNames <- c('Dorsal striatum','Ventral striatum','Ventral pallidum',
  'Central amygdala','Lateral hypothalamus','RMTg','PPTg','VTA type3','VTA type2','Dopamine')
us.perR$brainArea <- factor(us.perR$brainArea, AreaNames) 

# plot percent of reward responsive neurons
ggplot(us.perR[which(us.perR$ResponseType== "sig50Rvs50OM"),] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1])+
  coord_flip()+theme(legend.position="top",legend.title=element_blank())

graph2ppt(file="USsig.pptx", append=TRUE)
# plot percent of reward responsive neurons and pure reward neurons

us.reward = us.perR[us.perR$ResponseType== "sig50Rvs50OM"|us.perR$ResponseType== "pureReward",]
ggplot(us.reward , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + 
  labs(x="", y= "", title="Reward Response")+scale_y_continuous(labels  = percent) + 
  scale_fill_manual(values= cbPalette[1:2])+coord_flip()+theme(legend.position="top",legend.title=element_blank())
graph2ppt(file="USsig.pptx", append=TRUE)

us.rpe = us.perR[us.perR$ResponseType== "mixed"|us.perR$ResponseType== "pureReward"|
                      us.perR$ResponseType== "RPE",]

# plot percent of reward responsive neurons
us.rpe$ResponseType <- factor(us.rpe$ResponseType, levels = c("pureReward","RPE",'mixed'))

ggplot(us.rpe , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Reward Response") +
  scale_y_continuous(labels  = percent)+ scale_fill_manual(values= cbPalette[c(2,3,1)])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file="USsig.pptx", append=TRUE)
# plot percent of expectation signal
us.exp = us.perR[us.perR$ResponseType== "pureExp"|us.perR$ResponseType== "other",]
us.exp$ResponseType <- factor(us.exp$ResponseType, levels = c("pureExp","other"))


ggplot(us.exp , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Non Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1)) + scale_fill_manual(values= cbPalette[4:5])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file="USsig.pptx", append=TRUE)

# plot CS and delay responsive neurons

us.all <- rbind(subset(us.exp, ResponseType == "pureExp"), us.rpe)
us.all$ResponseType <- factor(us.all$ResponseType, levels = c("pureReward","pureExp","RPE",'mixed'))
ggplot(us.all , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="",y= "", title="Non Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1)) + scale_fill_manual(values= cbPalette[c(2,4,1,1)])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())

graph2ppt(file="USsig.pptx", append=TRUE)

# plot percent of RPE neurons

ggplot(us.rpe[-(1:10),] , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1))+ scale_fill_manual(values= cbPalette[c(3,1)])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file="USsig.pptx", append=TRUE)

