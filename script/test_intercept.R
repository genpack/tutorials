target = function(x) exp(1 + cos(-2*x) - sin(x^2) + log(0.1*x + 5) - 5/(2 + exp(x)))/(1 + exp(-x^3 - 1))

x = 0.1*(0:100)
plot(x, target(x))

a = -1
N =  15
df = data.frame(target(x))
for (i in 1:N){
  df = cbind((x - a)^i, df)
}
df = cbind(df, target(x))
colnames(df) <- c(paste('x', 1:N, sep = '_'), 'y')
fm = as.formula(paste('y ~', paste(paste('x', 1:N, sep = '_'), collapse = ' + ')))

m = lm(fm, data = df)
m$coefficients
(m$residuals^2 %>% mean %>% sqrt)
target(a)


