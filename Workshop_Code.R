# install.packages(repos = "http://cran.stat.ucla.edu", "car")
library(car)
str(mtcars) # more info: ?mtcars

head(mtcars)

# about the dataset:
dim(mtcars)
colnames(mtcars)

# What are we interested in?
#  "mpg", "cyl", "hp", "wt", "am", "gear"

# we can take a subset of the data:
mtcars_sub <- mtcars[,c("mpg", "cyl", "hp", "wt", "am", "gear")]

# About the data:
summary(mtcars_sub$mpg)
summary(mtcars_sub)

# for discrete attributes:
table(mtcars_sub$cyl)
table(mtcars_sub$gear)
table(mtcars_sub$am)

# We can also create histograms to understand these variables better:
library(ggplot2)
ggplot(mtcars_sub, aes(as.factor(cyl))) + geom_histogram(binwidth = 1)
ggplot(mtcars_sub, aes(as.factor(gear))) + geom_histogram()

# Using R's base plotting package
hist(mtcars_sub$hp, ylim = c(0, 15), col = "darkorange", labels = T, xlab = "Horsepower", main = "Histogram of Horsepower")

# changing "am" to an informative name:
names(mtcars_sub)[names(mtcars_sub) == "am"] <- "ManualTrans"


# two-way freq tables:
table(mtcars_sub$ManualTrans, mtcars_sub$gear)

freqTable <- table(mtcars_sub$ManualTrans, mtcars_sub$gear)
rownames(freqTable) <- c("Automatic", "Manual")
colnames(freqTable) <- paste(3:5, "gears", sep = "-")
freqTable
kable(freqTable)

# mpg for automatic vs. manual
mpgForAutoCars <- mtcars_sub$mpg[mtcars_sub$ManualTrans == 0]
mpgForManuCars <- mtcars_sub$mpg[mtcars_sub$ManualTrans == 1]

# Does that make sense? Manual cars have better MPG than automatic cars!
mean(mpgForAutoCars)
mean(mpgForManuCars)

library(ggplot2)
ggplot(mtcars_sub, aes(as.factor(ManualTrans), mpg)) + geom_boxplot() + xlab("Manual Transmission") 


# what are other related factors to mpg?
# number of Cylinders
tapply(mtcars_sub$mpg, mtcars_sub$cyl, mean)

# Maybe it's better to compare mpg between Auto and Manu for cars with the same # cylinders
mtcars_man <- mtcars_sub[mtcars_sub$ManualTrans == 1,]
mtcars_aut <- mtcars_sub[mtcars_sub$ManualTrans == 0,]
MPG_Man_vs_Aut <- rbind("Manual" = tapply(mtcars_man$mpg, mtcars_man$cyl, mean),
                        "Automatic" =  tapply(mtcars_aut$mpg, mtcars_aut$cyl, mean))
MPG_Man_vs_Aut

# mpg vs. horsepower (scatterplot)
# scatterplot:
ggplot(mtcars_sub, aes(cyl, mpg)) + geom_point() + stat_smooth()
ggplot(mtcars, aes(cyl, mpg)) + geom_point() + stat_smooth(method="lm")


#----------------------
# Some Cool R Charts --
#----------------------
# Interactive Plots (d3 style)
# No need to have any webserver to run them
# Stand-alone html files that you can put in your blog, publish online, ...

# First, We need to install the package from GitHub:
# require(devtools)
# install_github('ramnathv/rCharts@dev')
# install_github('ramnathv/rMaps')
# install.packages("choroplethr")

# slides on: http://ramnathv.github.io/user2014-rcharts/#2

# rCharts: uses lattice style plotting interface

library(rCharts)
library(rMaps)
library(choroplethr)
library(XML)
library(selectr)

#--------------------------
# Interactive Bar-Charts --
#--------------------------
# HairEyeColor table:
str(HairEyeColor)
HairEyeColor
hair_eye_male <- subset(as.data.frame(HairEyeColor), Sex == "Male")
hair_eye_male
n1 <- nPlot(Freq ~ Hair, group = "Eye", data = hair_eye_male, type = "multiBarChart")
n1

# Now suppose I'd like to change the color of the bars to be more informative:
n1$chart(color = c('brown', 'blue', '#594c26', 'green'))
n1

#---------------------
# Interactive Table -- Showing the whole dataset in an interactive way
#---------------------
install.packages(repos = "http://cran.stat.ucla.edu", "MASS")
library(MASS)
dTable(MASS::survey) # here we call survey dataset from the MASS library

# Looking at multiple variables at once!
hPlot(Pulse ~ Height, data = MASS::survey, size = "Age", group = "Exer", type = "bubble", title = "Zoom demo",
      subtitle = "bubble chart")

# to print:
n1$print('iframesrc', include_assets=TRUE)

#-----------------------
# Next: Data Analysis --
#-----------------------

# Reference: http://www.ats.ucla.edu

# Logistic Regression:
# In the logit model the log odds of the outcome is modeled as a linear combination of the predictor variables.
library(aod)
library(ggplot2)

mydata <- read.csv("http://www.ats.ucla.edu/stat/data/binary.csv")
## view the first few rows of the data
head(mydata)
summary(mydata)
sapply(mydata, sd)

## two-way contingency table of categorical outcome and predictors we want
## to make sure there are not 0 cells
xtabs(~admit + rank, data = mydata)

# Using the logit model:

mydata$rank <- factor(mydata$rank)
mylogit <- glm(admit ~ gre + gpa + rank, data = mydata, family = "binomial")
summary(mylogit)
exp(coef(mylogit))

# For every one unit change in gre, the log odds of admission (versus non-admission) increases by 0.002.
# For a one unit increase in gpa, the log odds of being admitted to graduate school increases by 0.804.
# The indicator variables for rank have a slightly different interpretation. For example, having attended an 
# undergraduate institution with rank of 2, versus an institution with a rank of 1, changes the log odds of 
# admission by -0.675.

# We can use the confint function to obtain confidence intervals for the coefficient estimates.
# Note that for logistic models, confidence intervals are based on the profiled log-likelihood function
confint(mylogit)

exp(cbind(OR = coef(mylogit), confint(mylogit)))

# We can test for an overall effect of rank using the wald.test function of the aod library. The order in which the 
# coefficients are given in the table of coefficients is the same as the order of the terms in the model. This is 
# important because the wald.test function refers to the coefficients by their order in the model. We use the wald.test 
# function. b supplies the coefficients, while Sigma supplies the variance covariance matrix of the error terms, 
# finally Terms tells R which terms in the model are to be tested, in this case, terms 4, 5, and 6, are the three 
# terms for the levels of rank.

wald.test(b = coef(mylogit), Sigma = vcov(mylogit), Terms = 4:6)


#  In order to create predicted probabilities we first need to create a new data frame with the values we want the 
# independent variables to take on to create our predictions.
newdata1 <- with(mydata, data.frame(gre = mean(gre), gpa = mean(gpa), rank = factor(1:4)))

newdata1$rankP <- predict(mylogit, newdata = newdata1, type = "response")
newdata1

# In the above output we see that the predicted probability of being accepted into a graduate program is 0.52 for 
# students from the highest prestige undergraduate institutions (rank=1), and 0.18 for students from the lowest 
# ranked institutions (rank=4), holding gre and gpa at their means

newdata2 <- with(mydata, data.frame(gre = rep(seq(from = 200, to = 800, length.out = 100),4), gpa = mean(gpa), 
                                    rank = factor(rep(1:4, each = 100))))

newdata3 <- cbind(newdata2, predict(mylogit, newdata = newdata2, type = "link", se = TRUE))

newdata3 <- within(newdata3, {
  PredictedProb <- plogis(fit)
  LL <- plogis(fit - (1.96 * se.fit))
  UL <- plogis(fit + (1.96 * se.fit))
})

## view first few rows of final dataset
head(newdata3)

# Below we make a plot with the predicted probabilities, and 95% confidence intervals.
ggplot(newdata3, aes(x = gre, y = PredictedProb)) + geom_ribbon(aes(ymin = LL, ymax = UL, fill = rank), alpha = 0.2) + geom_line(aes(colour = rank),size = 1)


#--------------------
# Next: Count Data --
#--------------------
require(ggplot2)
require(sandwich)
require(msm)

# The number of awards earned by students at one high school. Predictors of the number of awards earned include
# the type of program in which the student was enrolled (e.g., vocational, general or academic) and the score on 
# their final exam in math.
p <- read.csv("http://www.ats.ucla.edu/stat/data/poisson_sim.csv")
p <- within(p, {
  prog <- factor(prog, levels=1:3, labels=c("General", "Academic", "Vocational"))
  id <- factor(id)
})
head(p)
summary(p)


with(p, tapply(num_awards, prog, function(x) {
  sprintf("M (SD) = %1.2f (%1.2f)", mean(x), sd(x))
}))

ggplot(p, aes(num_awards, fill = prog)) + geom_histogram(binwidth=.5, position="dodge")

summary(m1 <- glm(num_awards ~ prog + math, family="poisson", data=p))

# Cameron and Trivedi (2009) recommended using robust standard errors for the parameter estimates to control for 
# mild violation of the distribution assumption that the variance equals the mean.

# We use R package sandwich below to obtain the robust standard errors and calculated the p-values accordingly:
cov.m1 <- vcovHC(m1, type="HC0")
std.err <- sqrt(diag(cov.m1))
r.est <- cbind(Estimate= coef(m1), "Robust SE" = std.err,
               "Pr(>|z|)" = 2 * pnorm(abs(coef(m1)/std.err), lower.tail=FALSE),
               LL = coef(m1) - 1.96 * std.err,
               UL = coef(m1) + 1.96 * std.err)

r.est


# Sometimes, we might want to look at the expected marginal means: 
# what are the expected counts for each program type holding math score at its overall mean?
# How to answer this question? predict()
s1 <- data.frame(math = mean(p$math), prog = factor(1:3, levels = 1:3, labels = levels(p$prog)))
s1
predict(m1, s1, type="response", se.fit=F)

## calculate and store predicted values
p$phat <- predict(m1, type="response")

## order by program and then by math
p <- p[with(p, order(prog, math)), ]

## create the plot
ggplot(p, aes(x = math, y = phat, colour = prog)) +
  geom_point(aes(y = num_awards), alpha=.5, position=position_jitter(h=.2)) +
  geom_line(size = 1) +
  labs(x = "Math Score", y = "Expected number of awards")

