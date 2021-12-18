library(stargazer)
library(ggpubr)
library(mixtools)
library(rsample)
library(bootstrap)
library(nlme)
library(stargazer)
library(ltm)
pnl_m <- read.csv('pnl_naji102_min.csv')
pnl_hr <- read.csv('pnl_naji102_hr.csv')
eth1m <- read.csv("ETHUSDT-1m-binance-imputed.csv")
eth1hr <- read.csv("ETHUSDT-1h-binance-imputed.csv")

cor.test(eth1m$close, eth1m$signal)



set.seed(101)
normal_mix_hr <- normalmixEM(pnl_hr$X0, k=2)
normal_mix_m <- normalmixEM(pnl_m$X0, k=3)

par(mfrow=c(2,2))
plot(normal_mix_hr, density=T, xlab2='Hourly PnL')
plot(normal_mix_m, density=T, xlab2 = 'Minute-wise PnL')


B = 1000 # Number of bootstrap samples
n = length(pnl_hr$X0)
params_hr <- list(mu1b=vector(), 
                  mu2b=vector(), 
                  sigma1b=vector(), 
                  sigma2b=vector(),
                  lambdab=vector())
params_m <- list(mu1b=vector(), 
                 mu2b=vector(), 
                 sigma1b=vector(), 
                 sigma2b=vector(),
                 lambda1b=vector(),
                 lambda2b=vector())

# Bootstrap
for(i in 1:B){
  #print(i)
  dat1 = sample(pnl_hr$X0,rep=T)
  dat2 = sample(pnl_m$X0, rep=T)
  normalmix <- normalmixEM(dat1, k=2, lambda=c(0.99024,(1-0.99024)), fast=FALSE, 
                           maxit=10000, epsilon = 1e-16, maxrestarts=1000)
  normalmix_m <- normalmixEM(dat2, k=3, lambda=c(0.99024,(1-0.99024)), fast=FALSE, 
                             maxit=10000, epsilon = 1e-16, maxrestarts=1000)
  params_hr[[1]][i] = normalmix$mu[1]     
  params_hr[[2]][i] = normalmix$mu[2]   
  params_hr[[3]][i] = normalmix$sigma[1]   
  params_hr[[4]][i] = normalmix$sigma[2]   
  params_hr[[5]][i] = normalmix$lambda[1]  
  
  params_m[[1]][i] = normalmix_m$mu[1]     
  params_m[[2]][i] = normalmix_m$mu[2]   
  params_m[[3]][i] = normalmix_m$sigma[1]   
  params_m[[4]][i] = normalmix_m$sigma[2]   
  params_m[[5]][i] = normalmix_m$lambda[1]
  params_m[[6]][i] = normalmix_m$lambda[2]
}

se.boot_hr <- sapply(params_hr, FUN = function(x) {quantile(x, c(0.025, 0.975))}) 
se.boot_m <- sapply(params_m, FUN = function(x) {quantile(x, c(0.025, 0.975))}) 




mean_hr <- c()
mean_m <- c()

for (i in 1:(B*100)){
  mean_hr[i] <- mean(pnl_hr$X0[sample(1:length(pnl_hr$X0), length(pnl_hr$X0), replace=T)])
  mean_m[i] <- mean(pnl_m$X0[sample(1:length(pnl_m$X0), length(pnl_m$X0), replace=T)])
}

quantile(mean_hr, c(0.025,0.975))
quantile(mean_m, c(0.025,0.975))
