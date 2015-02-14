
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)
data(crsp_weekly)
# R <- largecap_weekly[,1:4]

shinyServer(function(input, output) {
  
  ##### Dynamically choose the data #####
  datasetSelect <- reactive({
    switch(input$dataset,
           "ORCL" = largecap_weekly[,"ORCL"],
           "MSFT" = largecap_weekly[,"MSFT"],
           "HON" = largecap_weekly[,"HON"],
           "EMC" = largecap_weekly[,"EMC"],
           "Large Cap" = largecap_weekly[,1:20],
           "Mid Cap" = midcap_weekly[,1:20],
           "Small Cap" = smallcap_weekly[,1:20],
           "Micro Cap" = microcap_weekly[,1:20])
  })
  
  datasetInput <- reactive({
    # input$file1 will be NULL initially. After the user selects
    # and uploads a file, it will be a data frame with 'name',
    # 'size', 'type', and 'datapath' columns. The 'datapath'
    # column will contain the local filenames where the data can
    # be found.
    
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    data <- read.csv(file=inFile$datapath, sep=input$sep, header=input$header, as.is=TRUE)
    data.xts <- xts(data[,-1], as.Date(data[,1], format=input$format))
    #summary(data.xts)
    data.xts
  })
  
  data <- reactive({
    if(input$userFile){
      if(!is.null(datasetInput())){
        data <- datasetInput()
      }
    } else {
      data <- datasetSelect()
    }
  })
  
  R <- reactive({
    data()
  })
  
  assets <- reactive({
    if(input$assets == ""){
      out <- colnames(R())
    } else {
      out <- unlist(strsplit(input$assets, " "))
    }
    out
  })
  
  plotAssets <- reactive({
    if(input$plotAssets == ""){
      out <- colnames(R())
    } else {
      out <- unlist(strsplit(input$plotAssets, " "))
    }
    out
  })
  
  lambda <- reactive({
    if(input$estLambda){
      out <- NULL
    } else {
      out <- input$lambda
    }
    out
  })
  
  ewmaModel <- reactive({
    input$goButton
    isolate({
      EWMA(R=R()[,assets()], lambda=lambda(), initialWindow=input$window, n=input$n, type=input$type)
    })
  })
   
  output$model <- renderPrint({
    ewmaModel()
  })
  
  output$est <- renderPrint({
    getEstimate(ewmaModel())
  })
  
  output$assets <- renderPrint({
    colnames(R())
  })
  
  output$plot <- renderPlot({
    plot(ewmaModel(), assets=plotAssets(), legendLoc="topleft")
  })
  
  # Show all available data
  output$rawData <- renderPrint({
    head(data())
  })
  
  # Show the selected data for univariate case
  output$selectedData <- renderPrint({
    head(R()[,assets()])
  })
  
})

