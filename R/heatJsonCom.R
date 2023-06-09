#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
##rm(list=ls())

source('script/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)
require(dplyr)

monthL <- c("Gennaio","Febbraio","Marzo","Aprile","Giugno","July","August","September","October")
placeF <- read.csv("raw/placementTable.csv")
placeF <- merge(placeF,read.csv("raw/placementTableEditor.csv"),all.x=T)
groupN <- "rti"

month <- monthL[5]
month <- monthL[6]
for(month in monthL){
    print(month)
    fs <- read.csv(paste("raw/comScore",month,".csv",sep=""),stringsAsFactor=FALSE)
    if(typeof(fs$PC.Measured.Impressions)=="character"){
        fs$PC.Measured.Impressions <- as.numeric(gsub(",","",fs$PC.Measured.Impressions))
        fs$PC.Measured.Views <- as.numeric(gsub(",","",fs$PC.Measured.Views))
        fs$Mobile.Measured.Impressions <- as.numeric(gsub(",","",fs$Mobile.Measured.Impressions))
        fs$Mobile.Measured.Views <- as.numeric(gsub(",","",fs$Mobile.Measured.Views))
    }
    ds <- ddply(fs,.(External.Placement.ID),summarise,
                imps_pc1=sum(PC.Measured.Impressions,na.rm=TRUE),
                view_pc1=sum(PC.Measured.Views,na.rm=TRUE),
                imps_mob1=sum(Mobile.Measured.Impressions,na.rm=TRUE),
                view_mob1=sum(Mobile.Measured.Views,na.rm=TRUE))
    cs <- merge(ds,placeF,by.y="Placement.ID",by.x="External.Placement.ID",all.x=TRUE)
    head(cs)
    set <- grepl(groupN,cs$group)
    if(any(set)){cs <- cs[set,]}
    cs <- cs[!is.na(cs$External.Placement.ID),]
    cs <- cs[cs$External.Placement.ID>0,]    
    cs <- cs[!grepl("ln",cs$format),]
    cs <- cs[!grepl("r3",cs$format),]
    imps_tot <- cs$imps_pc1 + cs$imps_mob1
    
    ##cs <- cs[imps_tot > quantile(imps_tot,0.50),]
    cs[cs$view_pc1 > cs$imps_pc1,]
    cs$position <- paste(cs$format,cs$position2,sep="_")
    if(any(cs$position=="sn_2")){cs[cs$position=="sn_2","position"] <- "sn_u"}
    posL <- c("rn_2","rn_3","rn_u","sn_u")
    cs <- cs[cs$position %in% posL,]
    cs$site <- paste(cs$site,cs$section,sep="_")
    cs$editor[grepl("monda",cs$editor)] <- "ame"
    cs <- cs[!grepl("nl",cs$editor),]
    cs <- cs[!grepl("br",cs$editor),]
    cs$editor <- as.character(cs$editor)
    cs$site <- as.character(cs$site)
    cs$section <- as.character(cs$section)
    write.csv(cs,paste("intertino/data/csv/heatmapView",groupN,month,".csv",sep=""))
    ##---------------------------generate-publisher-site-section-tables----------------------
    mL <- ddply(cs,.(position),summarise,view_pc=sum(view_pc1,na.rm=TRUE)/sum(imps_pc1,na.rm=TRUE),view_mob=sum(view_mob1,na.rm=TRUE)/sum(imps_mob1,na.rm=TRUE) )
    chL <- ddply(cs,.(editor),summarise,imps=sum(imps_pc1,na.rm=TRUE)+sum(imps_mob1,na.rm=TRUE),view=sum(view_pc1,na.rm=TRUE)+sum(view_mob1,na.rm=TRUE) )
    chL1 <- ddply(cs,.(editor,position),summarise,view_pc=sum(view_pc1,na.rm=TRUE)/sum(imps_pc1,na.rm=TRUE),view_mob=sum(view_mob1,na.rm=TRUE)/sum(imps_mob1,na.rm=TRUE) )
    chL1$view_pc[is.nan(chL1$view_pc)] <- 0
    chL1$view_mob[is.nan(chL1$view_mob)] <- 0
    checkV <- c(chL1$view_mob>1,chL1$view_pc>1)
    if(any(checkV)){print(paste("view over 100%",sum(checkV)))}
    chL2 <- as.data.frame.matrix(xtabs("view_pc ~ editor + position",data=chL1))
    chL2$editor <- rownames(chL2)
    chL <- merge(chL,chL2,by="editor")
    chL2 <- as.data.frame.matrix(xtabs("view_mob ~ editor + position",data=chL1))
    chL2$editor <- rownames(chL2)
    chL <- merge(chL,chL2,by="editor")
    chL[chL==1] <- 0
    chL <- chL[order(-chL$imps),]
##    write.csv(chL,paste("intertino/data/heatmapView","Editor",month,".csv",sep=""))

    stL <- ddply(cs,.(Site.Name),summarise,imps=sum(imps_pc1,na.rm=TRUE)+sum(imps_mob1,na.rm=TRUE),view=sum(view_pc1,na.rm=TRUE)+sum(view_mob1,na.rm=TRUE),editor=head(editor,1))
    stL1 <- ddply(cs,.(Site.Name,position),summarise,view_pc=sum(view_pc1,na.rm=TRUE)/sum(imps_pc1,na.rm=TRUE),view_mob=sum(view_mob1,na.rm=TRUE)/sum(imps_mob1,na.rm=TRUE))
    stL1$view_pc[is.nan(stL1$view_pc)] <- 0
    stL1$view_mob[is.nan(stL1$view_mob)] <- 0
    checkV <- c(stL1$view_mob>1,stL1$view_pc>1)
    if(any(checkV)){print(paste("view over 100%",sum(checkV)))}
    stL2 <- as.data.frame.matrix(xtabs("view_pc ~ Site.Name + position",data=stL1))
    stL2$Site.Name <- rownames(stL2)
    stL <- merge(stL,stL2,by="Site.Name")
    stL2 <- as.data.frame.matrix(xtabs("view_mob ~ Site.Name + position",data=stL1))
    stL2$Site.Name <- rownames(stL2)
    stL <- merge(stL,stL2,by="Site.Name")
    stL[stL==1] <- 0
    stL <- stL[order(-stL$imps),]
##    write.csv(stL,paste("intertino/data/heatmapView","Site",month,".csv",sep=""))

    scL <- ddply(cs,.(site),summarise,imps=sum(imps_pc1,na.rm=TRUE)+sum(imps_mob1,na.rm=TRUE),view=sum(view_pc1,na.rm=TRUE)+sum(view_mob1,na.rm=TRUE),Site.Name=head(Site.Name,1) )
    scL1 <- ddply(cs,.(site,position),summarise,view_pc=sum(view_pc1,na.rm=TRUE)/sum(imps_pc1,na.rm=TRUE),view_mob=sum(view_mob1,na.rm=TRUE)/sum(imps_mob1,na.rm=TRUE) )
    scL1$view_pc[is.nan(scL1$view_pc)] <- 0
    scL1$view_mob[is.nan(scL1$view_mob)] <- 0
    checkV <- c(scL1$view_mob>1,scL1$view_pc>1)
    if(any(checkV)){print(paste("view over 100%",sum(checkV)))}
    scL2 <- as.data.frame.matrix(xtabs("view_pc ~ site + position",data=scL1))
    scL2$site <- rownames(scL2)
    scL <- merge(scL,scL2,by="site")
    scL2 <- as.data.frame.matrix(xtabs("view_mob ~ site + position",data=scL1))
    scL2$site <- rownames(scL2)
    scL <- merge(scL,scL2,by="site")
    scL[scL==1] <- 0
    scL <- scL[order(-scL$imps),]
##    write.csv(scL,paste("intertino/data/heatmapView","Section",month,".csv",sep=""))

    ## stL[grepl("style",stL$Site.Name),]
    ## stL1[grepl("style",stL1$Site.Name),]
    ## scL[grepl("style",scL$Site.Name),]
    ##weighted.mean(scL[grepl("style",scL$Site.Name),6],scL[grepl("style",scL$Site.Name),2])

    ch <- 1
    st <- 1
    sc <- 1
    ##---------------------------generate-json----------------------
    selCol <- c(1,4)
    chselCol <- c(1)
    chC <- list()
    for(ch in 1:length(chL$editor)){
        chN <- chL$editor[ch]
        stC <- list()
        stL1 <- stL[grepl(chN,stL$editor),]
        for(st in 1:length(stL1$Site.Name)){
            stN <- stL1$Site.Name[st]
            sectV <- list(label_short=stN,label_long=stN)
            scC <- list()
            scL1 <- scL[grepl(stN,scL$Site.Name),]
            for(sc in 1:length(scL1$site)){
                if(sc<1){next}
                scN <- scL1$site[sc]
                scV <- as.numeric(scL1[sc,-selCol])
                scV[-(1:2)] <- scV[-(1:2)]*100
                scV[scV==Inf] <- 0
                scB <- list(label_short=scN,label_long=scN,values=scV)
                scC[[sc]] <- scB
            }
            stV <- as.numeric(stL1[st,-selCol])
            stV[-(1:2)] <- stV[-(1:2)]*100
            stV[stV==Inf] <- 0
            stB <- list(label_short=stN,label_long=stN,values=stV)
            stB$children <- scC
            stC[[st]] <- stB
        }
        chV <- as.numeric(chL[ch,-chselCol])
        chV[-(1:2)] <- chV[-(1:2)]*100
        chV[chV==Inf] <- 0
        chB <- list(label_short=chN,label_long=chN,values=chV)
        chB$children <- stC
        chC[[ch]] <- chB
    }

    monthV <- sum(chL$imps,na.rm=TRUE)
    monthV <- c(monthV,0,mL$view_pc*100,mL$view_mob*100)
    monthB <- list(title="Viewability",depth=2,label_short=month,label_long=month,values=monthV)
    monthB$children <- chC

    write(toJSON(monthB),paste("intertino/data/heatmapView",groupN,month,".json",sep=""))
}


