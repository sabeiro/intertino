#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')
library('jsonlite')
library('rjson')
library('RJSONIO')
library(igraph)

mList <- c("October","November","December","January","February","March","April","May")
fSect <- "section"
isChiara <- FALSE
editorL <- c("rti","ame","TGCOM","METEO","SPORT MEDIASET","DONNAMODERNA","GRAZIA","COMINGSOON.NET","NOSTROFIGLIO","PANORAMA","SALE E PEPE","MARIA DE FILIPPI","IL GIORNALE","WITTY")
month <- mList[8]
NSect1 <- 20
fLab <- c("total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")


##-------------maiolica-viewability----------------------
for(month in mList){
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    formL <- unique(gsub("view\\.","",gsub("imps\\.","",colnames(siteGrp2[,-c(1,2,3)])) ))
    siteGrp2$ch <- unlist(lapply(strsplit(siteGrp2$section,split="\\|"),'[[',3))
    siteGrp2$site <- paste(unlist(lapply(strsplit(siteGrp2$section,split="\\|"),'[[',2)),unlist(lapply(strsplit(siteGrp2$section,split="\\|"),'[[',3)),sep="|")
    chL <- ddply(siteGrp2,.(ch),summarise,imps=sum(imps,na.rm=TRUE))
    chL <- chL[order(-chL$imps),]
    for(form in formL){
        chL1 <- data.frame(form = ddply(siteGrp2,.(ch),.fun=function(xx){sum(xx[,paste("view",form,sep=".")],na.rm=TRUE)/sum(xx[,paste("imps",form,sep=".")],na.rm=TRUE)})[2]*100)
        colnames(chL1) <- form
        chL <- cbind(chL,chL1)
    }
    chC <- list()
    ch <- 6
    for(ch in 1:length(chL$ch)){
        chN <-  chL$ch[ch]
        siteGrp <- siteGrp2[siteGrp2$ch %in% chN,]
        siteL <- ddply(siteGrp,.(site),summarise,imps=sum(imps,na.rm=TRUE))
        siteL <- siteL[order(-siteL$imps),]
        for(form in formL){
            siteL1 <- data.frame(form = ddply(siteGrp,.(site),.fun=function(xx){sum(xx[,paste("view",form,sep=".")],na.rm=TRUE)/sum(xx[,paste("imps",form,sep=".")],na.rm=TRUE)})[2]*100)
            colnames(siteL1) <- form
            siteL <- cbind(siteL,siteL1)
        }
        stC <- list()
        site <- 1
        for(site in 1:length(siteL$site)){
            siteN <-  siteL$site[site]
            siteGrp <- siteGrp2[siteGrp2$site %in% siteN,]
            sectL <- ddply(siteGrp,.(section),summarise,imps=sum(imps,na.rm=TRUE))
            sectL <- sectL[order(-sectL$imps),]
            for(form in formL){
                sectL1 <- data.frame(form = ddply(siteGrp,.(section),.fun=function(xx){sum(xx[,paste("view",form,sep=".")],na.rm=TRUE)/sum(xx[,paste("imps",form,sep=".")],na.rm=TRUE)})[2]*100)
                colnames(sectL1) <- form
                sectL <- cbind(sectL,sectL1)
            }
            sectV <- list(label_short=siteN,label_long=siteN)
            scC <- list()
            for(sect in 1:length(sectL$section)){
                sectN <-  sectL$section[sect]
                label <- unlist(lapply(strsplit(sectN,split="\\|"),'[[',1))
                sectV1 <- list(label_short=label,label_long=label,values=as.numeric(sectL[sectL$section %in% sectN,-1]) )
                scC[[sect]] <- sectV1
            }
            label <- unlist(lapply(strsplit(siteN,split="\\|"),'[[',1))
            siteV1 <- list(label_short=label,label_long=label,values=as.numeric(siteL[siteL$site %in% siteN,-1]) )
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
        values <- cbind( values,sum(siteGrp2[,paste("view",form,sep=".")],na.rm=TRUE)/sum(siteGrp2[,paste("imps",form,sep=".")],na.rm=TRUE)*100 )
    }
    chV <- list(label_short=month,label_long=month,values=as.numeric(values))
    chV$children <- chC
    write(toJSON(chV),paste("intertino/data/heatmap",month,".json",sep=""))


}

