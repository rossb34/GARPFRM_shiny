
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)
data(crsp.short)
data(managers)

shinyServer(function(input, output) {
  
  ##### Dynamically choose the data #####
  datasetSelect <- reactive({
    switch(input$dataset,
           "Managers" = managers,
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
  
  # combine the risk measures in a data.frame
  performanceMeasures <- reactive({
    input$goButton
    isolate({
      #df <- data.frame()
      df <- NULL
      # compute treynor ratio
      if(input$treynor){
        tmp <- try(TreynorRatio(Ra=assetReturns(), Rb=benchmarkReturns(), Rf=rfr()), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Sharpe Ratio
      if(input$sharpe){
        tmp <- try(SharpeRatio(R=assetReturns(), Rf=rfr(), FUN="StdDev", annualize=input$annualize), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Modified Sharpe
      if(input$modifiedSharpe){
        tmp <- try(SharpeRatio(R=assetReturns(), Rf=rfr(), p=input$p, FUN=input$FUN, annualize=input$annualizeM, method=input$method), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Jensen's alpha
      if(input$jensen){
        tmp <- try(CAPM.jensenAlpha(Ra=assetReturns(), Rb=benchmarkReturns(), Rf=rfr()), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Tracking Error
      if(input$tracking){
        tmp <- try(TrackingError(Ra=assetReturns(), Rb=benchmarkReturns()), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Information Ratio
      if(input$information){
        tmp <- try(InformationRatio(Ra=assetReturns(), Rb=benchmarkReturns()), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      
      # Compute Sortion Ratio
      if(input$sortino){
        tmp <- try(SortinoRatio(R=assetReturns(), MAR=input$MAR), silent=TRUE)
        if(!inherits(x=tmp, what="try-error")){
          df <- rbind(df, tmp)
        }
      }
      df
    })
  })
  
  
  output$measures <- renderPrint({
    performanceMeasures()
  })
  
  output$measuresTable <- renderTable({
    performanceMeasures()
  }, digits=6)
  
  # Asset returns
  output$assetReturns <- renderPrint({
    head(assetReturns())
  })
  
  output$benchmarkReturns <- renderPrint({
    head(benchmarkReturns())
  })
  
  output$rfr <- renderPrint({
    head(rfr())
  })
  
  output$rawData <- renderPrint({
    head(R())
  })
  
})

