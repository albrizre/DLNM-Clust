library(nimble)
library(sp)
library(sf)
library(maptools)
library(spatstat)
library(ggplot2)
library(ggspatial)
library(RColorBrewer)
library(mgcv)
library(splines)
library(fields)
library(npreg)
library(coda)
library(corrplot)
setwd("G:/Mi unidad/Investigacion/dlnm/COVID-19_Belgium/")
source("dlnm_basic_NB_cluster.R")
source("dlnm_Belgium_paper.R")
source("RW2.R")

# Set your working directory and follow the structure of the Github repository
# setwd("...")

# Define entropy function for a vector of frequencies
log_2 <- function(x){
  y=rep(0,length(x))
  y[x>0]=log(x[x>0],2)
  return(y)
}
entropy <- function(p){
  -sum(p*log_2(p))
}

# data.frames for storing results
df_entropy=c()
df_WAIC=c()
for (nclusters in c(2:7)){
  
  print(nclusters)
  model_name="dlnm_basic_NB_cluster_sp" # Choose model type
  load(paste0("Models/",model_name,"_",nclusters,".rda")) # Load the model
  df_WAIC=rbind(df_WAIC,data.frame(nclusters,WAIC=mcmc.output$WAIC$WAIC))
  
  find_z=grep("z\\[",colnames(mcmc.output$samples))
  z=mcmc.output$samples[,find_z]
  for (j in 1:ncol(z)){
    aux=table(z[,j])
    freqs=rep(0,nclusters)
    names(freqs)=1:nclusters
    freqs[names(aux)]=aux
    df_entropy=rbind(df_entropy,data.frame(nclusters,Obs=j,Entropy=entropy(freqs/nrow(z))))
  }
  
}
plot(df_WAIC$nclusters,df_WAIC$WAIC)
df_entropy$nclusters=paste0("C = ",df_entropy$nclusters)
mean_entropy_data <- aggregate(Entropy ~ nclusters, data = df_entropy, FUN = mean)
