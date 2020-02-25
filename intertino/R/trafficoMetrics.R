#!/usr/bin/env Rscript
setwd('C:/users/giovanni.marelli.PUBMI2/lav/media/')

source('script/graphEnv.R')
library('corrplot') #package corrplot
require(stats)
require(dplyr)
library(grid)


fs <- read.csv('raw/webtrekkAll.csv')
str(fs)
mfs <- as.data.frame.matrix(fs[,-1])
str(mfs)
iCorr <- cor(fs[,-1])
corrplot.mixed(iCorr,lower="pie",upper="number")

head(fs)



