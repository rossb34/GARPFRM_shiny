
# EWMA App

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  titlePanel("EWMA Model"),
  
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
      
      ##### UI for data selection
      # Selecte a dataset or choose a file to upload
      h4("Select a dataset or choose a file to upload"),
      
      selectInput("dataset", "Choose a dataset:", 
                  choices = c("ORCL", "MSFT", "HON", "EMC",
                              "Large Cap", "Mid Cap", "Small Cap", "Micro Cap")),
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
      
      textInput("assets", "Name of assets to subset the data", value = ""),
      
      tags$hr(),
      # Dropdown for EWMA model type
      selectInput("type", "Choose statistic to estimate with EWMA model:", 
                  choices = c("volatility", "covariance", "correlation")),
      
      # Compute optimal lambda value or use input value
      helpText("An optimal lambda value can be computed by minimizing
               the mean squared error between the realized value and
               the EWMA model value. Note that a value for lambda
               must be specified for multivariate correlation and
               covariance estimates."),
      checkboxInput('estLambda', 'Estimate lambda from data', FALSE),
      numericInput("lambda", "lambda:", 0.94, min=0, max=1, step=0.01),
      
      # initial window to compute the initial conditions
      helpText("Enter the length of the initial window (no. of periods) used
               to compute the starting values for the EWMA model."),
      numericInput("window", "Initial Window:", 10, min=1, max=1000, step=1),
      
      # Lookback period for computing realized value
      helpText("When computing the optimal value of lambda, n is the number
               of lookback periods used to compute the realized value."),
      numericInput("n", "n periods:", 10, min=1, max=1000, step=1),
      
      helpText("For multivariate data, the EWMA model estimated covariance
               and correlation between two assets can be charted. Enter
               the column names of the two assets, separated by a space, that 
               you wish to chart."),
      
      textInput("plotAssets", "Names of assets to chart", value = ""),
      
      tags$hr(),
      p('If you want a sample .csv file to upload,',
        'you can first download the sample',
        a(href = 'https://dl.dropboxusercontent.com/u/82385044/data/edhec.csv', 'edhec.csv'), 
        'file, and then try uploading the file. The first column must be the column
        where the index/time is stored. The data in the csv file must be in a format
        that can be coerced to an xts object.'
      )
    ),
    
    ##### Display the information
    mainPanel(
      h4("EWMA Model"),
      tabsetPanel(
        tabPanel("EWMA Model", 
                 verbatimTextOutput("model")
                 ),
        tabPanel("EWMA Model Estimate", verbatimTextOutput("est")),
        tabPanel("Plot", plotOutput("plot")),
        tabPanel("Data", 
                 h4("Selected Data for EWMA Model (displaying first 6 observations)"),
                 verbatimTextOutput("selectedData"),
                 h4("Available Data (displaying first 6 observations)"),
                 verbatimTextOutput("rawData")),
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

