#!/usr/bin/env Rscript
graphDevice <- function(fs,imprGrp,durGrp,siteGrp){
                                        #-----------------------impression-grouping-----------------------
print("impression grouping")
colSel <- c("impressions")
metricType <- c("measured")
channelType <- k
view <- as.data.frame(month)
i <- colSel[1]
for(i in colSel){
    view$var <- sapply(month,function(x) sum(subset(fs,Month==x)[i],na.rm=TRUE))
    colnames(view)[colnames(view)=='var'] <- c(i)
    
}
bstack <- melt(view,id="month",value.name="volume", variable.name="var", na.rm=TRUE)
bstack$share <- rep(0,length(bstack$month))
bstack$pos <- rep(0,length(bstack$month))
bstack$perc <- rep(0,length(bstack$month))
bstack$posVol <- rep(0,length(bstack$month))
bstack$percVol <- rep(0,length(bstack$month))
#bstack$ord <- rep(c(3,2,1),9)
channel <- vector()
for(i in channelType){channel <- c(channel,rep(i,nMonth))}
bstack$channel <- channel
type <- vector()
for(i in metricType){type <- c(type,rep(i,length(metricType)*nMonth))}
bstack$metric <- type
j <- metricType[1]
i <- month[1]
for(i in month){
    for(j in metricType){
        set <- bstack$month==i&bstack$metric==j
        bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume)
        bstack[set,]$pos <- cumsum(bstack[set,]$share) - 0.5*bstack[set,]$share
        bstack[set,]$posVol <- cumsum(bstack[set,]$volume) - 0.5*bstack[set,]$volume
        bstack[set,]$perc <-  paste(round(bstack[set,]$share*100)," %",sep="")
        bstack[set,]$percVol <-  paste(round(bstack[set,]$volume/1000000,digits=2),"",sep="")
    }
}

#bstack$month <- factor(bstack$month, levels = bstack$month[order(bstack$ord)])
#bstack$month <- factor(bstack$month, levels = bstack$ord)

months <- levels(bstack$month)[c(3,2,1)]
topic_names <- list("1"="October","2"="November","3"="December","4"="Misc")
top_labeller <- function(variable,value){
    return(topic_names[value])
}


graphTit <- paste("Impressions/views share",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=month,y=volume,fill=channel,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=month,label=percVol,y=posVol,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                    scale_fill_manual(values=gCol)
fName <- paste("fig/impressionVolume_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
imprGrp$var <<- bstack$volume
colnames(imprGrp)[colnames(imprGrp)=='var'] <<- sectType

                                        #-----------------------duration-grouping-----------------------
print("duration grouping")
colSel <- c("Direct.View.Time.1.5s","Direct.View.Time.5.60s","Direct.View.Time....60s")
metricType <- c("delivered","impressions","views")
channelType <-  c("1-5","5-60",">60")
view <- as.data.frame(month)
i <- colSel[1]
for(i in colSel){
    print(i)
    view$var <- sapply(month,function(x) sum(subset(fs,Month==x)[i],na.rm=TRUE))
    colnames(view)[colnames(view)=='var'] <- c(i)
}
bstack <- melt(view,id="month",value.name="volume", variable.name="var", na.rm=TRUE)
bstack$share <- rep(0,length(bstack$month))
bstack$pos <- rep(0,length(bstack$month))
bstack$perc <- rep(0,length(bstack$month))
bstack$posVol <- rep(0,length(bstack$month))
bstack$percVol <- rep(0,length(bstack$month))
channel <- vector()
for(i in channelType){channel <- c(channel,rep(i,nMonth))}
bstack$channel <- channel
i <- month[1]
for(i in month){
    set <- bstack$month==i
    bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume)
    bstack[set,]$pos <- cumsum(bstack[set,]$share) - 0.5*bstack[set,]$share
    bstack[set,]$posVol <- cumsum(bstack[set,]$volume) - 0.5*bstack[set,]$volume
    bstack[set,]$perc <-  paste(round(bstack[set,]$share*100)," %",sep="")
    bstack[set,]$percVol <-  paste(round(bstack[set,]$volume/1000000,digits=2),"",sep="")
}

graphTit <- paste("Duration share",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=month,y=share,fill=channel,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=month,label=perc,y=pos,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                scale_fill_manual(values=gCol)
fName <- paste("fig/durationShare_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

graphTit <- paste("Duration volume",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=month,y=volume,fill=channel,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=month,label=percVol,y=posVol,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                    scale_fill_manual(values=gCol)
fName <- paste("fig/durationVolume_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
durGrp$var <<- bstack$volume
colnames(durGrp)[colnames(durGrp)=='var'] <<- sectType


#-----------------------site-grouping-----------------------
print("site grouping")

#subset(fs[,c("site","Placement")],site=="ame")

v_id <- seq(1:length(table(fs$site)))
mTab <- as.data.frame(v_id)
mTab$site <- names(table(fs$site))
mTab$volume <- as.vector(table(fs$site))

bstack <- head(mTab[with(mTab,order(-volume)),],n=20)
bstack$site <- factor(bstack$site,unique(bstack$site))
bstack$posVol <- bstack$volume*.5
bstack$percVol <- bstack$volume
graphTit <- paste("Impressions per site",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=site,y=volume,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=site,label=percVol,y=posVol,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                    scale_fill_manual(values=gCol1)
fName <- paste("fig/siteImpressionVolume1_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

bstack <- head(mTab[with(mTab,order(-volume)),],n=40) %>% tail(n=20)
bstack$site <- factor(bstack$site,unique(bstack$site))
bstack$posVol <- bstack$volume*.5
bstack$percVol <- bstack$volume
graphTit <- paste("Impressions per site",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=site,y=volume,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=site,label=percVol,y=posVol,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                    scale_fill_manual(values=gCol1)
fName <- paste("fig/siteImpressionVolume2_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

i <- month[1]
j <- sites[1]
view <- as.data.frame(sites)
for(i in month){
    view$var <- rep(0,length(sites))
    totI <- 0
    totV <- 0
    for(j in sites){
        set <- fs$Month==i&fs$site==j
        view[sites==j,]$var <- sum(fs[set,]$views,na.rm=TRUE)/sum(fs[set,]$impressions,na.rm=TRUE)
        totI <- sum(fs[set,]$impressions,na.rm=TRUE)
        totV <- sum(fs[set,]$views,na.rm=TRUE)
    }
    view[view$sites=="ALTRI",]$var <- abs(sum(fs[fs$Month==i,]$views,na.rm=TRUE)/sum(fs[fs$Month==i,]$impressions,na.rm=TRUE) - totV/totI)
    colnames(view)[colnames(view)=='var'] <- c(i)
}

bstack <- melt(view,id="sites",value.name="volume", variable.name="month", na.rm=TRUE)
bstack$share <- rep(0,length(bstack$month))
bstack$pos <- rep(0,length(bstack$month))
bstack$perc <- rep(0,length(bstack$month))
bstack$posVol <- rep(0,length(bstack$month))
bstack$percVol <- rep(0,length(bstack$month))

for(i in month){
    set <- bstack$month==i
    bstack[set,]$share <- bstack[set,]$volume/sum(bstack[set,]$volume)
    bstack[set,]$pos <- cumsum(bstack[set,]$share) - 0.5*bstack[set,]$share
    bstack[set,]$posVol <- cumsum(bstack[set,]$volume) - 0.5*bstack[set,]$volume
    bstack[set,]$perc <-  paste(round(bstack[set,]$share*100)," %",sep="")
    bstack[set,]$percVol <-  paste(round(bstack[set,]$volume*100)," %",sep="")
}


graphTit <- paste("Site share",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=month,y=share,fill=sites,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=month,label=perc,y=pos,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                scale_fill_manual(values=gCol1)
fName <- paste("fig/siteShare_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)

graphTit <- paste("Site volume",sep="");
p <- ggplot(bstack) +
    geom_bar(aes(x=month,y=volume,fill=sites,group=1),stat="identity",alpha=.90) +
        geom_text(aes(x=month,label=percVol,y=posVol,0),size=3,colour='white') + 
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                text = element_text(size = gFontSize)
                ) +
                    scale_fill_manual(values=gCol1)
fName <- paste("fig/siteVolume_",sectType,".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
siteGrp$var <<- bstack$volume
colnames(siteGrp)[colnames(siteGrp)=='var'] <<- sectType



}
