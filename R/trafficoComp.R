#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
library('corrplot') #package corrplot
require(stats)
require(dplyr)
library(grid)

sitePerf1 <- read.csv('out/trafficAv.csv',stringsAsFactors=FALSE)
sitePerf <- read.csv('out/trafficAvTree.csv',stringsAsFactors=FALSE)
siteAgg <- read.csv('out/trafficAvComscore.csv',stringsAsFactors=FALSE)

sitePerf1$name <- gsub("[[:punct:]]","",sitePerf1$name)
siteAgg$site <-  gsub(" ","",siteAgg$site)
siteAgg$site <-  gsub("\\.com","",siteAgg$site)
siteAgg$site <-  gsub("\\.net","",siteAgg$site)
sitePerf$domain <-  gsub(" ","",sitePerf$domain)


siteComp <- merge(siteAgg,sitePerf,by.x="site",by.y="domain",all=TRUE)
siteComp <- merge(siteComp,sitePerf1,by.x="site",by.y="name",all=TRUE)
siteComp <- siteComp[-c(1,2),]
siteComp <- siteComp[order(-siteComp$impressions.x),]
siteComp <- siteComp[!is.na(siteComp$bounce),]
siteComp <- siteComp[!is.na(siteComp$impressions.x),]

## rName <- siteComp$site
## siteComp <- as.data.frame(siteComp[,-1])
## rownames(siteComp) <- rName
## is.na(siteComp) <- 0

siteComp$botTrf <- siteComp$bot / siteComp$impressions.x
siteComp$botTrf[is.nan(siteComp$botTrf)] <- 0
siteComp$botTrf <- siteComp$botTrf / max(siteComp$botTfr,nan.rm=TRUE)
siteComp$bounce <- siteComp$bounce / 100
siteComp$durAv <- siteComp$durAv / max(siteComp$durAv,na.rm=TRUE)
siteComp <- siteComp[-c(length(siteComp$site)),]
siteComp$trackShare <- siteComp$impressions.y/siteComp$impressions.x

melted <- melt(siteComp[,c("site","impressions.x")])
melted$site <- factor(melted$site , levels= melted$site )
melted$value <- melted$value/1000000
fLab <- c("comscore","webtrekk")
gLabel = c("\nsite","volume Mio",paste("impressioni per sito"),"volume")
bplot <- ggplot(melted,aes(x=site,y=value,fill=variable)) +
    geom_bar(stat="identity",position="dodge") +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(.75,.73),
        legend.background = element_rect(fill=alpha('white',0.3)),
        legend.position ="right"
    ) +
    scale_fill_manual(values=gCol,labels=fLab) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
bplot
fName <- paste("fig/viewabilityImps","","",".png",sep="")
ggsave(file=fName, plot=bplot, width=gWidth, height=gHeight)

melted <- melt(siteComp[,c("site","trackShare")])
melted$site <- factor(melted$site , levels= melted$site )
fLab <- c("comscore","webtrekk")
gLabel = c("\nsito","percentuale",paste("percentuale impressioni tracciate"),"tasso tracciato")
lplot <- ggplot(melted,aes(x=site,y=value,fill=variable)) +
    geom_point(stat="identity",size=2,color=gCol[2]) +
    coord_cartesian(ylim=c(0.0,1.0)) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(2.55,.73),
        legend.background = element_rect(fill=alpha('white',0.3)),
        legend.position ="right"
    ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
lplot
fName <- paste("fig/viewabilityImps","","",".png",sep="")
ggsave(file=fName, plot=lplot, width=gWidth, height=gHeight)



png("fig/viewTraffic.png",width=pngWidth,height=pngHeight)
grid.newpage()
gtable1 <- ggplot_gtable(ggplot_build(bplot))
gtable2 <- ggplot_gtable(ggplot_build(lplot))
par <- c(subset(gtable1[['layout']], name=='panel', select=t:r))
graf <- gtable_add_grob(gtable1, gtable2[['grobs']][[which(gtable2[['layout']][['name']]=='panel')]],par['t'],par['l'],par['b'],par['r'])
ia <- which(gtable2[['layout']][['name']]=='axis-l')
ga <- gtable2[['grobs']][[ia]]
ax <- ga[['children']][[2]]
ax[['widths']] <- rev(ax[['widths']])
ax[['grobs']] <- rev(ax[['grobs']])
ax[['grobs']][[1]][['x']] <- ax[['grobs']][[1]][['x']] - unit(1,'npc') + unit(0.05,'cm')
graf <- gtable_add_cols(graf, gtable2[['widths']][gtable2[['layout']][ia, ][['l']]], length(graf[['widths']])-1)
graf <- gtable_add_grob(graf, ax, par['t'], length(graf[['widths']])-1, par['b'])
graf <- gtable_add_grob(graf, gtable2$grobs[[7]], par$t, length(g$widths)-1, par$b)
graf <- gtable_add_grob(graf, gtable2$grobs[[8]], par$t, length(g$widths)-4, par$b)
grid.draw(graf)
dev.off()









melted <- melt(siteComp[,c("site","botTrf","bounce","viewability","visitAv","ctr","durAv")])
melted$site <- factor(melted$site , levels= melted$site )
gLabel = c("\nsite","percentage",paste("share by site"),"metric")
fLab <- c("bot share","bounce rate","viewability","page per visit","ctr","duration av")
lplot <- ggplot(melted,aes(x=site,y=value,group=variable,fill=variable)) +
    geom_bar(stat="identity",position="dodge") +
    ## geom_line(stat="identity",size=3) +
    ## geom_point(stat="identity",size=1.5) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(.85,.73),
        legend.background = element_rect(fill=alpha('white',0.3)),
        ##legend.background = theme_rect(col = 0),
        legend.position ="right"

    ) +
    scale_fill_manual(values=gCol1,labels=fLab) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
lplot
fName <- paste("fig/viewabilityMetrics","","",".png",sep="")
ggsave(file=fName, plot=lplot, width=gWidth, height=gHeight)


## svg("fig/Rating.svg",width=gWidth-2,height=gHeight)
## grid.arrange(bplot,lplot, heights = c(3/4, 1/4))
## gp1 <- ggplot_gtable(ggplot_build(bplot))
## gp2 <- ggplot_gtable(ggplot_build(lplot))
## pp <- c(subset(gp1$layout, name == "panel", se = t:r))
## g <- gtable_add_grob(gp1, gp2$grobs[[which(gp2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)
## ia <- which(gp2$layout$name == "axis-l")
## ga <- gp2$grobs[[ia]]
## ax <- ga$children[[2]]
## ax$widths <- rev(ax$widths)
## ax$grobs <- rev(ax$grobs)
## ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(0.25, "cm")
## g <- gtable_add_cols(g, gp2$widths[gp2$layout[ia, ]$l], length(g$widths) - 1)
## g <- gtable_add_grob(g, ax, pp$t, length(g$widths) - 1, pp$b)
## grobScale1 <- textGrob("percentage",rot=90,gp=gpar(fontsize=gFontSize-2))
## g <- gtable_add_grob(g,grobScale1,pp$t,length(g$widths),pp$b)
## grid.newpage()
## grid.draw(g)
## dev.off()


## seqBot <- seqBot[!rowSums(seqBot) < 0.00001,]
## nBin <- 10
## sampleM <- data.frame(x=1:(floor(length(rownames(seqBot)))/nBin+1))
## stepM <- seqBot
## i <- 1
## for(i in 1:length(colnames(seqBot))){
##     stepM[,i] <- cut(seqBot[,i],nBin,include.lowest=TRUE, labels=c(1:nBin))
##     lim = quantile(seqBot[,i],comprob)
##     seqBot[,i][seqBot[,i] > lim ] <- 0
##     sampleM[,i] <- as.vector(tapply( seqBot[,i], (seq_along(seqBot[,i])-1) %/% nBin, sum) )
## }
## names(sampleM) <- names(seqBot)
## seqBot <- sweep(seqBot, 2, colSums(seqBot), FUN="/")
## findInterval(seqBot[,i],seq(1:nBin))
## summary(bins)

siteCor <- as.matrix(siteComp[,c("botTrf","bounce","viewability","visitAv","ctr","durAv")])
siteCor <- as.matrix(siteComp[,c("viewability","visitAv","ctr","durAv")])
row.names(siteCor) <- siteComp$site
siteCor <- siteCor[-24,]
siteCor[is.na(siteCor)] <- 0
                                        #siteCor <- sweep(siteCor, 2, colSums(siteCor), FUN="/")
iCorr <- cor(siteCor)



fName <- paste("fig/corr2","bot",".png",sep="")
png(fName,width=pngWidth,height=pngHeight)
corrplot.mixed(iCorr,lower="pie",upper="number")
dev.off()


melted <- melt(siteCor)
p <- ggplot(melted,aes(x=Var1,y=value,fill=Var2,group=Var2)) +
    geom_line(aes(color=Var2),size=2)
##    geom_bar(stat="identity",position="dodge")
p



