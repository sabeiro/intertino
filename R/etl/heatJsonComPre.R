#!/usr/bin/env Rscript
#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
rm(list=ls())

fL <- 1:13
i <- 8
fs <- NULL
for(i in fL){
    print(i)
    fs1 <- read.csv(paste('raw/placementTable',i,'.csv',sep=""),stringsAsFactor=F)
    head(fs1)
    ds <- ddply(fs1[,c("Site.Name","Placement.ID","Placement.Name")],.(Placement.ID),head,1)
    fs <- rbind(ds,fs)
}
fs <- ddply(fs[,c("Site.Name","Placement.ID","Placement.Name")],.(Placement.ID),head,1)
fs <- fs[grepl("_",fs$Placement.Name),]
fs <- fs[!is.na(fs$Placement.ID),]
head(fs)
tail(fs)

splitL <- strsplit(fs$Placement.Name,split="_")
i <- 1
for(i in as.numeric(labels(splitL))){
    v <- splitL[[i]]
    vN <- length(v)
    fs$editor[i] <- tryCatch(v[1],error=function(e) NA)
    fs$site[i] <- tryCatch(v[2],error=function(e) NA)
    fs$section[i] <- tryCatch(v[3],error=function(e) NA)
    fs$channel[i] <- tryCatch(v[4],error=function(e) NA)
    fs$format[i] <- tryCatch(v[vN-1],error=function(e) NA)
    fs$position[i] <- tryCatch(v[vN],error=function(e) NA)
}
##fs$position
fs$Site.Name <- tryTolower(fs$Site.Name)
head(fs)

fs$position2 <- fs$position
fs$position2[as.numeric(fs$position2)>3] <- 3


write.csv(fs,'raw/placementTable.csv')

