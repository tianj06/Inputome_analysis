rm(list = ls())
matfn = "D:/Dropbox (Uchida Lab)/lab/FunInputome/rabies/allIdentified/us.txt";
us = read.table(matfn,header = TRUE)

library(tidyr)
us.long <- gather(us,ResponseType, sig,-brainArea)

library(plyr)
us.perR <- ddply(us.long,.(ResponseType,brainArea),summarise,
                       ResponseValue.PROP = mean(sig))

library("ggplot2")
library("scales")
theme_set(theme_classic())
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
us.perR$brainArea <- factor(us.perR$brainArea, c("DA","VTA2","VTA3","St", "VP", "LH", "RMTg",'PPTg'))

# plot percent of reward responsive neurons
ggplot(us.perR[which(us.perR$ResponseType== "sig50Rvs50OM"),] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1])

# plot percent of reward responsive neurons and pure reward neurons

us.reward = us.perR[us.perR$ResponseType== "sig50Rvs50OM"|us.perR$ResponseType== "pureReward",]
ggplot(us.reward , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + 
  labs(x="brain area", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1:2])

us.rpe = us.perR[us.perR$ResponseType== "mixed"|us.perR$ResponseType== "pureReward"|
                      us.perR$ResponseType== "RPE",]

# plot percent of reward responsive neurons
us.rpe$ResponseType <- factor(us.rpe$ResponseType, levels = c("pureReward","RPE",'mixed'))

ggplot(us.rpe , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent)+ scale_fill_manual(values= cbPalette[c(2,3,1)])+
theme(axis.text.x = element_text(angle = 45, hjust = 1))

# plot percent of expectation signal
us.exp = us.perR[us.perR$ResponseType== "pureExp"|us.perR$ResponseType== "other",]
us.exp$ResponseType <- factor(us.exp$ResponseType, levels = c("pureExp","other"))


ggplot(us.exp , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Non Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1)) + scale_fill_manual(values= cbPalette[4:5])+
 theme(axis.text.x = element_text(angle = 45, hjust = 1))

# plot CS and delay responsive neurons

us.all <- rbind(subset(us.exp, ResponseType == "pureExp"), us.rpe)
us.all$ResponseType <- factor(us.all$ResponseType, levels = c("pureReward","pureExp","RPE",'mixed'))
ggplot(us.all , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Non Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1)) + scale_fill_manual(values= cbPalette[c(2,4,1,1)])

# plot percent of RPE neurons

ggplot(us.rpe[-(1:16),] , aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType, order=ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Reward Response")+
  scale_y_continuous(labels  = percent,limits = c(0,1))+ scale_fill_manual(values= cbPalette[c(3)])

