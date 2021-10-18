#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')
require(data.table)
require(RJSONIO)
library(edgebundleR)
##library(gtools)
library(igraph)
library("d3Network")


fs <- read.csv("raw/networkPartyLink.csv",stringsAsFactor=F)
fs <- read.csv("raw/networkPartyNode.csv",stringsAsFactor=F)
tList <- list()
for(i in 1:nrow(fs)){
    rList = "list("
    for(j in colnames(fs)){
        chr <-  ifelse(typeof(fs[i,j])=="character",paste(j,"=\"",fs[i,j],"\",",sep=""),paste(j,"=",fs[i,j],",",sep=""))
        rList <- paste(rList,chr)
    }
    rList <- paste(gsub(",$","",rList),")",sep="")
    rVect <- eval(parse(text=rList))
    tList[[i]] = rVect
}
##write(toJSON(list(links=tList)),"intertino/data/networkPartyLinks.json")
##write(toJSON(list(nodes=tList)),"intertino/data/networkPartyNodes.json")







