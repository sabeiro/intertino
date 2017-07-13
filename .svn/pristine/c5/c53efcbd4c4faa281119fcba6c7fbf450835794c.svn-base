#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

mList <- c("October","November","December","January","February")
mList <- c("February")
fSect <- "Section"
month <- mList[1]
NSect <- 20

for(month in mList){
    fName <- paste("out/dotImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    siteGrp2 <- siteGrp2[!grepl("HOME PAGE",siteGrp2[,fSect]),]
    siteGrp2 <- siteGrp2[!grepl("ALL_AREA",siteGrp2[,fSect]),]
    siteGrp2 <- siteGrp2[!grepl("ALL AREA",siteGrp2[,fSect]),]
    fLab <- c("pc mh","pc rn uni","pc rn 2nd","pc rn 3rd","mob sn","mob rn uni","mob rn 2nd","mob rn 3rd")
    vGrp <- as.matrix(siteGrp2[,grepl("view",colnames(siteGrp2))])
    rownames(vGrp) <- siteGrp2[,fSect]
    iGrp <- as.matrix(siteGrp2[,grepl("imps",colnames(siteGrp2))])
    rownames(iGrp) <- siteGrp2[,fSect]
    cGrp <- vGrp / iGrp
    colnames(cGrp) <- gsub("view","ctr",colnames(cGrp))
    tot <- colSums(vGrp)/colSums(iGrp)
    rest <- (colSums(vGrp) - colSums(vGrp[1:NSect,]))/(colSums(iGrp) - colSums(iGrp[1:NSect,]))
    cGrp <- cGrp[order(-rowSums(iGrp)),]

    cGrp <- cGrp[1:NSect,]
    rName <- rownames(cGrp)
    cGrp <- rbind(cGrp,c(rest))
    cGrp <- rbind(cGrp,c(tot))
    cGrp[is.nan(cGrp)] <- 0
    rownames(cGrp) <- c(rName,"rest","total")
    melted <- melt(cGrp)
    melted$Var1 <- as.ordered(melted$Var1)
    melted$Var1 <- factor(melted$Var1,levels=melted$Var1 )
    melted$value <- sapply(melted$value,function(x) ifelse(x<=0.000001,NA,x))
    melted <- na.omit(melted)
    gLabel = c("\n\nsite","format",paste("ctr",month),"percentage")
    p <- ggplot(melted,aes(x=Var1,y=Var2,group=Var2)) +
        geom_tile(aes(fill=value),colour="white") +
        geom_text(aes(fill=value,label=formatC(value*100,digit=1,format="f")),colour="white",size=4) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
        scale_fill_gradient(low="white",high="steelblue") +
        ##scale_y_discrete(labels=fLab) +
        theme(
            axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
            panel.background = element_blank()
        )
    p
    fName <- paste("fig/viewabilityFormat_",fSect,month,".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    gLabel = c("format","percentage",paste("viewability vs format",month),"percentage")
    p <- ggplot(melted,aes(x=Var1,y=value)) +
        geom_boxplot(aes(fill=Var1)) + #+ geom_jitter()
        ##geom_line(data=meltLine,aes(x=x,y=y,group=1,color="overall"),size=2) +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
        ##scale_x_discrete(labels=fLab) +
        ##scale_fill_manual(values=gCol1,labels=fLab) +
        theme(
            axis.text.x = element_text(angle = 30, hjust = 1),
            panel.background = element_blank(),
            axis.title.x=element_text(margin=margin(20,0,0,0)),
            text = element_text(size = gFontSize)
        )
    p
    fName <- paste("fig/viewabilityFormat_",fSect,month,".png",sep="")
    ggsave(file=fName, plot=p, width=gWidth, height=gHeight)



}

