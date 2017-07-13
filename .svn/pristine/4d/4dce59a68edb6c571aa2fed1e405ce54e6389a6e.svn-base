#!/usr/bin/env Rscript
##https://docs.google.com/spreadsheets/d/1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c/edit?pref=2&pli=1#gid=274965455
##https://docs.google.com/spreadsheets/d/1EIpoV-qou7q33mX1EE3s4E1jrR73n7ayOYTX8gb7j7c/edit?pli=1#gid=2023380516
##setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')
##
setwd("/home/sabeiro/lav/media/")
source('script/graphEnv.R')
library(RCurl)
library(digest)
library(base64enc)
library(jsonlite)
library(rjson)

cred <- fromJSON(paste(readLines("credenza/bluekai.json"),collapse=""))
keyP = cred$bkuid_json
keyS = cred$bksecret_json
uDom <- 'http://services.bluekai.com'
uPath <- '/Services/WS/'
uServ <- 'audiences'
data <- '{}'
method <- 'GET'
stringToSign = paste(method,uPath,uServ,fromJSON(data),sep='')
current <- hmac(keyS,stringToSign,algo="sha256",serialize=FALSE,raw=TRUE)
encS <- URLencode(base64encode(current),reserved=TRUE)
URL <- paste(uDom,uPath,uServ,"?bkuid=",keyP,"&bksig=",encS,sep="")
html <- getURLContent(URL)
audList <- jsonlite::fromJSON(html)$audiences
audD <- data.frame(name=audList$name,id=audList$id)
## audD <- NULL
## audL <- as.numeric(labels(audList)[[1]])
## for(i in audL ){audD <- rbind(audD,c(audList[[i]]$name,audList[[i]]$id))}
## audD <- as.data.frame(audD)
audD$url <- NULL
for(j in 1:nrow(audD)){
    stringToSign = paste(method,uPath,uServ,"/",audD$id[j],fromJSON(data),sep='')
    current <- hmac(keyS,stringToSign,algo="sha256",serialize=FALSE,raw=TRUE)
    encS <- URLencode(base64encode(current),reserved=TRUE)
    URL <- paste(uDom,uPath,uServ,"/",audD$id[j],"?bkuid=",keyP,"&bksig=",encS,sep="")
    audD$url[j] <- URL
}

audComp <- NULL
j <- 1
for(j in 1:nrow(audD)){
    print(audD$name[j])
    html <- getURLContent(audD$url[j])
    ## audList <- jsonlite::fromJSON(html)
    ## audList[[1]][[1]]$segments
    ## str(rjson::fromJSON(html))
    audList <- fromJSON(html)$segments$AND[[1]]$AND[[1]]$OR
    catD <- NULL
    for(i in as.numeric(labels(audList)) ){
        catD <- rbind(catD,c(audList[[i]]$name,audList[[i]]$cat))
    }
    catD <- as.data.frame(catD)
    catD$audName <- audD$name[j]
    catD$audId <- audD$id[j]
    audComp <- rbind(audComp,catD)
}


write.csv(audComp,"rep/audienceYahooCat.csv")
write.csv(audD,"rep/audienceYahoo.csv")
set <- grepl("mm01",audComp$audName)
audN <- audComp[set,]
audO <- audComp[!set,]
audO <- audO[grepl("s-d",audO$audName) | grepl("i-t",audO$audName),]

audInt <- audO[match(audO$V2,audN$V2),]
audInt <- audInt[!is.na(audInt$V2),]

write.csv(audInt,"rep/audienceYahooCat.csv")


30*7/4
