#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library("igraph")
library("network")
library("sna")
library("ndtv")
##library('geomnet')
library(shiny)
library(plotly)
library(d3heatmap)
library(hash)
library(digest)

mList <- c("October","November","December","January","February","March","April")
mList <- c("April")
fSect <- "section"
isChiara <- FALSE
editorL <- c("rti","ame")
e <- editorL[1]

## fSect <- "adv"
## mList <- "March"
month <- mList[1]
NSect <- 20

fName <- paste("out/comImprDevFormat",fSect,month,"_V2.csv",sep="")
fLab <- c("pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")
siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep=",")
siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
print(e)
set <- TRUE
if(fSect=="section"){set <- set & grepl(e,siteGrp2[,fSect])}
if(isChiara){set <- set & (grepl("TGCOM",siteGrp2[,fSect]) | grepl("SPORT",siteGrp2[,fSect]) | grepl("METEO",siteGrp2[,fSect]))}
siteGrp3 <- siteGrp2[set,]
siteGrp3 <- siteGrp3[order(-siteGrp3$imps),]
tot <-  colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)
siteGrp3 <- siteGrp3[1:NSect,]
if(fSect=="section"){
    channelL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',1)
    siteL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',2)
    siteL <- gsub("MEDIASET","",siteL)
    siteGrp3[,fSect] <- paste(channelL,siteL,sep="_")
}
rest <- colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)

siteGrp <- data.frame(section = siteGrp3[,fSect])
siteGrp$section <- gsub("  "," ",siteGrp$section)
siteGrp$section <- gsub("DONNAMODERNA","DM",siteGrp$section)
vGrp <- as.matrix(siteGrp3[,grepl("view",colnames(siteGrp3))])
rownames(vGrp) <- siteGrp3[,fSect]
iGrp <- as.matrix(siteGrp3[,grepl("imps",colnames(siteGrp3))])
rownames(iGrp) <- siteGrp3[,fSect]
cGrp <- as.matrix(vGrp / iGrp)
colnames(cGrp) <- gsub("view","ctr",colnames(cGrp))
tot <- colSums(vGrp)/colSums(iGrp)
rest <- (colSums(vGrp) - colSums(vGrp[1:NSect,]))/(colSums(iGrp) - colSums(iGrp[1:NSect,]))
cGrp <- cGrp[order(-rowSums(iGrp)),]
rName <- rownames(cGrp)
cGrp <- rbind(cGrp,c(rest))
cGrp <- rbind(cGrp,c(tot))
cGrp[is.nan(cGrp)] <- 0
rownames(cGrp) <- c(rName,"rest","total")
melted <- melt(cGrp[,-1])
melted$Var1 <- as.ordered(melted$Var1)
melted$Var1 <- factor(melted$Var1,levels=melted$Var1 )
melted$Var2 <- gsub("ctrs","",melted$Var2)
melted$Var2 <- gsub("ctr\\.","",melted$Var2)
melted$Var2 <- as.ordered(melted$Var2)
melted$Var2 <- factor(melted$Var2,levels=melted$Var2)
melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
melted[is.na(melted)] <- 0
##melted <- na.omit(melted)

if(fSect=="section"){siteGrp <- siteGrp[c(order(siteL),NSect+1,NSect+2),]}
mSiteGrp <- as.matrix(siteGrp)
rownames(mSiteGrp) <- siteGrp
mSiteGrp[is.na(mSiteGrp)] <- 0
siteGrp$section <- as.ordered(siteGrp$section)
siteGrp$section <- as.factor(siteGrp$section)

##d3heatmap(mSiteGrp, scale = "column",color="Blues")

gLabel = c("\n\ncreatività","format",paste("viewability",month),"percentuale")
p <- ggplot(melted,aes(x=Var1,y=Var2,group=Var2)) +
    geom_tile(aes(fill=value),colour="white") +
    geom_text(aes(fill=value,label=formatC(value*100,digit=0,format="f")),colour="white",size=4) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    scale_fill_gradient(low="white",high="steelblue") +
    scale_y_discrete(labels=fLab) +
    theme(
        ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
        panel.background = element_blank()
    )
p

fName <- paste("fig/viewability_",e,"_",fSect,month,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
##(gg <- ggplotly(p))
## m <- matrix(bstack$percentage, ncol = length(siteGrp$section),nrow=length(colnames(siteGrp[,-1])))
## plot_ly(z=m,x=siteGrp$section,y=colnames(siteGrp[,-1]),type="heatmap",colorscale="steelblue")
