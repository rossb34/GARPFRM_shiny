#Define UI for Option Scenario Analysis
shinyUI(pageWithSidebar(
  
  #Application title
  headerPanel("Option Scenario Analysis-Ying Wang"),
  
  #Define the sidebar of the user-interface
  sidebarPanel(
    
    #Define a panel that contains the option inputs
    wellPanel(
      p(strong("Option Inputs")),
      numericInput("S","Underlying Price:",1850,step=0.1),
      numericInput("K","Strike Price:",1650,step=0.1),
      dateInput("start","Value Date:","2014-03-26"),
      dateInput("end","Expiry Date:","2015-03-26"),
      numericInput("vol","Implied Volatility:",0.2,step=0.01),
      numericInput("r","Annual Risk Free Rate:",0.005,step=0.0001),
      numericInput("div","Dividend Yield:",0,step=0.0001),
      selectInput("type","Choose Option type:",
                  choices=c("Call","Put"),
                  selected="Put")
      ),
    
    #Define a panel that contains the scenarios
    wellPanel(
      p(strong("Scenarios")),
      selectInput(inputId="scenario",label="Choose Scenario:",
                  choices=c("Scenario 1-Option Price vs Price of Underlying",
                            "Scenario 2-Option Delta vs Price of Underlying",
                            "Scenario 3-Option Gamma vs Price of Underlying",
                            "Scenario 4-Option Price vs Implied Volatility"),
                  selected="Scenario 1-Option Price vs Price of Underlying"),
      
            
      conditionalPanel(condition="input.scenario=='Scenario 1-Option Price vs Price of Underlying'",
                       sliderInput("S_range1","Range of % Change in Underlying Price:",
                                   min=-0.5,max=0.5,value=c(-0.2,0.2),step=0.01),
                       numericInput("S_step1","Step Size of the Range:",0.05,step=0.001)),
      
      conditionalPanel(condition="input.scenario=='Scenario 2-Option Delta vs Price of Underlying'",
                       sliderInput("S_range2","Range of % Change in Underlying Price:",
                                   min=-0.5,max=0.5,value=c(-0.2,0.2),step=0.01),
                       numericInput("S_step2","Step Size of the Range:",0.05,step=0.001)),
      
      conditionalPanel(condition="input.scenario=='Scenario 3-Option Gamma vs Price of Underlying'",
                       sliderInput("S_range3","Range of % Change in Underlying Price:",
                                   min=-0.5,max=0.5,value=c(-0.2,0.2),step=0.01),
                       numericInput("S_step3","Step Size of the Range:",0.05,step=0.001)),
      
      conditionalPanel(condition="input.scenario=='Scenario 4-Option Price vs Implied Volatility'",
                       sliderInput("vol_range","Range of Implied Volatility:",
                                   min=0.1,max=0.5,value=c(0.15,0.3),step=0.01),
                       numericInput("vol_step","Step Size of the Range:",0.01,step=0.001))
      
      )
  ),
  
  
  
  mainPanel(
    tabsetPanel(
      
      #Define a tab panel that display the plot
      tabPanel("Plot",
               conditionalPanel(condition="input.scenario=='Scenario 1-Option Price vs Price of Underlying'",
                                p(strong("Scenario 1")),
                                plotOutput(outputId="plot_1")
                                ),
               
               conditionalPanel(condition="input.scenario=='Scenario 2-Option Delta vs Price of Underlying'",
                                p(strong("Scenario 2")),
                                plotOutput(outputId="plot_2")
                                ),
               
               conditionalPanel(condition="input.scenario=='Scenario 3-Option Gamma vs Price of Underlying'",
                                p(strong("Scenario 3")),
                                plotOutput(outputId="plot_3")
                                ),
               
               conditionalPanel(condition="input.scenario=='Scenario 4-Option Price vs Implied Volatility'",
                                p(strong("Scenario 4")),
                                plotOutput(outputId="plot_4")
                                )
      ),
      
      #Define a tab panel that displays the data table
      tabPanel("Data Table",
               conditionalPanel(condition="input.scenario=='Scenario 1-Option Price vs Price of Underlying'",
                                        p(strong("Scenario 1")),                                        
                                        tableOutput("view_1")),
               
               conditionalPanel(condition="input.scenario=='Scenario 2-Option Delta vs Price of Underlying'",
                                p(strong("Scenario 2")),                           
                                tableOutput("view_2")),
               
               conditionalPanel(condition="input.scenario=='Scenario 3-Option Gamma vs Price of Underlying'",
                                p(strong("Scenario 3")),
                                tableOutput("view_3")),
               
               conditionalPanel(condition="input.scenario=='Scenario 4-Option Price vs Implied Volatility'",
                                p(strong("Scenario 4")),                                
                                tableOutput("view_4"))
               )
      
      )
    
  )

    
    
)
)
