#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')

fs <- read.csv('raw/impressionDelivered.csv',encoding="UTF-8")
fs$Impression <- gsub(",","",fs$Impression)
fs$settimana <- gsub(",","",fs$settimana)
fs$Data <- as.Date(fs$Data,format="%m/%d/%Y")
delivered <- fs[fs$settimana>0,c("Data","settimana")]
colnames(delivered) <- c("date","delivered")

fs <- read.csv('raw/impressionDefault.csv',encoding="UTF-8")
fs$Impression <- gsub(",","",fs$Impression)
fs$settimana <- gsub(",","",fs$settimana)
fs$Data <- as.Date(fs$Data,format="%m/%d/%Y")
default <- fs[fs$settimana>0,c("Data","settimana")]
colnames(default) <- c("date","default")

fs <- read.csv('raw/impressionTappi.csv',encoding="UTF-8")
fs$Impression <- gsub(",","",fs$Impression)
fs$settimana <- gsub(",","",fs$settimana)
fs$Data <- as.Date(fs$Data,format="%m/%d/%Y")
tappi <- fs[fs$settimana>0,c("Data","settimana")]
colnames(tappi) <- c("date","tappi")

fs <- read.csv('raw/impressionTotal.csv',encoding="UTF-8")
fs$Impression <- gsub(",","",fs$Impression)
fs$settimana <- gsub(",","",fs$settimana)
fs$Data <- as.Date(fs$Data,format="%m/%d/%Y")
total <- fs[fs$settimana>0,c("Data","settimana")]
colnames(total) <- c("date","total")

imprComp <- merge(delivered,default,by="date")
imprComp <- merge(imprComp,tappi,by="date")
imprComp <- merge(imprComp,total,by="date")

          
