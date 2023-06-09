#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
rm(list=ls())

source('script/graphEnv.R')

fs <- read.csv('raw/comScoreMaggio.csv',encoding="UTF-8",sep=",",header=TRUE)
fs$Month <- "May"

fs <- read.csv('raw/comScoreAprile.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreMarzo.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreFebbraio.csv',encoding="UTF-8",sep=",",header=TRUE)

fs <- read.csv('raw/comScoreGennaio.csv',encoding="UTF-8",sep=",",header=TRUE)
fs$Month <- "January"

fs <- read.csv('raw/Comscore09-12.2015.csv',encoding="UTF-8",sep=",",header=TRUE)
fs <- fs[-grep("September",fs$Month),]

##fs2 <- read.csv('raw/ComscoreGennaioGrazia.csv',encoding="UTF-8")

fs$Month <- gsub(" 2016","",fs$Month)
source('script/comLoad.R')
fs2 <- fs
devFile <- c("pc","mob")
fSect <- "section"
month <- unique(fs$Month)[1]
## sort(table(fs2$section),sort="ascending")

head(fs)
str(fs)
table(fs$position)
##-------------section-comp---------------------
for(month in unique(fs$Month)){
    fs <- fs2[fs2$Month==month,]
    ##fs <- fs2[fs2$section=="home|TGCOM|rti",]
    sectGrp <- ddply(fs,fSect,summarise,imps = sum(impressions,na.rm=TRUE),views = sum(views,na.rm=TRUE))
    empty <- rep(0,length(sectGrp$imps))
    for(dev in devFile){
        if(any(grep("pc",dev))){
            print(dev)
            fs$impressions <- fs$PC.Measured.Impressions
            fs$views <- fs$PC.Measured.Views
        } else if(any(grep("app",dev))){
            print(dev)
            fs$impressions <-  fs$Mobile.App.Measured.Impressions
            fs$views <-  fs$Mobile.App.Measured.Views
        } else if(any(grep("mob",dev))){
            print(dev)
            fs$impressions <-  fs$Mobile.Measured.Impressions
            fs$views <-  fs$Mobile.Measured.Views
        }
        fs1 <- fs[fs$format=="sn",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(impressions,na.rm=TRUE),views = sum(views,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".sn",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".sn",sep="")] <- x
        ## sectGrp[sectGrp[,fSect] %in% aggr1[,fSect],paste("view.",dev,".sn",sep="")] <- aggr1$imps[-l ength(aggr1$imps)]
        ## sectGrp[sectGrp[,fSect] %in% aggr1[,fSect],paste("view.",dev,".sn",sep="")] <- aggr1$view[-length(aggr1$view)]

        fs1 <- fs[fs$format=="rn"&fs$position=="u",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(impressions,na.rm=TRUE),views = sum(views,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".rn_u",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".rn_u",sep="")] <- x

        fs1 <- fs[fs$format=="rn"&fs$position=="2",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(impressions,na.rm=TRUE),views = sum(views,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".rn_2",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".rn_2",sep="")] <- x

        fs1 <- fs[fs$format=="rn"&fs$position=="3",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(impressions,na.rm=TRUE),views = sum(views,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".rn_3",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".rn_3",sep="")] <- x

    }
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    fName <- gsub(" ","",gsub("[[:digit:]]","",fName))
    print(fName)
    write.table(sectGrp,fName,row.names=FALSE,append=FALSE,sep="\t")
}




