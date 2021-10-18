#!/usr/bin/env Rscript
rm(list=ls())
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')

library('jsonlite')
library('rjson')
library('RJSONIO')
#library('shiny')
library('RCurl')
library('curl')
library('dataview')
library('data.tree')
library('htmlwidgets')
library(networkD3)
##
library('XML')
library("methods")
library(httr)
opts <- list(proxy="",proxyusername = "",proxypassword="",proxyport="")
options(RCurlOptions = opts)
getOption("RCurlOptions")


cats <- read.csv("node/taxonomy_files/taxonomy_top.csv")
top <- newXMLNode("opml",attrs=c(version="1.0"))
newXMLNode("head",c(newXMLNode("title","taxonomy_mediamond"),newXMLNode("expansionState","0,1")), parent = top)
body <- newXMLNode("body")
selfCl <- newXMLNode("outline",attrs=c(text="Self-Classification",CAT="false:false:false",REACH=0,IDS="498541::"),parent=body)
tName <- unique(cats$text)
i <- tName[2]
for(i in unique(cats$text)){
    catR <- cats[cats$text==i,]
    attR <- c(text=as.character(catR$text),CAT=as.character(catR$CAT),REACH=as.character(catR$REACH),IDS=as.character(catR$IDS))
    taxAdv <- newXMLNode("outline",attrs=attR,parent=selfCl)
    fName <-  paste("node/taxonomy_files/taxonomy_",i,".csv",sep="")
    tAdv <- read.csv(fName,stringsAsFactors=FALSE)
    fName <-  paste("node/taxonomy_files/taxonomy_grp_",i,".csv",sep="")
    gAdv <- read.csv(fName,stringsAsFactors=FALSE)
    ##j <- gAdv$text[1]
    for(j in gAdv$text){
        set <- tAdv[tAdv$group==j,]
        setG <- gAdv[gAdv$text==j,]
        aGroup <- newXMLNode("outline",attrs=c(text=setG$text,CAT=setG$CAT,REACH=setG$REACH,IDS=setG$IDS),parent=taxAdv)
        ##k <- 1
        for(k in 1:length(set$text)){
            newXMLNode("outline",attrs=c(text=set$text[k],CAT=set$CAT[k],REACH=set$REACH[k],IDS=set$IDS[k],BK_phints_rule=set$BK_phints_rule[k]),parent=aGroup)
        }
    }
}
addChildren(top,body)
doc = newXMLDoc(top)
saveXML(doc,"node/taxonomy_files/taxonomy_prod.opml")







