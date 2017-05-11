#!/usr/bin/env Rscript
##setwd('/home/sabeiro/lav/media/')
setwd('C:/users/giovanni.marelli/lav/media/')

source('script/graphEnv.R')
require(data.table)
require(RJSONIO)
library(edgebundleR)
##library(gtools)
library(igraph)
library("d3Network")

Flare <- rjson::fromJSON(file="json/flare.json")
Flare <- rjson::fromJSON(file="json/taxonomyMnoTree.json")
Flare <- rjson::fromJSON(file="json/taxonomyBluekai.json")




## Create Graph

pWidth <- 1400
pHeight <- 1000

d3Tree(List = Flare, fontsize = 8, diameter = 1200,textColour = "#D95F0E", linkColour = "#FEC44F",nodeColour = "#D95F0E",zoom=TRUE,width = pWidth, height = pHeight,file = "vis/d3Network.html")


d3ClusterDendro(List = Flare, zoom = TRUE,width = pWidth, height = pHeight,fontsize = 8, opacity = 0.9,widthCollapse = 0.8,file = "vis/d3Network.html")


EngLinks <- JSONtoDF(file="json/energy.json", array = "links")
EngNodes <- JSONtoDF(file="json/energy.json", array = "nodes")
d3Sankey(Links = EngLinks, Nodes = EngNodes, Source = "source",Target = "target", Value = "value", NodeID = "name",fontsize = 12, nodeWidth = 30,width = pWidth, height = pHeight,file = "vis/d3Network.html")



MisLinks <- JSONtoDF(file = "json/miserables.json", array = "links")
MisNodes <- JSONtoDF(file = "json/miserables.json", array = "nodes")
MisNodes$ID <- 1:nrow(MisNodes)
d3ForceNetwork(Links = MisLinks, Nodes = MisNodes,Source = "source", Target = "target",Value = "value", NodeID = "name",Group = "group", width = pWidth, height = pHeight,opacity = 0.9,file = "vis/d3Network.html")


# Load packages
library(RCurl)
library(d3Network)
library(shiny)

shinyUI(fluidPage(

    # Load D3.js
    tags$head(
        tags$script(src = 'http://d3js.org/d3.v3.min.js')
    ),

    # Application title
    titlePanel('d3Network Shiny Example'),
    p('This is an example of using',
    a(href = 'http://christophergandrud.github.io/d3Network/', 'd3Network'),
        'with',
        a(href = 'http://shiny.rstudio.com/', 'Shiny', 'web apps.')
    ),

    # Sidebar with a slider input for node opacity
    sidebarLayout(
        sidebarPanel(
            sliderInput('slider', label = 'Choose node opacity',
                min = 0, max = 1, step = 0.01, value = 0.5
            )
    ),

    # Show network graph
    mainPanel(
        htmlOutput('networkPlot')
    )
  )
))

#### Shiny ####
shinyServer(function(input, output) {

    output$networkPlot <- renderPrint({
        d3ForceNetwork(Nodes = MisNodes,
                        Links = MisLinks,
                        Source = "source", Target = "target",
                        Value = "value", NodeID = "name",
                        Group = "group", width = 400, height = 500,
                        opacity = input$slider, standAlone = FALSE,
                        parentElement = '#networkPlot')
    })
})



runApp(list(ui=shinyUI,server=shinyServer))


d <- structure(list(ID = c("KP1009", "GP3040", "KP1757", "GP2243",
                           "KP682", "KP1789", "KP1933", "KP1662", "KP1718", "GP3339", "GP4007",
                           "GP3398", "GP6720", "KP808", "KP1154", "KP748", "GP4263", "GP1132",
                           "GP5881", "GP6291", "KP1004", "KP1998", "GP4123", "GP5930", "KP1070",
                           "KP905", "KP579", "KP1100", "KP587", "GP913", "GP4864", "KP1513",
                           "GP5979", "KP730", "KP1412", "KP615", "KP1315", "KP993", "GP1521",
                           "KP1034", "KP651", "GP2876", "GP4715", "GP5056", "GP555", "GP408",
                           "GP4217", "GP641"),
                    Type = c("B", "A", "B", "A", "B", "B", "B",
                             "B", "B", "A", "A", "A", "A", "B", "B", "B", "A", "A", "A", "A",
                             "B", "B", "A", "A", "B", "B", "B", "B", "B", "A", "A", "B", "A",
                             "B", "B", "B", "B", "B", "A", "B", "B", "A", "A", "A", "A", "A",
                             "A", "A"),
                    Set = c(15L, 1L, 10L, 21L, 5L, 9L, 12L, 15L, 16L,
                            19L, 22L, 3L, 12L, 22L, 15L, 25L, 10L, 25L, 12L, 3L, 10L, 8L,
                            8L, 20L, 20L, 19L, 25L, 15L, 6L, 21L, 9L, 5L, 24L, 9L, 20L, 5L,
                            2L, 2L, 11L, 9L, 16L, 10L, 21L, 4L, 1L, 8L, 5L, 11L), Loc = c(3L,
                                                                                          2L, 3L, 1L, 3L, 3L, 3L, 1L, 2L, 1L, 3L, 1L, 1L, 2L, 2L, 1L, 3L,
                                                                                          2L, 2L, 2L, 3L, 2L, 3L, 2L, 1L, 3L, 3L, 3L, 2L, 3L, 1L, 3L, 3L,
                                                                                          1L, 3L, 2L, 3L, 1L, 1L, 1L, 2L, 3L, 3L, 3L, 2L, 2L, 3L, 3L)),
               .Names = c("ID", "Type", "Set", "Loc"), class = "data.frame",
               row.names = c(NA, -48L))

# let's add Loc to our ID
d$key <- d$ID
d$ID <- paste0(d$Loc,".",d$ID)

# Get vertex relationships
sets <- unique(d$Set[duplicated(d$Set)])
rel <-  vector("list", length(sets))
for (i in 1:length(sets)) {
  rel[[i]] <- as.data.frame(t(combn(subset(d, d$Set ==sets[i])$ID, 2)))
}

rel <- rbindlist(rel)

# Get the graph
g <- graph.data.frame(rel, directed=F, vertices=d)
clr <- as.factor(V(g)$Loc)
levels(clr) <- c("salmon", "wheat", "lightskyblue")
V(g)$color <- as.character(clr)
V(g)$size = degree(g)*5
# Plot
plot(g, layout = layout.circle, vertex.label=NA)


edgebundle( g )->eb

eb






