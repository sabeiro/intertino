#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')
##rm(list=ls())

source('script/graphEnv.R')

fs <- read.csv('raw/comScoreAprile.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreMarzo.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreFebbraio.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreGennaio.csv',encoding="UTF-8",sep=",",header=TRUE)
fs$Month <- "January"

fs <- read.csv('raw/Comscore09-12.2015.csv',encoding="UTF-8",sep=",",header=TRUE)
fs <- fs[-grep("September",fs$Month),]

##fs2 <- read.csv('raw/ComscoreGennaioGrazia.csv',encoding="UTF-8")
##fs2$Month <- gsub(" 2016","",fs$Month)

fs$Month <- gsub(" 2016","",fs$Month)
source('script/comLoad.R')
fs2 <- fs

devFile <- c("dur","bot")
devFile <- c("dur")
fSect <- "section"
table(fs[,fSect])
month <- unique(fs$Month)[1]

metricsCtr <- c("PC.Measured.Impressions","PC.Measured.Views","Mobile.App.Measured.Impressions","Mobile.App.Measured.Views","Mobile.Measured.Impressions","Mobile.Measured.Views")
metricDur <- c("Direct.View.Time.1.5s","Direct.View.Time.5.60s","Direct.View.Time....60s")
metricBot <- c("bot")
metrics <- c("impressions","views",metricsCtr,metricDur)#,metricBot)

##-------------section-comp---------------------
for(month in unique(fs$Month)){
    fs <- fs2[fs2$Month==month,]
    sectGrp <- ddply(fs[,c(fSect,metrics)],fSect,colwise(sum,na.rm=TRUE))
    fs1 <- fs[fs$format=="sn",]
    aggr1 <- ddply(fs1[,c(fSect,metrics)],fSect,colwise(sum,na.rm=TRUE))
    colnames(aggr1)[-1] <- gsub("$","_sn",colnames(aggr1)[-1])
    sectGrp <- merge(sectGrp,aggr1,by=fSect,all=TRUE)

    fs1 <- fs[fs$format=="rn"&fs$position=="u",]
    aggr1 <- ddply(fs1[,c(fSect,metrics)],fSect,colwise(sum,na.rm=TRUE))
    colnames(aggr1)[-1] <- gsub("$","_rn_u",colnames(aggr1)[-1])
    sectGrp <- merge(sectGrp,aggr1,by=fSect,all=TRUE)

    fs1 <- fs[fs$format=="rn"&fs$position=="2",]
    aggr1 <- ddply(fs1[,c(fSect,metrics)],fSect,colwise(sum,na.rm=TRUE))
    colnames(aggr1)[-1] <- gsub("$","_rn_2",colnames(aggr1)[-1])
    sectGrp <- merge(sectGrp,aggr1,by=fSect,all=TRUE)

    fs1 <- fs[fs$format=="rn"&fs$position=="3",]
    aggr1 <- ddply(fs1[,c(fSect,metrics)],fSect,colwise(sum,na.rm=TRUE))
    colnames(aggr1)[-1] <- gsub("$","_rn_3",colnames(aggr1)[-1])
    sectGrp <- merge(sectGrp,aggr1,by=fSect,all=TRUE)

    fName <- paste("out/comImprDevFormatMetrics",fSect,month,".csv",sep="")
    fName <- gsub(" ","",gsub("[[:digit:]]","",fName))
    print(fName)
    write.table(sectGrp,fName,row.names=FALSE,append=FALSE,sep="\t")
}


## AFFARI TURISMO INFORMATICA EDI
## ARREDAMENTO
## AUTO
## COSMESI
## DIREZIONE
## LARGO CONSUMO
## MODA

