
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
  
  methods <- reactive({
    out <- c()
    if(input$gaussian) out <- c(out, "gaussian")
    if(input$historical) out <- c(out, "historical")
    if(input$modified) out <- c(out, "modified")
    out
  })
  #####
  
  ##### Backtest VaR #####
  backtest <- reactive({
    backtestVaR(R=R(), window=input$window, p=input$p, method=methods())
  })
  
  ##### Secify and fit GARCH model #####
#   garchModel <- reactive({
#     model <- switch(input$model,
#                     "sGARCH" = "sGARCH",
#                     "fGARCH" = "fGARCH",
#                     "eGARCH" = "eGARCH",
#                     "apARCH" = "apARCH",
#                     "iGARCH" = "iGARCH",
#                     "csGARCH" = "csGARCH"
#     )
#     
#     # GARCH Order
#     q <- input$q
#     p <- input$pG
#     
#     # ARMA Order
#     ar <- input$ar
#     ma <- input$ma
#     
#     # distribution
#     dist <- switch(input$dist,
#                    "normal" = "norm",
#                    "skew normal" = "snorm",
#                    "student-t" = "std",
#                    "skew-student" = "sstd",
#                    "generalied error" = "ged",
#                    "skew-generalied error" = "sged",
#                    "normal inverse gaussian" = "nig",
#                    "generalized hyperbolic" = "ghyp",
#                    "Johnson's SU" = "jsu"
#     )
#     
#     # outSample
#     outSample <- input$outSample
#     
#     uvGARCH(R=R(), model=model, garchOrder=c(q,p), armaOrder=c(ar, ma), 
#             distribution=dist, outSample=outSample)
#   })
#   
#   ##### GARCH Model VaR Backtest
#   backtestGARCH <- reactive({
#     backtestVaR.GARCH(garch=garchModel(), p=input$p, refitEvery=input$refitEvery, window=input$window)
#   })
  
  #####
  
#   backtestAll <- reactive({
#     bt <- NULL
#     if(length(methods()) == 0){
#       if(input$garch){
#         # we only have GARCH checked as a method
#         bt <- backtestGARCH()
#       }
#     } else if((length(methods())) > 0 & !(input$garch)){
#       # we have at least one method, but no GARCH checked
#       bt <- backtest()
#     } else if((length(methods()) > 0) & (input$garch)){
#       # we have at least one method and GARCH checked
#       bt <- backtest()
#       btEst <- bt$VaR$estimate
#       btVio <- bt$VaR$violation
#       btGARCH <- backtestGARCH()
#       btEstGARCH <- btGARCH$VaR$estimate
#       btVioGARCH <- btGARCH$VaR$violation
#       
#       # combine the colnames (cbind is making ugly column names)
#       cnames <- c(colnames(btEst), colnames(btEstGARCH))
#       
#       bt$VaR$estimate <- na.omit(cbind(btEst, btEstGARCH))
#       colnames(bt$VaR$estimate) <- cnames
#       bt$VaR$violation <- na.omit(cbind(bt$VaR$violation, btGARCH$VaR$violation))
#       colnames(bt$VaR$violation) <- cnames
#     }
#     bt
#   })

backtestAll <- reactive({
  input$goButton
  isolate({
    bt <- NULL
    if(length(methods()) > 0){
      bt <- backtest()
    }
    bt
  })
})
  
  # Show the backtest results
  output$backtest <- renderPrint({
    backtestAll()
  })
  
  # Show the VaR Estimates
  output$estimates <- renderPrint({
    getVaREstimates(backtestAll())
  })
  
  # Show the VaR Violations
  output$violations <- renderPrint({
    getVaRViolations(backtestAll())
  })
  
  # Show the forecast
  output$backtestPlot <- renderPlot({
    input$goButton
    isolate({plot(backtestAll(), pch=18, legendLoc="topright", main=paste(colnames(R()), ": VaR Backtest"))})
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

