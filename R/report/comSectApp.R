#!/usr/bin/env Rscript
setwd('/home/sabeiro/lav/media/')

source('script/graphEnv.R')
library("igraph")
library("network")
library("sna")
library("ndtv")
library('geomnet')
library(shiny)
library(rCharts)
library(rjson)
library(plotly)
library(d3heatmap)
library(car)


mList <- c("October","November","December","January","February","March","April","May")
mList <- c("July","August","September","October")
fSect <- "section"
isChiara <- FALSE
editorL <- c("rti","ame")
## mList <- "March"
month <- mList[1]
editor <- editorL[1]
NSect <- 40
fLab <- c("total","total","pc masthead","pc box primo","pc box scroll 2","pc box scroll 3","mob masthead","mob box primo","mob box scroll2","mob box scroll3")

source('script/comSectAppLoad.R')
##Panorama auto
##Starbene

## d3heatmap(mSiteGrp, scale = "column",color="Blues")

## bstack <- melt(siteGrp,id="section",value.name="percentage", variable.name="var", na.rm=TRUE)
## bstack$percentage <- sapply(bstack$percentage,function(x) ifelse(x<=0.000001,NA,x))
## bstack <- na.omit(bstack)
## bstack$section <- factor(bstack$section , levels=unique(as.character(siteGrp$section)))
## gLabel = c("\n\ncreatività","format",paste("viewability",month),"percentuale")
## p <- ggplot(bstack,aes(x=section,y=var,z=percentage,group=var)) +
##     geom_tile(aes(fill=percentage),colour="white") +
##     geom_text(aes(fill=percentage,label=round(percentage*100)),colour="white",size=4) +
##     labs(x=gLabel[1],y=gLabel[2],title=gLabel[3]) +
##     scale_fill_gradient(low="white",high="steelblue") +
##     scale_y_discrete(labels=fLab) +
##     theme(
##         axis.text.x = element_text(angle = 30,margin=margin(-10,0,0,0)),
##         panel.background = element_blank()
##     )
## p
## ##plotly
## (gg <- ggplotly(p))
## m <- matrix(bstack$percentage, ncol = length(siteGrp$section),nrow=length(colnames(siteGrp[,-1])))
## plot_ly(z=m,x=siteGrp$section,y=colnames(siteGrp[,-1]),type="heatmap",colorscale="steelblue")

cRamp <- colorRampPalette(c('#FFFFFF','#7cb5ec'))(100)

serverS <- shinyServer(function(input, output, session) {
    ## Highcharts Heat Map
    output$text1 <- renderText({
        paste("You have selected", input$var)
    })
    output$text2 <- renderText({
        paste("You have chosen a range that goes from",input$range[1], "to", input$range[2])
    })
    output$heatmap <- renderChart2({
        map <- Highcharts$new()
        map$chart(zoomType = "x", type = 'heatmap')
        map$credits(text = "dashboard interattiva per mediamond", href = "http://mediamond.it")
        map$title(text='Viewability')
        map$series(name = 'viewability channel',data = toJSONArray2(dat, json=FALSE),color = "#cccccc",
                   dataLabels = list(enabled = TRUE,color = 'black',style = list(textShadow = 'none',HcTextStroke = NULL)))
        map$yAxis(categories = siteGrp$section)
        map$xAxis(categories = fLab,title=list(text = ""))
        ##map$addParams(colorAxis =list(min = input$slider1[0],max=input$slider1[1],minColor='#FFFFFF',maxColor='#7cb5ec'))
        map$addParams(colorAxis =list(min = 0,max=100,minColor='#FFFFFF',maxColor='#7cb5ec'))
        map$legend(align='right',layout='vertical',margin=0,verticalAlign='top',y=25,symbolHeight=320)
                                        # custom tooltip
        map$tooltip(formatter = "#! function() { return '<b>' + this.series.xAxis.categories[this.point.x] + '</b> (format) <br><b>' + this.point.value + '</b> viewability <br><b>' + this.series.yAxis.categories[this.point.y] + '</b>'; } !#")
                                        # set width and height of the plot and attach it to the DOM
        map$addParams(height = 1500, width=1000, dom="heatmap")
                                        # save heatmap as HTML page heatmap.html for debugging
        ##    map$save(destfile = 'heatmap.html')
                                        # print map
        print(map)
    })
})


uiS <- shinyUI(fluidPage(
    tags$head(
        tags$script(src = "https://code.jquery.com/jquery-1.12.0.min.js"),
        tags$script(src = "https://code.highcharts.com/highcharts.js"),
        tags$script(src = "https://code.highcharts.com/highcharts-more.js"),
        tags$script(src = "https://code.highcharts.com/modules/exporting.js"),
        tags$script(src = "https://code.highcharts.com/modules/heatmap.js")
    ),
    titlePanel("Selezione delle property mediamond per metrica",
               img(src="LogoMediamond.png",height=100,height=100)
               ),
    ## sidebarLayout(
    ##     mainPanel(
    ##         textOutput("text1"),
    ##         textOutput("text2")
    ##     ),
    ##     sidebarPanel(
    ##         helpText("Create demographic maps with information from the 2010 US Census.")
    ##     )
    ## ),
    fluidRow(
        column(3,radioButtons("radio", label = h3("Metrics"),choices = list("Viewability" = 1, "Click through rate" = 2,"View through rate" = 3),selected = 1)),
        ##column(3,dateRangeInput("dates", label = h3("Date range"))),
        column(3,checkboxGroupInput("checkGroup",label = h3("Editore"),choices = list("RTI" = 1,"AME" = 2),selected = 1))
    ),
    fluidRow(
        column(3,selectInput("range1", label = h3("Mese"),choices = list("November" = 1, "December" = 2,"January" = 3), selected = 3)),
        column(3,sliderInput("slider1", "",min = 0, max = 100, value = c(25, 75)))
        ## column(3,checkboxGroupInput("checkGroup",label = h3("Checkbox group"),choices = list("Choice 1" = 1,"Choice 2" = 2, "Choice 3" = 3),selected = 1)),
        ## column(3,dateInput("date",label = h3("Date input"),value = "2014-01-01"))
    ),
    ## fluidRow(
    ##     column(3,textInput("text", label = h3("Text input"),value = "Enter text...")),
    ##     column(3,h3("Help text"),helpText(textOutput("text2")))
    ##     ## column(3,dateRangeInput("dates", label = h3("Date range"))),
    ##     ## column(3,fileInput("file", label = h3("File input"))),
    ##     ## column(3,numericInput("num",label = h3("Numeric input"),value = 1))
    ## ),
    ## fluidRow(
    ##     ## column(3,radioButtons("radio", label = h3("Radio buttons"),choices = list("Viewability" = 1, "Ctr" = 2,"BounceRate" = 3),selected = 1)),
    ##     column(3,h3("Buttons"),actionButton("action", label = "Action"),br(),br(),submitButton("Submit"))
    ## ),
    tabsetPanel(tabPanel("Highcharts Heat Map",showOutput("heatmap","highcharts")),
                tabPanel("About",p("This is not really an app, but rather a quick demonstration how to use Highcharts Heat Maps in R Shiny.It uses the ",a(href='http://rcharts.io','rCharts'), " package and the ",a(href='http://www.highcharts.com/demo/heatmap','http://www.highcharts.com/demo/heatmap'),"example."))
                )
))

runApp(list(ui=uiS,server=serverS))





