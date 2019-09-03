library(survival)
library(ranger)
library(ggplot2)
library(dplyr)
library(ggfortify)

rm(list = ls())

#------------
data(veteran)
head(veteran)

# Kaplan Meier Survival Curve
km <- with(veteran, Surv(time, status))
head(km, 80)

# fit as a whole
km_fit <- survfit(Surv(time, status) ~ 1, data = veteran)

# The times parameter of the summary() function gives some control over which times to print.
# Here, it is set to print the estimates for 1, 30, 60 and 90 days, and then every 90 days thereafter.
summary(km_fit, times = c(1, 30, 60, 90 * (1:10)))

#plot(km_fit, xlab="Days", main = 'Kaplan Meyer Plot') #base graphics is always ready
autoplot(km_fit)

# Next, we look at survival curves by treatment.
km_trt_fit <- survfit(Surv(time, status) ~ trt, data = veteran)
autoplot(km_trt_fit)

# define new group AG
vet <- mutate(
    veteran,
    AG = ifelse((age < 60), "LT60", "OV60"),
    AG = factor(AG),
    trt = factor(trt, labels = c("standard", "test")),
    prior = factor(prior, labels = c("N0", "Yes"))
)

km_AG_fit <- survfit(Surv(time, status) ~ AG, data = vet)
autoplot(km_AG_fit)

############
# Cox Proportional Hazards Model
# Fit Cox Model
cox <-
    coxph(Surv(time, status) ~ trt + celltype + karno + diagtime + age + prior ,
          data = vet)
summary(cox)
# small cell type, adeno cell type and karno as significant.
# While the Cox Proportional Hazard’s model is thought to be “robust”, a careful analysis would check the assumptions underlying the model.
# the Cox model assumes that the covariates do not vary with time.

cox_fit <- survfit(cox)
#plot(cox_fit, main = "cph model", xlab="Days")
autoplot(cox_fit)

###########
aa_fit <- aareg(Surv(time, status) ~ trt + celltype +
                    karno + diagtime + age + prior ,
                data = vet)
aa_fit

#summary(aa_fit)  # provides a more complete summary of results
autoplot(aa_fit)


#########
# ranger model
r_fit <- ranger(
    Surv(time, status) ~ trt + celltype +
        karno + diagtime + age + prior,
    data = vet,
    mtry = 4,
    importance = "permutation",
    splitrule = "extratrees",
    verbose = TRUE
)

# Average the survival models
death_times <- r_fit$unique.death.times
surv_prob <- data.frame(r_fit$survival)
avg_prob <- sapply(surv_prob, mean)

# Plot the survival models for each patient
plot(
    r_fit$unique.death.times,
    r_fit$survival[1, ],
    type = "l",
    ylim = c(0, 1),
    col = "red",
    xlab = "Days",
    ylab = "survival",
    main = "Patient Survival Curves"
)

#
cols <- colors()
for (n in sample(c(2:dim(vet)[1]), 20)) {
    lines(r_fit$unique.death.times,
          r_fit$survival[n, ],
          type = "l",
          col = cols[n])
}
lines(death_times, avg_prob, lwd = 2)
legend(500, 0.7, legend = c('Average = black'))


#####
vi <-
    data.frame(sort(round(r_fit$variable.importance, 4), decreasing = TRUE))
names(vi) <- "importance"
head(vi)

cat("Prediction Error = 1 - Harrell's c-index = ",
    r_fit$prediction.error)


#############
# Set up for ggplot
kmi <- rep("KM", length(km_fit$time))
km_df <- data.frame(km_fit$time, km_fit$surv, kmi)
names(km_df) <- c("Time", "Surv", "Model")

coxi <- rep("Cox", length(cox_fit$time))
cox_df <- data.frame(cox_fit$time, cox_fit$surv, coxi)
names(cox_df) <- c("Time", "Surv", "Model")

rfi <- rep("RF", length(r_fit$unique.death.times))
rf_df <- data.frame(r_fit$unique.death.times, avg_prob, rfi)
names(rf_df) <- c("Time", "Surv", "Model")

plot_df <- rbind(km_df, cox_df, rf_df)

p <- ggplot(plot_df, aes(x = Time, y = Surv, color = Model))
p + geom_line()
