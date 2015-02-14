
# Mean - Standard Deviation Efficient Frontier

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(fluidPage(
  
  # Application title
  titlePanel("Mean - Standard Deviation Efficient Frontier"),
  
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
      
      ##### UI for data selection
      # Selecte a dataset or choose a file to upload
      h4("Select a dataset or choose a file to upload"),
      
      # choose a data set
      selectInput("dataset", "Choose a dataset:", 
                  choices = c("edhec", "largecap", "midcap", "smallcap", "microcap")),
      tags$hr(),
      # checkbox for header
      checkboxInput('userFile', 'Upload my own data', FALSE),
      
      conditionalPanel(
        condition = "input.userFile == true",
        fileInput('file1', 'Choose file to upload',
                  accept = c(
                    'text/csv',
                    'text/comma-separated-values',
                    'text/tab-separated-values',
                    'text/plain',
                    '.csv',
                    '.tsv'
                  )
        ),
        # checkbox for header
        checkboxInput('header', 'Header', TRUE),
        
        # radio buttons for seperator type
        radioButtons('sep', 'Separator',
                     c(Comma=',',
                       Semicolon=';',
                       Tab='\t'),
                     ','),
        
        # text input for data format
        textInput("format", "Index/time Column Format", value = "%Y-%m-%d")
      ),
      #####
      
      # Number of portfolios to generate along efficient frontier
      numericInput("obs", 
                   "Number of portfolios to generate for efficient frontier:", 
                   value=10, 
                   min=0, 
                   max=100, 
                   step=1),
      
      # Risk free rate
      numericInput("rf", 
                   "Risk free rate:", 
                   value=0, 
                   min=0, 
                   max=0.1, 
                   step=0.001),
      
      # Chart assets in efficient frontier plot?
      checkboxInput('chart.assets', 'Chart Assets', TRUE),
      
      # label.assets
      checkboxInput('labels.assets', 'Assets Names', TRUE),
      
      # tangent.line
      checkboxInput('tangent.line', 'Tangent Line', TRUE),
      
      h4("Constraints"),
      
      numericInput("weight_sum", 
                   "Sum of weights constraint:", 
                   value=1, 
                   min=0, 
                   max=2, 
                   step=0.01),
      
      # Box constraints
      checkboxInput('box_enabled', 'Enable Box Constraints', TRUE),
      
      sliderInput("box", 
                  "Box Constraints:", 
                  min = -1.5, 
                  max = 2, 
                  value = c(0, 1),
                  step=0.05)
      
      # helpText("More constraints to be added")
      
      # Group constraints
      
      # Turnover constraints
      
      # Other constraints?
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tabsetPanel(
        
        # plot tab
        tabPanel("Efficient Frontier Plot",
                 h4("Efficient Frontier Plot"),
                 # plot the efficient frontier
                 plotOutput("efPlot")
        ),
        
        # plot tab
        tabPanel("Weights Plot",
                 h4("Weights along Efficient Frontier"),
                 plotOutput("efWeightsPlot")
        ),
        
        # summary tab
        tabPanel("Summary", 
                 # print the portfolio
                 verbatimTextOutput("portfolio")
                 # print the weight_sum constraint
                 # textOutput("weight_sum"),
                 # print the box constraint
                 # textOutput("box")
        ),
        tabPanel("Data", 
                 h4("Input Data (displaying first 6 observations)"),
                 verbatimTextOutput("rawData")
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
      )
    )
  )
))
