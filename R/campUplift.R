#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')
source('script/graphEnv.R')
library(maps)
region_map <- map_data("italy")
library(deldir)
library(tripack)
library(gridExtra)
library('corrplot')


fs <- read.csv('raw/campRoadhouseVisits.csv',stringsAsFactor=FALSE)
fs <- fs[!grepl("day",fs$day),]
fs$n_visits <- as.numeric(as.character(fs$n_visits))

ts <- read.csv('raw/campRoadhouseTv.csv',stringsAsFactor=FALSE)
day <- ts[1,"Date"]
ch <- ts[1,"Channel"]
for(i in 1:nrow(ts)){
    if(ts[i,"Date"] == ""){ts[i,"Date"] <- day}else{day <- ts[i,"Date"]}
    if(ts[i,"Channel"] == ""){ts[i,"Channel"] <- ch}else{ch <- ts[i,"Channel"]}
}
ts$Date <- as.Date(ts$Date,format="%d/%m/%Y")
sT <- ddply(ts,.(Date),summarise,imps=sum(Insertions))

tT <- read.csv('raw/tempIt16.csv')
tT$DATA <- as.Date(tT$DATA,format="%d/%m/%Y")

fs$day <- as.Date(fs$day)
fs$place_id <- gsub("ROADHOUSE_GRILL_ITALIA::","",fs$place_id)
head(fs)
fVis <- ddply(fs,.(place_id),summarise,visit=sum(n_visits))
fsMap <-read.csv('raw/campRoadhousePoiMap.csv',stringsAsFactor=FALSE,sep=",")
fsMap$place_id <- gsub("ROADHOUSE_GRILL_ITALIA::","",fsMap$place_id)
fsMap <- merge(fVis,fsMap,by="place_id")
mDist <- matrix(0,nrow=nrow(fsMap),ncol=nrow(fsMap))
for(i in 1:(nrow(fsMap)-1)){
    for(j in (i+1):nrow(fsMap)){
        mDist[i,j] <- sqrt((fsMap$lat[i] - fsMap$lat[j])^2 + (fsMap$lng[i] - fsMap$lng[j])^2)*(fsMap$visit[i]+fsMap$visit[j])
    }
}
mDist <- mDist + t(mDist)
fit <- kmeans(mDist,centers=15)
aggregate(mDist,by=list(fit$cluster),FUN=mean)
fsMap$region <- fit$cluster
fsMap2 <- read.csv('raw/campRoadhousePoiMap2.csv',stringsAsFactor=FALSE,sep=",")
fsMap2$place_id <- gsub("ROADHOUSE_GRILL_ITALIA::","",fsMap2$place_id)
fsMap <-merge(fsMap,fsMap2,by="place_id",all=T)
fsMap$lat <- fsMap$lat.x
fsMap$lat[is.na(fsMap$lat)] <- fsMap$lat.y
fsMap$lng <- fsMap$lng.x
fsMap$lng[is.na(fsMap$lng)] <- fsMap$lng.y
fsMap[is.na(fsMap$provincia),"region"] <- 16

regionV <- ddply(fsMap,.(region),summarise,lat=mean(lat),lng=mean(lng))

melted <- ddply(fs,.(day,time),summarise,visits=sum(n_visits))
gLabel = c("day","visits",paste("visit evolution"),"time")
p <- ggplot(melted,aes(x=day,y=visits,group=day,fill=time)) +
    geom_bar(position="dodge",stat="identity",width=0.7) +
    stat_smooth(aes(color="regressione 1",fill="regressione 1"),method=lm,formula=y~poly(x,3),size=1,alpha=.2,linetype="solid") +
    scale_color_manual(values=gCol1) +
    scale_x_date(limits=as.Date(c(min(fs$day),max(fs$day))) ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p

fs$weekday <- weekdays(fs$day)
ds <- ddply(fs,.(day,weekday),summarise,visit=sum(n_visits))
nF <- 7
nW <- nrow(ds)/nF
ds$diff <- 0
ds$diff[(nF+1):nrow(ds)] <- ds$visit[(nF+1):nrow(ds)] - ds$visit[1:(nrow(ds)-nF)]
ds <- merge(ds,tT,by.x="day",by.y="DATA",all.x=T)
ds <- merge(ds,sT,by.x="day",by.y="Date",all.x=T)
ds$diff <- ds$diff/sum(abs(ds$diff))
ds$visit <- ds$visit/sum(ds$visit)
ds$TMEDIA..C <- ds$TMEDIA..C/sum(ds$TMEDIA..C)
ds$imps <- ds$imps/sum(ds$imps,na.rm=T)
ds$maltempo <- ds$FENOMENI!=""

lm(visit ~ TMEDIA..C + imps,data=ds)
lm(diff ~ TMEDIA..C + imps,data=ds)

p <- ggplot(ds,aes(x=day)) +
    geom_line(aes(y=diff,group=1,color="Delta visit")) +
    geom_line(aes(y=visit,group=1,color="visit")) +
    geom_line(aes(y=TMEDIA..C,group=1,color="temperature")) +  
    geom_line(aes(y=imps,group=1,color="tv")) + 
    ##stat_smooth(aes(color="regressione 1",fill="regressione 1"),method=lm,formula=y~poly(x,3),size=1,alpha=.2,linetype="solid") +
    scale_color_manual(values=gCol1) +
    scale_x_date(limits=as.Date(c(min(ds$day),max(ds$day))) ) +
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p

wMean <- ddply(fs,.(weekday),summarise,mean=mean(n_visits),sd=sd(n_visits))
fs$weekday <- factor(fs$weekday,levels=c("lunedì","martedì","mercoledì","giovedì","venerdì","sabato","domenica"))
head(fs)
ddply(fs,.(weekday),summarise,imps=sum(n_visits),mean=mean(n_visits),sd=sqrt(sd(n_visits)))

lm(n_visits ~ weekday,fs)

gLabel = c("day","visits",paste("visit evolution"),"time")
p1 <- ggplot(fs,aes(x=weekday,y=n_visits,group=weekday,color=weekday)) +
    geom_boxplot(aes(fill=weekday),alpha=.5) +
    geom_violin(alpha=.5) +
##    geom_jitter(height = 0) +
    geom_line(data=wMean,aes(x=weekday,y=mean,group=1),color=gCol1[1]) + 
    scale_y_continuous(limits = quantile(fs$n_visits,c(0.1,0.9))) +
##    scale_color_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p1

gLabel = c("visit","density",paste("density"),"time")
p2 <- ggplot(fs,aes(x=n_visits,fill=time,color=time)) +
    geom_density(alpha=.5) +
    ##    scale_color_manual(values=gCol1) +
    coord_flip() + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4])
p2

grid.arrange(p1,p2,ncol=3,layout_matrix=cbind(c(1,1),c(1,1),c(2,2)))

t.test(fs[grepl("dinner",fs$time),"n_visits"],fs[grepl("lunch",fs$time),"n_visits"])
##ggplot(fs) + geom_boxplot(aes(x=time,y=n_visits))

##-------------------------------geo----------------------------------
nWeek <- round(nrow(ds)/7)
nWeek <- 3
fitL <- list()
regPoi <- data.frame(day=as.Date(unique(fs$day)))
for(i in unique(fs$place_id)){
    print(i)
    cs <- ddply(fs[grepl(i,fs$place_id),],.(day),summarise,n_visits=sum(n_visits))
    if(nrow(cs) < 3) {next}
    cs <- merge(regPoi,cs,by="day",all.x=T)
    cs$n_visits[is.na(cs$n_visits)] <- mean(cs$n_visits,na.rm=T)
    fit <- lm(cs$n_visits ~ poly(cs$day,nWeek),na.action=na.exclude)
    cs$fit <- fitted(fit)
    regPoi <- merge(regPoi,cs[,c("day","fit")],by="day",all.x=T)
    ## regPoi <- join(regPoi,cs[,c("day","fit")],type="full",by="day")
    colnames(regPoi)[grepl("fit",colnames(regPoi))] <- i
    fitL[[length(fitL)+1]] <- fit
}

melted <- melt(regPoi,id="day")
melted <- merge(melted,fsMap,by.x="variable",by.y="place_id",all.x=T)
mPro <- ddply(melted,.(day,region),summarise,visit=sum(value))
mPro <- mPro[order(mPro$region),]

gLabel = c("day","visits",paste("visit evolution"),"visits","region")
p <- ggplot(melted,aes(x=day,y=value)) +
    geom_bar(data=fs,aes(x=day,y=n_visits,fill="serie"),position="stack",stat="identity",alpha=.2) + 
    ##geom_line(aes(color=variable,group=variable),position="stack",stat="identity",size=1,alpha=.7,linetype="solid",show.legend=FALSE) +
    geom_line(data=mPro,aes(y=visit,color=region,group=region),position="stack",stat="identity",size=1,alpha=.7,linetype="solid",show.legend=FALSE) +
    scale_fill_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[5])
p

corM <- as.data.frame.matrix(xtabs("visit ~ region + day",mPro))
str(corM)
corrplot.mixed(cor(t(corM)),lower="pie",upper="number")

regionV$uplift <- 0
for(i in regionV$region){
    set <-  mPro$region == i
    if(!any(set)){next}
    mDay <- min(mPro[set,"day"])
    MDay <- max(mPro[set,"day"])
    end <- mPro[set & mPro$day==MDay,"visit"]
    start <- mPro[set & mPro$day==mDay,"visit"]
    regionV$uplift[i] <- 2*(end-start)/(end+start)
}
regionV$vol <- ddply(mPro,.(region),summarise,vol=sum(visit))$vol
voro <- deldir(regionV$lng,regionV$lat)
regionV <- regionV[!regionV$region==16,]

gLabel = c("","",paste("visit uplift"),"uplift","visits")
p <- ggplot() + 
    geom_polygon(data=region_map,aes(x=long,y=lat,group=group),alpha=.2,color=gCol1[7],fill=gCol1[6]) + 
    geom_point(data=regionV,aes(x=lng,y=lat,fill=uplift,color=uplift,size=vol)) +
    geom_text(data=regionV,aes(x=lng,y=lat,label=paste(round(uplift*100),"",sep=""))) +
    geom_segment(aes(x = x1, y = y1, xend = x2, yend = y2),size = 1,data = voro$dirsgs,linetype = "dotted",color= "#FFB958") +
scale_size(range = c(0, 20)) +
##    scale_y_continuous(limits=c(37,47))+
    theme(axis.line=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank(),
      axis.ticks=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
##      legend.position="none",
      panel.background=element_blank(),
      panel.border=element_blank(),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      plot.background=element_blank()) +
    ##scale_scale_manual(values=gCol1) + 
    labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],fill=gLabel[4],color=gLabel[4],size=gLabel[5])
p
fName <- paste("fig/campUpliftMap.png")
ggsave(file=fName, plot=p, width=gWidth, height=gWidth,units="in",dpi=gRes)


ramp <- ddply(melted,.(day),summarise,val=sum(value))
2.*(ramp[nrow(ramp),"val"] - ramp[1,"val"])/(ramp[nrow(ramp),"val"] + ramp[1,"val"])
sum(melted[melted$region==16,"value"])/sum(melted[,"value"])


ddply(merge(fs,fsMap,by="place_id"),.(region),summarise,vol=sum(n_visits))
sum(fs[fs$region==16,"n_visits"])/sum(fs[,"n_visits"])



if(FALSE){
    summary(fit)
    coefficients(fit) # model coefficients
    confint(fit, level=0.95) # CIs for model parameters
    fitted(fit) # predicted values
    residuals(fit) # residuals
    anova(fit) # anova table
    
    fit2 <- lm(cs$n_visits~ poly(cs$day,1))
    anova(fit, fit2) 
    
    vcov(fit) # covariance matrix for model parameters
    influence(fit) # regression diagnostics
    layout(matrix(c(1,2,3,4),2,2)) # optional 4 graphs/page
    plot(fit2)
}


if(FALSE){
    ##install.packages(c('DAAG','bootstrap'))
library(DAAG)
cv.lm(df=mydata, fit, m=3) # 3 fold cross-validation
fit <- lm(y~x1+x2+x3,data=mydata)

library(bootstrap)
# define functions
theta.fit <- function(x,y){lsfit(x,y)}
theta.predict <- function(fit,x){cbind(1,x)%*%fit$coef}

# matrix of predictors
X <- as.matrix(mydata[c("x1","x2","x3")])
# vector of predicted values
y <- as.matrix(mydata[c("y")])

results <- crossval(X,y,theta.fit,theta.predict,ngroup=10)
cor(y, fit$fitted.values)**2 # raw R2
cor(y,results$cv.fit)**2 # cross-validated R2 
}





cs <- read.csv("raw/campRoadhouseAud.csv",stringsAsFactor=F)
cs <- cs[cs$Index<=7,]

cs <- read.csv("raw/campRoadhouseAud2.csv",stringsAsFactor=F)
cs$Visitors <- as.numeric(gsub(",","",cs$Visitors))
cs$Index <- as.numeric(gsub(",","",cs$Index))

cs <- cs[grepl("RTI",cs$Category.Path),]
cs <- cs[!grepl("advertiser",cs$Category.Name),]
cs <- cs[!grepl("Log",cs$Category.Path),]
cs <- cs[!grepl("Log",cs$Category.Name),]
cs <- cs[!grepl("Web",cs$Category.Name),]
cs <- cs[!grepl("Televisione",cs$Category.Name),]
cs <- cs[!grepl("Geo",cs$Category.Path),]

cs1 <- ddply(cs,.(Index),summarise,sVisitor=sum(Visitors,na.rm=T))
cs <- merge(cs,cs1)
cs$percent <- cs$Visitors/cs$sVisitor
cs$Index <- max(cs$Index)-cs$Index
cs <- cs[order(cs$Index),]
cs[,"pos"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.))))[2]
cs[,"posL"] <- (cs[,c("Index","percent")] %>% group_by(Index) %>% mutate_each(funs(cumsum(.)-.*0.5)))[2]
cs$angle <- 0# 180-cs$posL*360

##cs$posL <- cs$posL/cs$Volume
lim <- quantile(cs$posL,probs=c(.35,.65))
lim <- quantile(cs$posL,probs=c(.45,.55))
set <- (cs$posL > lim[1] & cs$posL < lim[2]) & (cs$Index < quantile(cs$Index,0.9))

gLabel = c("\nCategory","Visitors",paste("Category Affinity"),"Name")
pie <- ggplot(cs[set,]) +
##    geom_bar(aes(x=Index,y=percent,fill=Category.Name),width = 1,stat="identity") +
    geom_point(aes(x=Index,y=posL,color=Category.Name,size=Volume),stat="identity",alpha=0.5) +
    geom_point(aes(x=Index,y=posL,color=Category.Name,size=Visitors),stat="identity",alpha=0.5) +
    theme_bw() +
    geom_text(aes(x=Index,y=posL,angle=angle,label=Category.Name),size=4) + 
    scale_size(range = c(0, 30)) +
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



 
