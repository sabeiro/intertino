#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library('corrplot') #package corrplot
require(stats)
require(dplyr)
library(grid)

mList <- c("October","November","December","January")
fSect <- "section"
NSect <- 20
comprob <- 0.96
formatL <- c("_sn","_rn_u","_rn_2","_rn_3")
month <- mList[4]
f <- formatL[2]
fName <- paste("out/comImprDevFormatMetrics",fSect,month,".csv",sep="")
siteGrp <- siteGrp2[,grepl(f,colnames(siteGrp2))]
colnames(siteGrp) <- gsub(f,"",colnames(siteGrp))

seqSite <- as.data.frame(setNames(replicate(length(names(siteGrp)),numeric(0), simplify = F), names(siteGrp)))
seqBot <- data.frame(botMob = numeric(0),botPC = numeric(0),vtrMob = numeric(0),vtrPC = numeric(0))
seqMonth <- as.data.frame(setNames(replicate(length(names(siteGrp[,!colnames(siteGrp)%in%c("section")])),numeric(0), simplify = F), names(siteGrp[,!colnames(siteGrp)%in%c("section")])))
for(month in mList){
    fName <- paste("out/comImprDevFormatMetrics",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    siteGrp2[is.na(siteGrp2[,fSect]),fSect] <- "altri"
    fLab <- c("pc mh","pc rn uni","pc rn 2nd","pc rn 3rd","mob sn","mob rn uni","mob rn 2nd","mob rn 3rd")
    seqMonth[month,] <- 0
    for(f in formatL){
        siteGrp <- siteGrp2[,grepl(f,colnames(siteGrp2))]
        siteGrp$section <- siteGrp2[,fSect]
        colnames(siteGrp) <- gsub(f,"",colnames(siteGrp))
        corM <- data.frame(botMob = siteGrp$bot / siteGrp$Mobile.Measured.Impressions,
                           botPC = siteGrp$bot / siteGrp$PC.Measured.Impressions,
                           ##vtrApp = siteGrp$Mobile.App.Measured.Views / siteGrp$Mobile.App.Measured.Impressions,
                           vtrMob = siteGrp$Mobile.Measured.Views / siteGrp$Mobile.Measured.Impressions,
                           vtrPC =  siteGrp$PC.Measured.Views / siteGrp$PC.Measured.Impressions)
        comM <- as.matrix(corM)
        corM[is.na(corM)] <- 0
        corM[corM==Inf] <- 0
        corM[corM==NaN] <- 0
        seqBot <- rbind(seqBot,corM)
        seqSite <- rbind(seqSite,siteGrp)
        seqMonth[month,] <- seqMonth[month,] + colSums(siteGrp[,!colnames(siteGrp)%in%c("section")],na.rm=TRUE)
    }
}

seqSite$site <- unlist(lapply(strsplit(seqSite$section,split="\\|"),function(x) x[2]))
siteAgg <- ddply(seqSite[,!colnames(seqSite)%in%c("section")],.(site),colwise(sum,na.rm=TRUE))

melted <- melt(as.matrix(seqMonth[,grepl("Time",colnames(seqMonth))]))
melted[,"percentage"] <- (melted[,c("Var1","value")] %>% group_by(Var1) %>% mutate_each(funs(./sum(.))))[2]
melted[,"pos"] <- (melted[,c("Var1","percentage")] %>% group_by(Var1) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
melted[,"perc"] <- (melted[,c("Var1","percentage")] %>% group_by(Var1) %>% mutate_each(funs(paste(round(.*100),"%",sep=""))))[2]
melted$Var2 <- gsub("\\.","-",gsub("Direct.View.Time.","",melted$Var2))
gLabel = c("\nmonth","duration share",paste("duration",month),"percentage")
p <- ggplot(melted,aes(x=Var1,y=percentage,group=Var2,fill=Var2)) +
    geom_bar(stat="identity",alpha=.90) +
    geom_text(aes(label=perc,y=pos),size=3,colour='white') +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        panel.background = element_blank(),
        text = element_text(size = gFontSize)
    ) +
    scale_fill_manual(values=gCol) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3])
p
fName <- paste("fig/DurationShare_",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

melted <- melt(as.matrix(seqMonth[,grepl("Measure",colnames(seqMonth))]))
melted$Var3 <- grepl("Impr",melted$Var2)
melted$Var3 <- sapply(melted$Var3,function(x) if(x){"imps"}else{"view"})
melted$Var2 <- gsub(".Measured.Views","",melted$Var2)
melted$Var2 <- gsub(".Measured.Impressions","",melted$Var2)
melted$Var2 <- gsub("Mobile.","",melted$Var2)
melted[,"percentage"] <- (melted[,c("Var1","value")] %>% group_by(Var1) %>% mutate_each(funs(./sum(.))))[2]
melted[,"perc"] <- (melted[,c("Var2","value")] %>% group_by(Var2) %>% mutate_each(funs(paste(round(./1000000),"",sep=""))))[2]
melted[,"pos"] <- (melted[,c("Var1","Var2","value")] %>% group_by(Var1,Var2) %>% mutate_each(funs(cumsum(.)-.*0.5)))[3]

gLabel = c("\nmonth","volume",paste("volume by month"),"percentage")
p <- ggplot(melted,aes(x=Var3,y=value,group=1,fill=Var2)) +
    geom_bar(stat="identity",alpha=.90) +
##    geom_text(aes(label=perc,y=pos),size=3,colour='white') +
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



colSums(seqBot)

seqBot <- seqBot[!rowSums(seqBot) < 0.00001,]
nBin <- 10
sampleM <- data.frame(x=1:(floor(length(rownames(seqBot)))/nBin+1))
stepM <- seqBot
i <- 1
for(i in 1:length(colnames(seqBot))){
    stepM[,i] <- cut(seqBot[,i],nBin,include.lowest=TRUE, labels=c(1:nBin))
    lim = quantile(seqBot[,i],comprob)
    seqBot[,i][seqBot[,i] > lim ] <- 0
    sampleM[,i] <- as.vector(tapply( seqBot[,i], (seq_along(seqBot[,i])-1) %/% nBin, sum) )
}
names(sampleM) <- names(seqBot)
seqBot <- sweep(seqBot, 2, colSums(seqBot), FUN="/")

findInterval(seqBot[,i],seq(1:nBin))
summary(bins)
##scale(seqBot, center=FALSE, scale=colSums(seqBot))
seqBot <- as.matrix(seqBot)
sampleM <- as.matrix(sampleM)
cor2 <- t(seqBot) %*% (seqBot)
iCorr <- cov(seqBot)
iCorr <- cov(sampleM)
iCorr <- cor(seqBot)
iCorr <- cor(sampleM)
iCorr <- cor(stepM)


fName <- paste("fig/corr2","bot",".png",sep="")
png(fName,width=pngWidth,height=pngHeight)
corrplot.mixed(iCorr,lower="pie",upper="number")
dev.off()


melted <- melt(sampleM)
p <- ggplot(melted,aes(x=Var1,y=value,color=Var2,group=Var2)) + geom_line(size=1.5)
p

colnames(siteGrp2)
siteGrp$imps <- siteGrp2$imps
siteGrp$view <- siteGrp2$imps


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
sitePerf$domain <- gsub("\\.it","",sitePerf$domain)
sitePerf$domain <- gsub("\\.com","",sitePerf$domain)
sitePerf$domain <- gsub("[[:punct:]]"," ",sitePerf$domain)
sitePerf$domain <- gsub("[[:digit:]]","",sitePerf$domain)
sitePerf$domain <- gsub("^mediaset$","sport mediaset",sitePerf$domain)
sitePerf$domain <- gsub("salepepe","sale e pepe",sitePerf$domain)
sitePerf$domain <- gsub("mobile","",sitePerf$domain)
sitePerf$domain <- gsub("tgcom mediaset","tgcom",sitePerf$domain)
sitePerf$domain <- gsub("video mediaset","witty",sitePerf$domain)
sitePerf$domain <- gsub(" meteo","meteo",sitePerf$domain)

siteAgg$viewability <- siteAgg$views/siteAgg$impressions
siteAgg$site <- tryTolower(siteAgg$site)
siteAgg$site <- gsub("\\.it","",siteAgg$site)
siteAgg$site <- gsub("mediaseta","mediaset",siteAgg$site)
siteAgg$site <- gsub("mediasetf","mediaset",siteAgg$site)


siteComp <- merge(siteAgg,sitePerf,by.x="site",by.y="domain",all=TRUE)
siteComp <- siteComp[order(-siteComp$impressions),]
siteComp <- siteComp[1:20,c("site","impressions","viewability","bot","Imps","Bounce","Dur")]
siteComp$botTrf <- siteComp$bot / siteComp$impressions
siteComp$Bounce <- siteComp$Bounce / 100

melted <- melt(siteComp[,c("site","impressions")])
gLabel = c("\nsite","volume",paste("summary by site"),"volume")
bplot <- ggplot(melted,aes(x=site,y=value,fill=variable)) +
    geom_bar(stat="identity") +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        legend.justification=c(0,0),
        legend.position=c(.5,.73),
        legend.background = element_rect(fill=alpha('white',0.3)),
        legend.position ="right"
    ) +
    scale_fill_manual(values=gCol) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])

melted <- melt(siteComp[,c("site","botTrf","Bounce","viewability")])
gLabel = c("\nsite","percentage",paste("share by site"),"percentage")
lplot <- ggplot(melted,aes(x=site,y=value,color=variable,group=variable)) +
    geom_line(stat="identity",size=3) +
    geom_point(stat="identity",size=1.5) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(.5,.73),
        legend.background = element_rect(fill=alpha('white',0.3)),
        legend.position ="right"

    ) +
    scale_color_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])

svg("fig/Rating.svg",width=gWidth-2,height=gHeight)
grid.arrange(bplot,lplot, heights = c(3/4, 1/4))
gp1 <- ggplot_gtable(ggplot_build(bplot))
gp2 <- ggplot_gtable(ggplot_build(lplot))
pp <- c(subset(gp1$layout, name == "panel", se = t:r))
g <- gtable_add_grob(gp1, gp2$grobs[[which(gp2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)
ia <- which(gp2$layout$name == "axis-l")
ga <- gp2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(0.25, "cm")
g <- gtable_add_cols(g, gp2$widths[gp2$layout[ia, ]$l], length(g$widths) - 1)
g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)
grobScale1 <- textGrob("percentage",rot=90,gp=gpar(fontsize=gFontSize-2))
g <- gtable_add_grob(g,grobScale1,pp$t,length(g$widths),pp$b)
grid.newpage()
grid.draw(g)
dev.off()


fName <- paste("fig/impressionVolume_",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
