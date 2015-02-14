
# Monte Carlo App

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Monte Carlo Simulation"),
  
  p(a(img(src="cfrm-logo.png", height = 40, width = 304), 
      target="_blank", href="http://depts.washington.edu/compfin/")),
  p(a(img(src="garp_logo_sm.gif", height = 40, width = 304), 
      target="_blank", href="http://www.garp.org")),
  
  # Sidebar with a slider input for number of observations
  sidebarLayout(
    sidebarPanel(
      h4("Enter inputs below and click 'Run!'"),
      actionButton("goButton", "Run!"),
      tags$hr(),
      
      helpText("Monte Carlo Simulation of an asset price path 
             based on Geometric Brownian Motion"),
      
      # mu
      numericInput("mu", 
                   "Expected Growth Rate:", 
                   min = -1, 
                   max = 1, 
                   value = 0.05,
                   step=0.005),
      # sigma
      numericInput("sigma", 
                   "Annualized standard deviation:", 
                   min = 0, 
                   max = 1, 
                   value = 0.2,
                   step=0.05),
      
      # starting value
      numericInput("starting_value", 
                   "Starting value of asset:", 
                   min = 0, 
                   max = 1000, 
                   value = 10,
                   step=1
      ),
      
      # N
      numericInput("N", 
                   "Number of simulations:", 
                   min = 0, 
                   max = 10000, 
                   value = 1000,
                   step=1000),
      
      # Time
      numericInput("time", 
                   "Time (in years) of simulated asset path:", 
                   min = 0, 
                   max = 10, 
                   value = 1,
                   step=0.25),
      
      # steps
      numericInput("steps", 
                   "Number of time steps:", 
                   min = 0, 
                   max = 1000, 
                   value = 252,
                   step=1),
      
      downloadButton('downloadData', 'Download Data')
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h4("Monte Carlo Simulation"),
      tabsetPanel(
        tabPanel("Plots",
                 plotOutput("mcPlot"),
                 plotOutput("epPlot")),
        tabPanel("About", 
                 p(HTML("The application demonstrates functionality available in the GARP-FRM 
                   R package. The purpose of the this package is to implement the concepts 
                   and methods presented in the Global Association of Risk Professionals 
                   (GARP) Financial Risk Manager (FRM &reg) Part 1 series of books. 
                   Development of the GARP-FRM package is a collaborative project 
                   between the University of Washington Applied Mathematics Department 
                   MS-Degree Program in Computational Finance & Risk Management (MS-CFRM) 
                   and the Global Association of Risk Professionals to provide R 
                   computing applications that facilitate the learning of risk 
                   management concepts.")))
      ) # tabsetPanel
    ) # mainPanel
  ) # sidebarLayout
))

