#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

fs <- read.csv("raw/rep/audienceCommerciale.csv")
fs <- fs[order(-fs$Volume),]
fs$Volume <- fs$Volume/1000000
fs$Category.Name <- factor(fs$Category.Name,levels=fs$Category.Name)

gLabel = c("content","volume (Mio)",paste("users' interest"),"group")
p <- ggplot() +
    geom_bar(data=fs,aes(x=Category.Name,y=Volume,fill=Volume),stat="identity") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
p







