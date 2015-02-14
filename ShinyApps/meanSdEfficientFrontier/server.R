
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(PortfolioAnalytics)

data(edhec)
load("crsp.short.rda")

shinyServer(function(input, output) {
  
  ##### Dynamically choose the data #####
  datasetSelect <- reactive({
    switch(input$dataset,
           "edhec" = edhec[,1:10],
           "largecap" = largecap.ts[,1:10],
           "midcap" = midcap.ts[,1:10],
           "smallcap" = smallcap.ts[,1:10],
           "microcap" = microcap.ts[,1:10])
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
  
  #   R <- reactive({
  #     data()
  #   })
  
  portf <- reactive({
    input$goButton
    isolate({
      R <- data()
      n <- ncol(R)
      funds <- colnames(R)
      
      init.portf <- portfolio.spec(funds)
      init.portf <- add.constraint(init.portf, "weight_sum", min_sum=1, max_sum=1)
      init.portf <- add.constraint(init.portf, "box", min=0, max=1)
      init.portf <- add.objective(init.portf, type="return", name="mean")
      init.portf <- add.objective(init.portf, type="risk", name="StdDev")
      
      # weight_sum constraints
      init.portf$constraints[[1]]$min_sum <- input$weight_sum
      init.portf$constraints[[1]]$max_sum <- input$weight_sum
      
      # box constraints
      init.portf$constraints[[2]]$min <- rep(input$box[1], n)
      init.portf$constraints[[2]]$max <- rep(input$box[2], n)
      init.portf$constraints[[2]]$enabled <- input$box_enabled
      #opt <- optimize.portfolio(R, init.portf, optimize_method="ROI")
      #opt
      ef <- create.EfficientFrontier(R, portfolio=init.portf, 
                                     type="mean-StdDev", 
                                     n.portfolios=input$obs)
      ef
    })
  })
  
  output$portfolio <- renderPrint({
    summary(portf())
  })
  
  output$efPlot <- renderPlot({
    chart.EfficientFrontier(portf(), type="l",
                            match.col="StdDev", 
                            chart.assets=input$chart.assets,
                            tangent.line=input$tangent.line,
                            labels.assets=input$labels.assets,
                            rf=input$rf)
  })
  
  output$efWeightsPlot <- renderPlot({
    chart.Weights.EF(portf(), match.col="StdDev", colorset=bluemono)
  })
  
  # Show all available data
  output$rawData <- renderPrint({
    head(data())
  })
  
  
  
})
