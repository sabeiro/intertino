timeRef <- data.frame(day=as.Date(1:365,format="%Y-%m-%d",origin="2016-01-01"))
timeRef$week <- format(timeRef$day,"%W")
monday <-ddply(timeRef,.(week),summarise,monday=head(day,1))[-1,]
monday$saturday <- as.Date(monday$monday)+5
set <- match(timeRef$day,monday$monday)
set <- set | match(timeRef$day,monday$monday+1)
set <- set | match(timeRef$day,monday$monday+2)
set <- set | match(timeRef$day,monday$monday+3)
set <- set | match(timeRef$day,monday$monday+4)
set[is.na(set)] <- FALSE
timeRef$working <- set
fs <- read.csv(paste("raw/priceSection",month,".csv",sep=""),stringsAsFactor=FALSE)
fs$Data <- as.Date(fs$Data)
fs <- merge(fs,timeRef,by.x="Data",by.y="day",all.x=TRUE)
unique(fs$DeviceType)
fs[grep("ICON",fs$Channel),"Site"] <- "ICON"

fs[grepl("WEBTV",fs$Publisher),"Publisher"] <- "R T I"

set <- grepl("FEP",fs$Site)
set <- set | grepl("SNACKTV",fs$Site)
set <- set | grepl("LIVE",fs$Site)
fs[set,"Site"] <- "VIDEO MEDIASET"

set <- grepl("CARTOONITO",fs$Site) & grepl("LEADERBOARD",fs$Size)
set <- set | grepl("R101",fs$Site) & grepl("LEADERBOARD",fs$Size)
set <- set | grepl("SKUOLA.NET",fs$Site) & grepl("LEADERBOARD",fs$Size)
fs[set,"Size"] <- "STRIP SKIN MASTHEAD"

formL <- c("RECTANGLE","STRIP SKIN MASTHEAD","APP IPHONE BANNER","APP ANDROID BANNER","APP IPHONE OVERLAYER","APP ANDROID OVERLAYER","APP IPHONE VIDEO","APP ANDROID VIDEO","APP IPAD BANNER","APP TABLET ANDROID BANNER","APP IPAD OVERLAYER","APP TABLET ANDROID OVERLAYER","APP IPAD Video","APP TABLET ANDROID VIDEO")
##formL <- c("RECTANGLE","STRIP SKIN MASTHEAD","OVERLAYER","PROMOBOX","Mobile Splash Page","SPOT","APP ANDROID BANNER","APP ANDROID OVERLAYER","APP IPAD BANNER","APP IPAD OVERLAYER","APP IPHONE BANNER","APP IPHONE OVERLAYER","APP TABLET ANDROID BANNER","APP TABLET ANDROID OVERLAYER","LEADERBOARD","APP ANDROID VIDEO","APP IPAD Video","APP IPHONE VIDEO","APP TABLET ANDROID VIDEO","APP IPAD inpage","SKYSCRAPER","APP ANDROID Background","APP IPHONE Background")
set <- grepl("COMINGSOON",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- set | (grepl("COMINGSOON",fs$Site) & grepl("SKIN",fs$Size))
set <- grepl("METEO",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- grepl("SKUOLA",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- grepl("UNADONNA",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- grepl("MAMMA",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- grepl("VIVA",fs$Site) & grepl("RECTANGLE",fs$Size)
set <- grepl("ISA E CHIA",fs$Site) & grepl("RECTANGLE",fs$Size)
fs[set,"Imps"] <- fs[set,"Imps"]/2

set <- grepl("ISOLA",fs$Site) & grepl("SKIN",fs$Size)
set <- set | (grepl("SPORT",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("IENE",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("STARBENE",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("DONNAMODERNA",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("SORRISI",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("PANORAMA",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("ICON",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("TUSTYLE",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("FOCUS",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("NOSTROFIGLIO",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("SALEPEPE",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("PAPA",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("ROCKOL",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("VIRGIN",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("MONTE",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("RADIO 105",fs$Site) & grepl("SKIN",fs$Size))
set <- set | (grepl("FLAIR",fs$Site) & grepl("SKIN",fs$Size))
fs <- fs[!(set & grepl("Mobile",fs$Site)),]

chL <- ddply(fs[grepl("RECTANGLE",fs$Size),],"Channel",summarise,imps=sum(Imps,na.rm=TRUE))
chL <- chL[chL$imps>500,]

head(chL)
head(fs)

set <- FALSE
for(c in chL[,"Channel"]){set <- set | fs[,"Channel"] %in% c}
cs <- fs[set,]
set <- FALSE
for(f in formL){set <- set | cs[,"Size"] %in% f}
cs <- cs[set,]
head(cs)
##cs$FlightTotalSales <- as.numeric(gsub(",","\\.",cs$FlightTotalSales))
fsTot <- rbind(cs,fs)
