
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  titlePanel("Univariate GARCH Model"),
  
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
                  choices = c("Large Cap", "Mid Cap", "Small Cap", "Micro Cap")),
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
      helpText("A univariate dataset must be used to fit the univariate 
               GARCH model. Enter the column number of the data you wish to
               use to fit the GARCH model. See the 'Data' tab to view all
               available data."),
      numericInput("idx", "Select the column of data:", 1, min=1, max=100, step=1),
      
      ##### Parameters for GARCH model
      selectInput("model", "Choose a GARCH Model:", 
                  choices = c("sGARCH", "fGARCH", "eGARCH",
                              "gjrGARCH", "apARCH", "iGARCH",
                              "csGARCH")),
      tags$hr(),
      h6("GARCH Order"),
      numericInput("q", "ARCH(q) order:", 1, min=0, max=10, step=1),
      numericInput("p", "GARCH(p) order:", 1, min=0, max=10, step=1),
      
      tags$hr(),
      h6("ARMA Order"),
      numericInput("ar", "AR order:", 0, min=0, max=10, step=1),
      numericInput("ma", "MA order:", 0, min=0, max=10, step=1),
      
      tags$hr(),
      selectInput("dist", "Choose a distribution:", 
                  choices = c("normal", "skew normal", "student-t",
                              "skew-student", "generalized error", 
                              "skew-generalized error",
                              "normal inverse gaussian", "generalized hyperbolic",
                              "Johnson's SU")),
      tags$hr(),
      helpText("Number of periods before the last period to keep for out of 
               sample forecasting. The number of out of sample points must be
               at least as large as the number of rolling forecasts to create
               beyond the first forecast."),
      numericInput("outSample", "Out of sample points:", 0, min=0, max=1000, step=1),
      
      tags$hr(),
      h5("Forecast Inputs"),
      helpText("A standard n-period ahead forecast is computed based on the 
               unconditional expectation of the GARCH model. A rolling forecast
               is computed by rolling the forecast 1 step at a time by specifying
               the number of rolling forecasts to compute."),
      numericInput("nAhead", "Number of periods ahead to forecast:", 1, min=1, max=1000, step=1),
      numericInput("nRoll", "Number of rolling forecasts:", 0, min=0, max=1000, step=1),
      
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
      h4("GARCH Model"),
      tabsetPanel(
        tabPanel("GARCH Model Spec", verbatimTextOutput("spec")), 
        tabPanel("GARCH Model Fit", verbatimTextOutput("fit")), 
        tabPanel("Table", tableOutput("view")),
        tabPanel("GARCH Model Forecast", verbatimTextOutput("forecast")),
        tabPanel("Data", 
                 h4("Selected Data for GARCH Model (displaying first 6 observations)"),
                 verbatimTextOutput("selectedData"),
                 h4("Available Data (displaying first 6 observations)"),
                 verbatimTextOutput("rawData")
                 )
      )
    )
  )
))

