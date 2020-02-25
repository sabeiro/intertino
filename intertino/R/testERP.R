setwd('~/lav/media')
source('src/R/graphEnv.R')


fs <- read.csv("raw/storicoAdServer2017.csv",stringsAsFactor=F)
fs = ddply(fs,.(OrderExtId),summarise,Imps=sum(as.numeric(Imps),na.rm=T))
es <- read.csv("raw/storicoERP2017.csv",stringsAsFactor=F)

cs = merge(fs,es,by.x="OrderExtId",by.y="Numero.Contratto",all=T)
sum(is.na(cs$N))/nrow(cs)
cs = cs[grepl("DATA PLANNING",cs$Pacchetto),]
gs = cs[,c("OrderExtId","Imps","Quantità.Ordine")]
gs$diff = gs$Imps - gs$Quantità.Ordine     
melted = melt(gs,id="OrderExtId")
ggplot(melted) + geom_line(aes(x=OrderExtId,y=value,color=variable,group=variable))
head(melted)

con <- pipe("xclip -selection clipboard -i", open="w")
write.csv(cs,con,row.names=F)
close(con)


fs <- read.csv('src/py/tmp.csv')
fs$X = as.Date(fs$X)
fs1 <- read.csv('src/py/tmp1.csv')
fs1$X = as.Date(fs1$X)
fs2 <- read.csv('src/py/tmp2.csv')
fs2$X = as.Date(fs2$X)
fs2$y = fs2$y*mean(fs$y)
fs3 <- read.csv('src/py/tmp3.csv')
fs3$y = fs3$y*mean(fs$y)
fs3$X = as.Date(fs3$X)

fs4 = merge(fs1,fs2,all.x=T)

head(fs4)

labL = c("daily series","rolling average","trend","de-trend","history month","history week","history spline","history spline","history correction","periodic least square","prediction period+trend","prediction + trend","prediction")
gLabel = c("day","iventory (M)",paste(""),"type")
i = 1
p = ggplot(fs,aes(x=X)) +
    geom_line(aes(y=y,color="series",group=1),stat="identity",size=1.5,color=gCol1[1]) +
    theme(legend.position=c(.1,.75)) +
    scale_x_date(date_breaks="1 week",labels=date_format("%y-%m-%d"),limits=c(as.Date("2017-01-01"),as.Date("2017-04-01"))) + ##, date_labels = "%W") +
    scale_y_continuous(limits=c(-2,4.5)) + 
    scale_color_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
for(i in 1:length(labL)){
    p2 = p + annotate("text",x=as.Date('2017-01-30'),y=-2,label=labL[i],size=10)
    if(i==1){p1 = p2}
    if(i==2){
        p1 = p2 + geom_line(aes(y=roll,color="roll",group=1),stat="identity",size=1.5,color=gCol1[7])
    }
    if(i==3){
        p1 = p2 + geom_line(aes(y=roll,color="roll",group=1),stat="identity",size=1.5,color=gCol1[7]) + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i==4){
        p1 = p2 + geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2]) + geom_line(data=fs4,aes(y=y-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i==5){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1])
    }
    if(i==6){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1]) + geom_bar(data=fs2,aes(y=y,fill="hist week",group=1),stat="identity",alpha=.3,fill=gCol1[3])
    }
    if(i==7){
        p1 = p2 +  geom_bar(data=fs3,aes(y=y,fill="hist month",group=1),stat="identity",alpha=.3,fill=gCol1[1]) + geom_bar(data=fs2,aes(y=y,fill="hist week",group=1),stat="identity",alpha=.3,fill=gCol1[3]) + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3])
    }
    if(i==8){
        p1 = p2 + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3]) + geom_line(data=fs4,aes(y=y-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i == 9){
        p1 = p2 + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3]) + geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    if(i == 9){
        p1 = p2 + geom_line(data=fs1,aes(y=hist,color="hist",group=1),stat="identity",size=1.5,color=gCol1[3]) + geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2])
    }
    ggsave(file=paste("fig/tmp/serEv",sprintf("%02d",i),".jpg",sep=""),plot=p1,width=gWidth,height=gHeight)
}

    ## geom_line(aes(y=e_av,color="mov av",group=1),stat="identity",size=1.5) +
    ## geom_line(aes(y=dev,color="deriv",group=1),stat="identity",size=1.5) +
    ## geom_line(aes(y=diff,color="difference",group=1),stat="identity",size=1.5) +
    ## geom_line(aes(y=stat,color="stationary",group=1),stat="identity",size=1.5) +
    ## geom_line(data=fs1,aes(y=y,color="prediction",group=1),stat="identity",size=1.5) +
    ## geom_line(data=fs1,aes(y=y,color="prediction",group=1),stat="identity",size=1.5) +
    geom_line(data=fs1,aes(y=trend,color="trend",group=1),stat="identity",size=1.5,color=gCol1[2]) +
    ##geom_line(data=fs4,aes(y=y/hist-trend,color="de-trend/hist",group=1),stat="identity",size=1.5,color=gCol1[2]) +
    ##geom_line(data=fs1,aes(y=lsq,color="lsq",group=1),stat="identity",size=1.5,color=gCol1[4]) +
    geom_line(data=fs1,aes(y=pred,color="prediction",group=1),stat="identity",size=1.5,color=gCol1[5]) +
    ##
    ##
    ## 


    



