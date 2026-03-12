dlnm_Belgium_paper <- nimbleCode({
  
  alpha_int ~ dnorm(0,sd = 10)
  
  for (i in 1:ncov){
    beta[i] ~ dnorm(0,sd = 10)
  }
  
  for (i in 1:N){
    Y[i] ~ dnegbin(p[i],r)
    p[i] <- r/(r + lambda[i])
    log(lambda[i]) <- alpha_int + log(pop_tot[i]) + inprod(beta[1:ncov],X[i,1:ncov]) + u[s[i]] + v[s[i]] + gamma[t[i]]
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