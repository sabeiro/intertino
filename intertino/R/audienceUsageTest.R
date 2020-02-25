####--------------------------test--------------------------------

fs <- read.csv('log/matchedKeywordBkSite.csv',header=F,stringsAsFactor=F)
colnames(fs) <- c("camp","key","date","imps")
keywords <- strsplit(fs[,2],split="bk_")
keyL <- NULL
keyFT <- NULL
i <- length(keywords)
for(i in 1:length(keywords) ){
    keyL <- rbind(keyL,c(paste(keywords[[i]][-1],collapse=",")))
}
keyV <- as.vector(unlist(keyL))
set <- grepl(",",keyV)
keyD1 <- unlist(lapply(strsplit(keyV[set],split=","),'[[',1))
keyD2 <- unlist(lapply(strsplit(keyV[set],split=","),'[[',2))
keyD <- data.frame(date=fs[set,"date"],key=keyD1,imps=fs[set,"imps"],camp=fs[set,"camp"])
keyD <- rbind(keyD,data.frame(date=fs[set,"date"],key=keyD2,imps=fs[set,"imps"],camp=fs[set,"camp"]))
keyF1 <- rbind(keyD,data.frame(date=fs[!set,"date"],key=keyV[!set],imps=fs[!set,"imps"],camp=fs[!set,"camp"]))
keyF1$key <- gsub("§","",keyF1$key)
keyF1 <- merge(keyF1,campD,by.x="key",by.y="id",all.x=T)
keyF1$date <- as.Date(strptime(as.character(keyF1$date),format="%Y%m%d"))
keyFT <- rbind(keyFT,keyF1)

campL <- unique(fs$camp)
fs1 <- read.csv('log/runningOnKey.csv')
head(fs1)
set <- FALSE | grepl("SCA ",fs1$AdDescription) | grepl("SWIFFER",fs1$AdDescription)
for(i in campL){set <- set | grepl(i,fs1$AdDescription)}
table(set)
fs1 <- fs1[set,]
fs1[grepl("SCA ",fs1$AdDescription),]
fs1$Data <- as.Date(fs1$Data)

fs2 <- ddply(fs,.(date, camp),summarise,imps=sum(imps))
fs2$date <- as.Date(strptime(as.character(fs2$date),format="%Y%m%d"))

gLabel = c("category","impressions (k/day)",paste("category usage"),"camp")
p <- ggplot(fs1,aes(x=Data,y=Imps/1000)) +
    geom_bar(aes(fill=AdDescription,group=AdDescription),stat="identity",position="dodge",alpha=.7) +
    geom_line(data=fs2,aes(x=date,y=imps/1000,color=camp,group=camp),size=2) +
    coord_cartesian(ylim = c(0, 100)) +
    ##theme(legend.position="bottom") + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill="camp report",color="camp somma keyword")
p

fs1$camp <- fs1$AdDescription

gLabel = c("category","impressions (k/day)",paste("category usage"),"camp")
p <- ggplot(keyFT,aes(x=date,y=imps/1000)) +
    geom_bar(aes(fill=name,group=name),stat="identity",position="dodge") +
    theme(legend.position="bottom") +
    facet_grid(.~camp) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p

write.csv(fs1,"log/keywordSumCheck_Report.csv")
write.csv(fs2,"log/keywordSumCheck_FullReport.csv")
write.csv(keyF,"log/keywordSumCheck_keyUsage.csv")







fs <- read.csv("raw/bluekaiContainerHitsQ1.tsv",sep="\t")
fs <- rbind(fs,read.csv("raw/bluekaiContainerHitsQ2.tsv",sep="\t"))
fs <- rbind(fs,read.csv("raw/bluekaiContainerHitsQ3.tsv",sep="\t"))
fs$PERIOD <- as.Date(fs$PERIOD)
head(fs)

hitSum <- ddply(fs,.(SITE),summarise,hit=sum(SITE_HITS))
sum(hitSum[grepl("swap",hitSum$SITE),"hit"])

melted <- fs
melted <- fs[grepl("swap",fs$SITE),]
melted <- fs[grepl("retar",fs$SITE),]
melted <- fs[!grepl("json",fs$SITE),]

ggplot(melted,aes(x=PERIOD,y=SITE_HITS,color=SITE,group=SITE)) +
    geom_line() +
    scale_x_date(labels = date_format("%Y-%m"))

melted$month <- format(melted$PERIOD,format="%m")
##melted <- melted[!melted$SITE_HITS > quantile(melted$SITE_HITS,c(0.01,0.99))[2],]
mSite <- ddply(melted,.(month),summarise,imps=sum(SITE_HITS))
mSite$name <- mSite$month

mSite <- ddply(melted,.(SITE),summarise,imps=sum(SITE_HITS))
mSite$name <- mSite$SITE

mSite <- mSite[mSite$imps>quantile(mSite$imps,0.70),]


mSite$percentage <- mSite$imps/sum(mSite$imps)
gLabel = c("",lVar,paste("provider share",lVar),"browser")
pie <- ggplot(mSite, aes(x="",y=percentage,fill=name,label=percent(percentage))) +
    geom_bar(width = 1,stat="identity") +
    scale_fill_manual(values=gCol1) +
    geom_text(aes(x=1,y = percentage/2 + c(0,cumsum(percentage)[-length(percentage)]),
                  label = percent(percentage)), size=5) +
    geom_text(aes(x=1.3,y = percentage/2 + c(0,cumsum(percentage)[-length(percentage)]),
                  label = paste(round(imps/1000000,1),"M")), size=5) +
    geom_text(aes(x=1.6,y = percentage/2 + c(0,cumsum(percentage)[-length(percentage)]),
                  label = name), size=5) +
    geom_text(aes(x=0,y =0,label=paste(round(sum(imps)/1000000),"M")), size=5) +
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
    coord_polar("y",start=0) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
pie



(sum(mSite$imps)/1000000 + 90 + 90 + 90) / ((4768907503.2+384157591.2) /1000000*4/3)

448+311+44

122/97




cs <- read.csv("rep/anomalieVideo2.csv")
cs <- merge(cs,es,by.y="Numero.Contratto",by.x="OrderExtId",all.x=T)
head(cs)
write.csv(cs,"rep/anomalieVideo3.csv")



