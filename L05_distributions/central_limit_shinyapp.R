library(shiny)

ui <- fluidPage(
  titlePanel("Central Limit Theorem Demonstration"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dist_type", "Select Distribution:",
                  choices = c("Gamma", "Exponential", "Poisson")),
      numericInput("n_dist", "Number of Distributions (for sampling means):",
                   value = 1000, min = 100, step = 100)
    ),
    mainPanel(
      plotOutput("firstDistPlot"),
      plotOutput("meansDistPlot")
    )
  )
)

server <- function(input, output) {
  
  # Reactive expression to generate the first sample distribution (1000 observations)
  firstSample <- reactive({
    switch(input$dist_type,
           "Gamma"      = rgamma(1000, shape = 2, rate = 1),
           "Exponential" = rexp(1000, rate = 0.5),
           "Poisson"     = rpois(1000, lambda = 3)
    )
  })
  
  # Reactive expression to generate the sample means from many distributions
  meansSample <- reactive({
    n_dist <- input$n_dist
    sample_size <- 100  # fixed sample size for each distribution sample
    means <- switch(input$dist_type,
      "Gamma" = replicate(n_dist, mean(rgamma(sample_size, shape = 2, rate = 1))),
      "Exponential" = replicate(n_dist, mean(rexp(sample_size, rate = 0.5))),
      "Poisson" = replicate(n_dist, mean(rpois(sample_size, lambda = 3)))
    )
    means
  })
  
  # Plot the first distribution sample
  output$firstDistPlot <- renderPlot({
    hist(firstSample(),
         main = paste(input$dist_type, "Distribution"),
         xlab = "Value",
         col = "lightblue", border = "white")
  })
  
  # Plot the distribution of sample means with a normal overlay
  output$meansDistPlot <- renderPlot({
    means <- meansSample()
    hist(means, freq = FALSE,
         main = "Distribution of Sample Means",
         xlab = "Mean Value",
         col = "lightgreen", border = "white")
    # Calculate mean and standard deviation for overlaying normal curve
    mu <- mean(means)
    sigma <- sd(means)
    curve(dnorm(x, mean = mu, sd = sigma), add = TRUE, col = "blue", lwd = 2)
  })
}

shinyApp(ui = ui, server = server)