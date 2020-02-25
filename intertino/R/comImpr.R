#!/usr/bin/env Rscript

comImpr <- function(fs,sectType,timeVar,metricVar,metricType){
                                        #-----------------------impression-grouping-----------------------
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
    view <- as.data.frame(c(filterList,"rest"))
    colnames(view) <- "filter"
    for(i in timeVar){
        view$var <- rep(0,length(filterList)+1)
        totI <- 0
        totV <- 0
j <- filterList[6]
        for(j in filterList){
            set <- fs$x==i&fs[,filterName]==j
            view[filterList==j,]$var <- sum(fs[set,metricVar[2]],na.rm=TRUE)/sum(fs[set,metricVar[1]],na.rm=TRUE)
            totI <- sum(fs[set,]$impressions,na.rm=TRUE)
            totV <- sum(fs[set,]$views,na.rm=TRUE)
        }
        view[view$filter=="rest",]$var <- abs(sum(fs[fs$Month==i,]$views,na.rm=TRUE)/sum(fs[fs$Month==i,]$impressions,na.rm=TRUE) - totV/totI)
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



