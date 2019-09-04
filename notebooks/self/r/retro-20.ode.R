library(deSolve)

library(ggplot2)

rm(list = ls())


###################################################
## eg.1
LVmod <- function(Time, State, Pars) {
  with(as.list(c(State, Pars)), {
    Ingestion <- rIng * Prey * Predator
    GrowthPrey <- rGrow * Prey * (1 - Prey / K)
    MortPredator <- rMort * Predator

    dPrey <- GrowthPrey - Ingestion
    dPredator <- Ingestion * assEff - MortPredator

    return(list(c(dPrey, dPredator)))
  })
}

pars <- c(
  rIng = 0.2, # /day, rate of ingestion
  rGrow = 1.0, # /day, growth rate of prey
  rMort = 0.2, # /day, mortality rate of predator
  assEff = 0.5, # -, assimilation efficiency
  K = 10
) # mmol/m3, carrying capacity

yini <- c(Prey = 1, Predator = 2)
times <- seq(0, 200, by = 1)
out <- ode(yini, times, LVmod, pars)
summary(out)

## Default plot method
plot(out)

## User specified plotting
matplot(out[, 1], out[, 2:3],
  type = "l", xlab = "time", ylab = "Conc",
  main = "Lotka-Volterra", lwd = 2
)
legend("topright", c("prey", "predator"), col = 1:2, lty = 1:2)

###########################################################
## eg.2: logistc 逻辑回归中的转换函数
## Time
t <- seq(0, 100, 1)

## Initial population
N0 <- 10

## Parameter values
params <- list(r = 0.1, K = 1000)

## The logistic equation
fn <- function(t, N, params) with(params, list(r * N * (1 - N / K)))

## Solving and plotin the solution numerically
out <- ode(N0, t, fn, params)
plot(out, lwd = 2, main = "Logistic equation\nr=0.1, K=1000, N0=10")

## Ploting the analytical solution
with(params, lines(t, K * N0 * exp(r * t) / (K + N0 * (exp(r * t) - 1)), col = 2, lwd = 2))


############################################################
## eg.3 流行病学分析，最简单的模型  epidemiological
## SIR model: susceptible, infected, recovered
## closed epidemic
closed.sir.model <- function(t, x, params) {
  ## first extract the state variables
  S <- x[1]
  I <- x[2]
  R <- x[3]
  ## now extract the parameters
  beta <- params["beta"]
  gamma <- params["gamma"]
  ## now code the model equations
  dSdt <- -beta * S * I
  dIdt <- beta * S * I - gamma * I
  dRdt <- gamma * I
  ## combine results into a single vector
  dxdt <- c(dSdt, dIdt, dRdt)
  ## return result as a list!
  list(dxdt)
}

params <- c(beta = 400, gamma = 365 / 13)
times <- seq(from = 0, to = 60 / 365, by = 1 / 365 / 4) # returns a sequence
y0 <- c(S = 0.999, I = 0.001, R = 0.000) # initial conditions

closed.sir.ode <- ode(
  y = y0,
  times = times,
  func = closed.sir.model,
  parms = params
)

# 图像其实是时序图
plot(closed.sir.ode, type = "l")

closed.sir.out <- as.data.frame(closed.sir.ode)
plot(I ~ time, data = closed.sir.out, type = "l")

str(closed.sir.out)



############################################################
## eg.4 基本图像
simple.one.fn <- function(t, y, params) {
  # return(list(-t / y))
  return(list(1 + t - y))
}

simple.one.times <- seq(0, 10, by = .1)
simple.one.y0 <- 10
# simple.one.params <- 0

simple.one.out <- ode(simple.one.y0, simple.one.times, simple.one.fn)
plot(simple.one.out)

summary(simple.one.out)
print(simple.one.out)

simple.one.df <- as.data.frame(simple.one.out)
str(simple.one.df)
simple.one.df$y <- 10

dev.off()
plot( `1` ~ time, data = simple.one.df, type = "l")

print(simple.one.out)

op <- par(mfrow = c(3, 3))

# 初始值不同，对应的曲线就不相同，但是不相交
y0 <- seq(-9, 9, 1)
for (y in y0) {
  print(y)
  out <- as.data.frame(ode(y, simple.one.times, simple.one.fn))

  title <- paste("y0 =", y)

  # plot( `1` ~ time, data = out, type = "l", main = title)

  out$y <- y
  simple.one.df <- rbind(simple.one.df, out)
}

par(op)

dim(simple.one.df)

str(simple.one.df)

colnames(simple.one.df) <- c("time", "value", "y")

library(ggplot2)

ggplot(simple.one.df) +
    geom_line(aes(x = time, y = value, color = factor(y)))



############################################################
## eg.4 基本图像 2
rm(list = ls())

simple.one.fn <- function(x, y, params) {
  yPrime <- x * x + y / x

  # yPrime <- 2*x / (1 + cos(x)) + y*sin(x) / (1 + cos(x))

  return(list(yPrime))
}

simple.one.times <- seq(-4, 4, by = 0.1)

# x = 0 时，fn 没定义，所以要跳过
simple.one.times <- simple.one.times[simple.one.times != 0]
# simple.one.times <- simple.one.times[cos(simple.one.times) > -0.995]

simple.one.y0 <- 10
# simple.one.params <- 0

simple.one.df <- as.data.frame(ode(simple.one.y0, simple.one.times, simple.one.fn))
simple.one.df$y0 <- simple.one.y0

# 初始值不同，对应的曲线就不相同，但是不相交
y_init <- seq(-10, 8, 2)
for (y in y_init) {
  out <- as.data.frame(ode(y, simple.one.times, simple.one.fn))
  out$y0 <- y

  simple.one.df <- rbind(simple.one.df, out)
}

colnames(simple.one.df) <- c("time", "value", "y0")

ggplot(simple.one.df) +
  geom_line(aes(x = time, y = value, color = factor(y0)))



