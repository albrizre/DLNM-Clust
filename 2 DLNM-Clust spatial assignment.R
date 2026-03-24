library(nimble)
library(sp)
library(sf)
library(spdep)
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

# Set your working directory and follow the structure of the Github repository
# setwd("...")
source("NIMBLE codes/dlnm_Belgium_paper.R")
source("NIMBLE codes/dlnm_basic_NB_cluster.R")
source("NIMBLE codes/dlnm_basic_NB_cluster_sp.R")
source("Functions/RW2.R")

# Data loading. The following datasets can be obtained from https://github.com/Rutten-Sara/Bayesian-DLNM-Air-pollution-and-COVID-19-in-Belgium
# after running file 04_crossbasis_definition.Rmd
load("FinalData/data_prep.rda")
load("FinalData/basis_bc.rda")

# RW2 structure for the time (week-level)
W <- max(data_prep$tot_week_num,na.rm=T)
RW2_W <- RW2(W)

# Load shapefile
grid=readOGR("data/belgium_shape/Apn_AdMu.shp")
grid@data$SpUnit=1:length(grid)
grid_nb=poly2nb(grid,snap=1.5)
grid_WB=nb2WB(grid_nb)

for (nclusters in c(2:7)){
  
  # Define constants
  
  constants <- list(
    
    N = nrow(data_prep),
    X = basis_bc,
    s = data_prep$mcp_id,
    t = data_prep$tot_week_num,
    nareas = length(unique(data_prep$mcp_code)),
    nweeks = length(unique(data_prep$tot_week_num)),
    
    adj_W = RW2_W$adj,                             
    num_W = RW2_W$num,
    weights_W = RW2_W$weights, 
    N_adj_W = length(RW2_W$adj),
    
    adj_grid = grid_WB$adj,                             
    num_grid = grid_WB$num,
    weights_grid = grid_WB$weights,
    N_adj_grid = length(grid_WB$adj),
    
    pop_tot = data_prep$pop_tot
    
  )
  constants$ncov=ncol(constants$X)
  constants$nclusters=nclusters
  constants$mu_0=rep(0,constants$ncov)
  constants$tau_0=diag(0.01,constants$ncov)
  
  # Response and initial values
  
  set.seed(12345)
  data <- list(Y = data_prep$cases_per_week)
  inits <- function() list(alpha_int = 0,
                           beta = matrix(0,nrow=constants$ncov,ncol=constants$nclusters),
                           pr_beta = matrix(rep(1/nclusters, constants$nareas*nclusters), nrow = constants$nareas, ncol = nclusters),
                           z_u = matrix(rep(0, constants$nareas*nclusters), nrow = constants$nareas, ncol = nclusters),
                           z_v = matrix(rep(0, constants$nareas*nclusters), nrow = constants$nareas, ncol = nclusters),
                           z = rep(1,constants$nareas),
                           gamma = rep(0,constants$nweeks),
                           u = rep(0,constants$nareas),
                           v = rep(0,constants$nareas),
                           sigma.zu = rep(2.5,constants$nclusters),
                           sigma.zv = rep(2.5,constants$nclusters),
                           sigma.gamma = 5,
                           sigma.u = 5,
                           sigma.v = 5,
                           r = 1
                           
  )
  
  # Fit the model
  
  model_name="dlnm_basic_NB_cluster_sp"
  Sys.time()
  if (model_name=="dlnm_basic_NB_cluster_sp"){code=dlnm_basic_NB_cluster_sp;area=""}
  mcmc.output <- nimbleMCMC(code, data = data, inits = inits, constants = constants,
                            monitors = c("alpha_int",
                                         "beta",
                                         "z",
                                         "z_u",
                                         "z_v",
                                         "gamma",
                                         "u",
                                         "v",
                                         "sigma.gamma",
                                         "sigma.u",
                                         "sigma.v",
                                         "sigma.zu",
                                         "sigma.zv",
                                         "r",
                                         "lambda"), thin = 10,
                            niter = 80000, nburnin = 40000, nchains = 1, 
                            summary = TRUE, WAIC = TRUE)
  Sys.time()
  save(mcmc.output,file=paste0("Models/",model_name,"_",nclusters,".rda"))

}

