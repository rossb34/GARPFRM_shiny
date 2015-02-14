
# Option Analysis App

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  titlePanel("European Option Analysis"),
  
  p(a(img(src="cfrm-logo.png", height = 40, width = 304), 
      target="_blank", href="http://depts.washington.edu/compfin/")),
  p(a(img(src="garp_logo_sm.gif", height = 40, width = 304), 
      target="_blank", href="http://www.garp.org")),
  
  # Sidebar with controls to select a dataset and specify the number
  # of observations to view. The helpText function is also used to 
  # include clarifying text. Most notably, the inclusion of a 
  # submitButton defers the rendering of output until the user 
  # explicitly clicks the button (rather than doing it immediately
  # when inputs change). This is useful if the computations required
  # to render output are inordinately time-consuming.
  sidebarLayout(
    sidebarPanel(
      h4("Enter inputs below and click 'Run!'"),
      actionButton("goButton", "Run!"),
      tags$hr(),
      
      # style
      # h4("Select a dataset or choose a file to upload"),
      selectInput("style", "Option Style:", 
                  choices = c("european")),
      # type
      # h4("Select a dataset or choose a file to upload"),
      selectInput("type", "Option Type:", 
                  choices = c("call", "put")),
      
      # S0
      # h4("Enter the Underlying Asset Price"),
      numericInput("S0", "Underlying Asset Price:", 100, min=0, max=1000, step=0.5),
      
      # K
      # h4("Strike Price"),
      numericInput("K", "Strike:", 100, min=0, max=1000, step=0.5),
      
      # maturity
      # h4("Time to Maturity"),
      numericInput("maturity", "Time to Maturity:", 1, min=0, max=5, step=0.25),
      
      # risk-free-rate
      # h4("Risk Free Rate"),
      numericInput("rfr", "Risk Free Rate:", 0.01, min=0, max=0.2, step=0.01),
      
      # volatility
      # h4("Volatility"),
      numericInput("vol", "Volatility:", 0.2, min=0, max=1, step=0.05),
      
      # dividend yield
      # h4("Dividend Yield Rate"),
      numericInput("q", "Risk Free Rate:", 0, min=0, max=1, step=0.05),
      
      # stuff to solve the option calculation
      h4("Estimate the Option Value"),
      selectInput("method", "Method to Estimate Option Value:", 
                  choices = c("Black-Scholes")),
      
      sliderInput("price_range","Range of Underlying Asset Price:",
                  min=1,max=500,value=c(50,150),step=1)
      
      #sliderInput("maturity_range","Range of Time to Maturity:",
      #            min=0.01,max=10,value=c(0.01,10),step=0.1)
      
      #numericInput("N", "Number of Steps for Binomial Tree:", 100, min=1, max=1000, step=1)
      
      ),
    
    ##### Display the information
    mainPanel(
      h4("Option Data Output"),
      tabsetPanel(
        tabPanel("Output", 
                 h4("Estimated Option Value"),
                 verbatimTextOutput("value"),
                 h4("delta"),
                 verbatimTextOutput("delta"),
                 h4("theta"),
                 verbatimTextOutput("theta"),
                 h4("gamma"),
                 verbatimTextOutput("gamma"),
                 h4("rho"),
                 verbatimTextOutput("rho"),
                 h4("vega"),
                 verbatimTextOutput("vega")
        ),
        #tabPanel("Greeks", 
        #         h4("delta"),
        #         verbatimTextOutput("delta"),
        #         h4("theta"),
        #         verbatimTextOutput("theta"),
        #         h4("gamma"),
        #         verbatimTextOutput("gamma"),
        #         h4("rho"),
        #         verbatimTextOutput("rho"),
        #         h4("vega"),
        #         verbatimTextOutput("vega")
        #),
        tabPanel("Plot", 
                 h4("The following plots show the greek values
                    as the underlying asset price varies."),
                 plotOutput("plotDelta"),
                 plotOutput("plotTheta"),
                 plotOutput("plotGamma"),
                 plotOutput("plotRho"),
                 plotOutput("plotVega")
        ),
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

