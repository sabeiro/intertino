#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)

mList <- c("01","02","03","04","05","06","07","08","09","10","11","12")
mList <- c("January","February","March","April","May","June")
fSect <- "section"
month <- mList[1]
NSect1 <- 20
fLab <- c("total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")
chCol <- "Publisher"
stCol <- "Site"
scCol <- "Channel"

##-------------maiolica-viewability----------------------
for(month in mList){
    fName <- paste("raw/priceSection",month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.csv(fName,header=TRUE,fill=TRUE,sep=",",stringsAsFactors=FALSE)
    siteGrp2[grepl("WEBTV",siteGrp2$Publisher),"Publisher"] <- "R T I"
    formI <- ddply(siteGrp2,.(Size),summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob <- 0.90
    lim = quantile(formI$imps,cumprob)
    formL <- formI[formI$imps>lim,"Size"]
    siteGrp2$month <- substr(siteGrp2$Data,start=6,stop=7)
    chL <- ddply(siteGrp2,chCol,summarise,imps=sum(Imps,na.rm=TRUE))
    cumprob <- 0.50
    lim = quantile(chL$imps,cumprob)
    chL <- chL[chL$imps>lim,]
    chL <- chL[order(-chL$imps),]
    form <- formL[1]
    for(form in formL){
        siteGrp <- siteGrp2[grepl(form,siteGrp2$Size),]
        chL1 <- ddply(siteGrp,chCol,summarise,ctr={sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE)},cpm=sum(FlightTotalSales,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
        if(nrow(chL1)==0){next}
        colnames(chL1) <- c(chCol,paste("ctr",form),paste("cpm",form))
        ## chL[,paste("ctr",form)] <- rep(0,nrow(chL))
        ## set <- match(chL1[,chCol],chL[,chCol])
        ## chL[set[!is.na(set)],paste("ctr",form)] <- chL1[,2]*100
        ## chL[,paste("cpm",form)] <- rep(0,nrow(chL))
        #chL[match(chL1[,chCol],chL[,chCol]),paste("cpm",form)] <- chL1[,3]
        chL <- merge(chL,chL1,by=chCol)
    }
    chC <- list()
    ch <- 1
    for(ch in 1:length(chL$ch)){
        chN <-  chL[ch,chCol]
        siteGrp3 <- siteGrp2[siteGrp2[,chCol] %in% chN,]
        siteL <- ddply(siteGrp3,stCol,summarise,imps=sum(Imps,na.rm=TRUE))
        siteL <- siteL[order(-siteL$imps),]
        for(form in formL){
            siteGrp <- siteGrp3[grepl(form,siteGrp3$Size),]
            siteL1 <- ddply(siteGrp,stCol,summarise,ctr={sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE)},cpm=sum(FlightTotalSales,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
            if(nrow(siteL1)==0){next}
            colnames(siteL1) <- c(stCol,paste("ctr",form),paste("cpm",form))
            ## siteL[,paste("ctr",form)] <- rep(0,nrow(siteL))
            ## siteL[match(siteL1[,stCol],siteL[,stCol]),paste("ctr",form)] <- siteL1[,2]*100
            ## siteL[,paste("cpm",form)] <- rep(0,nrow(siteL))
            ## siteL[match(siteL1[,stCol],siteL[,stCol]),paste("cpm",form)] <- siteL1[,3]
            siteL <- merge(siteL,siteL1,by=stCol)
        }
        stC <- list()
        site <- 1
        for(site in 1:length(siteL[,stCol])){
            siteN <-  siteL[site,stCol]
            siteGrp3 <- siteGrp2[siteGrp2[,stCol] %in% siteN,]
            sectL <- ddply(siteGrp3,scCol,summarise,imps=sum(Imps,na.rm=TRUE))
            sectL <- sectL[order(-sectL$imps),]
            for(form in formL){
                siteGrp <- siteGrp3[grepl(form,siteGrp3$Size),]
                sectL1 <- ddply(siteGrp,scCol,summarise,ctr={sum(Click,na.rm=TRUE)/sum(Imps,na.rm=TRUE)},cpm=sum(FlightTotalSales,na.rm=TRUE)/sum(Imps,na.rm=TRUE))
                if(nrow(sectL1)==0){next}
                colnames(sectL1) <- c(scCol,paste("ctr",form),paste("cpm",form))
                ## sectL[,paste("ctr",form)] <- rep(0,nrow(sectL))
                ## sectL[match(sectL1[,scCol],sectL[,scCol]),paste("ctr",form)] <- sectL1[,2]*100
                ## sectL[,paste("cpm",form)] <- rep(0,nrow(sectL))
                ## sectL[match(sectL1[,scCol],sectL[,scCol]),paste("cpm",form)] <- sectL1[,3]
                sectL <- merge(sectL,sectL1,by=scCol)
            }
            sectV <- list(label_short=siteN,label_long=siteN)
            scC <- list()
            sect <- 1
            for(sect in 1:length(sectL[,scCol])){
                sectN <-  sectL[sect,scCol]
                sectV1 <- list(label_short=sectN,label_long=sectN,values=as.numeric(sectL[sectL[,scCol] %in% sectN,-1]) )
                scC[[sect]] <- sectV1
            }
            siteV1 <- list(label_short=siteN,label_long=siteN,values=as.numeric(siteL[siteL[,stCol] %in% siteN,-1]) )
            siteV1$children <- scC
            stC[[site]] <- siteV1
        }
        chV1 <- list(label_short=chN,label_long=chN,values=as.numeric(chL[grep(chN,chL$ch),-1]))
        chV1$children <- stC
        chC[[ch]] <- chV1
        ##chV$children <- list(chV$children,chV1)
    }
    values <- sum(siteGrp2$imps,na.rm=TRUE)
    for(form in formL){
        siteGrp <- siteGrp2[grepl(form,siteGrp2$Size),]
        values <- cbind(values,c(sum(siteGrp2[,"Click"],na.rm=TRUE)/sum(siteGrp2[,"Imps"],na.rm=TRUE)*100,sum(siteGrp2[,"FlightTotalSales"],na.rm=TRUE)/sum(siteGrp2[,"Imps"],na.rm=TRUE) ))
    }
    chV <- list(label_short=month,label_long=month,values=as.numeric(values))
    chV$children <- chC
    write(toJSON(chV),paste("intertino/data/heatmapDot",month,".json",sep=""))
}

