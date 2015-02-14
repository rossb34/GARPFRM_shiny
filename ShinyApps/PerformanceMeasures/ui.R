
# Performance Measures App

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  titlePanel("Performance Measures"),
  
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
                  choices = c("Managers", "Large Cap", "Mid Cap", 
                              "Small Cap", "Micro Cap")),
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
      
      tags$hr(),
      helpText("Enter the column names separated by a space."),
      
      # Enter the column names of the assets to use for the data
      textInput("assets", "Name of assets to use for asset returns", value = "HAM1 HAM3 HAM4"),
      
      textInput("benchmark", "Name of asset to use for benchmark returns", value = "SP500 TR"),
      
      h4("Risk Free Rate"),
      numericInput("rfrN", "Risk Free Rate:", 0, min=0, max=1, step=0.01),
      
      checkboxInput('rfrCheck', 'Use time series for risk free rate', FALSE),
      conditionalPanel(
        condition = "input.rfrCheck == true",
        textInput("rfr", "Name of assets to use for risk free rate", value = "US 3m TR")
      ),
      
      tags$hr(),
      # Treynor
      h4("Treynor Ratio"),
      checkboxInput('treynor', 'Treynor Ratio', TRUE),
      
      tags$hr(),
      # Sharpe
      h4("Sharpe Ratio"),
      checkboxInput('sharpe', 'Sharpe Ratio', TRUE),
      checkboxInput('annualize', "Annualize returns", FALSE),
      
      tags$hr(),
      # Modified Sharpe
      h4("Modified Sharpe Ratio"),
      checkboxInput('modifiedSharpe', 'Modified Sharpe Ratio', TRUE),
      checkboxInput('annualizeM', "Annualize returns", FALSE),
      selectInput("FUN", "Choose risk measure for modified Sharpe Ratio:", 
                  choices = c("VaR", "ES")),
      selectInput("method", "Choose method to compute the risk measure:", 
                  choices = c("historical", "gaussian", "modified")),
      numericInput("p", "Confidence level for calculation:", 0.95, min=0.5, max=1, step=0.01),
      
      tags$hr(),
      # Jensen's alpha
      h4("Jensen's alpha"),
      checkboxInput('jensen', "Jensen's alpha", TRUE),
      
      tags$hr(),
      # Tracking Error
      h4("Tracking Error"),
      checkboxInput('tracking', 'Tracking Error', TRUE),
      
      tags$hr(),
      # Information Ratio
      h4("Information Ratio"),
      checkboxInput('information', 'Information Ratio', TRUE),
      
      tags$hr(),
      # Sortino Ratio
      h4("Sortino Ratio"),
      checkboxInput('sortino', 'Sortino Ratio', TRUE),
      numericInput("MAR", "Minimum Acceptable Return:", 0, min=-1, max=1, step=0.01),
      
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
      h4("Performance Measures"),
      tabsetPanel(
        tabPanel("Performance Measures", 
                 verbatimTextOutput("measures")
        ),
        tabPanel("Table", 
                 tableOutput("measuresTable")
        ),
        tabPanel("Data", 
                 h4("Asset Returns Data (displaying first 6 observations)"),
                 verbatimTextOutput("assetReturns"),
                 h4("Benchmark Returns Data (displaying first 6 observations)"),
                 verbatimTextOutput("benchmarkReturns"),
                 h4("Risk Free Rate Data (displaying first 6 observations)"),
                 verbatimTextOutput("rfr"),
                 h4("All Available Returns Data (displaying first 6 observations)"),
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

