matfn = "C:/Users/uchidalab/Dropbox (Uchida Lab)/lab/FunInputome/rabies/analysis2015Fall/clustering_all.txt";
cls = read.table(matfn,header = TRUE)
library("ggplot2")
library("hexbin")
theme_set(theme_classic())

ggplot (cls, aes (x = proj1, y = proj2,fill = Area)) + 
  stat_binhex (bins=10, aes (alpha = log(..density..))) + facet_wrap (~ Area)
ggplot (cls, aes (x = proj1, y = proj3,fill = Area)) + 
  stat_binhex (bins=10, aes (alpha = log(..density..))) + facet_wrap (~ Area)
