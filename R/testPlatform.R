#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
##U:\MARKETING\Inventory\Analisi VM\Inventory VM
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')

evDot <- read.csv("raw/testTimeDmp.csv")

reach <- c(20366720,1222400,1308800,5398720)/20366720
p1 <- c(5.5,1.3,1,2)/20.8
p2 <- c(0.22,0.33,0.12)/20.8
p3 <- 0.079/20.8
expected <- c(1,p1[2]/2 - p2[2]/6 - p2[3]/6 + p3[1]/12,p1[3]/2 - p2[3]/6 - p2[1]/6 + p3[1]/12,p1[1]/2 - p2[1]/6 - p2[2]/6 + p3[1]/12)
tFirst <- evDot[grepl("POSTA",evDot$FlightDescription),]

## a c d s t
reach <- c(16.48,0.51,0.50,2.34,4.78)/16.48
p1 <- c(0.51,0.50,2.34,4.78)/16.48
## cd cs ct ds dt st
p2 <- c(0.046,0.042,0.18,0.074,0.48,0.70)/16.48
p3 <- 0.013/16.48 ##cts 0.038
expected <- c(1,p1[1]/2 - p2[1]/6 - p2[2]/6 + p3[1]/12,p1[2]/2 - p2[1]/6 - p2[4]/6 + p3[1]/12,p1[3]/2 - p2[2]/6 - p2[4]/6 + p3[1]/12,p1[4]/2 - p2[3]/6 - p2[4]/6 + p3[1]/12)
tFirst <- evDot[grepl("178074",evDot$FlightDescription),]

tFirst$Data <- tFirst$Data
tFirst$FlightDescription <- gsub("300x250_POSTA_BELEN","",tFirst$FlightDescription)
tFirst$FlightDescription <- gsub("DMP TARGETING","",tFirst$FlightDescription)
tFirst$FlightDescription <- gsub("178074-DMP-","",tFirst$FlightDescription)
tFirst$FlightDescription <- gsub("-300x250_Mediaset LIVE_mobile pc","",tFirst$FlightDescription)
tFirst$FlightDescription <- gsub("[[:punct:]]","",tFirst$FlightDescription)
allActive <- (rownames(table(tFirst$Data)[table(tFirst$Data)>1]))
tToge = NULL
x <- allActive[1]
for(i in allActive){tToge <- rbind(tToge, tFirst[tFirst$Data==x,])}
aggrDot <- ddply(tToge,.(FlightDescription),summarise,imps=sum(Imps),click=sum(Click))
aggrDot$delivered <-  aggrDot$imps/aggrDot$imps[1]
aggrDot$reach <- reach
aggrDot$expected <- expected
aggrDot
melted <- melt(aggrDot[-1,c("FlightDescription","delivered","reach","expected")])
names(melted) <- c("name","variable","value")

ggplot(melted, aes(x=name,y=value,fill=variable)) + geom_bar(stat="identity",position="dodge") +
    theme(
        panel.border = element_blank(),
        legend.justification=c(0,0), legend.position=c(.2,.5),
        text = element_text(size = gFontSize),
        panel.background = element_blank()
    )

aggrDot$diff <- aggrDot$delivered/aggrDot$expected
aggrDot$ctr <- aggrDot$click/aggrDot$imps
aggrDot$ctr <- aggrDot$ctr/aggrDot$ctr[1]
melted <- melt(aggrDot[-1,c("FlightDescription","ctr")])
names(melted) <- c("name","variable","value")
gLabel = c("target","ctr target/ctr general",paste("ctr improvement",""),"target")
ggplot(melted, aes(x=name,y=value,fill=name)) + geom_bar(stat="identity",position="dodge") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
    theme(
        panel.border = element_blank(),
        legend.justification=c(0,0), legend.position=c(2.2,.5),
        text = element_text(size = gFontSize),
        panel.background = element_blank()
    )

pie <- ggplot(melted, aes(x = "",y=percentage,fill=FlightDescription,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4]) +
     geom_text(aes(y = percentage/2 + c(0, cumsum(percentage)[-length(percentage)]),
                label = percent(percentage)), size=5) +
    theme_bw() +
    theme(
        panel.border = element_blank(),
        text = element_text(size = gFontSize),
        panel.background = element_blank()
    ) +
    coord_polar("y",start=0)
pie



evBlue <- read.csv("raw/testTimeEvBluekai.csv",sep="\t")
head(evBlue)
aggrBlue <- ddply(evBlue,.(CAMPAIGN_NAME),summarise,imps=sum(STAMPS))
aggrBlue$share <- aggrBlue$imps/aggrBlue$imps[1]
aggrBlue <- aggrBlue[aggrBlue$CAMPAIGN_NAME %in% c("ALL","donne camp","brasato","triciclo racing"),]
aggrBlue <- aggrBlue[order(match(aggrBlue$CAMPAIGN_NAME,c("ALL","donne camp","brasato","triciclo racing"))),]


write.csv(cbind(aggrDot,aggrBlue,reach),"out/testAutoComp.csv")


comp <- data.frame(name=reach$name)
comp$dot <- aggrDot$share
comp$blue <- aggrBlue$share
comp$reach <- reach$share

melted <- melt(comp)

##unique browser / internet population * mediamond share
28.7/(37.7*.58)



4.59/17
108/271
1.600
