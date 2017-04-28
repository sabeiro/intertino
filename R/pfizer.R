#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')


##tmp pfizer
fs <- read.table("raw/pfizer.csv",header=TRUE,sep=",",fill=TRUE,quote='"')
head(fs)

fList <- data.frame(filter = names(table(fs$Keywords)))
x <- fList$filter[1]
fList$sum =  sapply(fList$filter,function(x) sum(fs[fs$Keywords==x,"action"],na.rm=TRUE))
tot <- sum(fList$sum)
fList$share = sapply(fList$sum,function(x) x/tot)
fList$share = paste(floor(fList$share*100),"%" )

fList[fList$filter=="complete","sum"]/fList[fList$filter=="start","sum"]

source("script/comImpr.R")
fs1 <- fs
head(fs)
fs$x <- fs$Site
fs$y <- fs$action
timeType <- "Site"
timeVar <- names(table(fs$Site))#c("Desktop","Mobile","Tablet","Unknown")
filterList <- as.vector(fList$filter)
filterName <- c("Keywords")
sectType <- c("tutti")
metricVar <- c("action")
metricType <- c("measured")
devFile <- c("")
mTab <- data.frame(x = c(as.vector(filterList),"rest","total"))
rTab <- mTab#head(mTab[with(mTab,order(-y)),],n=100)
sectGrp <<- data.frame(filter = rep(rTab$x,length(timeVar)))
sectGrp$x <- as.vector(sapply(timeVar,function(x) rep(x,length(rTab$x))))
dev <- devFile[1]
for(dev in devFile){
    sectType <- paste(dev,"",sep="")
    set <- grepl(dev,fs1[,metricVar[1]])
    print(sectType)
    set[is.na(set)] <- FALSE
    fs <- fs1[set,]
    if(any(set)){
        bstack <- comImprFilterMelt(fs,sectType,timeVar,timeType,metricVar,metricType,filterList,filterName)
        sectGrp$var <- bstack$volume
        colnames(sectGrp)[colnames(sectGrp)=='var'] <- sectType
    }
    else{print("No elements selectable")}
}

write.table(sectGrp,"out/pfizerDevFormat.csv",row.names=FALSE,append=FALSE,sep=",")

totAll <- sum(sectGrp[sectGrp$filter=="total",3])
for(x in timeVar){
    tot <- sectGrp[sectGrp$x==x&sectGrp$filter=="total",3]/totAll
    perc <- sectGrp[sectGrp$x==x&sectGrp$filter=="complete",3]/sectGrp[sectGrp$x==x&sectGrp$filter=="start",3]
    print(c(x,tot,perc))
}
