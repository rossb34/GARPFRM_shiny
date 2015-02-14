
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)
data(crsp_weekly)

# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  
  ##### Dynamically choose the data #####
  datasetSelect <- reactive({
    switch(input$dataset,
           "Large Cap" = largecap_weekly,
           "Mid Cap" = midcap_weekly,
           "Small Cap" = smallcap_weekly,
           "Micro Cap" = microcap_weekly)
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
    data()[,input$idx]
  })
  
  #####
  
  ##### Specify and fit the GARCH model #####
  garchModel <- reactive({
    model <- switch(input$model,
                    "sGARCH" = "sGARCH",
                    "fGARCH" = "fGARCH",
                    "eGARCH" = "eGARCH",
                    "apARCH" = "apARCH",
                    "iGARCH" = "iGARCH",
                    "csGARCH" = "csGARCH"
    )
    
    # GARCH Order
    q <- input$q
    p <- input$p
    
    # ARMA Order
    ar <- input$ar
    ma <- input$ma
    
    # distribution
    dist <- switch(input$dist,
                   "normal" = "norm",
                   "skew normal" = "snorm",
                   "student-t" = "std",
                   "skew-student" = "sstd",
                   "generalied error" = "ged",
                   "skew-generalied error" = "sged",
                   "normal inverse gaussian" = "nig",
                   "generalized hyperbolic" = "ghyp",
                   "Johnson's SU" = "jsu"
    )
    
    # outSample
    outSample <- input$outSample
    
    uvGARCH(R=R(), model=model, garchOrder=c(q,p), armaOrder=c(ar, ma), 
            distribution=dist, outSample=outSample)
  })
  
  #####
  
  out <- reactive({
    input$goButton
    isolate({
      garchModel()
    })
  })
  
  # GARCH forecast
  garchForecast <- reactive({
    forecast(model=out(), nAhead=input$nAhead, nRoll=input$nRoll)
  })
  
  # Show the specified GARCH model
  output$spec <- renderPrint({
    getSpec(out())
  })
  
  # Show the fitted GARCH model
  output$fit <- renderPrint({
    getFit(out())
  })
  
  # Show the conditional sigma, conditional mean, and residuals
  output$view <- renderTable({
    fit <- getFit(out())
    # conditional sigma
    cond.sigma <- sigma(fit)
    # conditional mean
    cond.mean <- fitted(fit)
    res <- residuals(fit)
    df <- data.frame(conditional.sigma=cond.sigma, 
                     conditional.mean=cond.mean,
                     residuals=res)
    df
  }, digits=6)
  
  # Show the forecast
  output$forecast <- renderPrint({
    garchForecast()
  })
  
  # Show all available data
  output$rawData <- renderPrint({
    head(data())
  })
  
  # Show the selected data for univariate case
  output$selectedData <- renderPrint({
    head(R())
  })
  
})

