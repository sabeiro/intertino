#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')
##rm(list=ls())

source('script/graphEnv.R')
comprob <- 0.96
fs <- read.csv('raw/flightPriceReport.csv',encoding="UTF-8",sep=",",header=TRUE)
fs <- fs[grepl("SPOT",fs$Size),]
head(fs)


priceSize <- ddply(fs,.(Size),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
priceSize$cpm <- priceSize$price/priceSize$imps*1000
priceSize$cpmTot <- priceSize$priceTot/priceSize$imps*1000

priceData <- ddply(fs,.(Data),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
priceData$cpm <- priceData$price/priceData$imps*1000
priceData$cpmTot <- priceData$priceTot/priceData$imps*1000

priceId <- ddply(fs,.(FlightID),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
priceId$cpm <- priceId$price/priceId$imps*1000
priceId$cpmTot <- priceId$priceTot/priceId$imps*1000
priceId <- priceId[order(-priceId$imps),]


fs <- read.csv('raw/flightPriceVideo2.csv',encoding="UTF-8",sep=",",header=TRUE)
fs$Imps <- as.numeric(as.character(gsub("[[:punct:]]","",fs$Imps)))
##fs$AdvertiserType <- as.character(fs$AdvertiserType)
##sectId <-  grepl('XAXIS',fs$Section) | grepl('RTB',fs$Section)
##fs <- fs[!sectId,]
##fs <- fs[!fs$FlightPrice<0.0000001,]
fs$cpm <- fs$FlightTotalSales/fs$Imps*1000
sum(fs$FlightPrice,na.rm=TRUE)/sum(fs$Imps,na.rm=TRUE)
sectId <- fs$cpm<50
sectId[is.na(sectId)] <- FALSE
sum(fs[sectId,"FlightTotalSales"],na.rm=TRUE)/sum(fs[sectId,"Imps"],na.rm=TRUE)*1000
fs <- fs[order(-fs$Imps),]
head(fs,n=15)
write.csv(fs,"out/AnomalieCpm.csv")


priceId <- ddply(fs,.(Section),summarise,imps=sum(Imps,na.rm=TRUE),price=sum(FlightPrice,na.rm=TRUE),priceTot=sum(FlightTotalSales,na.rm=TRUE))
priceId[is.na(priceId)] <- 0
head(priceId)
sum(priceId$price,na.rm=TRUE)/sum(priceId$imps,na.rm=TRUE)
sum(priceId$priceTot,na.rm=TRUE)/sum(priceId$imps,na.rm=TRUE)*1000


priceId$cpm <- priceId$price/priceId$imps*1000
priceId$cpmTot <- priceId$priceTot/priceId$imps*1000
priceId <- priceId[order(-priceId$cpmTot),]
priceId$cpm[priceId$cpm==Inf] <- 0

head(priceId)

table(fs$Size)
boxplot(priceId$cpmTot)
summary(priceId$cpmTot)
hist(priceId$cpmTot)
mean(priceId$cpmTot,na.rm=TRUE)
weighted.mean(priceId$priceTot,priceId$imps,na.rm=TRUE)



