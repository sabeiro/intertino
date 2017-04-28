#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')
rm(list=ls())

source('script/graphEnv.R')

source('script/comLoad.R')
##source("script/comGeneral.R")

##-------------impressions-comp---------------------
month <- names(table(fs$Month))
imprGrp <<- as.data.frame(month)
##-------------duration-comp---------------------
month <- rep(names(table(fs$Month)),3)
durGrp <<- as.data.frame(month)
durGrp$duration <- as.vector(sapply(c("1-5","5-60",">60"),function(x) rep(x,3)))
##-------------site-comp---------------------
v_id <- seq(1:length(table(fs$site)))
mTab <- as.data.frame(v_id)
mTab$site <- names(table(fs$site))
mTab$volume <- sapply(mTab$site,function(x) sum(fs[fs$site==x,]$impression,na.rm=TRUE))
rTab <- head(mTab[with(mTab,order(-volume)),],n=10)
siteList <- names(table(rTab$site))
month <- rep(names(table(fs$Month)),12)
siteGrp <<- as.data.frame(month)
siteGrp$site <- as.vector(sapply(c(siteList,"rest","total"),function(x) rep(x,3)))
##-------------section-comp---------------------
v_id <- seq(1:length(table(fs$section)))
mTab <- as.data.frame(names(table(fs$section)))
colnames(mTab) <- "section"
mTab$site <- sapply(mTab$section,function(x) fs[match(x,fs$section),"site"])
mTab$volume <- sapply(mTab$section,function(x) sum(fs[fs$section==x,]$impression,na.rm=TRUE))
rTab <- head(mTab[with(mTab,order(-volume)),],n=100)
sectList <- rTab$section
month <- rep(names(table(fs$Month)),length(sectList)+2)
sectGrp <<- as.data.frame(month)
sectGrp$section <- c(as.vector(sapply(paste(rTab$section," ",rTab$site,sep=""),function(x) rep(x,3))),rep("rest",3),rep("total",3))
month <- rep(names(table(fs$Month)),length(sectList)+2)
sectTotGrp <<- as.data.frame(c(as.vector(sapply(paste(rTab$section," ",rTab$site,sep=""),function(x) rep(x,1))),rep("rest",1),rep("total",1)))
colnames(sectTotGrp) <- "section"
##-------------reset----------------------------
source("script/comImpr.R")
pointMetric <- function(fs,set,sectType,metricType){
    print(sectType)
    set[is.na(set)] <- FALSE
    fs <- fs1[set,]
    if(any(grep("pc",sectType))){
        fs$impressions <- fs$PC.Measured.Impressions
        fs$views <- fs$PC.Measured.Views
    }
    else if(any(grep("app",sectType))){
        fs$impressions <-  fs$Mobile.App.Measured.Impressions
        fs$views <-  fs$Mobile.App.Measured.Views
    }
    else if(any(grep("mob",sectType))){
        fs$impressions <-  fs$Mobile.Measured.Impressions
        fs$views <-  fs$Mobile.Measured.Views
    }
    if(any(set)){
        ## fs$views <- sapply(fs$impressions,function(x) ifelse(x<=0,NA,fs$views))
        ## fs$impressions <- sapply(fs$impressions,function(x) ifelse(x<=0,NA,x))
        metricVar <- ("impressions")
        metricType <- c("measured")
        bstack <- comImpr(fs,sectType,timeVar,metricVar,metricType)
        imprGrp$var <<- bstack$volume
        fName <- paste("fig/impressionVolume_",sectType,".png",sep="")
        ##graphImprVolume(bstack,fName)
        colnames(imprGrp)[colnames(imprGrp)=='var'] <<- sectType

        metricVar <- c("Direct.View.Time.1.5s","Direct.View.Time.5.60s","Direct.View.Time....60s")
        metricType <- c("measured")
        view <- as.data.frame(month)
        bstack <- comImpr(fs,sectType,timeVar,metricVar,metricType)
        durGrp$var <<- bstack$volume
        colnames(durGrp)[colnames(durGrp)=='var'] <<- sectType
        ##graph
        fName <- paste("durationVolume",sectType,".png",sep="")
        gLabel <- c("month","impressions (M)","measured impression share","category")
        bstack$x <- bstack$timeVar
        bstack$y <- bstack$volume
        bstack$f <- bstack$var
        bstack$label <- sapply(bstack$volume,function(x){paste(round(x/1000000),"",sep="")})
        p <- stackBarLabel(bstack,gLabel)
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

        metricVar <- c("impressions","views")
        filterList <- siteList
        filterName <- "site"
         bstack <- comConvFilter(fs,sectType,timeVar,metricVar,metricType,filterList,filterName)
        siteGrp$var <<- bstack$volume
        colnames(siteGrp)[colnames(siteGrp)=='var'] <<- sectType

        metricVar <- c("impressions","views")
        filterList <- sectList
        filterName <- "section"
        bstack <- comConvFilter(fs,sectType,timeVar,metricVar,metricType,filterList,filterName)
        sectGrp$var <<- bstack$volume
        colnames(sectGrp)[colnames(sectGrp)=='var'] <<- sectType

        metricVar <- c("impressions","views")
        filterList <- sectList
        filterName <- "section"
        bstack <- comConvFilterNoTime(fs,sectType,metricVar,metricType,filterList,filterName)
        sectTotGrp$var <<- bstack$volume
        colnames(sectTotGrp)[colnames(sectTotGrp)=='var'] <<- sectType
    }
    else{print("No elements selectable")}
}

month <- names(table(fs$Month))
timeVar <- names(table(fs$Month))
metricVar <- c("viewability")
metricType <- c("measured")
devFile <- c("pc","mob")
dev<-devFile[2]
dev<-devFile[1]
for(dev in devFile){
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_sn",sep="")
    sectType <- paste(dev,"_sn",sep="")
    set <- fs1$format=="sn"
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_u",sep="")
    sectType <- paste(dev,"_rn_u",sep="")
    set <- (fs1$format=="rn"&fs1$position=="u")
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_2",sep="")
    sectType <- paste(dev,"_rn_2",sep="")
    set <- (fs1$format=="rn"&fs1$position=="2")
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_3",sep="")
    sectType <- paste(dev,"_rn_3",sep="")
    set <- (fs1$format=="rn"&fs1$position=="3")
    pointMetric(fs,set,sectType,metricType)
}



write.table(imprGrp,"out/imprDevFormat.csv",row.names=FALSE,append=FALSE)
write.table(durGrp,"out/durationDevFormat.csv",row.names=FALSE,append=FALSE)
write.table(siteGrp,"out/siteDevFormat.csv",row.names=FALSE,append=FALSE)
write.table(sectGrp,"out/sectDevFormat.csv",row.names=FALSE,append=FALSE)
write.table(sectTotGrp,"out/sectTotDevFormat.csv",row.names=FALSE,append=FALSE)

