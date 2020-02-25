#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')

fs <- read.csv('raw/evClick.csv')
head(fs)
fs$Ctr.. <- as.numeric(gsub(",",".",gsub("[[:punct:]]","",fs$Ctr..)))
fs$day <- weekdays(as.Date(fs$Data))

p <- ggplot(fs,aes(x=day,y=Ctr..,fill=day)) +  geom_boxplot()
p





