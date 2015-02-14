library(shiny)

#' Plot the two asset frontier
#' 
#' @param R1 Expected return of asset 1
#' @param R2 Expected return of asset 2
#' @param sd1 Standard deviation of asset 1
#' @param sd2 sd1 Standard deviation of asset 2
#' @param rho correlation coefficient between asset 1 and asset 2
#' @param weights vector of weights for asset 1. It is assumed
#' @param n_points Number of points to generate for the frontier. Ignored if \code{weights} passed in.
#' @param plot TRUE/FALSE to plot the frontier
#' @param xlim limits on x-axis
#' @param ylim limits on y-axis
#' @param main main title to the plot
#' @param \dots any other passthru parameters
twoAssetFrontier <- function(R1, R2, sd1, sd2, rho, weights=NULL, n_points=20, plot=FALSE, xlim=NULL, ylim=NULL, main="Frontier of Two Asset Portfolio", ...){
  if(is.null(weights)){
    w1 <- seq(from=0, to=1, length.out=n_points)
  } else {
    w1 <- weights
  }
  w2 <- 1 - w1
  port_sd <- vector(mode="numeric", length=length(w1))
  port_return <- vector(mode="numeric", length=length(w1))
  # calculate the portfolio sd and return
  for(i in 1:length(port_sd)){
    port_sd[i] <- sqrt(w1[i]^2 * sd1^2 + 2 * w1[i] * w2[i] * sd1 * sd2 * rho + w2[i]^2 * sd2^2)
    port_return[i] <- w1[i] * R1 + w2[i] * R2
  }
  out <- cbind(port_sd, port_return, w1, w2)
  
  if(plot){
    # set the y limit
    if(is.null(ylim)){
      ylim <- range(port_return)
      ylim[1] <- 0
      ylim[2] <- ylim[2] * 1.25
    }
    # set the x limit
    if(is.null(xlim)){
      xlim <- range(port_sd)
      xlim[1] <- 0
      xlim[2] <- xlim[2] * 1.25
    }
    # Plotting
    plot(x=port_sd, y=port_return, type="l", lwd=2, ylim=ylim, xlim=xlim, ylab=expression(mu[P]), xlab=expression(sigma[P]), main=main, cex.lab=1.75, ...)
    #lines(x=port_sd, y=port_return, lwd=2)
    points(x=sd1, y=R1, col="blue", pch=19)
    text(x=sd1, y=R1, col="blue", pch=19, labels="Colonel Motors", pos=4, cex=1.25)
    points(x=sd2, y=R2, col="red", pch=19)
    text(x=sd2, y=R2, col="red", pch=19, labels="Separated Edison", pos=4, cex=1.25)
    cor_coef <- rho
    legend("topleft", legend=bquote(rho==.(cor_coef)), bty="n", cex=1.5)
    invisible(out)
  } else {
    return(out)
  }
}

# Define server logic required to generate and plot a random distribution
shinyServer(function(input, output) {
  
  # Expression that generates a plot of the distribution. The expression
  # is wrapped in a call to renderPlot to indicate that:
  #
  #  1) It is "reactive" and therefore should be automatically 
  #     re-executed when inputs change
  #  2) Its output type is a plot 
  #
  output$frontierPlot <- renderPlot({
    
    # generate an rnorm distribution and plot it
    #dist <- rnorm(input$obs)
    #hist(dist)
    twoAssetFrontier(R1=input$R1, R2=input$R2, sd1=input$sd1, sd2=input$sd2, rho=input$rho, plot=TRUE)
  })
  
  # correlation coefficient used for plot
  output$rho_value <- renderPrint({
    cat("Correlation Coefficient = ", input$rho, "\n", sep="")
  })
  
  output$view <- renderTable({
    twoAssetFrontier(R1=input$R1, R2=input$R2, sd1=input$sd1, sd2=input$sd2, rho=input$rho, plot=FALSE)
  }, digits=4)
  
})