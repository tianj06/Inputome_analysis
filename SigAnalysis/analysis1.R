rm(list = ls())
matfn = "D:/Dropbox (Uchida Lab)/lab/FunInputome/rabies/allIdentified/Results.txt";
Inputome = read.table(matfn,header = TRUE)
# preprocess data
# add brainAreaGrouped, which groups type2 and type3
Inputome$brainAreaGrouped <- Inputome$brainArea
Inputome$brainAreaGrouped[grep("VTA+",Inputome$brainArea, perl=TRUE)] = "VTA2"

CS <- Inputome[c("CSsig","Expsig","EarlyExpsig","csValue","delayValue","EarlydelayValue","brainArea")]
# prepare data for ggplot2, wide to long
library(tidyr)
dataLong <- gather(Inputome, ResponseType, ResponseValue, 1:4)

# plot percentage of significant response for four catogories of response and each area
# first compute the percentage
library(plyr)
dataLong.perR <- ddply(dataLong,.(ResponseType,brainArea),summarise,
                       ResponseValue.PROP = mean(ResponseValue))
library("ggplot2")
theme_set(theme_classic())
#by response type
ggplot(dataLong.perR, aes(x = brainArea, y = ResponseValue.PROP)) +
   geom_bar(stat = "identity") + facet_wrap(~ResponseType) 
#by area
ggplot(dataLong.perR, aes(x = brainArea, y = ResponseValue.PROP, fill = ResponseType)) +
  geom_bar(stat = "identity",position="dodge") 

#plot overlap between different catagories for each area
dataWide <- Inputome
attach(dataWide)
dataWide$CS_Exp = CSsig&Expsig
dataWide$CS_EarlyExp = CSsig&EarlyExpsig
dataWide$EarlyExp_Exp = EarlyExpsig&Expsig
dataWide$Rew_Exp = Rewardsig&Expsig
dataWide$EarlyExp_Rew = EarlyExpsig&Rewardsig
dataWide$CS_Rew = CSsig&Rewardsig
detach(dataWide)
dataWide <- dataWide[, -(1:8)]
dataLong <- gather(dataWide, ResponseType, ResponseValue, 2:7)
dataLong.perR <- ddply(dataLong,.(ResponseType,brainArea),summarise,
                       ResponseValue.PROP = mean(ResponseValue))       

ggplot(dataLong.perR, aes(x =ResponseType , y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position="dodge") + facet_wrap(~brainArea) 



# add Reward Tag includes both RPE and pure reward signal
Inputome$RewardTag <-rep(0, nrow(Inputome)) 
Inputome$RewardTag[abs(Inputome$usReward)==1] <- 1
Inputome$RewardTag[abs(Inputome$usRPE1)==1] <-2
Inputome <- subset(Inputome, select = -c(usReward,usRPE1) )

Inputome[,5:7] <- lapply(Inputome[,5:7], factor,  c(0,-1,1), labels = c('Other','Inh','Ext'))
Inputome$RewardTag <- factor(Inputome$RewardTag, c(0,1,2), labels = c('Other','Reward','RPE'))


# table based plotting


CStable= table(Inputome$csValue, Inputome$brainArea,Inputome$CSsig)
SigCS_Summary = prop.table(CStable,2)[,,2]
barplot(SigCS_Summary, main="CS type (500ms)",
        xlab="Brain area", ylim = c(0,1),
        legend = rownames(SigCS_Summary)) 

Delaytable= table(Inputome$delayValue, Inputome$brainArea,Inputome$Expsig)
SigDelay_Summary = prop.table(Delaytable,2)[,,2]
barplot(SigDelay_Summary, main="Expectation type(500ms pre US)",
        xlab="Brain area", ylim = c(0,1),
        legend = rownames(SigDelay_Summary)) 

Rewardtable= table(Inputome$RewardTag, Inputome$brainArea,Inputome$Rewardsig)
SigReward_Summary = prop.table(Rewardtable,2)[,,2]
barplot(SigReward_Summary, main="US type(500ms after reward)",
        xlab="Brain area", ylim = c(0,1),
        legend = rownames(SigReward_Summary)) 

EarlyDtable= table(Inputome$EarlydelayValue, Inputome$brainArea, Inputome$EarlyExpsig)
SigED_Summary = prop.table(EarlyDtable,2)[,,2]
barplot(SigED_Summary, main="Early delay type(1000-1500ms after odor)",
        xlab="Brain area", ylim = c(0,1),
        legend = rownames(SigED_Summary)) 

Rewardtable= table(Inputome$RewardTag, Inputome$brainArea)
SigReward_Summary = prop.table(Rewardtable,2)
barplot(SigReward_Summary, main="US type(500ms after reward)",
        xlab="Brain area", ylim = c(0,1),
        legend = rownames(SigReward_Summary)) 

# neuron number plot
SigCS_Summary = CStable[,,2]
barplot(SigCS_Summary, main="CS type (500ms)",
        xlab="Brain area",legend = rownames(SigCS_Summary)) 

SigDelay_Summary = Delaytable[,,2]
barplot(SigDelay_Summary, main="Expectation type(500ms pre US)",
        xlab="Brain area",legend = rownames(SigDelay_Summary)) 

SigReward_Summary = Rewardtable[,,2]
barplot(SigReward_Summary, main="US type(500ms after reward)",
        xlab="Brain area",legend = rownames(SigReward_Summary)) 

stack(dcs)
# library(plyr)
# ddply(Inputome, c("brainArea","CSsig"), function(x) {
#   a = aggregate(x,list(value = x$csValue),nrow)/nrow(x)
#   data.frame(PercentSig = a)
# })


library("ggplot2")
ggplot(dcs,)


ggplot(data=d, aes(x=brainArea, y=sum_CSsig, fill=csValue)) +
  geom_bar(stat="identity")
totolNeuronPerArea = aggregate(Inputome$GroupCount, by=list(Inputome$brainArea), FUN=sum)
Inputome$Density = Inputome$sum_CSsig/totolNeuronPerArea[,2]


# percentage plot, using ggplot2
ValueLong <- gather(Inputome[,-(1:4)], ResponseType, ResponseValue, c(1:3))
ValueLong$ResponseValue <- as.factor(ValueLong$ResponseValue)
ValueLong.perR <- ddply(ValueLong,.(ResponseType,brainArea),summarise,
                        Inh = summary(ResponseValue))

ggplot(ValueLong.perR, aes(x =ResponseType , y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity",position="dodge") + facet_wrap(~brainArea) 
