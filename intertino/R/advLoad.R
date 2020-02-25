#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')
library(tm)
source('script/CommLibrary.R')


advList <- read.table("raw/advertiser.csv",header=TRUE,sep=",",fill=TRUE,quote='"')
advList$Ctr.. <- gsub(",",".",gsub("%","",advList$Ctr..))

head(advList)

aType <- read.csv("raw/advType.csv",header=FALSE)[,1]
aStop <- read.csv("raw/advStop.csv",header=FALSE)[,1]
aProperty <- read.csv("raw/advProperty.csv",header=FALSE)[,1]
aTime <- read.csv("raw/advTime.csv",header=FALSE)[,1]
aFormat <- read.csv("raw/advFormat.csv",header=FALSE)[,1]
aAdvertiser <- read.csv("raw/advAdvertiser.csv",header=FALSE)[,1]
aContent <- read.csv("raw/advContent.csv",header=FALSE)[,1]
aStopAdv <- read.csv("raw/advStopAdvertiser.csv",header=FALSE)[,1]
aCat <- read.csv("raw/advCat.csv",header=TRUE)
aCat$cat <- paste(aCat$cat,aCat$subCat,sep="|")

x <- advList$AdvertiserName[13]
advList$cat <- sapply(advList$AdvertiserName,function(x) aCat[match(x,aCat$name),"cat"])

advList$AdvertiserName <- removeWords(as.character(advList$AdvertiserName), aStopAdv)
advList$AdvertiserName = clean.text(advList$AdvertiserName)
## advList$Site = clean.text(advList$Site)
## advList$Channel = clean.text(advList$Channel)
##advList$Publisher = clean.text(advList$Publisher)

comm_field <- advList$AdDescription
comm_field <- gsub("300x250"," rnsm ",comm_field)
comm_field <- gsub("300x600"," rnlg ",comm_field)
comm_field <- gsub("970x250"," snsm ",comm_field)
comm_field <- gsub("988x320"," snlg ",comm_field)
omm_field <- gsub("728x90"," leaderboard ",comm_field)
comm_field <- gsub("android","android ",comm_field)
comm_field <- gsub("iphone","iphone ",comm_field)
comm_field <- gsub("ihpone","iphone",comm_field)
comm_field <- gsub(" serie "," serie ",comm_field)
comm_field <- gsub(" super ","",comm_field)
comm_field <- gsub(" intratten "," intrattenimento ",comm_field)
comm_field <- gsub(" entert "," intrattenimento ",comm_field)
comm_field <- gsub(" men "," man ",comm_field)
comm_field <- gsub(" women "," donna ",comm_field)
comm_field <- gsub(" woman "," donna ",comm_field)
comm_field <- gsub(" donne "," donna ",comm_field)
comm_field <- gsub(" donnas "," donna ",comm_field)
comm_field <- gsub(" dona "," donna ",comm_field)
comm_field <- gsub(" man "," uomo ",comm_field)
comm_field <- gsub(" girl "," ragazza ",comm_field)
comm_field <- gsub(" bambino "," kids ",comm_field)
comm_field <- gsub(" skuolanet "," skuola ",comm_field)
comm_field <- gsub(" tweb "," webtv ",comm_field)
comm_field <- gsub(" starbeen "," starbene ",comm_field)
comm_field <- gsub(" il mio papa "," ilmiopapa ",comm_field)
comm_field <- gsub(" bo "," boing ",comm_field)
comm_field <- gsub(" ca "," cartoonito ",comm_field)
comm_field <- gsub(" cf "," casafacile ",comm_field)
comm_field <- gsub(" co "," coomingsoon ",comm_field)
comm_field <- gsub(" dm "," donnamoderna ",comm_field)
comm_field <- gsub(" fc "," focus ",comm_field)
comm_field <- gsub(" fj "," focusjunior ",comm_field)
comm_field <- gsub(" gr "," grazia ",comm_field)
comm_field <- gsub(" icon "," icon ",comm_field)
comm_field <- gsub(" ig "," ilgiornale ",comm_field)
comm_field <- gsub(" in "," interni ",comm_field)
comm_field <- gsub(" mo "," meteo ",comm_field)
comm_field <- gsub(" nc "," nelcuore ",comm_field)
comm_field <- gsub(" mp "," miopapa ",comm_field)
comm_field <- gsub(" nf "," nostrofiglio ",comm_field)
comm_field <- gsub(" pa "," panorama ",comm_field)
comm_field <- gsub(" pau "," panoramaauto ",comm_field)
comm_field <- gsub(" pr "," programmi ",comm_field)
comm_field <- gsub(" r1 "," radio101 ",comm_field)
comm_field <- gsub(" ri "," radioitalia ",comm_field)
comm_field <- gsub(" rv "," radiovirgin ",comm_field)
comm_field <- gsub(" r105 "," radio105 ",comm_field)
comm_field <- gsub(" rmc "," radiomontecarlo ",comm_field)
comm_field <- gsub(" ro "," rockol ",comm_field)
comm_field <- gsub(" sb "," starbene ",comm_field)
comm_field <- gsub(" sh "," shazam ",comm_field)
comm_field <- gsub(" sk "," skuola ",comm_field)
comm_field <- gsub(" sm "," sportmediaset ",comm_field)
comm_field <- gsub(" sp "," salepepe ",comm_field)
comm_field <- gsub(" so "," sorrisi ",comm_field)
comm_field <- gsub(" st "," sportube ",comm_field)
comm_field <- gsub(" ts "," tustyle " ,comm_field)
comm_field <- gsub(" tg "," tgcom ",comm_field)
comm_field <- gsub(" ud "," unadonna ",comm_field)
comm_field <- gsub(" mod "," mediaset ",comm_field)
comm_field <- gsub(" med "," mediaset ",comm_field)
comm_field <- gsub(" vm "," videomediaset ",comm_field)
comm_field <- gsub(" giornale "," ilgiornale ",comm_field)
comm_field <- gsub(" donna moderna "," donnamoderna ",comm_field)
comm_field <- gsub(" pano "," panorama ",comm_field)
comm_field <- gsub(" multisite "," multisito ",comm_field)
comm_field <- gsub(" multisit "," multisito ",comm_field)
comm_field <- gsub(" auto promo "," autopromo ",comm_field)
comm_field <- gsub(" auto "," motori ",comm_field)
comm_field <- gsub(" motor "," motori ",comm_field)
comm_field <- gsub(" ent "," enterteinment ",comm_field)
comm_field <- gsub(" hp "," homepage ",comm_field)
comm_field <- gsub("flashvideo"," swf ",comm_field)
comm_field <- gsub("flash"," swf ",comm_field)
comm_field = clean.text(comm_field)
comm_field = removeWords(comm_field, aStop)
advList$clean <- comm_field

flightType <- tryTolower(c("RN","SP","PB","BP","LN","DE","MS","RH","NL","SK","OV","SN","RE","MD","IP","AN","PP","IN","PV","SE","PR","CM","MO","R","SL","SV","FL","FB","CB","MV","MH","S","SH","Rectangle","Default","Custom","Concorso","Leaderboard","PromoBox","AP","Strip","FloorAd","Rectangle Exp-Video","Skin","Masthead","Half Page","Pre-Roll Video","Intro","Speciali","Publiredazionale","Dem","Overlayer","PI","PBY","BG","LBA","ST","PY","LB","NP","MASTHEAD","BC","SY","SB","LT","NH","ET","SZ"))


## advList$property <- as.vector(unlist(sapply(comm_field,function (y) aProperty[sapply(aProperty,function(x) grepl(x,y))][1])))
## advList$advertiser <- as.vector(unlist(sapply(comm_field,function (y) aAdvertiser[sapply(aAdvertiser,function(x) grepl(x,y))][1])))
## advList$content <- as.vector(unlist(sapply(comm_field,function (y) aContent[sapply(aContent,function(x) grepl(x,y))][1])))
## advList$format <- as.vector(unlist(sapply(comm_field,function (y) aFormat[sapply(aFormat,function(x) grepl(x,y))][1])))


## advList[is.na(advList$Imps),"Imps"] <- 0
## advList[is.na(advList$Imps),"Click"] <- 0
## advList[is.na(advList$Imps),"Ctr.."] <- 0

#write.table(advList,"raw/advComplete.csv",header=TRUE,sep=",",fill=TRUE,quote='"')
write.table(advList,"raw/advComplete.csv",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)


