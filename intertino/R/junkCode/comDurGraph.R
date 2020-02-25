#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library(tm)
source('script/CommLibrary.R')
library('corrplot') #package corrplot
require(stats)
require(dplyr)
library(grid)

mList <- c("October","November","December","January","February","March","April")
##mList <- c("April")
##mList <- c("January","February")
fSect <- "section"
NSect <- 20
comprob <- 0.96
formatL <- c(".sn",".rn_u",".rn_2",".rn_3")
month <- mList[1]
f <- formatL[2]
fName <- paste("out/comImprDevFormatMetrics",fSect,month,".csv",sep="")
siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
siteGrp <- siteGrp2[,grepl(f,colnames(siteGrp2))]
colnames(siteGrp) <- gsub(f,"",colnames(siteGrp))

seqSite <- as.data.frame(setNames(replicate(length(names(siteGrp)),numeric(0), simplify = F), names(siteGrp)))
seqBot <- data.frame(vtrMob = numeric(0),vtrPC = numeric(0))
seqMonth <- as.data.frame(setNames(replicate(length(names(siteGrp[,!colnames(siteGrp)%in%c("section")])),numeric(0), simplify = F), names(siteGrp[,!colnames(siteGrp)%in%c("section")])))
for(month in mList){
    fName <- paste("out/comImprDevFormatMetrics",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    head(siteGrp2)
    siteGrp2[is.na(siteGrp2[,fSect]),fSect] <- "altri"
    fLab <- c("pc mh","pc rn uni","pc rn 2nd","pc rn 3rd","mob sn","mob rn uni","mob rn 2nd","mob rn 3rd")
    seqMonth[month,] <- 0
    for(f in formatL){
        siteGrp <- siteGrp2[,grepl(f,colnames(siteGrp2))]
        siteGrp$section <- siteGrp2[,fSect]
        colnames(siteGrp) <- gsub(f,"",colnames(siteGrp))
        head(siteGrp)
        if(is.null(siteGrp$bot)){siteGrp$bot <- 0}
        corM <- data.frame(##vtrApp = siteGrp$Mobile.App.Measured.Views / siteGrp$Mobile.App.Measured.Impressions,
                           vtrMob = siteGrp$Mobile.Measured.Views / siteGrp$Mobile.Measured.Impressions,
                           vtrPC =  siteGrp$PC.Measured.Views / siteGrp$PC.Measured.Impressions)
        comM <- as.matrix(corM)
        corM[is.na(corM)] <- 0
        corM[corM==Inf] <- 0
        corM[corM==NaN] <- 0
        seqBot <- rbind(seqBot,corM)
        seqSite <- rbind(seqSite,siteGrp)
        head(seqSite)
        head(siteGrp)
        seqMonth[month,] <- seqMonth[month,] + colSums(siteGrp[,!colnames(siteGrp)%in%c("section")],na.rm=TRUE)
    }
}

seqSite$site <- unlist(lapply(strsplit(seqSite$section,split="\\|"),function(x) x[2]))
siteAgg <- ddply(seqSite[,!colnames(seqSite)%in%c("section")],.(site),colwise(sum,na.rm=TRUE))
siteAgg$viewa.mob <- siteAgg$Mobile.Measured.Views/siteAgg$Mobile.Measured.Impressions
siteAgg$viewa.pc <- siteAgg$PC.Measured.Views/siteAgg$PC.Measured.Impressions
siteAgg$site <- tryTolower(siteAgg$site)
siteAgg$site <- gsub("\\.it","",siteAgg$site)
siteAgg$site <- gsub("mediaseta","mediaset",siteAgg$site)
siteAgg$site <- gsub("mediasetf","mediaset",siteAgg$site)
write.csv(siteAgg,"out/trafficAvComscore.csv")


melted <- melt(as.matrix(seqMonth[,grepl("Time",colnames(seqMonth))]))
## seqMonth$month <- rownames(seqMonth)
## melted <- melt(seqMonth)
melted[,"percentage"] <- (melted[,c("Var1","value")] %>% group_by(Var1) %>% mutate_each(funs(./sum(.))))[2]
melted[,"pos"] <- (melted[,c("Var1","percentage")] %>% group_by(Var1) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
melted[,"perc"] <- (melted[,c("Var1","percentage")] %>% group_by(Var1) %>% mutate_each(funs(paste(round(.*100),"%",sep=""))))[2]
melted$Var2 <- gsub("\\.","-",gsub("Direct.View.Time.","",melted$Var2))
fLabel <- c(">60s","1-5s","5-60s")
gLabel = c("\nmese","percentuale",paste("tasso di durata",""),"durata")
p <- ggplot(melted,aes(x=Var1,y=percentage,group=Var2,fill=Var2)) +
    geom_bar(stat="identity",alpha=.90) +
    geom_text(aes(label=perc,y=pos),size=5,colour='white') +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        legend.position="right",
        panel.background = element_blank(),
        text = element_text(size = gFontSize)
    ) +
    scale_fill_manual(values=gCol,labels=fLabel) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
fName <- paste("fig/DurationShare_",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

melted <- melt(as.matrix(seqMonth[,grepl("Measure",colnames(seqMonth))]))
melted$Var3 <- grepl("Impr",melted$Var2)
melted$Var3 <- sapply(melted$Var3,function(x) if(x){"imps"}else{"view"})
melted$Var2 <- gsub(".Measured.Views","",melted$Var2)
melted$Var2 <- gsub(".Measured.Impressions","",melted$Var2)
melted$Var2 <- gsub("Mobile.","",melted$Var2)
melted[,"percentage"] <- (melted[,c("Var1","Var2","value")] %>% group_by(Var1,Var2) %>% mutate_each(funs(./sum(.))))[3]
melted[,"perc"] <- (melted[,c("Var2","value")] %>% group_by(Var2) %>% mutate_each(funs(paste(round(./1000000),"",sep=""))))[2]
melted[,"pos"] <- (melted[,c("Var1","Var2","value")] %>% group_by(Var1,Var2) %>% mutate_each(funs(cumsum(.)-.*0.3)))[3]
melted <- melted[!melted$Var2=="App",]
melted$value <- melted$value/1000000
melted$pos <- melted$pos/1000000

gLabel = c("\ndevice","volume Mio",paste("volume per mese"),"sorgente")
p <- ggplot(melted,aes(x=Var2,y=value,group=1,fill=Var3)) +
    geom_bar(stat="identity",alpha=.95,position="dodge") +
    geom_text(aes(label=percent(percentage),y=pos),size=3,colour='white') +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.background = element_blank(),
        text = element_text(size = gFontSize)
    ) +
    facet_grid(. ~ Var1) +
    scale_fill_manual(values=gCol) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("fig/impressionVolume_",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

