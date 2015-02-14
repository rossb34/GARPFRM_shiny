
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)
data(crsp.short)

shinyServer(function(input, output) {
  
  ##### Dynamically choose the data #####
  datasetSelect <- reactive({
    switch(input$dataset,
           "Large Cap" = largecap.ts,
           "Mid Cap" = midcap.ts,
           "Small Cap" = smallcap.ts,
           "Micro Cap" = microcap.ts)
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
  
  # get the asset returns to use for Ra
  assetReturns <- reactive({
    if(input$assets == ""){
      out <- colnames(R())
    } else {
      out <- unlist(strsplit(input$assets, " "))
    }
    R()[,out, drop=FALSE]
  })
  
  # get the asset returns to use for Rb
  benchmarkReturns <- reactive({
    if(input$benchmark == ""){
      warning("A benchmark must be specified")
    } else {
      out <- input$benchmark
    }
    R()[,out, drop=FALSE]
  })
  
  # get the asset returns to use for Rf
  rfr <- reactive({
    if(input$rfrCheck){
      if(input$rfr == ""){
        warning("A risk free rate must be specified")
      } else {
        out <- R()[,input$rfr, drop=FALSE]
      }
    } else {
      out <- input$rfrN
    }
    out
  })
  
  # fit data to CAPM
  fitCAPM <- reactive({
    input$goButton
    isolate({
      tmpR <- Return.excess(assetReturns(), rfr())
      colnames(tmpR) <- colnames(assetReturns())
      Rb <- Return.excess(benchmarkReturns(), rfr())
      colnames(Rb) <- colnames(benchmarkReturns())
      CAPM(R=tmpR, Rmkt=Rb)
    })
  })
  
  
  output$fit <- renderPrint({
    fitCAPM()
  })
  
  output$fitTable <- renderTable({
    fitCAPM()
  }, digits=6)
  
  output$alphas <- renderPrint({
    getAlphas(fitCAPM())
  })
  
  output$betas <- renderPrint({
    getBetas(fitCAPM())
  })
  
  output$statistics <- renderPrint({
    getStatistics(fitCAPM())
  })
  
  output$plotCAPM <- renderPlot({
    plot(fitCAPM())
  })
  
  # Asset returns
  output$assetReturns <- renderPrint({
    tmpR <- Return.excess(assetReturns(), rfr())
    colnames(tmpR) <- colnames(assetReturns())
    head(tmpR)
  })
  
  output$benchmarkReturns <- renderPrint({
    Rb <- Return.excess(benchmarkReturns(), rfr())
    colnames(Rb) <- colnames(benchmarkReturns())
    head(Rb)
  })
  
  output$rfr <- renderPrint({
    head(rfr())
  })
  
  output$rawData <- renderPrint({
    head(R())
  })
  
})

