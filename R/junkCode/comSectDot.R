#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')
rm(list=ls())

source('script/graphEnv.R')

matchingSites <- read.csv("out/matchingSites.csv")

fs <- read.csv("raw/sizeSectionSiteFeb.csv")
fs$section <- paste(fs$Site,fs$Section,sep="|")
fs$Month <- "February"

fs2 <- fs
head(fs,n=20)
devFile <- c("pc","mob","tab")
fSect <- "Site"
month <- unique(fs$Month)[1]
## sort(table(fs2$section),sort="ascending")

x <- ddply(fs,.(DeviceType),summarise,imps=sum(Imps,na.rm=TRUE))
x[order(x$imps),]


##-------------section-comp---------------------
for(month in unique(fs$Month)){
    fs <- fs2[fs2$Month==month,]
    ## fs <- fs2[fs2$section=="blog|GRAZIA|ame",]
    sectGrp <- ddply(fs,fSect,summarise,imps = sum(Imps,na.rm=TRUE),views = sum(Click,na.rm=TRUE))
    empty <- rep(0,length(sectGrp$imps))
    for(dev in devFile){
        if(any(grep("pc",dev))){
            print(dev)
            fs <- fs[fs$DeviceType=="Desktop",]
        } else if(any(grep("tab",dev))){
            print(dev)
            fs <- fs[grepl("Tablet",fs$DeviceType),]
        } else if(any(grep("mob",dev))){
            print(dev)
            fs <- fs[grepl("Mobile",fs$DeviceType),]
        }
        fs1 <- fs[fs$Size=="STRIP SKIN MASTEHEAD",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(Imps,na.rm=TRUE),views = sum(Click,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".sn",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".sn",sep="")] <- x

        fs1 <- fs[fs$Size=="RECTANGLE",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(Imps,na.rm=TRUE),views = sum(Click,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".rn_u",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".rn_u",sep="")] <- x

        fs1 <- fs[fs$Size=="PROMOBOX",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(Imps,na.rm=TRUE),views = sum(Click,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".promo",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".promo",sep="")] <- x

        fs1 <- fs[fs$Size=="SPOT",]
        aggr1 <- ddply(fs1,fSect,summarise,imps = sum(Imps,na.rm=TRUE),views = sum(Click,na.rm=TRUE))
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$imps
        sectGrp[,paste("imps.",dev,".spot",sep="")] <- x
        x <- empty ; x[sectGrp[,fSect] %in% aggr1[,fSect]]  <- aggr1$views
        sectGrp[,paste("view.",dev,".spot",sep="")] <- x


    }
    fName <- paste("out/dotImprDevFormat",fSect,month,".csv",sep="")
    fName <- gsub(" ","",gsub("[[:digit:]]","",fName))
    print(fName)
    write.table(sectGrp,fName,row.names=FALSE,append=FALSE,sep="\t")
}


