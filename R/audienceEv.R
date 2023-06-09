#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')


fs <- read.csv('raw/audiencePubmatic.csv')
fs$date <- as.Date(substr(fs$Creation.Time,start=1,stop=10),format="%m-%d-%Y")
fs$dateInit <- as.Date(substr(fs$Creation.Time,start=1,stop=10),format="%m-%d-%Y")
head(fs)

cs <- ddply(fs,.(date,Audience.Name),summarise,unique=sum(Total.Uniques,na.rm=TRUE),imps=sum(Impressions,na.rm=TRUE))
cs <- ddply(fs,.(Audience.Name),summarise,unique=sum(Total.Uniques,na.rm=TRUE),imps=sum(Impressions,na.rm=TRUE))
cs <- cs[cs$imps>0,]
cs$video <- cs$imps*.14*30
cs$skin  <- cs$imps*.14*30
cs$box <- cs$imps*.47*30
cs$masthead <- cs$imps*.23*30

cs$rate/sum(cs$rate)


write.csv(cs,"out/audienceSizeEv.csv")

## video skin box masthead
## 14 14 47 23 pubmatic
## 9 16 23 16 dot



cs <- cs[cs$date >= "2016-06-21",]
gLabel = c("date","impression (Mio)",paste("evoluzione imps per audience"),"section")
p <- ggplot(cs,aes(x=date,y=imps,group=(Audience.Name))) +
    geom_point(aes(color=Audience.Name),position="stack",show.legend=FALSE) +
    geom_area(aes(fill=(Audience.Name)),position="stack",size=1,alpha=.5) +
    ##geom_text(data=colD,aes(x=x,y=y,label=name),color="black") +
    ##scale_fill_manual(values=aggr1$col,breaks=aggr1$name,labels=aggr1$name) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4])
p

fs1 <- read.csv('raw/audienceReach.csv')
fs1$rate <- fs1$reach/19000
fs1$video <- fs1$rate*7733315193/90*0.09
fs1$skin <- fs1$rate*7733315193/90*0.16
fs1$box <- fs1$rate*7733315193/90*0.23
fs1$mastehead <- fs1$rate*7733315193/90*0.16
head(fs1)
write.csv(fs1,"out/audienceSizeEv.csv")

fs2 <- read.csv('raw/sizeDot.csv')
head(fs2)
cs2 <- ddply(fs2,.(Size),summarise,imps=sum(Imps,na.rm=TRUE))
cs2 <- cs2[cs2$imps>mean(cs2$imps),]
cs2$rate <- cs2$imps/sum(as.numeric(cs2$imps),na.rm=TRUE)



