#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/node/')
setwd('/home/sabeiro/lav/media/')
rm(list=ls())

##source('script/graphEnv.R')

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


tName <- c("mno","nugg","adv")

data <- xmlToList(xmlParse("node/taxonomy/opml/taxonomy_prod.opml"))


##mno
tCats <- 1:(length(data$body$outline)-1)
i <- 2
j <- 2
k <- 1

cats <- NULL
for(i in tCats){
    taxA <- (data$body$outline[[i]])
    cBranch <- NULL
    gBranch <- NULL
    for(j in 1:(length(taxA)-1)){
        taxB <- taxA[[j]]
        newrow <- c(taxB$.attrs[[1]],taxB$.attrs[[2]],taxB$.attrs[[3]],taxB$.attrs[[4]])
        gBranch = rbind(gBranch,newrow)
        for(k in 1:(length(taxB)-1)){
            taxC <- taxB[[k]]
            ## key <- unlist(strsplit(taxC[[5]],split=","))[1]
            ## value <- unlist(strsplit(taxC[[5]],split=","))[3]
            newrow <- c(taxB$.attrs[[1]],taxC[[1]],taxC[[2]],taxC[[3]],taxC[[4]],taxC[[5]])
            cBranch = rbind(cBranch,newrow)
        }
    }
    tBranch <- t(as.data.frame(taxA$.attrs))
    cats <- rbind(cats,tBranch)
    fName <- paste("node/taxonomy_files/taxonomy_grp_",tBranch[1],".csv",sep="")
    colnames(gBranch) <-  c("text","CAT","REACH","IDS")
    write.csv(gBranch,fName)
    getwd()
    fName <- paste("node/taxonomy_files/taxonomy_",tBranch[1],".csv",sep="")
    colnames(cBranch) <-  c("group","text","CAT","REACH","IDS","BK_phints_rule")
    write.csv(cBranch,fName)
}
colnames(cats) <- c("text","CAT","REACH","IDS")
write.csv(cats,"node/taxonomy_files/taxonomy_top.csv")

cats

cBranch <- as.data.frame(cBranch)
head(cBranch)
class(cBranch)
Geo <- cBranch[grep("Geo",cBranch$group),]


