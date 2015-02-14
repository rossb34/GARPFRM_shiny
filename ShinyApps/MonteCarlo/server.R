
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(GARPFRM)

shinyServer(function(input, output) {
  
  mc <- reactive({
    input$goButton
    isolate({
      monteCarlo(mu=input$mu, sigma=input$sigma, N=input$N, 
                 time=input$time, steps=input$steps, 
                 starting_value=input$starting_value)
    })
  })
  
  # Plot of each asset price path simulation
  output$mcPlot <- renderPlot({
    plot(mc())
  })
  
  # plot of the ending prices of the simulation
  output$epPlot <- renderPlot({
    plotEndingPrices(mc())
  })
  
  # download the data
  output$downloadData <- downloadHandler(
    filename = function() { "monte_carlo.csv" },
    content = function(file) {
      write.csv(mc(), file)
    }
  )
  
})

