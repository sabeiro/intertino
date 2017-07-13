#!/usr/bin/env Rscript
setwd('~/lav/media/')
source('src/R/graphEnv.R')
library('corrplot') #package corrplot
library('svglite')
require(stats)
require(dplyr)
library(grid)
library(sqldf)
library('rjson')
library('jsonlite')
library('RJSONIO')
library(RCurl)


fs <- read.csv("raw/audReach.csv",stringsAsFactor=F)
## fs <- read.csv("raw/audienceReachElab.csv")
fs$reach <- fs$reach/1000
fs$group <- substring(fs$name,first=1,last=3)
fs$group <- tryTolower(fs$group)
fs1 <- read.csv('raw/audClusterMapBluekai.csv',stringsAsFactor=F)
for(i in 1:length(fs1$target)){
    set <-  match(fs$name,fs1$target[i])
    if(any(!is.na(set))){
        fs[!is.na(set),"group"] = fs1$cluster[i]
    }
}
fs = fs[!grepl("analisi",fs$group),]
fs$name <- fs$name %>% gsub("s-d ","",.) %>% gsub("i-t ","",.) %>% gsub("i-b ","",.) %>% gsub("pub ","",.) %>% gsub("I-t ","",.) %>% gsub("I-b ","",.) %>% gsub("g-o ","",.) %>% gsub("an ","",.)
fs2 <- read.csv("raw/audReachBanzai.csv",stringsAsFactor=F)
fs2$reach = as.numeric(gsub("[[:punct:]]","",fs2$Devices))/1000
fs2$group = fs2$Type
fs2$name = fs2$Label
fs1 <- read.csv("raw/audClusterMapBanzai.csv",stringsAsFactor=F)
for(i in 1:length(fs1$target)){
    set <-  match(fs2$name,fs1$target[i])
    if(any(!is.na(set))){
        fs2[!is.na(set),"group"] = fs1$cluster[i]
    }
}
fs2$name <- fs2$name %>% gsub("Travel ","",.) %>% gsub("eCommerce ","",.) %>% gsub("Studenti ","",.) %>% gsub("Cooking ","",.) %>% gsub("Età ","",.) 

fs = rbind(fs[,c("name","reach","group")],fs2[,c("name","reach","group")])
fs = fs[order(fs$group),]
fs$label = paste("",round(ifelse(fs$reach > 100,fs$reach/1000,fs$reach),1),ifelse(fs$reach > 1000,"M","k")  )
##melted <- fs[fs$group=="i-t",]
##melted <- melt(fs[grepl("SOCIODEMO",fs$Tier),-1],id="Segmento")
view = c(16,9)
view = c(view,sqrt(view[1]^2+view[2]^2))
grpL <- ddply(fs,.(group),summarise,n=length(reach),size=sum(reach))
grpL$img = paste("ico_",grpL$group,"",sep="")
grpL$size = view[3]*grpL$size/sum(grpL$size)
grpL = grpL[order(-grpL$size),]
## var i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
## var k = diameter / v[2]; view = v;
## node.attr("transform", function(d) { return "translate(" + (d.x - v[0]) * k + "," + (d.y - v[1]) * k + ")"; });
grpL$x = cumsum(4*view[1]/1:nrow(grpL))
grpL$y = cumsum(grpL$size)
gCol1[1] = "#97003F"
grpL$color = gCol1[1:nrow(grpL)]

melted <- fs
melted <- merge(fs,grpL,by="group",all=T)
melted$x = melted$x + (melted$size/2 - runif(nrow(melted),0,melted$size))*4
yV = (melted[,c("group","n")] %>% group_by(group) %>% mutate_each(funs(cumsum(.)/.)))[2]
melted$y = unlist(yV)
melted <- melted[order(melted$group,melted$name),]

nodeC <- 0
nodeD <- NULL
linkD <- NULL
pointL = list()
for(i in 1:nrow(grpL)){
    melted1 = melted[melted$group==grpL$group[i],]
    empG = list()
    nodeD = rbind(nodeD,c(grpL[i,"group"],nodeC))
    parentC = nodeC
    nodeC = nodeC + 1
    for(j in 1:nrow(melted1)){
        empG[[j]] = list(name=melted1[j,"name"],size=melted1[j,"reach"],x=melted1[j,"x"],y=melted1[j,"y"],type="leaf",color=toInt(grpL[i,"color"],.5),img="")
        nodeD = rbind(nodeD,c(melted1[j,"name"],nodeC))
        linkD = rbind(linkD,c(melted1[j,"source"],nodeC,parentC,1,""))
        nodeC = nodeC + 1
    }
    pointL[[i]] = list(name=grpL[i,"group"],type="group",n=grpL[i,"n"],size=grpL[i,"size"],img=grpL[i,"img"],x=grpL[i,"x"],y=grpL[i,"y"],color=toInt(grpL[i,"color"],.5),children=empG)
}
write(toJSON(list(name="Offerta audience",color="rgba(230,230,230,0.9)",title="...",children=pointL)),"intertino/data/audPoint.json")
colnames(nodeD) <- c("name","id")
colnames(linkD) <- c("source","target","value","name")
write(toJSON(list(nodes=df2l(nodeD),links=df2l(linkD))),"intertino/data/audNetwork.json")



fes <- read.csv("raw/audienceEv.csv")
fes$size = 1
fes$img = paste("logo",fes$name,sep="_")
fesL <- list(name="traffic evolution",size=nrow(fes),children=group2l(fes,"group"))
for(i in 1:length(fesL$children)){
    fesL$children[[i]]$img = paste("ico",fesL$children[[i]]$name,sep="_")
}
write(toJSON(fesL),"intertino/data/trafficGrp.json")

fet <- read.csv("raw/audienceEvTime.csv",stringsAsFactor=T)
fet$Page.Impressions = as.numeric(fet$Page.Impressions)
fet$Visits = as.numeric(fet$Visits)
fet$Livello4...Sito = tryTolower(fet$Livello4...Sito)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("t24","tgcom24",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("radio101","r101",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("witty","filippi",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("uomini e donne","filippi",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("selfie","filippi",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("cè posta per te","filippi",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("una donna","unadonna",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("girogirobimbo","mamma",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("ondemand","grandefratello",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("mediaset","iene",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("sportiene","sportmediaset",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("onore","isola",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("verissimo","tgcom",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("quartogrado","tgcom",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("casafacile","panorama",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("donna-moderna","pianetamamma",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("interni","pianetamamma",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("icon","pianetamamma",.)
fet$Livello4...Sito = fet$Livello4...Sito %>% gsub("radio","cook",.)
feb <- read.csv("raw/audienceEvBanz2.csv",stringsAsFactor=T)
feb <- feb[,-1]
feb$Hours = seq(1,nrow(feb))
colnames(feb) <- colnames(feb) %>% gsub(".1","",.)
febm <- melt(feb,id="Hours")
colnames(febm) <- c("Hours","name","imps")
febm$Hours <- febm$Hours %% 24
febd <- ddply(febm,.(Hours,name),summarise,imps=sum(imps)/floor(nrow(feb)/24))
fet$name = "rest"
for(i in fes$name){
    fet[grepl(i,fet$Livello4...Sito),"name"] = i
}
unique(fet$Livello4...Sito[fet$name=="rest"])
##fed <- ddply(fet,.(name,Hours),summarise,imps=sum(Page.Impressions,na.rm=T)/7)
fed <- ddply(fet,.(name,Hours),summarise,imps=sum(Visits,na.rm=T)/7)
fed = fed[!fed$Hours=="Sum",]
fed <- rbind(fed,febd)
fed = merge(fed,fes)
fed$Hours = sprintf("%02d",as.numeric(fed$Hours))
## fex <- as.data.frame.matrix(xtabs("imps ~ Hours + name",fed))
## write.csv(fex,"tmp/audienceEv.csv")
fed$norm = unlist( (fed[,c("name","imps")] %>% group_by(name) %>% mutate_each(funs(./sum(.,na.rm=T))))[2]*24 )

hourL = list()
hL = unique(fed$Hours)
for(i in 1:length(hL)){
    fedt = fed[fed$Hours==hL[i], c("name","imps","group","size","img","norm")]
    ##hourL[[i]] = list(name=i,size=nrow(fedt),children=group2l(fedt,"group"))
    hourL[[i]] = group2l(fedt,"group")
    for(j in 1:length(hourL[[i]])){
        hourL[[i]][[j]]$norm = hourL[[i]][[j]]$norm/hourL[[i]][[j]]$size
        hourL[[i]][[j]]$img = paste("ico",hourL[[i]][[j]]$name,sep="_")
        hourL[[i]][[j]]$hour = sprintf("%02d",as.numeric(i-1))
    }
}
fedG <- ddply(fed,.(group,Hours),summarise,imps=sum(imps))
for(i in 1:length(hL)){
    for(j in 1:length(hourL[[i]])){
        set <- fedG$Hours == hourL[[i]][[j]]$hour & fedG$group == hourL[[i]][[j]]$name
        hourL[[i]][[j]]$imps = head(fedG[set,"imps"],1)
    }
}

write(toJSON(list(name="traffic evolution",size=nrow(fed),children=hourL)),"intertino/iab/data/trafficHou.json")
ddply(fed,.(name),summarise,imps=sum(imps))
for(j in 1:length(hourL[[i]])){
    print(paste(hourL[[i]][[j]]$name,hourL[[i]][[j]]$imps))
}



themeBlank <- theme(
    legend.position="none",
    ##axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
    panel.background = element_blank(),
    panel.border = element_blank(), 
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(), 
    panel.margin = unit(c(0,0,0,0), "lines"), 
    axis.ticks = element_blank(), axis.text.x = element_blank(),
    axis.text.y = element_blank(),
    axis.line = element_blank(), 
    axis.text.x = element_blank(), 
    axis.text.y = element_blank(),
    axis.ticks = element_blank(), 
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    axis.ticks.margin = unit(c(0,0,0,0), "lines"), 
    plot.background =  element_blank(), 
    plot.margin = unit(c(0,0,0,0), "lines")
) 


i=1
for(i in 1:nrow(grpL)){
    melted1 = melted[melted$group==grpL$group[i],]
    melted1$x = runif(nrow(melted1),0,melted1$size)/2
    melted1$y = runif(nrow(melted1),0,melted1$size)/2
    grpL1 = grpL[grpL$group==grpL$group[i],]
    gLabel = c("","",paste(""),"margin")
    xAv = mean(melted1$x) + mean(melted1$x)/2
    yAv = mean(melted1$y) + mean(melted1$y)/2
    p <- ggplot(melted1,aes(x=x,y=y,color=color)) +
        geom_point(aes(size=reach),alpha=0.4) +
        ##    geom_point(aes(size=imps),alpha=0.4) +
        geom_text(aes(label=name),hjust=1,size=3) +
        #geom_text(aes(label=paste(round(reach),"k")),hjust=1,vjust=-0.5,size=4) +
        geom_text(aes(label=label),hjust=1,vjust=-0.5,size=4) +
        geom_text(data=grpL1,aes(x=xAv,y=yAv,label=group),hjust=1,size=25) +
        ##scale_size_area() +
        scale_size(range = c(0,20)) +
        scale_color_manual(values=melted1$color) +
        xlim(-0.2,max(melted1$x)*1.2) +
        ylim(-0.2,max(melted1$y)*1.2) +
        ##ylim(-2,2) +
        themeBlank +
        labs(x=gLabel[1],y=gLabel[2],title=gLabel[3],color=gLabel[4])
    p
    ggsave(paste("fig/audienceComposition",i,".svg",sep=""),width=gWidth,height=gHeight)
}


##install.packages(c('beanplot','vioplot','digest'))
require('beanplot')
require(vioplot)
require(devtools)
require(digest)
##source_gist("https://gist.github.com/mbjoseph/5852613")

plot(x=NULL, y=NULL,xlim = c(0.5, 2.5), ylim=c(min(melted$reach), max(melted$reach)),type="n", ann=FALSE, axes=F)
axis(1, at=c(1, 2),  labels=c("A", "B"))
axis(2)
for (i in unique(melted$Gender)) {
    for (j in unique(melted$variable)){
        vioplot(melted$value[which(melted$Gender == i & melted$variable  == j)],at = ifelse(i == "Female", 1, 2),side = ifelse(j == "Zwoman", "left", "right"),col = ifelse(j == "Zwoman" , "purple", "lightblue"),add = T)
    }
}
title("Violin plot", xlab="Treatment")
legend("bottomright", fill = c("purple", "lightblue"),legend = c("Group 1", "Group 2"), box.lty=0)


labelN <- unique(melted$variable)
plot(x=NULL, y=NULL,xlim = c(0.5, 2.5), ylim=c(min(melted$value), max(melted$value)),type="n", ann=FALSE, axes=F)
axis(1, at=1:length(labelN),  labels=labelN)
axis(2)
for (j in 1:length(labelN)){
    vioplot(melted$value[melted$variable %in% labelN[j]],at=j,side=2,add=TRUE)
}





