library(shiny)

# Define UI for application that plots random distributions 
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Two Asset Efficient Frontier Plot"),
  
  p(a(img(src="cfrm-logo.png", height = 40, width = 304), 
      target="_blank", href="http://depts.washington.edu/compfin/")),
  p(a(img(src="garp_logo_sm.gif", height = 40, width = 304), 
      target="_blank", href="http://www.garp.org")),
  
  # Sidebar with a slider input for number of observations
  sidebarLayout(
    sidebarPanel(
      numericInput("R1", "Expected return of Colonel Motors (C):", 0.14, step=0.005),
      numericInput("R2", "Expected return of Separated Edison (S):", 0.08, step=0.005),
      numericInput("sd1", "Standard deviation of Colonel Motors (C):", 0.06, step=0.005),
      numericInput("sd2", "Standard deviation of Separated Edison (S):", 0.03, step=0.005),
      sliderInput("rho",
                  "Correlation Coefficient:", 
                  min = -1,
                  max = 1, 
                  value = -1,
                  step=0.1,
                  animate=animationOptions(interval=300, loop=F)),
      helpText("Note: This application is based on Chapter 3 of",
               "Financial Risk Manager Part 1: Foundations of Risk Management.")
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      h4("Performance Measures"),
      tabsetPanel(
        tabPanel("Efficient Frontier", 
                 plotOutput("frontierPlot"),
                 
                 h4("Data points along frontier"),
                 verbatimTextOutput("rho_value"),
                 tableOutput("view")),
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
