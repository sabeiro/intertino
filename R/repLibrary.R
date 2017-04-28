#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')

Sys.setlocale(category = "LC_ALL", locale = "English_United States.1252")
Sys.setenv(LANG = "en_US.UTF-8")
setAs("character","num.with.commas",function(from) as.numeric(gsub(",", "", from)))
