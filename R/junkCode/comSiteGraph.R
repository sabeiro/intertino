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


mList <- c("October","November","December","January","February","March","April","May")
fSect <- "site"
isChiara <- FALSE
month <- mList[8]
NSect <- 20
fLab <- c("total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")

## t <- data.frame(d=siteGrp2$site,c=siteGrp2$imps)
## t[order(-t$c),]

##-------------maiolica-viewability----------------------
e <- editorL[1]
for(month in mList){
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    viewTot <-  sum(siteGrp2[,grepl("view",colnames(siteGrp2))],na.rm=TRUE)/sum(siteGrp2[,grepl("imps",colnames(siteGrp2))],na.rm=TRUE)
    set <- TRUE
    siteGrp3 <- siteGrp2[set,]
    siteGrp3 <- siteGrp3[order(-siteGrp3$imps),]
    tot <-  colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)
    siteGrp3 <- siteGrp3[1:NSect,]
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
    melted <- melt(cGrp)
    melted$Var1 <- as.ordered(melted$Var1)
    melted$Var1 <- factor(melted$Var1,levels=melted$Var1 )
    melted$Var2 <- gsub("ctrs","",melted$Var2)
    melted$Var2 <- gsub("ctr\\.","",melted$Var2)
    melted$Var2 <- as.ordered(melted$Var2)
    melted$Var2 <- factor(melted$Var2,levels=melted$Var2)
    melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
    melted <- na.omit(melted)

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

    ##(gg <- ggplotly(p))
    ## m <- matrix(bstack$percentage, ncol = length(siteGrp$section),nrow=length(colnames(siteGrp[,-1])))
    ## plot_ly(z=m,x=siteGrp$section,y=colnames(siteGrp[,-1]),type="heatmap",colorscale="steelblue")
    fName <- paste("fig/viewability_",e,"_",fSect,month,".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
}




##volume pc app mobile
##flurry sdk (yahoo) 1/3 device in the world (demo) user flow in app
##phone id
##2d agreement

lim = quantile(siteGrp2$imps,0.70)
siteTmp <- siteGrp2[siteGrp2$imps>lim,]
melted <- data.frame(site=siteTmp[,fSect],viewability=siteTmp$views/siteTmp$imps)
melted <- melted[order(-melted$viewability),]
melted$site <-  factor(melted$site , levels=melted$site )
set <- sample(1:nrow(melted),size=30)
melted <- melted[set,]
gLabel = c("\nsite","viewability",paste("viewability"),"percentuale\ntracciata")
p <- ggplot(melted,aes(x=site,y=viewability)) +
    geom_bar(stat="identity",position="stack",fill=gCol[2]) +
    geom_text(aes(y=viewability*.5,fill=viewability,color=viewability,label=paste(formatC(viewability*100,digit=0,format="f"),"%",sep="")),size=8) +
    theme(
        axis.text.x = element_text(angle = 30, hjust = 1),
        text = element_text(size = gFontSize),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank(),
        legend.justification=c(0,0),
        legend.position=c(1.75,.73),
        ##        legend = element_blank(),
        legend.background = element_rect(fill=alpha('white',0.3),color="white"),
        legend.position ="right"
    ) +
    ##    scale_fill_manual(values=gCol,labels=fLab) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p
fName <- paste("fig/viewabilitySite_","Score",".png",sep="")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)



siteGrp
m <- matrix(rnorm(9), nrow = 3, ncol = 3)
str(siteGrp)
mSite <- as.matrix(siteGrp[,-1])




viewability <- as.matrix(siteGrp[,-1])
rownames(viewability) <- siteGrp$section
section <- siteGrp$section
format <- colnames(siteGrp[,-1])
vals <- unique(scales::rescale(c(viewability)))
vals <- vals[-1]
o <- order(vals, decreasing = FALSE)
cols <- scales::col_numeric("Blues", domain = NULL)(vals)
colz <- setNames(data.frame(vals[o], cols[o]), NULL)
##plot_ly(z = volcano, colorscale = colz, type = "heatmap")
plot_ly(x=format,y=section,z=viewability,colorscale=colz, type = "heatmap")


