matfn = "D:/Dropbox (Uchida Lab)/lab/FunInputome/rabies/allIdentified/Results.txt";
Inputome = read.table(matfn,header = TRUE)
# preprocess data
# add brainAreaGrouped, which groups type2 and type3
Inputome$brainAreaGrouped <- Inputome$brainArea
Inputome$brainAreaGrouped[grep("VTA+",Inputome$brainArea, perl=TRUE)] = "VTA2"

CS <- Inputome[c("CSsig","Expsig","EarlyExpsig","csValue","delayValue","EarlydelayValue","brainArea")]
CS[,4:6] <- abs(CS[,4:6]) 
for (i in 1:3) {
  CS[,i+3] = CS[,i+3]* CS[,i]
}

library(tidyr)
CS.long <- gather(CS,ResponseType, sig,-brainArea)

library(plyr)
CS.perR <- ddply(CS.long,.(ResponseType,brainArea),summarise,
                 ResponseValue.PROP = mean(sig))
CS.perR$brainArea <- factor(CS.perR$brainArea, c("DA","VTA2","VTA3","St", "VP", "LH", "RMTg",'PPTg'))

library(ggplot2)
library(scales)
theme_set(theme_classic())

ggplot(CS.perR[which(CS.perR$ResponseType== "CSsig"),] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1])

ggplot(CS.perR[CS.perR$ResponseType== "CSsig"|CS.perR$ResponseType== "csValue",] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType,order = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + labs(x="brain area", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[1:2])


## plot direction (excitatioin vs inhibition)
CS <- Inputome[c("CSsig","Expsig","EarlyExpsig","csValue","delayValue","EarlydelayValue","brainArea")]
for (i in 1:3) {
  CS[,i+3] = CS[,i+3]* CS[,i]
  nonValueIdx <- CS[,i+3]==0 & CS[,i]==1
  CS[nonValueIdx,i+3] <- 3
}
CS <- CS[,-c(1:3)]
CS.dir <- CS
for (i in 1:3){
  CS.dir[,i] <- factor(CS[,i],c(0,1,-1,3),labels = c("non-response","Excitation","Inhibition","non-value"))
}


CS.dirlong <- gather(CS.dir,Epoch, Type,-brainArea)
CS.dirlong$Type <- as.factor(CS.dirlong$Type)

CS.dirlong <- ddply( CS.dirlong, .(Epoch,brainArea),transform, totalNeuron = length(Type))
CS.dirProp <- ddply(CS.dirlong, .(Epoch,brainArea,Type),summarise, 
                    Response.Prop = length(totalNeuron)/totalNeuron[1])
CS.dirProp$brainArea <- factor(CS.dirProp$brainArea, c("DA","VTA2","VTA3","St", "VP", "LH", "RMTg",'PPTg'))



ggplot(CS.dirProp[CS.dirProp$Epoch== "csValue"& (CS.dirProp$Type != "non-response"),] ,      
       aes(x = brainArea, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[c(5,3,1)])

CS.dirProp$Epoch <- factor(CS.dirProp$Epoch, c("csValue","EarlydelayValue","delayValue"))

ggplot(CS.dirProp[(CS.dirProp$Type != "non-response"),] ,      
       aes(x = brainArea, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x="brain area", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[c(5,3,1)]) +
   facet_wrap(~Epoch) 


ggplot(CS.dirProp[(CS.dirProp$Type != "non-response"),] ,      
       aes(x = Epoch, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x = "",y= "Percent neuron")+
  scale_y_continuous(labels  = percent) + scale_fill_manual(values= cbPalette[c(5,3,1)]) +
  facet_wrap(~brainArea) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_discrete(labels=c("Cue","Early delay","Late delay"))
  

