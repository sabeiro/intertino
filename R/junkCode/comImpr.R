#!/usr/bin/env Rscript
subFilter <- function(fs,key,value){
    set <- fs[,key]==value
    set[is.na(set)] <- FALSE
    if(any(set)){set} else{NULL}
}
sub2Filter <- function(fs,key1,value1,key2,value2){
    set <- fs[,key1]==value1&fs[,key2]==value2
    set[is.na(set)] <- FALSE
    if(any(set)){set}else{NULL}
}
comImpr <- function(fs,sectType,timeVar,metricVar,metricType){
    ##-----------------------impression-grouping-----------------------
    print("impression grouping")
    metricType <- c("measured")
    channelType <- unlist(strsplit(sectType,"_"))[1]#dev
    view <- as.data.frame(timeVar)
    for(i in metricVar){
        view$var <- sapply(timeVar,function(xx) sum(subset(fs,x==xx)[i],na.rm=TRUE))
        colnames(view)[colnames(view)=='var'] <- c(i)
    }
    bstack <- melt(view,id="timeVar",value.name="volume", variable.name="var", na.rm=FALSE)
    bstack$share <- rep(0,length(bstack$timeVar))
    channel <- vector()
    for(i in channelType){channel <- c(channel,rep(i,length(timeVar)))}
    bstack$channel <- rep(unlist(strsplit(sectType,"_"))[1],length(timeVar))
    type <- vector()
    for(i in metricType){type <- c(type,rep(i,length(metricType)*length(timeVar)))}
    bstack$metric <- type
    for(i in timeVar){
        for(j in metricType){
             set <- bstack$timeVar==i&bstack$metric==j
             bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume,na.rm=TRUE)
         }
    }
    bstack
}
comImprFilter <- function(fs,sectType,timeVar,metricVar,metricType,filterList,filterName){
    print("impression site grouping")
    view <- data.frame(filter = c(filterList,"rest","total"))
    i <- timeVar[1]
    j <- filterList[1]
    for(i in timeVar){
        view$var <- rep(0,length(filterList)+2)
        totI <- 0
        for(j in filterList){
            set <- fs$x==i & grepl(j,fs[,filterName])
            set[is.na(set)] <- FALSE
            if(!any(set)){next}
            sumMet <- sum(fs[set,metricVar[1]],na.rm=TRUE)
            view[filterList==j,]$var <- sumMet
            totI <- totI + sumMet
        }
        view[view$filter=="total",]$var <- sum(fs[fs$x==i,metricVar[1]],na.rm=TRUE)
        view[view$filter=="rest",]$var <- view[view$filter=="total","var"] - totI
        colnames(view)[colnames(view)=='var'] <- c(i)
    }
    view

    ## bstack <- melt(view,id="filter",value.name="volume", variable.name="timeVar", na.rm=FALSE)
    ## bstack$share <- rep(0,length(bstack$timeVar))
    ## i <- timeVar[1]
    ## for(i in timeVar){
    ##     set <- bstack$timeVar==i
    ##     bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume,na.rm=TRUE)
    ## }
    ## bstack
}
comImprFilterMelt <- function(fs,sectType,timeVar,timeType,metricVar,metricType,filterList,filterName){
    print("impression site grouping")
    view <- data.frame(filter = c(filterList,"rest","total"))
    i <- timeVar[1]
    j <- filterList[1]
    for(i in timeVar){
        view$var <- rep(0,length(filterList)+2)
        totI <- 0
        for(j in filterList){
            set <- grepl(i,fs[,timeType[1]]) & grepl(j,fs[,filterName])
            set[is.na(set)] <- FALSE
            if(!any(set)){next}
            sumMet <- sum(fs[set,metricVar[1]],na.rm=TRUE)
            view[filterList==j,]$var <- sumMet
            totI <- totI + sumMet
        }
        view[view$filter=="total",]$var <- sum(fs[grepl(i,fs[,timeType[1]]),metricVar[1]],na.rm=TRUE)
        view[view$filter=="rest",]$var <- view[view$filter=="total","var"] - totI
        colnames(view)[colnames(view)=='var'] <- c(i)
    }
    bstack <- melt(view,id="filter",value.name="volume", variable.name="timeVar", na.rm=FALSE)
    bstack$share <- rep(0,length(bstack$timeVar))
    i <- timeVar[1]
    for(i in timeVar){
        set <- bstack$timeVar==i
        bstack[set,]$share <- round(bstack[set,]$volume/sum(bstack[set,]$volume,na.rm=TRUE),3)
    }
    bstack
}

comConvFilterMelt <- function(fs,sectType,timeVar,timeType,metricVar,metricType,filterList,filterName){
    print("impression site grouping")
    view <- as.data.frame(c(filterList,"rest","total"))
    colnames(view) <- "filter"
    i <- timeVar[1]
    j <- filterList[1]
    for(i in timeVar){
        view$var <- rep(0,length(filterList)+2)
        totI <- 0
        totV <- 0
        for(j in filterList){
            set <- fs[,timeType[1]]==i&fs[,filterName[1]]==j
            set[is.na(set)] <- FALSE
            if(!any(set)){next}
            sumV <- sum(fs[set,metricVar[2]],na.rm=TRUE)
            sumI <- sum(fs[set,metricVar[1]],na.rm=TRUE)
            ratio <- ifelse(sumI <= 0, 0, sumV/sumI)
            view[filterList==j,]$var <- ratio
            totI <- totI + sumI
            totV <- totV + sumV
        }
        sumV <- sum(fs[fs[,timeType[1]]==i,metricVar[2]],na.rm=TRUE)
        sumI <- sum(fs[fs[,timeType[1]]==i,metricVar[1]],na.rm=TRUE)
        ratio <- ifelse(sumI <= 0, 0, sumV/sumI)
        view[view$filter=="total",]$var <- ratio
        view[view$filter=="rest",]$var <- (sumV-totV)/(sumI-totI)
        colnames(view)[colnames(view)=='var'] <- c(i)
    }
    bstack <- melt(view,id="filter",value.name="volume", variable.name="timeVar", na.rm=FALSE)
    bstack$share <- rep(0,length(bstack$timeVar))
    i <- timeVar[1]
    for(i in timeVar){
        set <- bstack$timeVar==i
        bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume,na.rm=TRUE)
    }
    bstack
}

comConvFilterNoTime <- function(fs,sectType,metricVar,metricType,filterList,filterName){
    print("impression site grouping")
    view <- as.data.frame(c(filterList,"rest","total"))
    colnames(view) <- "filter"
    view$var <- rep(0,length(filterList)+2)
    totI <- 0
    totV <- 0
    for(j in filterList){
        set <- fs[,filterName]==j
        set[is.na(set)] <- FALSE
        if(!any(set)){next}
        sumV <- sum(fs[set,metricVar[2]],na.rm=TRUE)
        sumI <- sum(fs[set,metricVar[1]],na.rm=TRUE)
        view[filterList==j,]$var <- sumV/sumI
        totI <- totI + sumI
        totV <- totV + sumV
    }
    view[view$filter=="total",]$var <- sum(fs[metricVar[2]],na.rm=TRUE)/sum(fs[metricVar[1]],na.rm=TRUE)
    view[view$filter=="rest",]$var <- view[view$filter=="total",]$var - totV/totI

    bstack <- melt(view,id="filter",value.name="volume", variable.name="timeVar", na.rm=FALSE)
    bstack$share <- rep(0,length(bstack$timeVar))
    bstack$share <- bstack$volume/sum(bstack$volume,na.rm=TRUE)
    bstack
}






