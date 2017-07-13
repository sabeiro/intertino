#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

mList <- c("October","November","December","January")
fSect <- "adv"
month <- mList[4]
NSect <- 20

for(month in mList){
    fName <- paste("out/comImprDevFormat",fSect,month,".csv",sep="")
    print(fName)
    siteGrp2 <- read.table(fName,header=TRUE,fill=TRUE,sep="\t")
    siteGrp2[,fSect] <- as.character(siteGrp2[,fSect])
    fLab <- c("pc mh","pc rn uni","pc rn 2nd","pc rn 3rd","mob sn","mob rn uni","mob rn 2nd","mob rn 3rd")

    if(fSect == "section"){
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
        melted <- melt(siteGrp,id="section",value.name="viewability", variable.name="format", na.rm=TRUE)
        melted$section <- as.ordered(melted$section)
        melted$section <- factor(melted$section , levels=colnames(siteGrp)[-1] )

        melted$viewability <- sapply(melted$viewability,function(x) ifelse(x<=0.000001,NA,x))
        ## melted <- na.omit(melted)
        ## meltLine <- melt(singleSect)
        meltLine <- data.frame(y =  c(.45,.463,.463,.463,.45,.463,.463,.463))
        meltLine$x <- colnames(siteGrp)[-1]
        ## singleSect <- as.data.frame(viewability[2:length(viewability)])

        gLabel = c("format","percentage",paste("viewability vs format",month),"percentage")
        p <- ggplot(melted,aes(x=format,y=viewability)) +
            geom_boxplot(aes(fill=format)) + #+ geom_jitter()
            geom_line(data=meltLine,aes(x=x,y=y,group=1,color="overall"),size=2) +
            labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
            scale_x_discrete(labels=fLab) +
            theme(
                axis.text.x = element_text(angle = 30, hjust = 1),
                panel.background = element_blank(),
                axis.title.x=element_text(margin=margin(20,0,0,0)),
                text = element_text(size = gFontSize)
            ) +
            scale_fill_manual(values=gCol1,labels=fLab)
        p
        fName <- paste("fig/viewabilityFormat_",fSect,month,".png",sep="")
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    }

    i <- 1
    nEditor <- 1
    if(fSect=="section"){nEditor <- 2}
    for(i in 1:nEditor){
        print(i)
        if(i == 1){siteGrp3 <- siteGrp2[!grepl("ame",siteGrp2[,fSect]),]
        }else{siteGrp3 <- siteGrp2[grepl("ame",siteGrp2[,fSect]),]}
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
        siteGrp3[NSect+1,] <- c("rest",tot - rest)
        siteGrp3[NSect+2,] <- c("total",tot)



        siteGrp <- data.frame(section = siteGrp3[,fSect])
        siteGrp$pc_sn <- as.numeric(siteGrp3$view.pc.sn)/as.numeric(siteGrp3$imps.pc.sn)
        siteGrp$pc_rn_u<- as.numeric(siteGrp3$view.pc.rn_u)/as.numeric(siteGrp3$imps.pc.rn_u)
        siteGrp$pc_rn_2<- as.numeric(siteGrp3$view.pc.rn_2)/as.numeric(siteGrp3$imps.pc.rn_2)
        siteGrp$pc_rn_3<- as.numeric(siteGrp3$view.pc.rn_3)/as.numeric(siteGrp3$imps.pc.rn_3)
        siteGrp$mob_sn <- as.numeric(siteGrp3$view.mob.sn)/as.numeric(siteGrp3$imps.mob.sn)
        siteGrp$mob_rn_u<- as.numeric(siteGrp3$view.mob.rn_u)/as.numeric(siteGrp3$imps.mob.rn_u)
        siteGrp$mob_rn_2<- as.numeric(siteGrp3$view.mob.rn_2)/as.numeric(siteGrp3$imps.mob.rn_2)
        siteGrp$mob_rn_3<- as.numeric(siteGrp3$view.mob.rn_3)/as.numeric(siteGrp3$imps.mob.rn_3)
        siteGrp$section <- as.ordered(siteGrp$section)
        siteGrp$section <- as.factor(siteGrp$section)

        bstack <- melt(siteGrp,id="section",value.name="percentage", variable.name="var", na.rm=TRUE)
        bstack$percentage <- sapply(bstack$percentage,function(x) ifelse(x<=0.000001,NA,x))
        bstack <- na.omit(bstack)
        bstack$section <- as.ordered(bstack$section)
        bstack$section <- factor(bstack$section , levels=unique(as.character(bstack$section )) )
        bstack$section <- factor(bstack$section , levels=siteGrp3[,fSect] )
        gLabel = c("\n\nsite","format",paste("viewability",month),"percentage")
        p <- ggplot(bstack,aes(x=section,y=var,group=var)) +
            geom_tile(aes(fill=percentage),colour="white") +
            geom_text(aes(fill=percentage,label=round(percentage*100)),colour="white",size=4) +
            labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
            scale_fill_gradient(low="white",high="steelblue") +
            scale_y_discrete(labels=fLab) +
            theme(
                axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
                panel.background = element_blank()
            )
        p
        fName <- paste("fig/viewabilitySite_",fSect,month,".png",sep="")
        if(i==2){
            fName <- paste("fig/viewabilitySiteAme_",fSect,month,".png",sep="")
        }
        ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
    }
}



##volume pc app mobile
##flurry sdk (yahoo) 1/3 device in the world (demo) user flow in app
##phone id
##2d agreement
