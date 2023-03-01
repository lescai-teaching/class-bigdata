###### ONE DISTRIBUTION ########

set.seed(123) # set seed for reproducibility
n <- 100 # sample size
x <- rnorm(n, mean = 0, sd = 1) # generate random sample from normal distribution
hist(x, freq = FALSE, main = "Normal Probability Density Function and Histogram", xlab = "x", ylab = "Density")
x <- rnorm(10000, mean = 0, sd = 1) # generate very large random sample from normal distribution
curve(dnorm(x, mean = 0, sd = 1), add = TRUE, col = "blue", lwd = 2)


###### FREQ VS DISTRIBUTION 

set.seed(123) # set seed for reproducibility
par(mfrow = c(3,3), mar = c(2,2,1,1), oma = c(1,1,1,1)) # set up plotting parameters
for (n in c(10,100,200,400,600,800,1000,2000,5000)) {
  x <- rnorm(n, mean = 0, sd = 1) # generate random sample from normal distribution
  hist(x, freq = FALSE, main = paste("Sample Size:", n), xlab = "x", ylab = "Density")
  x <- rnorm(100000, mean = 0, sd = 1) # generate very large random sample from normal distribution
  curve(dnorm(x, mean = 0, sd = 1), add = TRUE, col = "blue", lwd = 2)
  n <- n + 100 # increase sample size by 100 for each iteration
}
