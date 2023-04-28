# EIR: Event Impact Regression

# check the shapes of some kernel functions
x = 1:100
a1 = 1
a2 = 0.3
a3 = 1.5
a4 = 1

f = function(x) (a1/x)*cos(a2*x + a3)

plot(x, f(x), type = 'l')

################################


a1 = 0.18
a2 = 0.5  # impact peak/permanent impact
a3 = 0
a4 = - 1.0
a5 = 1  # 
a6 = 0
a7 = 0.6 # impact duration

x1 = 1:100
y1 = a1 + (a2*x1^2 + a3*x1 + a4)/exp(a5*exp(log(x1)*a7) + a6)
plot(x1, y1, type = 'l', ylim = c(0,2))

x2 = 25:100
y2 = rep(0, length(y1))
y2[x2] = 1.0 + (0.4*(x2-25)^2 + a3*(x2-25) - 1)/exp(0.9*exp(log(x2-25)*0.7) + 0)

lines(x1, y2, type = 'l', col = 'red')

lines(x1, y1 + y2, type = 'l', col = 'blue', ylim = 3)
