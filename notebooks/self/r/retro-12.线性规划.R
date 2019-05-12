library(lpSolve)

# 例子1
objective.in <- c(25, 20)

const.mat <- matrix(c(20, 12, 1/15, 1/15), nrow=2, byrow=TRUE) 
const.rhs <- c(1800, 8)
const.dir <- c("<=", "<=")

optimum <- lp(direction="max", objective.in, const.mat, const.dir, const.rhs)


# 例子2
f.obj <- c(1, 9, 1)
f.con <- matrix (c(1, 2, 3, 3, 2, 2), nrow=2, byrow=TRUE)
f.dir <- c("<=", "<=")
f.rhs <- c(9, 15)

o <- lp("max", f.obj, f.con, f.dir, f.rhs, compute.sens=TRUE)
o$duals

f.con.d <- matrix (c(rep (1:2,each=3), rep (1:3, 2), t(f.con)), ncol=3)

f.con.d
f.con


# Run again, this time requiring that all three variables be integer
#
oi <- lp ("max", f.obj, f.con, f.dir, f.rhs, int.vec=1:3, compute.sens=TRUE)


# Here􏰁s an example in which we want more than one solution to a problem
# in which all variables are binary: the 8-queens problem,
# with dense constraints.
#
chess.obj <- rep (1, 64)
q8 <- make.q8 ()
chess.dir <- rep (c("=", "<"), c(16, 26))
chess.rhs <- rep (1, 42)
c <- lp("max", chess.obj, , chess.dir, chess.rhs, dense.const=q8, all.bin = TRUE, num.bin.solns = 3)

q8
chess.dir
