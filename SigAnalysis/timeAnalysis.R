library(tidyr)
library(plyr)
library("ggplot2")
library("scales")


rm(list = ls())
# read us
matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/us_time_all1.txt";
us = read.table(matfn,header = TRUE,sep = ",")
us <- us[c('Timewin','brainArea','pureReward','Rewardsign','pureExp','pureExpDir','RPE','pureRPEDir','mixed')]
tempIdx <- (us[ "pureReward"]==1) & (us[ "Rewardsign"]==0)
us[ tempIdx, "Rewardsign"] = 2
us["Rewardsign"] = us["Rewardsign"]*us["pureReward"]
us <- us[c("Rewardsign",'pureExpDir','pureRPEDir','Timewin','brainArea')]
# turn to long shape
us.long <- gather(us,responseType, responseDir, -brainArea,-Timewin)
us.long['excitation'] = 1*(us.long['responseDir']==1)
us.long['inhibtion'] = 1*(us.long['responseDir']==2)

us.perR <- ddply(us.long,.(responseType,brainArea,Timewin),numcolwise(mean))
us.perR['responseDir']<- NULL
us.perR <- gather(us.perR, responseDir,per,-responseType,-brainArea,-Timewin)

us.perR['responseDir']<-interaction(us.perR[["responseDir"]], us.perR[["responseType"]]) 


# read cs
matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/CSresults_all.txt";
Inputome = read.table(matfn,header = TRUE,sep = ",")
CS <- Inputome[c("csValue","delayValue","EarlydelayValue","brainArea")]

CS.long <- gather(CS,timewindow,responseDir,-brainArea)
CS.long['excitation'] = 1*(CS.long['responseDir']==1)
CS.long['inhibtion'] = 1*(CS.long['responseDir']==-1)

cs.perR <- ddply(CS.long,.(brainArea,timewindow),numcolwise(mean))
cs.perR['responseDir']<- NULL
cs.perR = rename(cs.perR, c("timewindow"="Timewin"))
cs.perR <- gather(cs.perR, responseDir,per,-brainArea,-Timewin)

theme_set(theme_classic(base_size = 18))
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")


#us.perR$brainArea <- factor(us.perR$brainArea, AreaNames) 
csus = rbind(cs.perR, us.perR[c('brainArea','Timewin','responseDir','per')])
csus$Timewin <- factor(csus$Timewin, 
                levels = c("csValue","EarlydelayValue","delayValue","before","early","late"))

# remove rabies VTA neurons
tempIdx = is.element(csus$brainArea, c('r VTA Type3', 'rVTA Type2','rdopamine'))
csus<- csus[!tempIdx,]

ggplot(csus,      
       aes(x = Timewin, y = per,fill = responseDir,order = responseDir)) +
  geom_bar(stat = "identity") + labs(x = "",y= "Percent neuron")+ scale_fill_manual(values= cbPalette)+
  scale_y_continuous(labels  = percent,limits = c(0, 1))  +
  facet_wrap(~brainArea) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_discrete(labels=c("Cue","Early delay","Late delay","Late delay","early","late"))



#graph2ppt(file=savefile, append=TRUE)

