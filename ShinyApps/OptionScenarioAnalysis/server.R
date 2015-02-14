#Define server logic required
shinyServer(function(input,output){
  
  #The function computes the price of the option
  OptionPrice<-function(K,S,r,div,vol,T,type){  
    # type: enter 1 for call, -1 for put   
    d1=(log(S/K)+(r-div+0.5*vol^2)*T)/(vol*sqrt(T))
    d2=(log(S/K)+(r-div-0.5*vol^2)*T)/(vol*sqrt(T))
    price=type*S*exp(-div*T)*pnorm(type*d1)-type*exp(-r*T)*K*pnorm(type*d2)    
    return(price)
  }
  
  #The function computes the delta of the option
  Delta<-function(K,S,r,div,vol,T,type){   
    # type: enter 1 for call, -1 for put    
    d1=(log(S/K)+(r-div+0.5*vol^2)*T)/(vol*sqrt(T))
    d2=(log(S/K)+(r-div-0.5*vol^2)*T)/(vol*sqrt(T))    
    if(type==1){
      delta=exp(-div*T)*pnorm(d1)
    }else{
      delta=exp(-div*T)*(pnorm(d1)-1)
    }    
    return(delta)
  }
  
  #The function computes the gamma of the option
  Gamma<-function(K,S,r,div,vol,T,type){    
    # type: enter 1 for call, -1 for put    
    d1=(log(S/K)+(r-div+0.5*vol^2)*T)/(vol*sqrt(T))
    d2=(log(S/K)+(r-div-0.5*vol^2)*T)/(vol*sqrt(T))    
    gamma=exp(-div*T)*dnorm(d1)/(vol*S*sqrt(T))    
    return(gamma)
  }
  
  #option inputs
  K_<-reactive({input$K})
  S_<-reactive({input$S})
  r_<-reactive({input$r})
  div_<-reactive({input$div})
  vol_<-reactive({input$vol})
  T_<-reactive({(as.numeric(input$end-input$start))/365})
  
  type_<-reactive({
    if(input$type=="Call"){
      a=1
    }else{a=-1}
    return(a)
  })
  
  #underlying price range and volatility range for four scenarios
  S1_<-reactive({
    S<-S_()
    S*(1+seq(input$S_range1[1],input$S_range1[2],input$S_step1))
  })
  S2_<-reactive({
    S<-S_()
    S*(1+seq(input$S_range2[1],input$S_range2[2],input$S_step2))
  })
  S3_<-reactive({
    S<-S_()
    S*(1+seq(input$S_range3[1],input$S_range3[2],input$S_step3))
  })
  v_<-reactive({
    seq(input$vol_range[1],input$vol_range[2],input$vol_step)
  })
  
  
  #output for scenario 1
  scenario1_<-reactive({
    K<-K_()
    S1<-S1_()
    r<-r_()
    div<-div_()
    vol<-vol_()
    T<-T_()
    type<-type_()
    data<-OptionPrice(K,S1,r,div,vol,T,type)
    return(data)
  })  
  output$plot_1<-renderPlot({
    S1<-S1_()
    scenario1<-scenario1_()
    plot(S1,scenario1,type="b",col="blue",xlab="Underlying Price",
         ylab="Option Price",main="Option Price vs Price of Underlying")
  })
  output$view_1<-renderTable({
    OptionPrice<-scenario1_()
    UnderlyingPrice<-S1_()
    data.frame(OptionPrice,UnderlyingPrice)   
  })
  
  #output for scenario 2
  scenario2_<-reactive({
    K<-K_()
    S2<-S2_()
    r<-r_()
    div<-div_()
    vol<-vol_()
    T<-T_()
    type<-type_()
    data<-Delta(K,S2,r,div,vol,T,type)
    return(data)
  }) 
  output$plot_2<-renderPlot({
    S2<-S2_()
    scenario2<-scenario2_()
    plot(S2,scenario2,type="b",col="blue",xlab="Underlying Price",
         ylab="Option Delta",main="Option Delta vs Price of Underlying")
  })
  output$view_2<-renderTable({
    Delta<-scenario2_()
    UnderlyingPrice<-S2_()
    data.frame(Delta,UnderlyingPrice)   
  })
  
  #output for scenario 3
  scenario3_<-reactive({
    K<-K_()
    S3<-S3_()
    r<-r_()
    div<-div_()
    vol<-vol_()
    T<-T_()
    type<-type_()
    data<-Gamma(K,S3,r,div,vol,T,type)
    return(data)
  }) 
  output$plot_3<-renderPlot({
    S3<-S3_()
    scenario3<-scenario3_()
    plot(S3,scenario3,type="b",col="blue",xlab="Underlying Price",
         ylab="Option Gamma",main="Option Gamma vs Price of Underlying")  
  })
  output$view_3<-renderTable({
    Gamma<-scenario3_()
    UnderlyingPrice<-S3_()
    data.frame(Gamma,UnderlyingPrice)   
  })
  
  #output for scenario 4
  scenario4_<-reactive({
    K<-K_()
    S<-S_()
    r<-r_()
    div<-div_()
    v<-v_()
    T<-T_()
    type<-type_()
    data<-OptionPrice(K,S,r,div,v,T,type)
    return(data)
  }) 
  output$plot_4<-renderPlot({
    v<-v_()
    scenario4<-scenario4_()
    plot(v,scenario4,type="b",col="blue",xlab="Implied Volatility",
         ylab="Option Price",main="Option Price vs Price of Underlying")
  })
  output$view_4<-renderTable({
    OptionPrice<-scenario4_()
    ImpliedVolatility<-v_()
    data.frame(OptionPrice,ImpliedVolatility)   
  })
  
  
})
