#!/usr/bin/env Rscript
setwd('C:/Users/giovanni.marelli.PUBMI2/lav/media/')
source('script/graphEnv.R')
library(splines)


fs <- read.csv('rep/zalandoHit.csv')
fs$Perid <- as.Date(fs$Period)
fs$Hits <- as.numeric(fs$Hits)

ggplot(fs,aes(x=Period,y=Hits,color=Container.Name,group=Container.Name)) +
    geom_line(size=2)


fs <- read.csv('rep/nielsenCanale2.csv')
melted <- melt(fs[-c(12,24),])
gLabel = c("segment","percentage",paste("audience composition"),"-")
ggplot(melted,aes(x=Demo.Segment,y=value,group=variable)) +
    geom_bar(aes(fill=variable),position="dodge",stat="identity") +
    ##geom_line(data=data.frame(spline(melted, n=nrow(melted)*10))) +
    scale_fill_manual("",values=gCol1,breaks=unique(melted$variable)) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])





