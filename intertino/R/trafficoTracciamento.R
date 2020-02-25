#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library('corrplot') #package corrplot
require(stats)
require(dplyr)
library(grid)

probcum <- 0.60

fs1 <- read.csv("raw/sizeSectionSiteFeb.csv")
fs1$section <- paste(fs1$Site,fs1$Section,sep="|")
set <- TRUE ##
set <- set & ( fs1$Size == 'RECTANGLE' | fs1$Size == 'STRIP SKIN MASTHEAD')
set <- set & (!grepl('Autopromo',fs1$AdvertiserType))
set <- set & (!grepl('XAXIS',fs1$Section) | !grepl('RTB',fs1$Section))
set <- set & (!grepl('PUBMATIC',fs1$AdvertiserName) | !grepl('Pubmatic',fs1$Section) | !grepl('PUBLITALIA',fs1$Section) | !grepl('Test',fs1$Section) | !grepl('TEST',fs1$Section))
set <- set & (grepl('[REDIRECT]',fs1$AdTemplateDescription) | grepl('[IMGFLASHHTML5]',fs1$AdTemplateDescription)| grepl('[FLASHIMGHTML5]',fs1$AdTemplateDescription))
table(set)
fs1 <- fs1[set,]
site1 <- ddply(fs1[,c("Imps","Site")],.(Site),summarise,imps=sum(Imps,na.rm=TRUE))
head(fs1)
colnames(site1) <- c("site","imps")
site1$site <- as.character(site1$site)
site1$imps <- as.numeric(site1$imps)
site1$site <- gsub("[[:punct:]]","",site1$site)
site1 <- site1[order(-site1$imps),]
site1[is.na(site1$site),"site"] <- "-"
site1[site1$site==NULL,"site"] <- "-"
site1[site1$site=="","site"] <- "-"
lim <- quantile(site1$imps,probcum)
tot1 <- sum(as.numeric(site1$imps),na.rm=TRUE)
site1 <- site1[site1$imps > lim,]

fs <- read.csv('raw/comScoreFebbraio.csv',encoding="UTF-8",sep=",",header=TRUE)
fs$Month <- gsub(" 2016","",fs$Month)
source('script/comLoad.R')

site0 <- ddply(fs[,c("impressions","site")],.(site),summarise,imps=sum(impressions,na.rm=TRUE))
colnames(site0) <- c("site","imps")
site0$site <- as.character(site0$site)
site0$imps <- as.numeric(site0$imps)
site0$site <- gsub("[[:punct:]]","",site0$site)
site0 <- site0[order(-site0$imps),]
site0[is.na(site0$site),"site"] <- "-"
site0[site0$site==NULL,"site"] <- "-"
site0[site0$site=="","site"] <- "-"
lim <- quantile(site0$imps,probcum)
tot0 <- sum(as.numeric(site0$imps),na.rm=TRUE)
site0 <- site0[site0$imps > lim,]



##sapply(site1$site,function(x) site0[grepl(x,site0$site),"site"])
set <- match(site0$site,site1$site)
set <- !is.na(set)
siteM <- site0[set,]
set <- match(siteM$site,site1$site)
set <- set[!is.na(set)]
siteM$imps1 <- site1[set,"imps"]
siteM <- rbind(siteM,c("rest",tot0-sum(siteM$imps),tot1-sum(siteM$imps1)))
##siteM <- rbind(siteM,c("total",tot0,tot1))
siteM$share <- as.numeric(siteM$imps)/as.numeric(siteM$imps1)
siteM$imps <- as.numeric(siteM$imps)/1000000
siteM$imps1 <- as.numeric(siteM$imps1)/1000000
siteM <- siteM[order(-siteM$imps1),]
siteM$site <- tryTolower(siteM$site)
siteM$site <- factor(siteM$site , levels= siteM$site )

write.csv(siteM$site,"out/matchingSites.csv")

melted <- melt(siteM[,c("site","imps","imps1")],id="site")
melted$site <- factor(melted$site , levels= melted$site )
##melted$value <- as.numeric(melted$value)/1000000
fLab <- c("comscore","dotandad")
gLabel = c("\nsite","volume Mio",paste("impressioni e tracciamento per sito"),"percentuale\ntracciata")
bplot <- ggplot(siteM,aes(x=site,fill=1)) +
    geom_bar(aes(y=imps1),stat="identity",position="stack",fill=gCol[1]) +
    geom_bar(aes(y=imps),stat="identity",position="stack",fill=gCol[2]) +
    geom_text(aes(y=imps1/2,fill=1,label=percent(share)),color="white",size=4) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(.75,.73),
##        legend = element_blank(),
        legend.background = element_rect(fill=alpha('white',0.3),color="white"),
        legend.position ="right"
    ) +
##    scale_fill_manual(values=gCol,labels=fLab) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
bplot
fName <- paste("fig/trackingShare","","",".png",sep="")
ggsave(file=fName, plot=bplot, width=gWidth, height=gHeight)




