#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

#fs <- read.csv('http://dashboard.ad.dotandad.com/downloadFullReportExcel.jsp?p=448d78ad-fbe3-42e5-a6ae-84e9f2a7d238_9220')

fs <- read.csv('raw/impressions23.csv',encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##

## devShare <- ddply(fs[grepl('RTB',fs$Section),],.(AdvertiserType),summarise,imps=sum(Imps,na.rm=TRUE))
## devShare$share <- devShare$imps/sum(devShare$imps)

fs$x <- fs$Data
fs$Imps <- as.numeric(as.character(gsub("[[:punct:]]","",fs$Imps)))
fs$AdvertiserType <- as.character(fs$AdvertiserType)
sectId <-  grepl('XAXIS',fs$Section) | grepl('RTB',fs$Section)
sum(fs[grepl('RTB',fs$Section),"Imps"],na.rm=TRUE)
progShare <- sum(fs[sectId,"Imps"],na.rm=TRUE)
dirShare <- sum(fs[!sectId,"Imps"],na.rm=TRUE)
progShare/dirShare
fs <- fs[!sectId,]
##head(fs)
timeVar <- names(table(fs$x))
filterList <- c(names(table(fs$AdvertiserType)))
##filterList <- filterList[-]1

metricVar <- c("impressions")
metricType <- c("measured")
devFile <- c("desktop")
metricVar <- c("Imps")
filterName <- "AdvertiserType"
source("script/Old/comImpr.R")
#source("script/comGraph.R")

filterDat <- as.data.frame(timeVar)
##-tappi (autopromo,default)
tapIdx <- grepl('Tapp',fs$FlightDescription) | grepl('TAPP',fs$FlightDescription)
##count(sum(fs[grepl('XAXIS',fs$Section),]$Imps )
view <- comImprFilter(fs[!tapIdx,],sectType,timeVar,metricVar,metricType,filterList,filterName)

filterDat$Paganti <- as.vector(t(view[view$filter=="Paganti",-1]))
filterDat$Default <- as.vector(t(view[view$filter=="Default",-1]))
filterDat$Autopromo <- as.vector(t(view[view$filter=="Autopromo",-1]))
##tappi
filterDat$Tappi <- sapply(timeVar,function(xx) sum(subset(fs[tapIdx,],x==xx)["Imps"],na.rm=TRUE))
##total
filterDat$Total <- filterDat$Paganti + filterDat$Default + filterDat$Autopromo + filterDat$Tappi #sapply(timeVar,function(xx) sum(subset(fs,x==xx)["Imps"],na.rm=TRUE))

filterDat$timeVar <- as.Date(filterDat$timeVar)
filterDat <- filterDat[with(filterDat,rev(order(timeVar))),]
fName <- paste("out/advertiserDay",min(timeVar),".",max(timeVar),".csv",sep="")
write.csv(filterDat,fName)

sSum <- sapply(names(table(fs$Section)),function(x) sum(fs[fs$Section==x,"Imps"]))
sSum <- sSum[order(-sSum)]
sum(sSum[c(1:5)])/sum(sSum)
sSum[c(1:5)]

fs <- read.csv('raw/impressionsPartner23.csv',encoding="UTF-8",fill=TRUE,sep=",",quote='"',header=TRUE,stringsAsFactors=FALSE)##
fs$x <- fs$Data
fs$AdvertiserType <- as.character(fs$AdvertiserType)
fs$Imps <- as.numeric(as.character(gsub("[[:punct:]]","",fs$Imps)))
colnames(fs)

timeVar <- names(table(fs$x))
filterList <- c(names(table(fs$AdvertiserType)))
##filterList <- filterList[-1]

metricVar <- c("impressions")
metricType <- c("measured")
devFile <- c("desktop")
metricVar <- c("Imps")
filterName <- "AdvertiserType"

fs$Imps <- as.numeric(as.character(gsub("\\'","",fs$Imps)))

table(view$filter)

partnerDat <- as.data.frame(timeVar)
##-tappi (autopromo,default)
view <- comImprFilter(fs,sectType,timeVar,metricVar,metricType,filterList,filterName)
partnerDat$Paganti <- as.vector(t(view[view$filter=="Paganti",-1]))
partnerDat$Autopromo <- as.vector(t(view[view$filter=="Autopromo",-1]))
partnerDat$Default <- as.vector(t(view[view$filter=="Default",-1]))
partnerDat$Total <- as.vector(t(view[view$filter=="total",-1]))
partnerDat$Invenduto <-  partnerDat$Total - partnerDat$Paganti

partnerDat <- partnerDat[with(partnerDat,rev(order(timeVar))),]
fName <- paste("out/advertiserPartnerDay",min(timeVar),".",max(timeVar),".csv",sep="")
write.csv(partnerDat,fName)



fs[order(-fs$Imps),c("Partner","Imps")] %>% head

sSum <- sapply(names(table(fs$Partner)),function(x) sum(fs[fs$Partner==x,"Imps"],na.rm=TRUE))
sSum <- sSum[order(-sSum)]
sSum/sum(sSum)

sSum


##59497+69899+22053+76187
filterDat$day <- c("Sunday","Saturday","Friday","Thursday","Wednesday","Tuesday","Monday")

cbind(filterDat[,c("timeVar","day","Paganti","Default","Autopromo","Tappi")],partnerDat[,c("Paganti","Invenduto")])



fs <- read.csv('raw/inventoryWeek13-16.csv')
head(fs)

fs <- fs[,c("Data","Totale.inventory")]
head(fs)

ggplot()+
    geom_line(data=fs,aes(x=Data,y=Totale.inventory,group=1),size=2)
