#!/usr/bin/env Rscript
setwd('~/lav/media')
source('src/R/graphEnv.R')
library(dplyr)
library(grid)
library('rjson')
library('RJSONIO')
library("tm")



## source('src/R/audienceUsageLoad2016.R')
## source('src/R/audienceUsageLoad2017.R')
fs <- read.csv('log/bkOrder2016.csv',stringsAsFactor=F)
fs <- rbind(fs,read.csv('log/bkOrder2017.csv',stringsAsFactor=F))
advL <- unique(fs$camp)
fs1 <- read.csv("raw/bkBrroll.csv",stringsAsFactor=F)
fs1$Day <- as.Date(fs1$Day,format="%m/%d/%y")
fs1 <- fs1[,c("Day","Campaign.Name","Targeted.Audience.Name","Impressions")]
colnames(fs1) <- c("date","camp","aud","imps")
fs1 = fs1[grepl("Mediamond",fs1$aud) | grepl("Banzai",fs1$aud),]
#fs1$aud <- fs1$aud %>% gsub("IT_Mediamond_","",.) %>% gsub("IT_Banzai_","",.)
fs1$source <- fs1$aud
fs1$source[grepl("Banzai",fs1$source)] = "banzai s/d"
#fs1$source <- fs1$aud %>% gsub("IT_Mediamond_","",.) %>% gsub("IT_Banzai_","",.)
fs1$source[grepl("1st",fs1$source)] = "first s/d"
fs1$source[grepl("1st",fs1$source)] = "first"
fs1$source[grepl("Za",fs1$source)] = "zalando s/d"
fs1$source[grepl("Vo",fs1$source)] = "vodafone"
fs1$source[grepl("Interest",fs1$source)] = "first"
unique(fs1$source)

#fs1$source <- unlist(lapply(strsplit(fs1$source,split="_"),'[[',1))
fs1$format <- "dsp"
fs1$Size <- "dsp"
fs1$OrderExtId <- 234235
fs2 <- read.csv('raw/bkDfp.csv',stringsAsFactor=F)
fs2$ID = fs2$Key.values %>% gsub("ksg=","",.)
fs2M <- read.csv('raw/bkDfpMap.csv',stringsAsFactor=F)
fs2$aud = "rest"
for(i in 1:nrow(fs2M)){
    fs2[fs2$ID == fs2M[i,"ID"],"aud"] = fs2M[i,"Name"]
}
fs2 = fs2[grepl("BK",fs2$aud),]
fs2$aud = fs2$aud %>% gsub("Banzai - BK ","",.)
fs2$source = "rest"
fs2[grepl(" v",fs2$aud),"source"] = "vodafone"
fs2[grepl(" z",fs2$aud),"source"] = "zalando s/d"
fs2$imps = as.numeric(fs2$Total.targeted.impressions)

fs$date = as.Date(fs$date)
fs <- rbind(fs[,-1],fs1)
fs = fs[order(fs$date),]
fs$week <- format(fs$date,format="%y-%m")


##----------------------------campaign-------------------------------
## library('snow')
## clus <- makeCluster(4)
## clusterEvalQ(clus, {library(dplyr); library(magrittr)})
## clusterExport(clus, "mergePar")
## mergePar <- function(df1,df2,byx,byy){
##     merge(df1,df2,by.x=byx,by.y=byy,all.x=T)
## }
##myfunction <- function(otherDataFrame, fst, snd) {dplyr::filter(otherDataFrame, COLUMN1_odf==fst & COLUMN2_odf==snd)}
##do.call(bind_rows,parApply(clus,myDataFrame,1,function(r, fst, snd) { myfunction(r[fst],r[snd]), "[fst]", "[snd]") }

es <- read.csv("raw/storicoERP2016.csv",stringsAsFactor=F)
es <- rbind(es,read.csv("raw/storicoERP2017.csv",stringsAsFactor=F))
es$date <- as.Date(es$Data.Prenotazione,format="%Y-%m-%d")
es$month <- format(es$date,"%y-%m")
set <- grepl("DATA PLANNING",es$Pacchetto)
formL <- c("FloorAd","Half Page","INTERSTITIAL","Intro","Ipad Display","iPhone","Leaderboard","Masthead","Mobile Display","Minisito","Overlayer","Pre-Roll Video","PromoBox","Rectangle","Rectangle Exp-Video","Skin","Splash Page","SPLASH PAGE","Strip")
formL <- c("Masthead","Pre-Roll Video","Rectangle","Skin")

es <- es[es$Formato %in% formL,]
if(FALSE){
    set <- grepl("DATA PLANNING",es$Pacchetto)
    ddply(es[set,],.(month),summarise,imps=sum(Quantità.Ordine),price=sum(Valore.Netto))
    efs <- merge(fs,es[set,],by.x="OrderExtId",by.y="Numero.Contratto",all=T)
    sum(is.na(match(unique(fs$OrderExtId),unique(es$Numero.Contratto))))
    sum(is.na(match(unique(es[set,"Numero.Contratto"]),unique(fs$OrderExtId))))
}
##as.Date(es$Data.Caricamento.Contratto,format="%d/%m/%Y")
##es <- es[es$date > as.Date("2016-01-01"),]
es <- es[order(es$date),]
es$Quantità.Ordine <- es$Quantità.Ordine
esOrder <- ddply(es,.(Numero.Contratto),summarise,price=sum(Valore.Netto),quant=sum(Quantità.Ordine),client=head(Cliente,1))
esClient <- ddply(es,.(Cliente),summarise,price=sum(Valore.Netto),quant=sum(Quantità.Ordine))
es$week <- format(es$date,format="%y-%m")
esWeek <- ddply(es,.(week),summarise,price=sum(Valore.Netto),quant=sum(Quantità.Ordine))
esWeekData <- ddply(es[grepl("DATA PLANNING",es$Pacchetto),],.(week),summarise,price=sum(Valore.Netto),quant=sum(Quantità.Ordine))
esWeek <- merge(esWeek,esWeekData,by="week",all=T)
esWeek[is.na(esWeek)] <- 0
colnames(esWeek) <- c("week","price_tot","quant_tot","price_target","quant_target")
esWeek$perc_imps = esWeek$quant_target / esWeek$quant_tot
esWeek$perc_price = esWeek$price_target / esWeek$price_tot
## esWeek$perc.quant <- esWeek$quant_target/esWeek$quant_tot
## esWeek$perc.price <- esWeek$price_target/esWeek$price_tot
## esWeek$av.price.tot <- esWeek$price_tot/esWeek$quant_tot
## esWeek$av.price.target <- esWeek$price_target/esWeek$quant_target
print("spent on target")
print(esWeek)

con <- pipe("xclip -selection clipboard -i", open="w")
write.table(esWeek,con,row.names=F,sep=",")
close(con)

gLabel = c("month","impressions (M/month)",paste("imps on target"),"type")
bplot <- ggplot(esWeek,aes(x=week)) +
    geom_bar(aes(y=quant_tot/1000000,group=1,fill="tot"),stat="identity",alpha=0.3) + 
    geom_bar(aes(y=quant_target/1000000,group=1,fill="target"),stat="identity") + 
    scale_fill_manual(values=gCol1) +
    theme(
        legend.position="bottom"
    ) + 
    scale_fill_manual(values=gCol1[seq(1,10,2)]) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])

lplot <- ggplot(esWeek,aes(x=week)) +
    geom_line(aes(y=quant_target/quant_tot*100,group=1,color="ratio"),stat="identity",size=2) + 
    scale_color_manual(values=gCol1[3]) +
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
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])

gp1 <- ggplot_gtable(ggplot_build(bplot))
gp2 <- ggplot_gtable(ggplot_build(lplot))
pp <- c(subset(gp1$layout, name == "panel", se = t:r))
g1 <- gtable_add_grob(gp1, gp2$grobs[[which(gp2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)
ia <- which(gp2$layout$name == "axis-l")
ga <- gp2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(0.25, "cm")
g1 <- gtable_add_cols(g1, gp2$widths[gp2$layout[ia, ]$l], length(g1$widths) - 1)
g1 <- gtable_add_grob(g1, ax, pp$t, length(g1$widths) - 1, pp$b)
grobScale1 <- textGrob("percentage",rot=90,gp=gpar(fontsize=gFontSize-2))
g1 <- gtable_add_grob(g1,grobScale1,pp$t,length(g1$widths),pp$b)

gLabel = c("month","revenue (M/month)",paste("rev on target"),"type")
bplot <- ggplot(esWeek,aes(x=week)) +
    geom_bar(aes(y=price_tot/1000000,group=1,fill="tot",color="tot"),stat="identity",alpha=0.3) + 
    geom_bar(aes(y=price_target/1000000,group=1,fill="target"),stat="identity") + 
    scale_fill_manual(values=gCol1) +
    theme(
        legend.position="bottom"
    ) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
lplot <- ggplot(esWeek,aes(x=week)) +
    geom_line(aes(y=price_target/price_tot*100,group=1,color="ratio"),stat="identity",size=2) + 
    scale_color_manual(values=gCol1[3]) +
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
    scale_fill_manual(values=gCol1[seq(1,10,2)]) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])

gp1 <- ggplot_gtable(ggplot_build(bplot))
gp2 <- ggplot_gtable(ggplot_build(lplot))
pp <- c(subset(gp1$layout, name == "panel", se = t:r))
g2 <- gtable_add_grob(gp1, gp2$grobs[[which(gp2$layout$name == "panel")]], pp$t, pp$l, pp$b, pp$l)
ia <- which(gp2$layout$name == "axis-l")
ga <- gp2$grobs[[ia]]
ax <- ga$children[[2]]
ax$widths <- rev(ax$widths)
ax$grobs <- rev(ax$grobs)
ax$grobs[[1]]$x <- ax$grobs[[1]]$x - unit(0.25, "cm")
g2 <- gtable_add_cols(g2, gp2$widths[gp2$layout[ia, ]$l], length(gp2$widths) - 1)
g2 <- gtable_add_grob(g2, ax, pp$t, length(g2$widths) - 1, pp$b)
grobScale1 <- textGrob("percentage",rot=90,gp=gpar(fontsize=gFontSize-2))
g2 <- gtable_add_grob(g2,grobScale1,pp$t,length(g2$widths),pp$b)

png("intertino/fig/audienceShare.png",width=pngWidth,height=pngHeight)
grid.newpage()
grid.arrange(g1,g2,ncol=2)
dev.off()

##spot --> preroll

##fs$key <- substring(fs$key,first=1,last=7)
##table(fs$key)
##table(fs$date)
##-----------------------------time-ev--------------------------------
keyD <- ddply(fs,.(date,aud,source),summarise,imps=sum(imps,na.rm=T))
write.csv(keyD,"raw/audSourceEv.csv")

melted <- keyD
melted$week = format(melted$date,"%y-%m")
set <- grepl("zalando",melted$source)
set = set | grepl("vodafone",melted$source)
set = set | grepl("banzai",melted$source)
melted$source[set] = "2nd s/d"
melted = ddply(melted,.(week,source),summarize,imps=sum(imps))
melted[,"perc"] <- (melted[,c("week","imps")] %>% group_by(week) %>% mutate_each(funs(./sum(.))))[2]

con <- pipe("xclip -selection clipboard -i", open="w")
write.table(melted,con,row.names=F,sep=",")
close(con)


melted <- keyD
melted$week = format(melted$date,"%y-%W")
weekL = as.data.frame(as.Date("2016-01-07") + seq(0,52*7*2,7))
colnames(weekL) = "date"

weekL$week = format(weekL$date,"%y-%W")
melted = ddply(melted,.(week,source),summarize,imps=sum(imps))
melted = merge(melted,weekL,all.x=T)
##melted$name <- factor(melted$name,levels=melted$name[order(melted$name)])
melted <- melted[order(melted$date,melted$source),]
#melted$source <- factor(melted$source,levels=melted$source[order(melted$source)])
gLabel = c("month","impressions (k/week)",paste("category usage"),"cat")
p <- ggplot(melted,aes(x=date,y=imps/1000)) +
    ##geom_violin(position = "dodge") +
    geom_bar(aes(fill=source),stat="identity",position="stack",width=4) +
    ##geom_area(aes(color=source,fill=source,group=source),stat="identity",position="stack") +
    theme(legend.position=c(.2,.3)) +
    scale_x_date(labels=date_format("%y-%m"),breaks = date_breaks("1 month")) +
    scale_fill_manual(values=gCol1) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
fName <- paste("intertino/fig/audienceUsage.svg")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
fName <- paste("intertino/fig/audienceUsage.jpg")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
melted = melted[order(melted$source),]
p <- ggplot(melted,aes(x=date,y=imps/1000)) +
    ##geom_violin(position = "dodge") +
    geom_bar(aes(fill=factor(source)),stat="identity",position="fill",width=6) +
    ##geom_area(aes(color=source,fill=source,group=source),stat="identity",position="stack") +
    scale_fill_manual(values=gCol1) +
    scale_x_date(labels=date_format("%y-%m"),breaks = date_breaks("1 month")) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p
fName <- paste("intertino/fig/audienceUsageFill.jpg")
ggsave(file=fName, plot=p, width=gWidth, height=gHeight)
##(gg <- ggplotly(p,filename="intertino/target_usage.html"))

##-----------------------------split-------------------------------
fs$aud[grepl("103163",fs$key)] <- "F z beha"
fs$aud[grepl("108047",fs$key)] <- "F z"
keyF <- ddply(fs,.(OrderExtId,aud,source,format,Size),summarise,imps=sum(imps))
head(keyF)
print(paste("lost keyword:",sum(keyF[is.na(keyF$aud),"imps"])))
print(paste("unknown key: ",unique(fs[is.na(fs$aud),"key"])))
##keyF <- keyF[!is.na(keyF$aud),]

keySW <- ddply(fs,.(week,source),summarise,imps=sum(imps))
keyW <- ddply(fs,.(week,OrderExtId),summarise,imps=sum(imps))
keyW <- merge(keyW,esOrder,by.x="OrderExtId",by.y="Numero.Contratto",all.x=T)
keyW$perc <- unlist((keyW[,c("OrderExtId","imps")] %>% group_by(OrderExtId) %>% mutate_each(funs(./sum(.,na.rm=T))))[2])
keyW$price <- keyW$price*keyW$perc
keyW <- ddply(keyW,.(week),summarise,imps=sum(imps,na.rm=T),price=sum(price,na.rm=T))#,quant=sum(quant,na.rm=T))
keyW <- merge(keyW,esWeek,by.x="week",by.y="week")
keyW$target_perc <- keyW$price_target/keyW$price_tot

set <- grepl("SPOT",keyF$size)
keyF$size[set] <- gsub(" ","",keyF$size[set])
keyF$format <- "DISPLAY"
keyF$format[set] <- "VIDEO"
keyF <- merge(keyF,esOrder[,c("Numero.Contratto","client","price")],by.x="OrderExtId",by.y="Numero.Contratto",all.x=T)
write.csv(keyF,"raw/impressionKeywordAdv.csv",row.names=F)

##clipB <- keyFW
##clipB <- ddply(fs,.(week,source,format),summarise,imps=sum(imps,na.rm=T))
##clipB <- ddply(fs,.(camp,source,format),summarise,imps=sum(imps,na.rm=T))
##clipB <- ddply(fs,.(camp,source,format),summarise,imps=sum(imps,na.rm=T))
##clipB <- ddply(fs,.(week,camp,source),summarise,imps=sum(imps,na.rm=T))
if(FALSE){
    clipB <- ddply(fs,.(week,source,format),summarise,imps=sum(imps,na.rm=T))##Riassunto
    clipB = clipB[sort(clipB$week),]
    clipB <- keyF##audience-camp
    clipB <- esWeek##target rev
    clipB <- ddply(es,.(Cliente,Formato),summarise,imps=sum(Quantità.Gratis+Quantità.Ordine),price=sum(Valore.Netto))##Riassunto
    clipB <- ddply(fs2,.(source),summarise,imps=sum(imps))##dfp
    fs4 = fs[grepl("VODAFONE",fs$camp) | grepl("Vodafone",fs$camp),]
    fs4 = fs4[grep("vodafone",fs4$source),]
    clipB = ddply(fs4,.(week,camp),summarise,imps=sum(imps))##storno

    con <- pipe("xclip -selection clipboard -i", open="w")
    write.csv(clipB,con,row.names=F)
    close(con)
}


clipB = ddply(fs,.(week,source),summarise,imps=sum(imps))
targetUs <- as.data.frame.matrix(xtabs("imps ~ week + source",clipB))
targetL <- list()
for(i in 1:nrow(targetUs)){
    targetL[[i]] = list(y=rownames(targetUs)[i],a=targetUs[i,1],b=targetUs[i,2],c=targetUs[i,3],d=targetUs[i,4],e=targetUs[i,5],f=targetUs[i,6])
}
print(toJSON(targetL)) %>% gsub("\\\n","",.)  %>% cat
names(targetUs) %>% toJSON %>% cat
##clipB <- ddply(keyF,.(OrderExtId,client,Size,aud,source),summarise,imps=sum(imps))

tmp <- ddply(fs,.(Size),summarise,imps=sum(imps,na.rm=T)/1000000)
tmp$perc = round(tmp$imps/sum(tmp$imps),2)
tmp
ddply(fs,.(week),summarise,imps=sum(imps,na.rm=T)/1000000)
tmp <- ddply(fs,.(source),summarise,imps=sum(imps,na.rm=T)/1000000)
tmp$perc = tmp$imps/sum(tmp$imps)
tmp

##--------------------------------------pies--------------------------------------

chPie <- 1
pie = list()
gLabel = c("","",paste(""),"")
for(chPie in 1:5){
    print(chPie)
    if(chPie==1){
        keyPrice <- ddply(keyF,.(OrderExtId),summarise,imps=sum(imps))
        keyPrice <- merge(keyPrice,esOrder,by.x="OrderExtId",by.y="Numero.Contratto",all.x=T)
        valN <- "client"
        keyPrice <- ddply(keyPrice,valN,summarise,imps=sum(imps),price=sum(price),quant=sum(quant))
        valN <- "Size"
        valN <- "source"
        keyPrice <- ddply(keyF,valN,summarise,imps=sum(imps))
        keyPrice$percentage <- keyPrice$imps/sum(keyPrice$imps)

        melted <- keyPrice
        varN <- "price"
        varN <- "imps"
        melted$var <- melted[,valN]
        melted$val <- melted[,varN]
        melted$percentage <- melted$val/sum(melted$val,na.rm=T)
        stopwordsIt <- read.csv("out/train/stopwords_comp_it.csv",header=F,stringsAsFactor=F)$V1
        melted$var <- tryTolower(melted$var)
        melted$var <- gsub("[[:punct:]]","",melted$var)
        melted$var <- removeWords(melted$var,stopwordsIt)
        melted$var <- gsub("[ ]{2,}"," ",melted$var)
        melted$var <- gsub(" $","",melted$var)
        melted$var <- gsub("^ ","",melted$var)
        gLabel = c("source","",paste(""),"")
    }
    if(chPie==2){
        keyPrice <- ddply(keyF,.(OrderExtId),summarise,imps=sum(imps))
        keyPrice <- merge(keyPrice,esOrder,by.x="OrderExtId",by.y="Numero.Contratto",all.x=T)
        head (keyPrice)
        varN <- "client"
        keyPrice <- ddply(keyPrice,varN,summarise,imps=sum(imps),price=sum(price),quant=sum(quant))
        varN <- "Size"
        keyPrice <- ddply(keyF,varN,summarise,imps=sum(imps))
        keyPrice$percentage <- keyPrice$imps/sum(keyPrice$imps)
        melted <- keyPrice
        valN <- "imps"
        melted$var <- melted[,varN]
        melted$val <- melted[,valN]
        gLabel = c("",varN,paste(""),"")
        melted$percentage <- melted$val/sum(melted$val,na.rm=T)
        stopwordsIt <- read.csv("out/train/stopwords_comp_it.csv",header=F,stringsAsFactor=F)$V1
        melted$var <- tryTolower(melted$var)
        melted$var <- gsub("[[:punct:]]","",melted$var)
        melted$var <- removeWords(melted$var,stopwordsIt)
        melted$var <- gsub("[ ]{2,}"," ",melted$var)
        melted$var <- gsub(" $","",melted$var)
        melted$var <- gsub("^ ","",melted$var)
        melted = melted[!melted$Size=="LEADERBOARD",]
        gLabel = c("size","",paste(""),"")
    }   
    if(chPie==3){
        keySum <- ddply(keyF,.(aud),summarise,imps=sum(imps))
        keySum$type <- "interest"
        set <- grepl(" v",keySum$aud) |  grepl(" z",keySum$aud) | grepl("st",keySum$aud) 
        keySum$type[set] <- "socio-demo"
        keySum$type[grepl("shopp",keySum$aud)] <- "intention-buy"
        melted <- ddply(keySum,.(type),summarise,imps=sum(imps))
        melted$aud <- melted$type
        melted$percentage <- melted$imps/sum(melted$imps)
        melted$var <- melted$aud
        melted$val <- melted$imps
    }
    if(chPie==4){
        set <- TRUE
        melted <- ddply(keyF[set,],.(Size),summarise,imps=sum(imps))
        melted$aud <- melted$Size
        melted$percentage <- melted$imps/sum(melted$imps)
        melted$var <- melted$aud
        melted$val <- melted$imps
    }

    strLen <- as.vector(regexpr("([a-z][ ].*){2}",melted$var))
    strLen[strLen<=0] <- Inf
    strLen[is.na(strLen)] <- Inf
    strLen <- pmin(strLen,nchar(melted$var,keepNA=0))
    melted$label <- substring(melted$var,first=1,last=strLen)
    melted$y <- cumsum(melted$percentage) - melted$percentage/2
    melted$valL <- paste(round(melted$val/1000000,1),"M")
    if(!sum(melted$val)/nrow(melted)>1000000){
        melted$valL <- paste(round(melted$val/1000,1),"k")
    }
    meltedQuant <- melted[melted$val>quantile(melted$val,0.2,na.rm=T),]
    meltedQuant2 <- melted[melted$val<=quantile(melted$val,0.2,na.rm=T),]

    pie[[chPie]] <- ggplot(melted, aes(x="",y=percentage,fill=var,label=percent(percentage))) +
        geom_bar(width=1,stat="identity") +
        geom_text(data=meltedQuant,aes(x=0.6,y=y,label=percent(percentage)),size=5) +
        geom_text(data=meltedQuant,aes(x=0.9,y=y,label=valL), size=5) +
        geom_text(data=meltedQuant,aes(x=1.5,y=y,label=label), size=5) +
        geom_text(data=meltedQuant2,aes(x=1.7,y=y,label=label), size=5) +
        geom_text(aes(x=0,y =0,label=paste(round(sum(val,na.rm=T)/1000000,1),"M")), size=5) +
        theme_bw() +
        theme(
            panel.border = element_blank(),
            text = element_text(size = gFontSize),
            axis.line=element_blank(),
            axis.text.x=element_blank(),
            axis.ticks=element_blank(),
            legend.position="none",
            plot.background=element_blank(),
            panel.background = element_blank()
        ) +
        scale_fill_manual(values=c(gCol1,gCol1)) +
        coord_polar("y",start=0) + 
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
}

jpeg("intertino/fig/audienceUsageSource1.jpg",width=pngWidth,height=pngHeight)
grid.arrange(pie[[1]],pie[[2]],ncol=2)
dev.off()


melted <- ddply(keyF,.(client),summarise,imps=sum(imps),price=sum(price))
melted$aud <- paste(substring(tryTolower(melted$client),1,12),"_",sep="")
melted = melted[order(melted$imps),]
melted[melted$imps < quantile(melted$imps,.5),"aud"] = "rest"
melted <- ddply(melted,.(aud),summarise,imps=sum(imps),price=sum(price))
melted$price[is.na(melted$price)] = 0
melted$percentage <- melted$price/sum(melted$price,na.rm=T)
melted$var <- melted$aud
melted$val <- melted$price
strLen <- as.vector(regexpr("([a-z][ ].*){2}",melted$var))
strLen[strLen<=0] <- Inf
strLen[is.na(strLen)] <- Inf
strLen <- pmin(strLen,nchar(melted$var,keepNA=0))
melted$label <- substring(melted$var,first=1,last=strLen)
melted$y <- cumsum(melted$percentage) - melted$percentage/2
melted$valL <- paste(round(melted$val/1000000,1),"M")
if(!sum(melted$val)/nrow(melted)>1000000){
    melted$valL <- paste(round(melted$val/1000,1),"k")
}
melted$label = factor(melted$label,levels=melted$label[rev(order(melted$imps))])
melted = melted[rev(order(melted$imps)),]


pClient <- ggplot(melted, aes(x=label,y=imps,fill=var,label=percent(percentage))) +
    geom_bar(width=1,stat="identity") +
    geom_text(aes(x=label,y=imps/2,label=percent(percentage)),size=2) +
    geom_text(aes(x=label,y=imps/2+.02*max(imps),label=valL),size=2) +
    theme(
        panel.border = element_blank(),
        text = element_text(size = gFontSize),
        legend.position="none"
    ) +
    scale_fill_manual(values=c(gCol1,gCol1)) +
    scale_y_continuous(breaks=seq(0,20000000,2000000),labels=paste(seq(0,20,2),"M")) +
#    coord_polar("y",start=0) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
pClient


fName <- paste("intertino/fig/audienceUsageSource4.jpg",sep="")
ggsave(file=fName, plot=pClient, width=gWidth, height=gHeight)



## g1 <- ggplotGrob(p)
## g1 <- gtable_add_cols(g1, unit(0,"mm")) # add a column for missing legend
## g2 <- ggplotGrob(pieC)
## g <- rbind(g1, g2, size="first") # stack the two plots
## g$widths <- unit.pmax(g1$widths, g2$widths) # use the largest widths
## # center the legend vertically
## g$layout[grepl("guide", g$layout$name),c("t","b")] <- c(1,nrow(g))
## grid.newpage()
## grid.draw(g)

##---------------------------------------cpm-ctr----------------------------

esCl <- ddply(es,.(Cliente,Formato),summarise,imps=sum(Quantità.Gratis+Quantità.Ordine),price=sum(Valore.Netto))
esCl$cpm <- esCl$price/esCl$imps*1000
write.csv(esCl,"raw/pricePerClient.csv")
##Size,FlightDescription,Data,FlightTotalSales,Imps,Click,Ctr %,Action,Registration,Smart Passback
gs <- read.csv("raw/priceDataPlanning.csv",stringsAsFactor=F)
gs$pack <- "tot"
gs[grepl("DATA PLANNING",gs$FlightDescription),"pack"] <- "target"
gs$Size[grepl("APP",gs$Size)] <- "APP"
gs$Size[gs$Size %in% c("OVERLAYER","LEADERBOARD","Mobile","PROMOBOX","Mobile Splash Page","SKYSCRAPER")] = "Rest"
gs[gs$Size=="STRIP SKIN MASTHEAD","Size"] = "Skin/masthead"
gs[gs$Size=="SPOT","Size"] = "Preroll"

gs$cpm = gs$FlightTotalSales/gs$Imps*1000
gs$cpm[is.nan(gs$cpm)] = 0
gs$cpm[is.na(gs$cpm)] = 0
gs$cpm[gs$cpm==Inf] = 0
gs$ctr = gs$Click/gs$Imps*100
gs$ctr[is.nan(gs$ctr)] = 0
gs$ctr[is.na(gs$ctr)] = 0
gs$ctr[gs$ctr==Inf] = 0

gsD <- ddply(gs[gs$Size %in% c("RECTANGLE","Preroll","Skin/masthead"),],.(Data,Size,pack),summarise,imps=sum(Imps,na.rm=T),click=sum(Click,na.rm=T),price=sum(FlightTotalSales,na.rm=T))
write.csv(gsD,"raw/priceDataPlanningDec.csv")
gsD$ctr <- gsD$click/gsD$imps*100
gsD$cpm <- gsD$price/gsD$imps*1000

es$pack <- "tot"
es[grepl("DATA PLANNING",es$Pacchetto),"pack"] <- "target"
es$imps = es$Quantità.Ordine+es$Quantità.Gratis
es$cpm = es$Valore.Netto/es$imps*1000
es$cpm[is.nan(es$cpm)] = 0
es$cpm[is.na(es$cpm)] = 0
es$cpm[es$cpm==Inf] = 0
es1 <- es[!is.na(match(es$Cliente,advL)),]
esD <- ddply(es1[es1$Formato %in% c("Masthead","Pre-Roll Video","Rectangle","Skin"),],.(date,Formato,pack),summarise,imps=sum(Quantità.Ordine,na.rm=T),price=sum(Valore.Netto,na.rm=T))
esD$cpm <- esD$price/esD$imps*1000
esD$cpm[is.nan(esD$cpm)] <- 0
esD$cpm[esD$cpm==Inf] <- 0

gLabel = c("pack","ctr",paste("ctr@ad-server"),"ctr")
p1 <- ggplot(gsD,aes(x=pack,y=ctr,color=Size)) +
    geom_boxplot(show.legend=F) + 
    geom_jitter(height = 0,alpha=0.3,show.legend=F) +
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    facet_grid(Size ~ . ,scales="free") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
gLabel = c("pack","cpm",paste("cpm@ad-server"),"cpm")
p2 <- ggplot(gsD,aes(x=pack,y=cpm,color=Size)) +
    geom_boxplot(show.legend=F) + 
    geom_jitter(height = 0,alpha=0.3,show.legend=F) +
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    facet_grid(Size ~ . ,scales="free") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
gLabel = c("pack","cpm",paste("cpm@gestionale"),"cpm")
p3 <- ggplot(esD,aes(x=pack,y=cpm,color=Formato)) +
    geom_boxplot(show.legend=F) + 
    geom_jitter(height = 0,alpha=0.3,show.legend=F) +
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    facet_grid(Formato ~ . ,scales="free") +
    scale_y_continuous(limits=quantile(esD$cpm,c(0.2,0.8),na.rm=T)) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])


jpeg("intertino/fig/audPerformance.jpg",width=pngWidth,height=pngHeight)
grid.arrange(p1,p2,p3,ncol=3)
dev.off()


gs$Imps = as.numeric(gs$Imps)
gs$cpm = as.numeric(gs$cpm)
gs$ctr = as.numeric(gs$ctr)
weighted.sd <- function(x,wt){
    wmean <- weighted.mean(x,wt)
    ret <- sum(wt*(x-wmean)^2)/(sum(wt)*(length(wt)-1))
    sqrt(ret)
}

gs1 = gs[gs$Size %in% c("RECTANGLE","Preroll","Skin/masthead"),]
lim = quantile(gs1$cpm,c(0.02,0.98))
gs1 = gs1[gs1$cpm < lim[2],]##code alte
lim = quantile(gs1$ctr,c(0.02,0.98))
gs1 = gs1[gs1$ctr < lim[2],]##code alte
es1 <- es[!is.na(match(es$Cliente,advL)),]##perimetro con/senza target
#es1 <- es1[!grepl("PROCTER",es1$Cliente),]
es1 = es1[es1$Formato %in% c("Masthead","Pre-Roll Video","Rectangle","Skin"),]
esC = ddply(es1,.(Cliente,Formato,pack),summarise,imps=sum(imps),price=sum(Valore.Netto))
esC$cpm = esC$price/esC$imps*1000
#esC[esC$cpm>1000,]
lim = quantile(esC$cpm,c(0.02,0.95))
esC = esC[esC$cpm < lim[2],]
## ggplot(esC,aes(x=cpm)) + geom_density() + xlim(c(0,50))
## ggplot(gs,aes(x=cpm)) + geom_density() + xlim(c(0,50))
## weighted.mean(esC$cpm,esC$imps)
## weighted.mean(gs1$cpm,gs1$Imps)
gs1 = gs[gs$Size %in% c("RECTANGLE","Preroll","Skin/masthead"),]
gsM <- ddply(gs1,.(Size,pack),summarise,cpm=weighted.mean(cpm,Imps),ctr=weighted.mean(ctr,Imps))
gsM$cpm_sd = ddply(gs1, .(Size,pack),function(gs.sub) weighted.sd(gs.sub$cpm, gs.sub$Imps))$V1
gsM$ctr_sd = ddply(gs1, .(Size,pack),function(gs.sub) weighted.sd(gs.sub$ctr, gs.sub$Imps))$V1
gsM$cpm_sd = gsM$cpm_sd/rep(gsM$cpm[seq(1,nrow(gsM),2)+1],each=2)
gsM$ctr_sd = gsM$ctr_sd/rep(gsM$ctr[seq(1,nrow(gsM),2)+1],each=2)
gsM$cpm = gsM$cpm/rep(gsM$cpm[seq(1,nrow(gsM),2)+1],each=2)
gsM$ctr = gsM$ctr/rep(gsM$ctr[seq(1,nrow(gsM),2)+1],each=2)

esM <- ddply(esC,.(Formato,pack),summarise,cpm=weighted.mean(cpm,imps))
esM$cpm_sd = ddply(esC, .(Formato,pack),function(esC.sub) weighted.sd(esC.sub$cpm,esC.sub$imps))$V1
esM$cpm_sd = esM$cpm_sd/rep(esM$cpm[seq(1,nrow(esM),2)+1],each=2)
esM$cpm = esM$cpm/rep(esM$cpm[seq(1,nrow(esM),2)+1],each=2)


gLabel = c("pack","ratio",paste("ctr@ad-server"),"ctr")
p1 <- ggplot(gsM,aes(color=Size,x=pack,y=ctr)) +
    geom_bar(aes(fill=Size,group=1),stat="identity",show.legend=F,size=2,alpha=0.3) + 
    geom_errorbar(aes(ymin=ctr-ctr_sd,ymax=ctr+ctr_sd),show.legend=F,width=.2,size=2) + 
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    facet_grid(Size ~ . ,scales="free") +
    ##scale_y_continuous(labels=percent) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
gLabel = c("pack","ratio",paste("cpm@ad-server"),"cpm")
p2 <- ggplot(gsM,aes(x=pack,y=cpm,color=Size)) +
    geom_bar(aes(fill=Size,group=1),stat="identity",show.legend=F,size=2,alpha=0.3) + 
    geom_errorbar(aes(ymin=cpm-cpm_sd,ymax=cpm+cpm_sd),show.legend=F,width=.2,size=2) + 
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    facet_grid(Size ~ . ,scales="free") +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
gLabel = c("pack","ratio",paste("cpm@gestionale"),"cpm")
p3 <- ggplot(esM,aes(x=pack,color=Formato,y=cpm)) +
    geom_bar(aes(fill=Formato,group=1),stat="identity",show.legend=F,alpha=0.3,size=2) + 
    geom_errorbar(aes(ymin=cpm-cpm_sd,ymax=cpm+cpm_sd),show.legend=F,width=.2,size=2) + 
    facet_grid(Formato ~ . ,scales="free") +
    theme(strip.background = element_rect(fill=gCol1[8])) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])

jpeg("intertino/fig/audPerformanceBar.jpg",width=pngWidth,height=pngHeight)
grid.arrange(p1,p3,ncol=2)
dev.off()

con <- pipe("xclip -selection clipboard -i", open="w")
write.table(gsM,con,row.names=F,col.names=F,sep=",")
close(con)



esD$bin <- FALSE
esD$bin[esD$pack == "target"] <- TRUE
t.test(esD$cpm ~ esD$bin)
boxplot(esD$cpm ~ esD$bin)










