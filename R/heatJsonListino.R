#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
##rm(list=ls())

source('script/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)

monthL <- c("Gennaio","Febbraio","Marzo","Aprile","Maggio","Giugno")
mList <- c("01","02","03","04","05","06","07","08","09","10","11","12")
monthL <- c("January","February","March","April","May","June")
fSect <- "section"
month <- mList[1]
NSect1 <- 20
chCol <- "Publisher"
stCol <- "Site"
scCol <- "Channel"

month <- "30"
print(month)
fs <- read.csv(paste("raw/priceSection",month,".csv",sep=""),stringsAsFactor=FALSE)
fs$Data <- as.Date(fs$Data)

sum(fs[grepl("BOING",fs$Site) & grepl("RECTANG",fs$Size),"Imps"],na.rm=TRUE)

source("script/heatJsonDotPre.R")


set <- grepl("RECTA",cs$Size) | grepl("SKIN",cs$Size) | grepl("SKIN",cs$Size)
cs <- cs[set,]
##---------------------------generate-publisher-site-section-tables----------------------
chL <- ddply(cs,chCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE))
chL1 <- ddply(cs,.(Publisher,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
chL2 <- as.data.frame.matrix(xtabs("imps ~ Publisher + Size",data=chL1))
chL2$Publisher <- rownames(chL2)
chL <- merge(chL,chL2,by="Publisher")

chL1 <- ddply(cs[cs$working,],.(Publisher,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
chL2 <- as.data.frame.matrix(xtabs("imps ~ Publisher + Size",data=chL1))
chL2$Publisher <- rownames(chL2)
chL <- merge(chL,chL2,by="Publisher")

chL1 <- ddply(cs[!cs$working,],.(Publisher,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
chL2 <- as.data.frame.matrix(xtabs("imps ~ Publisher + Size",data=chL1))
chL2$Publisher <- rownames(chL2)
chL <- merge(chL,chL2,by="Publisher")

chL <- chL[order(-chL$imps),]
write.csv(chL,paste("intertino/data/heatmapDot","Editor",month,".csv",sep=""))



stL <- ddply(cs,stCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE),Publisher=head(Publisher,1))
stL1 <- ddply(cs,.(Site,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
stL2 <- as.data.frame.matrix(xtabs("imps ~ Site + Size",data=stL1))
stL2[,stCol] <- rownames(stL2)
stL <- merge(stL,stL2,by=stCol)

stL1 <- ddply(cs[cs$working,],.(Site,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
stL2 <- as.data.frame.matrix(xtabs("imps ~ Site + Size",data=stL1))
stL2[,stCol] <- rownames(stL2)
stL <- merge(stL,stL2,by=stCol)

stL1 <- ddply(cs[!cs$working,],.(Site,Size),summarise,imps=sum(Imps,na.rm=TRUE),ctr=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
stL2 <- as.data.frame.matrix(xtabs("imps ~ Site + Size",data=stL1))
stL2[,stCol] <- rownames(stL2)
stL <- merge(stL,stL2,by=stCol)

stL <- stL[order(-stL$imps),]
write.csv(stL,paste("intertino/data/heatmapDot","Site",month,".csv",sep=""))



cs[,scCol] <- tryTolower(paste(cs[,scCol],cs[,stCol],sep="|"))
scL <- ddply(cs,scCol,summarise,imps=sum(Imps,na.rm=TRUE),click=sum(Click,na.rm=TRUE),Site=head(Site,1))
scL1 <- ddply(cs,.(Channel,Size),summarise,imps=sum(Imps,na.rm=TRUE),cpm=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
scL2 <- as.data.frame.matrix(xtabs("imps ~ Channel + Size",data=scL1))
scL2[,scCol] <- rownames(scL2)
scL <- merge(scL,scL2,by=scCol)

scL1 <- ddply(cs[cs$working,],.(Channel,Size),summarise,imps=sum(Imps,na.rm=TRUE),cpm=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
scL2 <- as.data.frame.matrix(xtabs("imps ~ Channel + Size",data=scL1))
scL2[,scCol] <- rownames(scL2)
scL <- merge(scL,scL2,by=scCol)

scL1 <- ddply(cs[!cs$working,],.(Channel,Size),summarise,imps=sum(Imps,na.rm=TRUE),cpm=sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
scL2 <- as.data.frame.matrix(xtabs("imps ~ Channel + Size",data=scL1))
scL2[,scCol] <- rownames(scL2)
scL <- merge(scL,scL2,by=scCol)

scL <- scL[order(-scL$imps),]
write.csv(scL,paste("intertino/data/heatmapDot","Section",month,".csv",sep=""))
head(scL)


ch <- 1
st <- 1
sc <- 1
##---------------------------generate-json----------------------
selCol <- c(1,3)#,4)#,5)
chselCol <- c(1)#,3)#,4)
chC <- list()
for(ch in 1:length(chL[,chCol])){
    chN <- chL[ch,chCol]
    stC <- list()
    stL1 <- stL[grepl(chN,stL[,chCol]),]
    for(st in 1:length(stL1[,stCol])){
        stN <- stL1[st,stCol]
        sectV <- list(label_short=substr(stN,start=1,stop=5),label_long=stN)
        scC <- list()
        scL1 <- scL[grepl(stN,scL[,stCol]),]
        for(sc in 1:length(scL1[,scCol])){
            if(sc<1){next}
            scN <- scL1[sc,scCol]
            scN <- gsub("\\|.*$","",scN)
            scV <- (as.numeric(scL1[sc,-selCol]))
            scV[-1] <- scV[-1]##*100
            scB <- list(label_short=substr(scN,start=1,stop=5),label_long=scN,values=scV)
            scC[[sc]] <- scB
        }
        stV <- (as.numeric(stL1[st,-selCol]))
        stV[-1] <- stV[-1]##*100
        stB <- list(label_short=substr(stN,start=1,stop=5),label_long=stN,values=stV)
        stB$children <- scC
        stC[[st]] <- stB
    }
    chV <- (as.numeric(chL[ch,-chselCol]))
    chV[-1] <- chV[-1]##*100
    chB <- list(label_short=substr(chN,start=1,stop=5),label_long=chN,values=chV)
    chB$children <- stC
    chC[[ch]] <- chB
}
monthV <- sum(chL$imps,na.rm=TRUE)
monthV <- c(monthV,sapply( (1:ncol(chL))[-chselCol],function(i) weighted.mean(chL[,i],chL$imps)))

monthB <- list(title="Listino",depth=2,label_short=as.character(head(fs$Data,1)),label_long=as.character(head(fs$Data,1)),values=monthV)
monthB$children <- chC

write(toJSON(monthB),paste("intertino/data/heatmapDot",month,".json",sep=""))



