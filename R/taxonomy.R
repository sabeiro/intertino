#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/node/')
rm(list=ls())

source('../script/graphEnv.R')

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
require('XML')
library("methods")
library(httr)
opts <- list(proxy="",proxyusername = "",proxypassword="",proxyport="")
options(RCurlOptions = opts)
getOption("RCurlOptions")






taxonomyMediamond<-RJSONIO::fromJSON("http://services.bluekai.com/Services/WS/classificationCategories?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=5aNsna3%2FL%2FgWdyxDiHi%2B4YuM7fm045i2cgfmBBZ%2FMBU%3D")
r <- httr::GET("http://services.bluekai.com/Services/WS/classificationCategories?bkuid=750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f&bksig=5aNsna3%2FL%2FgWdyxDiHi%2B4YuM7fm045i2cgfmBBZ%2FMBU%3D")

GET("http://example.com/")
getURL("http://example.com")

google <- handle("http://google.com")
GET(handle = google, path = "/")
GET(handle = google, path = "search")


req <- curl_fetch_memory("https://httpbin.org/get")
str(req)



#curlSetOpt(cookiejar = 'cookies.txt' ,useragent = agent,followlocation = TRUE ,autoreferer = TRUE ,curl = curl,.opts = list(proxy="proxylocation.com:8080")

library(jsonlite)
serviceKey <- "750191b6ae4af549a35fffae8dd27930500f6b5ec43569b72b741680f92ab26f"
privateKey <- "0e3cb02cacfcca23724e25515b4cbe61b2ac954dc0fc495d1daadd246eddd0c5"
catUrl <- paste("http://services.bluekai.com/Services/WS/classificationCategories?","bkuid=",serviceKey,"&bksig=",privateKey,sep="")
postJson <- '{"name": "nugg","parent_id": 498541,"description": "nugg taxonomy","analytics_excluded": "false","navigation_only": "false","mutex_children": "false","notes": "Sample notes"}'
req <- POST(url=catUrl,body=postJson)
stop_for_status(req)
json <- content(req, "text")
# JSON starts with an invalid character:
validate(json)
json <- substring(json, 2)
validate(json)

# Now we can parse
object <- jsonlite::fromJSON(json)
print(objects)



fs <- read.csv("json/listaCap.csv")
fs$cap <- substring(fs$CAP,first=1,last=2)
table(fs$cap)
head(fs)
aFs <- ddply(fs,.(cap),summarise,prov=head(Regione,n=1))
aFs <- ddply(aFs,.(prov),summarise,caps=paste(cap,collapse=" "))


write.csv(aFs,"tmp.csv")



fs1 <- read.csv("../raw/provinceRegioni.csv")
head(fs1)




