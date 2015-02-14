# Portfolio Optimization with PortfolioAnalytics
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
  
  
  portf <- reactive({
    input$goButton
    isolate({
      R <- data()
      n <- ncol(R)
      funds <- colnames(R)
      
      if(input$optimize_method != "ROI"){
        min_sum <- input$weight_sum - 0.01
        max_sum <- input$weight_sum + 0.01
      } else {
        min_sum <- input$weight_sum
        max_sum <- input$weight_sum
      }
      
      init.portf <- portfolio.spec(funds)
      init.portf <- add.constraint(init.portf, "weight_sum", 
                                   min_sum=min_sum, 
                                   max_sum=max_sum)
      if(input$box_enabled){
        init.portf <- add.constraint(init.portf, "box", 
                                     min=input$box[1], 
                                     max=input$box[2])
      }
      if(input$return_enabled){
        init.portf <- add.objective(init.portf, type="return", 
                                    name=input$return_name)
      }
      if(input$risk_enabled){
        init.portf <- add.objective(init.portf, type="risk", 
                                    name=input$risk_name, 
                                    risk_aversion=input$risk_aversion,
                                    arguments=list(p=input$risk_p))
      }
      if(input$risk_budget_enabled){
        init.portf <- add.objective(init.portf, type="risk_budget", 
                                    name=input$risk_budget_name,
                                    arguments=list(p=input$risk_budget_p),
                                    min_prisk=input$prisk[1],
                                    max_prisk=input$prisk[2],
                                    min_concentration=input$min_concentration)
      }
      init.portf
    })
  })
  
  opt <- reactive({
    input$goButton
    isolate({
      optimize.portfolio(R=data(), portfolio=portf(), 
                         optimize_method=input$optimize_method, 
                         search_size=input$search_size, trace=TRUE)
    })
  })
  
  output$portfolio <- renderPrint({
    print(portf())
  })
  
  output$optimization <- renderPrint({
    print(opt())
  })
  
  output$chart.RiskReward <- renderPlot({
    input$goButton
    isolate({
      if(input$risk_enabled){
        risk_col <- input$risk_name
      } else if(input$risk_budget_enabled){
        risk_col <- input$risk_budget_name
      } else {
        risk_col <- "StdDev"
      }
      chart.RiskReward(opt(), return.col=input$return_name, risk.col=risk_col, 
                       chart.assets=TRUE, main="Optimization")
    })
  })
  
  output$chart.Weights <- renderPlot({
    chart.Weights(opt(), main="Optimal Weights")
  })
  
  output$chart.RiskBudget <- renderPlot({
    input$goButton
    isolate({
      if(input$risk_budget_enabled){
        chart.RiskBudget(opt(), neighbors=10, risk.type="percentage", 
                         main="Risk Budget", match.col=input$risk_budget_name)
      }
    })
  })
  
  # Show all available data
  output$rawData <- renderPrint({
    head(data())
  })
  
  
  
})
