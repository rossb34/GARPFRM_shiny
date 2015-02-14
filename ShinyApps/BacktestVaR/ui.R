
# BacktestVaR App

# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  titlePanel("Value at Risk Backtest"),
  #img(src="cfrm-logo.png", height = 90, width = 481),
  
  #p(a(img(src="cfrm-logo.png", height = 90, width = 481), 
  #  target="_blank", href="http://depts.washington.edu/compfin/")),
  #p(a(img(src="garp_logo_sm.gif", height = 56, width = 422), 
  #  target="_blank", href="http://www.garp.org")),
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
                  choices = c("Large Cap", "Mid Cap", "Small Cap", "Micro Cap")),
      
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
      helpText("A univariate dataset must be used for the VaR backtest.
               Enter the column number of the data you wish to use for the
               VaR backtest. See the 'Data' tab to view all available data."),
      numericInput("idx", "Select the column of data:", 1, min=1, max=100, step=1),
      
      tags$hr(),
      helpText("The moving window specifies the number of periods used for
               estimating VaR."),
      numericInput("window", "Moving window for estimation period:", 150, min=1, max=1000, step=1),
      
      
      helpText("For a return series, VaR is defined as the high quantile 
               (e.g. 95% quantile) of the negative value of the returns. The
               alpha value is calculated as 1 - p."),
      numericInput("p", "Confidence level for calculation:", 0.95, min=0.5, max=1, step=0.01),
      
      # checkboxes for methods
      h6("VaR Estimation Methods"),
      checkboxInput('gaussian', 'Gaussian', TRUE),
      checkboxInput('historical', 'Historical', TRUE),
      checkboxInput('modified', 'Modified', TRUE),
      # checkboxInput('garch', 'GARCH', FALSE),
      
      # Conditional panel display for GARCH model inputs
      #       conditionalPanel(
      #         condition = "input.garch == true",
      #         ##### Parameters for GARCH model
      #         selectInput("model", "Choose a GARCH Model:", 
      #                     choices = c("sGARCH", "fGARCH", "eGARCH",
      #                                 "gjrGARCH", "apARCH", "iGARCH",
      #                                 "csGARCH")),
      #         tags$hr(),
      #         h6("GARCH Order"),
      #         numericInput("q", "ARCH(q) order:", 1, min=0, max=10, step=1),
      #         numericInput("pG", "GARCH(p) order:", 1, min=0, max=10, step=1),
      #         
      #         tags$hr(),
      #         h6("ARMA Order"),
      #         numericInput("ar", "AR order:", 0, min=0, max=10, step=1),
      #         numericInput("ma", "MA order:", 0, min=0, max=10, step=1),
      #         
      #         tags$hr(),
      #         selectInput("dist", "Choose a distribution:", 
      #                     choices = c("normal", "skew normal", "student-t",
      #                                 "skew-student", "generalized error", 
      #                                 "skew-generalized error",
      #                                 "normal inverse gaussian", "generalized hyperbolic",
      #                                 "Johnson's SU")),
      #         tags$hr(),
      #         numericInput("outSample", "Out of sample points:", 0, min=0, max=1000, step=1),
      #         numericInput("refitEvery", "Number of periods to re-estimate the model:", 20, min=1, max=1000, step=1)
      #       ),
      
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
      h4("VaR Backtest"),
      tabsetPanel(
        tabPanel("VaR Backtest Results", 
                 plotOutput("backtestPlot"),
                 verbatimTextOutput("backtest")), 
        tabPanel("VaR Estimates", 
                 h4("VaR Estimates"),
                 verbatimTextOutput("estimates")), 
        tabPanel("VaR Violations", 
                 h4("VaR Violations"),
                 verbatimTextOutput("violations")),
        tabPanel("Data", 
                 h4("Selected Data for VaR Backtest (displaying first 6 observations)"),
                 verbatimTextOutput("selectedData"),
                 h4("Available Data (displaying first 6 observations)"),
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
      ) # tabsetPanel
    ) # mainPanel
  ) # sidebarLayout
))

