
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)

shinyServer(function(input, output) {
  
  spec <- reactive({
    input$goButton
    isolate({
      optionSpec(style=input$style, 
                 type=input$type, 
                 S0=input$S0, 
                 K=input$K, 
                 maturity=input$maturity, 
                 r=input$rfr, 
                 volatility=input$vol, 
                 q=input$q)
    })
  })
  
  sol <- reactive({
    input$goButton
    isolate({
      #optimize.portfolio(R=data(), portfolio=portf(), 
      #                   optimize_method=input$optimize_method, 
      #                   search_size=input$search_size, trace=TRUE)
      optionValue(option=spec(), method=input$method, N=input$N)
    })
  })
  
  delta <- reactive({
    input$goButton
    isolate({
      computeGreeks(spec(), greek="delta")
    })
  })
  
  theta <- reactive({
    input$goButton
    isolate({
      computeGreeks(spec(), greek="theta")
    })
  })
  
  gamma <- reactive({
    input$goButton
    isolate({
      computeGreeks(spec(), greek="gamma")
    })
  })
  
  rho <- reactive({
    input$goButton
    isolate({
      computeGreeks(spec(), greek="rho")
    })
  })
  
  vega <- reactive({
    input$goButton
    isolate({
      computeGreeks(spec(), greek="vega")
    })
  })
  
  output$value <- renderPrint({
    sol()
  })
  
  output$delta <- renderPrint({
    delta()
  })
  
  output$theta <- renderPrint({
    theta()
  })
  
  output$gamma <- renderPrint({
    gamma()
  })
  
  output$rho <- renderPrint({
    rho()
  })
  
  output$vega <- renderPrint({
    vega()
  })
  
  output$plotDelta <- renderPlot({
    computeGreeks(option = spec(), 
                  greek = "delta", 
                  prices = seq(input$price_range[1],input$price_range[2], 0.5), 
                  plot = TRUE)
  })
  
  output$plotTheta <- renderPlot({
    computeGreeks(option = spec(), 
                  greek = "theta", 
                  prices = seq(input$price_range[1],input$price_range[2], 0.5), 
                  plot = TRUE)
  })
  
  output$plotGamma <- renderPlot({
    computeGreeks(option = spec(), 
                  greek = "gamma", 
                  prices = seq(input$price_range[1],input$price_range[2], 0.5), 
                  plot = TRUE)
  })
  
  output$plotRho <- renderPlot({
    computeGreeks(option = spec(), 
                  greek = "rho", 
                  prices = seq(input$price_range[1],input$price_range[2], 0.5), 
                  plot = TRUE)
  })
  
  output$plotVega <- renderPlot({
    computeGreeks(option = spec(), 
                  greek = "vega", 
                  prices = seq(input$price_range[1],input$price_range[2], 0.5), 
                  plot = TRUE)
  })
  
})

