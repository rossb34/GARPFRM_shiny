# Portfolio Optimization with PortfolioAnalytics
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)

shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Portfolio Optimization with PortfolioAnalytics"),
  
  # Sidebar with a slider input for number of observations
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
    
    h3("Constraints"),
    h4("Sum of Weights Constraint"),
    numericInput("weight_sum", 
                 "Sum of weights constraint:", 
                 value=1, 
                 min=0, 
                 max=2, 
                 step=0.01),
    
    h4("Box Constraints"),
    # Box constraints
    checkboxInput('box_enabled', 'Enable Box Constraints', TRUE),
    
    sliderInput("box", 
                "Box Constraints:", 
                min = -1.5, 
                max = 2, 
                value = c(0, 1),
                step=0.05),
    
    h3("Objectives"),
    
    h4("Return Objective"),
    checkboxInput('return_enabled', 'Enable Return Objective', FALSE),
    selectInput("return_name", "Select a Return Objective:", 
                choices = c("mean")),
    numericInput("rb_multiplier", 
                 "Return Multiplier:", 
                 value=-1, 
                 min=-10, 
                 max=0, 
                 step=1),
    
    h4("Risk Objective"),
    checkboxInput('risk_enabled', 'Enable Risk Objective', TRUE),
    selectInput("risk_name", "Select a Risk Objective:", 
                choices = c("StdDev", "VaR", "ES")),
    numericInput("risk_p", 
                 "Confidence Level for VaR and ES Calculation:", 
                 value=0.95, 
                 min=0.5, 
                 max=0.99, 
                 step=0.01),
    numericInput("risk_aversion", 
                 "Risk Aversion Parameter:", 
                 value=1, 
                 min=0, 
                 max=100, 
                 step=0.1),
    helpText("Note: The risk aversion parameter is only used for the quadratic
             utility optimization problem (i.e. when the return objective and 
             risk objective are enabled and ROI is the optimization method)."),
    
    numericInput("risk_multiplier", 
                 "Risk Multiplier:", 
                 value=1, 
                 min=0, 
                 max=10, 
                 step=1),
    
    h4("Risk Budget Objective"),
    helpText("Note: Risk budget objectives cannot be solved with the ROI optimizatio method"),
    checkboxInput('risk_budget_enabled', 'Enable Risk Budget Objective', FALSE),
    selectInput("risk_budget_name", "Select a Risk Budget Objective:", 
                choices = c("StdDev", "VaR", "ES")),
    numericInput("risk_budget_p", 
                 "Confidence Level for VaR and ES Calculation:", 
                 value=0.95, 
                 min=0.5, 
                 max=0.99, 
                 step=0.01),
    sliderInput("prisk", 
                "Percentage Risk:", 
                min = -1, 
                max = 1, 
                value = c(0, 1),
                step=0.05),
    checkboxInput('min_concentration', 'Minimize Concentration', FALSE),
    numericInput("rb_multiplier", 
                 "Risk Budget Multiplier:", 
                 value=1, 
                 min=0, 
                 max=10, 
                 step=1),
    
    h3("Optimization"),
    selectInput("optimize_method", "Select Optimization Method:", 
                choices = c("ROI", "random", "DEoptim", "pso", "GenSA")),
    
    numericInput("search_size", 
                 "Search Size:", 
                 value=2000, 
                 min=1000, 
                 max=10000, 
                 step=1000)
  ),
    
    mainPanel(
      tabsetPanel(
        
        tabPanel("Optimization",
                 # print the optimization output
                 verbatimTextOutput("optimization")
        ),
        
        # plot tab
        tabPanel("Plot",
                 # plot the optimal weights
                 plotOutput("chart.RiskReward"),
                 plotOutput("chart.Weights"),
                 plotOutput("chart.RiskBudget")
        ),
        
        # summary tab
        tabPanel("Portfolio Specification", 
                 # print the portfolio
                 verbatimTextOutput("portfolio")
        ),
        tabPanel("Data", 
                 h4("Input Data (displaying first 6 observations)"),
                 verbatimTextOutput("rawData")
        )
      )
    )
  ))
  