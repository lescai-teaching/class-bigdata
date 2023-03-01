library(ggplot2)

# Define parameters for each distribution
n <- 20 # number of trials for binomial distribution
m <- 20 # population size for hypergeometric distribution
k <- 5  # number of successes for hypergeometric distribution
lambda <- 5 # expected number of successes for Poisson distribution

# Generate data for each distribution
binomial_data <- data.frame(x = 0:n, y = dbinom(0:n, n, 0.5))
hypergeometric_data <- data.frame(x = 0:n, y = dhyper(0:m, k, m - k, m))
poisson_data <- data.frame(x = 0:n, y = dpois(0:n, lambda))

##### in the code above note the descriptors of the probability function
##### note the difference between k (known) and lambda (expected)

# Plot the distributions using ggplot
ggplot() +
  geom_point(data = binomial_data, aes(x = x, y = y), color = "red") +
  geom_line(data = binomial_data, aes(x = x, y = y), color = "red") +
  geom_point(data = hypergeometric_data, aes(x = x, y = y), color = "blue") +
  geom_line(data = hypergeometric_data, aes(x = x, y = y), color = "blue") +
  geom_point(data = poisson_data, aes(x = x, y = y), color = "green") +
  geom_line(data = poisson_data, aes(x = x, y = y), color = "green") +
  labs(title = "Binomial, Hypergeometric, and Poisson Distributions",
       x = "Number of Successes", y = "Probability") +
  scale_x_continuous(limits = c(0, n)) +
  scale_y_continuous(limits = c(0, max(binomial_data$y, hypergeometric_data$y, poisson_data$y) * 1.2))
