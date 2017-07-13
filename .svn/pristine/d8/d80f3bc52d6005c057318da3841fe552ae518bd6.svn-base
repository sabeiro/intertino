#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library(car)

advList <- read.csv("raw/adv2015.csv",sep=",")
advList$Ctr.. <- advList$Click/advList$Imps
advList$Ctr..[is.na(advList$Ctr..)] <- 0
advList$Ctr..[advList$Ctr.. == Inf] <- 0
advList$AdvertiserName <- as.character(advList$AdvertiserName)
## aCat <- read.csv("raw/advCat.csv",header=TRUE)
## advList$cat <- sapply(advList$AdvertiserName,function(x) aCat[match(x,aCat$name),"cat"])

advList <- advList[-grepl("Default",advList$AdvertiserName),]
advList <- advList[-grepl("PUBMATIC",advList$AdvertiserName),]
advList <- advList[-grepl("FORMATI VUOTI",advList$AdvertiserName),]

cumprob <- c(0.90,0.60,0.50,0.60,0.60,0.90,0.70)
filterN <- c("AdvertiserName","Publisher","Site","Channel","Section","Size","DeviceType")

for(i in 1:length(cumprob)){
    filter <- table(advList[,filterN[i]])
    filter <- filter[order(-filter)]
    lim <- quantile(filter,cumprob[i])
    filter <- filter[filter > lim]
    advList <- advList[advList[,filterN[i]] %in% names(filter),]
}
##----------------------assign----cat--------------------------
aCat <- read.csv("raw/advCat.csv",header=TRUE)
aCat$cat <- paste(aCat$cat,aCat$subCat,sep="|")
advList$cat <- sapply(advList$AdvertiserName,function(x) aCat[match(x,aCat$name),"cat"])
##---------------------clean-adv-name----------------------------
aStopAdv <- read.csv("raw/advStopAdvertiser.csv",header=FALSE)[,1]
advList$AdvertiserName <- removeWords(advList$AdvertiserName,aStopAdv)
advList$AdvertiserName = gsub("[[:punct:]]","",advList$AdvertiserName)
advList$AdvertiserName <- removeWords(advList$AdvertiserName,aStopAdv)
advList$AdvertiserName = gsub("  "," ",advList$AdvertiserName)
## advList$AdvertiserName = gsub("  "," ",advList$AdvertiserName)
advList$AdvertiserName = gsub("SPA","",advList$AdvertiserName)
## advList$AdvertiserName = tryTolower(advList$AdvertiserName)
##-----------------------write-out---------------------------
fName <- paste("raw/adv2015short.csv",sep="")
write.csv(advList,fName)


aCat <- read.csv("raw/advCat.csv",header=TRUE)
table(aCat$cat)
write.csv(table(aCat$cat),"raw/advCatMap.csv")
head(aCat)













