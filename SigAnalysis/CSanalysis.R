matfn = "C:/Users/uchidalab/Documents/GitHub/Inputome_analysis/SigAnalysis/Results_nonlight.txt";
Inputome = read.table(matfn,header = TRUE,sep = ",")
# preprocess data
# add brainAreaGrouped, which groups type2 and type3
Inputome$brainAreaGrouped <- Inputome$brainArea
savefile = "CSsig_nonlight.pptx"
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
AreaNames <- c('Dorsal striatum','Ventral striatum','Ventral pallidum',
               'Central amygdala','Lateral hypothalamus','RMTg','PPTg','VTA type3','VTA type2','Dopamine')

CS.perR$brainArea <- factor(CS.perR$brainArea, AreaNames)

library(ggplot2)
library(scales)
theme_set(theme_classic(base_size = 18))

ggplot(CS.perR[which(CS.perR$ResponseType== "CSsig"),] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent,limits = c(0, 1)) + scale_fill_manual(values= cbPalette[1])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE)

ggplot(CS.perR[CS.perR$ResponseType== "CSsig"|CS.perR$ResponseType== "csValue",] ,       
       aes(x = brainArea, y = ResponseValue.PROP,fill = ResponseType,order = ResponseType)) +
  geom_bar(stat = "identity",position = "identity") + labs(x="", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent,limits = c(0, 1)) + scale_fill_manual(values= cbPalette[1:2])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE)


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
CS.dirProp$brainArea <- factor(CS.dirProp$brainArea, AreaNames)



ggplot(CS.dirProp[CS.dirProp$Epoch== "csValue"& (CS.dirProp$Type != "non-response"),] ,      
       aes(x = brainArea, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent,limits = c(0, 1)) + scale_fill_manual(values= cbPalette[c(5,3,1)])+coord_flip()+
  theme(legend.position = "top",legend.title=element_blank())
graph2ppt(file=savefile, append=TRUE)

CS.dirProp$Epoch <- factor(CS.dirProp$Epoch, c("csValue","EarlydelayValue","delayValue"))

ggplot(CS.dirProp[(CS.dirProp$Type != "non-response"),] ,      
       aes(x = brainArea, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x="", y= "", title="Cue Response")+
  scale_y_continuous(labels  = percent,limits = c(0, 1)) + scale_fill_manual(values= cbPalette[c(5,3,1)]) +coord_flip()+
   facet_wrap(~Epoch) + theme(legend.position = "top")
graph2ppt(file=savefile, append=TRUE)


ggplot(CS.dirProp[(CS.dirProp$Type != "non-response"),] ,      
       aes(x = Epoch, y = Response.Prop ,fill = Type,order = Type)) +
  geom_bar(stat = "identity") + labs(x = "",y= "Percent neuron")+
  scale_y_continuous(labels  = percent,limits = c(0, 1)) + scale_fill_manual(values= cbPalette[c(5,3,1)]) +
  facet_wrap(~brainArea) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_x_discrete(labels=c("Cue","Early delay","Late delay"))
graph2ppt(file=savefile, append=TRUE)


