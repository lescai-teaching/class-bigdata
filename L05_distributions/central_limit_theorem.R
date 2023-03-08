library(stats)

set.seed(123)

# Generate a gamma distribution
gamma_dist <- rgamma(1000, shape = 2, rate = 1)

# Generate an exponential distribution
exp_dist <- rexp(1000, rate = 0.5)

# Generate a Poisson distribution
poisson_dist <- rpois(1000, lambda = 3)

par(mfrow = c(1,3), mar = c(2,2,1,1), oma = c(1,1,1,1)) # set up plotting parameters

# Plot the gamma distribution
hist(gamma_dist, main = "Gamma Distribution")

# Plot the exponential distribution
hist(exp_dist, main = "Exponential Distribution")

# Plot the Poisson distribution
hist(poisson_dist, main = "Poisson Distribution")


dev.off()

##### let's scale this up and show what happens 
##### when we get the mean from multiple distributions

set.seed(123)

# Generate 1000 gamma distributions
gamma_dists <- replicate(10000, rgamma(100, shape = 2, rate = 1))

# Calculate the mean of each gamma distribution
means <- apply(gamma_dists, 2, mean)


# Plot the distribution of means
hist(means, main = "Distribution of Means", xlab = "Mean", freq = FALSE, ylim = c(0,3))

# Add a normal distribution to the plot
mu <- mean(means)
sigma <- sd(means)
x <- seq(min(means), max(means), length = 100)
curve(dnorm(x, mean = mu, sd = sigma), add = TRUE, col = "blue", lwd = 2)

