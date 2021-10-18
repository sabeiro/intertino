#!/usr/bin/env Rscript
##http://www.inside-r.org/howto/time-series-analysis-and-order-prediction-r
setwd('C:/users/giovanni.marelli/lav/media/')
source('script/graphEnv.R')
library(tm)
source('script/CommLibrary.R')


fs <- read.csv('raw/WebtrekkTree.csv',stringsAsFactors=FALSE)

colnames(fs) <- as.character(fs[5,])
fs <- fs[-c(1:5),]
fs <- fs[!fs$Pages=='',]

head(fs)

bRate <- fs[,c("Pages","Page Impressions","Exits","Bounce Rate %","Page Duration Avg")]
colnames(bRate) <- c("Pages","imps","exits","bounce","dur")
bRate$imps <- as.numeric(bRate$imps)
bRate$exits <- as.numeric(bRate$exits)
bRate$bounce <- as.numeric(bRate$bounce)
bRate$dur <- as.numeric(bRate$dur)
bRate$Pages <-  gsub("http://", "", bRate$Pages)
bRate$Pages <-  gsub("www.", "", bRate$Pages)
bRate$domain <- do.call(rbind,strsplit(bRate$Pages,split="/") )[,1]
bRate$section <- do.call(rbind,strsplit(bRate$Pages,split="/") )[,2]
comm_prob = 0.96
lFreq = sort(table(bRate$domain), decreasing=TRUE)
lim = quantile(lFreq, probs=comm_prob)
lGood <- names(lFreq[lFreq > lim])
bRate <- bRate[!is.na(match(bRate$domain,lGood)),]
table(bRate$domain)
head(bRate)

## bRate[is.na(bRate$bounce),"imps"] <- NA
## bRate[is.na(bRate$dur),"imps"] <- NA
## bRate[is.na(bRate$imps),"bounce"] <- NA
## bRate[is.na(bRate$imps),"dur"] <- NA

sitePerf <- ddply(bRate,c("domain"),summarise,Imps = sum(imps,na.rm=TRUE),Exits = sum(exits,na.rm=TRUE),Bounce = weighted.mean(bounce,imps,na.rm=TRUE),Dur = weighted.mean(dur,imps,na.rm=TRUE))





sPerf <- read.csv("pres/sitePerformances.csv")
sPerf$bounce.rate <- as.numeric(sPerf$bounce.rate)
sPerf$page.views.M <- as.numeric(sPerf$page.views.M)
head(sPerf)

bstack <- melt(sPerf[,c("site","section","source","page.views.M")],id="site",value.name="volume", variable.name="var", na.rm=TRUE)

gLabel = c("site","page views",paste("pageviews",month),"percentage")
p <- ggplot(sPerf) +
    geom_bar(aes(x=site,y=page.views.M,fill=source),stat="identity",alpha=.90) +
##    facet_grid(. ~ section) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.background = element_blank(),
        text = element_text(size = gFontSize)
    )
p
fName <- paste("fig/pageViewsSite_",month,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)



gLabel = c("site","bounce rate",paste("bounce rate",month),"percentage")
p <- ggplot(sPerf) +
    geom_bar(aes(x=site,y=bounce.rate,fill=source),stat="identity",alpha=.90) +
##    facet_grid(. ~ section) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.background = element_blank(),
        text = element_text(size = gFontSize)
    )
p
fName <- paste("fig/bounceRateSite_",month,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
