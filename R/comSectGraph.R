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
fSect <- "section"
isChiara <- FALSE
editorL <- c("rti","ame","TGCOM","METEO","SPORT MEDIASET","DONNAMODERNA","GRAZIA","COMINGSOON.NET","NOSTROFIGLIO","PANORAMA","SALE E PEPE","MARIA DE FILIPPI","IL GIORNALE","WITTY")
month <- mList[8]
NSect1 <- 20
fLab <- c("total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")



## t <- data.frame(d=siteGrp2$site,c=siteGrp2$imps)
## t[order(-t$c),]

##-------------maiolica-viewability----------------------
for(month in mList){
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    viewTot <-  sum(siteGrp2[,grepl("view",colnames(siteGrp2))],na.rm=TRUE)/sum(siteGrp2[,grepl("imps",colnames(siteGrp2))],na.rm=TRUE)
    e <- editorL[10]
    for(e in editorL){
        print(e)
        set <- TRUE
        set <- set & grepl(e,siteGrp2[,fSect])
        siteGrp3 <- siteGrp2[set,]
        siteGrp3 <- siteGrp3[order(-siteGrp3$imps),]
        tot <-  colSums(siteGrp3[,!(names(siteGrp3) %in% fSect)],na.rm=TRUE)
        NSect <- (min(NSect1,nrow(siteGrp3)))
        siteGrp3 <- siteGrp3[1:NSect,]
        channelL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',1)
        siteL <- lapply(strsplit(siteGrp3$section,split="\\|"),'[[',2)
        siteL <- gsub("MEDIASET","",siteL)
        siteGrp3[,fSect] <- paste(channelL,siteL,sep="_")
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
        melted$Var2 <- gsub("ctrs","total",melted$Var2)
        melted$Var2 <- gsub("ctr\\.","",melted$Var2)
        melted$Var2 <- as.ordered(melted$Var2)
        melted$Var2 <- factor(melted$Var2,levels=melted$Var2)
        ## melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
        ## melted <- na.omit(melted)

        ## if(fSect=="section"){siteGrp <- siteGrp[c(order(siteL),NSect+1,NSect+2),]}
        ## mSiteGrp <- as.matrix(siteGrp[,-1])
        ## rownames(mSiteGrp) <- siteGrp$section
        ## mSiteGrp[is.na(mSiteGrp)] <- 0
        ## siteGrp$section <- as.ordered(siteGrp$section)
        ## siteGrp$section <- as.factor(siteGrp$section)
        ##d3heatmap(mSiteGrp, scale = "column",color="Blues")

        gLabel = c("creatività","format",paste("viewability",month),"percentuale")
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
        ##p
        (gg <- ggplotly(p))
        ## p <- plotly_build(g)
        ## str(p)
        ## m <- matrix(bstack$percentage, ncol = length(siteGrp$section),nrow=length(colnames(siteGrp[,-1])))
        ## plot_ly(z=m,x=siteGrp$section,y=colnames(siteGrp[,-1]),type="heatmap",colorscale="steelblue")
        fName <- paste("fig/viewability_",fSect,month,"_",e,".png",sep="")
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    }
}

##-----------------------boxplot-formato--------------------------
for(month in mList){
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    ##fName <- paste("out/dotImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    viewTot <-  sum(siteGrp2[,grepl("view",colnames(siteGrp2))],na.rm=TRUE)/sum(siteGrp2[,grepl("imps",colnames(siteGrp2))],na.rm=TRUE)

    siteGrp <- data.frame(section = siteGrp2[,fSect])
    siteGrp$pc_sn <- as.numeric(siteGrp2$view.pc.sn)/as.numeric(siteGrp2$imps.pc.sn)
    siteGrp$pc_rn_u<- as.numeric(siteGrp2$view.pc.rn_u)/as.numeric(siteGrp2$imps.pc.rn_u)
    siteGrp$pc_rn_2<- as.numeric(siteGrp2$view.pc.rn_2)/as.numeric(siteGrp2$imps.pc.rn_2)
    siteGrp$pc_rn_3<- as.numeric(siteGrp2$view.pc.rn_3)/as.numeric(siteGrp2$imps.pc.rn_3)
    siteGrp$mob_sn <- as.numeric(siteGrp2$view.mob.sn)/as.numeric(siteGrp2$imps.mob.sn)
    siteGrp$mob_rn_u<- as.numeric(siteGrp2$view.mob.rn_u)/as.numeric(siteGrp2$imps.mob.rn_u)
    siteGrp$mob_rn_2<- as.numeric(siteGrp2$view.mob.rn_2)/as.numeric(siteGrp2$imps.mob.rn_2)
    siteGrp$mob_rn_3<- as.numeric(siteGrp2$view.mob.rn_3)/as.numeric(siteGrp2$imps.mob.rn_3)

    siteGrp$section <- as.ordered(siteGrp$section)
    siteGrp$section <- as.factor(siteGrp$section)
    melted <- melt(siteGrp,id="section",value.name="viewability",variable.name="format",na.rm=TRUE)
    melted$section <- as.ordered(melted$section)
    melted$section <- factor(melted$section , levels=colnames(siteGrp)[-1] )

    melted$viewability <- sapply(melted$viewability,function(x) ifelse(x<=0.000001,NA,x))
    ## melted <- na.omit(melted)
    ## meltLine <- melt(singleSect)
    meltLine <- data.frame(y =  c(.45,.463,.463,.463,.45,.463,.463,.463))
    meltLine$x <- colnames(siteGrp)[-1]
    meltLine$riferimento <- "benchmark"
    meltLine <- rbind(meltLine,data.frame(x=colnames(siteGrp)[-1],y=viewTot,riferimento="overall") )
    ## singleSect <- as.data.frame(viewability[2:length(viewability)])

    gLabel = c("formato","percentuale",paste("viewability vs formato",month),"formato")
    p <- ggplot(melted,aes(x=format,y=viewability)) +
        geom_boxplot(aes(fill=format)) + #+ geom_jitter()
        geom_line(data=meltLine,aes(x=x,y=y,group=riferimento,color=riferimento),size=2) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
        scale_x_discrete(labels=fLab) +
        theme(
            axis.text.x = element_text(angle = 30, hjust = 1),
            panel.background = element_blank(),
            ##axis.title.x=element_text(margin=margin(20,0,0,0)),
            text = element_text(size = gFontSize)
        ) +
        scale_fill_manual(values=gCol1,labels=fLab)
    p
    fName <- paste("fig/viewabilityFormat_",fSect,month,".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
}




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


