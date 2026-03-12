dlnm_basic_NB_cluster_sp <- nimbleCode({
  
  for (i in 1:nareas){
    for (k in 1:nclusters){
      pr_beta[i, k] <- Phi[i, k]/sum(Phi[i, 1:nclusters])
      log(Phi[i, k]) <- z_u[i,k] + z_v[i,k]
    }
    z[i] ~ dcat(pr_beta[i,1:nclusters])
  }
  
  # Unstructured spatial effect for cluster assignment
  for (i in 1:nareas) {
    for (k in 1:nclusters){
      z_v[i,k] ~ dnorm(0,sd=sigma.zv[k])
    }
  }
  # Structured spatial effect for cluster assignment
  for (k in 1:nclusters){
    z_u[1:nareas,k] ~ dcar_normal(adj_grid[1:N_adj_grid], weights_grid[1:N_adj_grid], num_grid[1:nareas], 1/sigma.zu[k]^2, zero_mean = 1) 
  }
  for (k in 1:nclusters){
    # sigma.zv[k] ~ dunif(0,5)
    # sigma.zu[k] ~ dunif(0,5)
    sigma.zv[k] ~ T(dnorm(0, sd = 1), 0, )
    sigma.zu[k] ~ T(dnorm(0, sd = 1), 0, )
  }

  alpha_int ~ dnorm(0,sd = 10)
  for (k in 1:nclusters){
    beta[1:ncov,k] ~ dmnorm(mu_0[1:ncov], tau_0[1:ncov, 1:ncov])
  }
  
  for (i in 1:N){
    Y[i] ~ dnegbin(p[i],r)
    p[i] <- r/(r + lambda[i])
    log(lambda[i]) <- alpha_int + log(pop_tot[i]) + inprod(beta[1:ncov,z[s[i]]],X[i,1:ncov]) + u[s[i]] + v[s[i]] + gamma[t[i]]
  }
  r ~ dgamma(0.001,0.001)
  
  # Unstructured spatial effect
  for (i in 1:nareas) {
    v[i] ~ dnorm(0,sd=sigma.v)
  }
  sigma.v ~ dunif(0,10)
  
  # Structured spatial effect
  u[1:nareas] ~ dcar_normal(adj_grid[1:N_adj_grid], weights_grid[1:N_adj_grid], num_grid[1:nareas], 1/sigma.u^2, zero_mean = 1) 
  sigma.u ~ dunif(0,10)
  
  # Structured week effect
  gamma[1:nweeks] ~ dcar_normal(adj_W[1:N_adj_W], weights_W[1:N_adj_W], num_W[1:nweeks], 1/sigma.gamma^2, zero_mean = 1)
  sigma.gamma ~ dunif(0,10)
  
})