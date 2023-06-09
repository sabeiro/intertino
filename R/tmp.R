#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library('tm')
source('script/CommLibrary.R')

fs <- read.csv('raw/tmp.csv')

aggr1 <- ddply(fs,.(Section),summarise,imps=sum(Imps,na.rm=TRUE))
aggr1 <- aggr1[order(-aggr1$imps),]

var <- "AdvertiserName"
fs[,var] <- tryTolower(fs[,var])
advT <- fs[grep("sky",fs[,var]),]

advT$cpm <- advT$FlightTotalSale/advT$Imps*1000

write.csv(advT,"out/tmp.csv")


sum(advT$FlightTotalSale)
sum(advT$FlightPrice)
