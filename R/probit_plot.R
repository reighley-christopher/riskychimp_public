##NB: to run this file, open an R console and type: source('~/code/riskybiz/R/probit_plot.R', echo=TRUE)

#We use a trick from a book by 'Data Analysis With Open Source Software' by Philipp K Janert:
#To test whether numerical data fit a particular distribution,
#compute the inverse of the cumulative distribution function (CDF) of that distribution,
#and plot the CDF of the quantiles against the data.

#Import features_digest table into R
fd <- read.csv('/Users/eastagile/code/riskybiz/lib/other/features_digest.csv')

#Let x be the amount column
x=sample_data$amount

#Sort x, and call the result 'dollars'
dollars = sort(x)

#Let n to the number of data points
n=length(dollars)

#Compute the quantiles of the (sorted) data points
percentiles = c(1:n) / (n+1)

#Write down the inverse cumulative distribution for the proposed model
## exponential distribution with parameter lambda
inv_exp = function(t, lambda) { -log(1-t)/lambda }
## Pareto distribution with shape parameter alpha
inv_paret = function(t, min, alpha) { min/(t^(1/alpha)) }

#Compute the sample mean
sample_mean = mean(dollars)

#Compute the sample minimum
sample_lower_bound = min(dollars)

#Compute the sample shape (for Pareto)
sample_shape = sample_mean/(sample_mean-sample_lower_bound)

#If the data are exponential, then the following plot should be near a straight line with slope 1 and intercept 0
#probit_dollars = inv_exp(percentiles, 1/sample_mean)
#plot(dollars, probit_dollars)
#abline(0, 1)
#Exponential is not a great fit, but not terrible either

#If the data are Pareto, then the following plot should be near a straight line with slope 1 and intercept 0
#probit_dollars = inv_paret(percentiles, sample_lower_bound, sample_shape)
#plot(dollars, probit_dollars)
#abline(0, 1)
#You can see that the amounts are definitely not Pareto
