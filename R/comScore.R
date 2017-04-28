#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')

source('script/comLoad.R')
source("script/comImpr.R")
source("script/comGraph.R")
#source("script/comGeneral.R")

#-------------impressions-comp---------------------
month <- names(table(fs$Month))
imprGrp <<- as.data.frame(month)
#-------------duration-comp---------------------
month <- rep(names(table(fs$Month)),3)
durGrp <<- as.data.frame(month)
durGrp$duration <- as.vector(sapply(c("1-5","5-60",">60"),function(x) rep(x,3)))
#-------------site-comp---------------------
v_id <- seq(1:length(table(fs$site)))
mTab <- as.data.frame(v_id)
mTab$site <- names(table(fs$site))
mTab$volume <- as.vector(table(fs$site))
rTab <- head(mTab[with(mTab,order(-volume)),],n=10)
rTab[length(rTab$v_id)+1,] <- c(2,"ALTRI",sum(mTab$volume)-sum(rTab$volume))
month <- rep(names(table(fs$Month)),11)
siteGrp <<- as.data.frame(month)
sites <- names(table(rTab$site))
siteGrp$site <- as.vector(sapply(sites,function(x) rep(x,3)))
                                        #-------------section-comp---------------------
sections <- names(table(fs$section)) #unique(paste(fs$site,fs$section))
mTab <- as.data.frame(sections)
mTab$site <- fs[as.numeric(rownames(mTab)),]$site
mTab$volume <- as.vector(table(fs$section))
mTab <- mTab[with(mTab,order(-volume)),]
month <- rep(names(table(fs$Month)),length(sections))
sectGrp <<- as.data.frame(month)
sectGrp$sections <- as.vector(sapply(paste(mTab$site,"",mTab$section),function(x) rep(x,3)))
 
                                        #-------------reset----------------------------
pointMetric <- function(fs,set,sectType,metricType){
    print(sectType)
    set[is.na(set)] <- FALSE
    fs <- fs1[set,]
    if(any(grep("desktop",sectType))){
        fs$impressions <- fs$PC.Measured.Impressions
        fs$views <- fs$PC.Measured.Views
    }
    else if(any(grep("app",sectType))){
        fs$impressions <-  fs$Mobile.App.Measured.Impressions
        fs$views <-  fs$Mobile.App.Measured.Views 
    }
    else if(any(grep("mobile",sectType))){
        fs$impressions <-  fs$Mobile.Measured.Impressions
        fs$views <-  fs$Mobile.Measured.Views
    }
    if(any(set)){
        metricVar <- ("impressions")
        metricType <- c("measured")
        bstack <- comImpr(fs,sectType,timeVar,metricVar,metricType)
        imprGrp$var <<- bstack$volume
        fName <- paste("fig/impressionVolume_",sectType,".png",sep="")
        #graphImprVolume(bstack,fName)
        colnames(imprGrp)[colnames(imprGrp)=='var'] <<- sectType

        metricVar <- c("Direct.View.Time.1.5s","Direct.View.Time.5.60s","Direct.View.Time....60s")
        metricType <- c("measured")
        view <- as.data.frame(month)
        bstack <- comImpr(fs,sectType,timeVar,metricVar,metricType)
        durGrp$var <<- bstack$volume
        colnames(durGrp)[colnames(durGrp)=='var'] <<- sectType

        metricVar <- c("impressions","views")
        filterList <- names(table(fs$site))
        filterName <- "site"
        bstack <- comImprFilter(fs,sectType,timeVar,metricVar,metricType,filterList,filterName)
        siteGrp$var <<- bstack$volume
        colnames(siteGrp)[colnames(siteGrp)=='var'] <<- sectType
        
        metricVar <- c("impressions","views")
        filterList <- c(names(table(fs$section)))
        filterName <- "section"
        bstack <- comImprFilter(fs,sectType,timeVar,metricVar,metricType,filterList,filterName)
        siteGrp$var <<- bstack$volume
        colnames(siteGrp)[colnames(siteGrp)=='var'] <<- sectType
    }
    else{print("No elements selectable")}
}

month <- names(table(fs$Month))
timeVar <- names(table(fs$Month))
metricVar <- c("impressions")
metricType <- c("measured")
devFile <- c("desktop","mobile")
dev<-devFile[2]
dev<-devFile[1]
for(dev in devFile){
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_sn",sep="")
    set <- fs1$format=="sn"
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_u",sep="")
    set <- (fs1$format=="rn"&fs1$position=="u")
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_2",sep="")
    set <- (fs1$format=="rn"&fs1$position=="2")
    pointMetric(fs,set,sectType,metricType)
    sectType <- paste(dev,"_",metricVar,"_",metricType,"_rn_3",sep="")
    set <- (fs1$format=="rn"&fs1$position=="3")
    pointMetric(fs,set,sectType,metricType)
}



write.csv(imprGrp,"out/imprDevFormat.csv")
write.csv(durGrp,"out/durationDevFormat.csv")
write.csv(siteGrp,"out/siteDevFormat.csv")
write.csv(sectGrp,"out/sectDevFormat.csv")


