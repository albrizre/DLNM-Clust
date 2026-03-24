R codes and files for fitting the models proposed in the paper 'A mixture of distributed lag non-linear models to account for spatially heterogeneous exposure-lag-response associations', by Álvaro Briz-Redón, Ana Corberán-Vallet, Adina Iftimi, and Carmen Íñiguez.

The following main codes are included:

- 1 Replication paper Rutten.R: Allows fitting in NIMBLE the standard DLNM with spatial random effects employed by Rutten et al. (2025) in their paper

  Rutten, S., Espinasse, M., Duarte, E., Neyens, T., & Faes, C. (2025). On the lagged non-linear association between air pollution and COVID-19 cases in Belgium. Spatial and Spatio-temporal Epidemiology, 52, 100709.
- 2 DLNM-Clust non-spatial assignment.R: Allows fitting the DLNM-Clust model proposed in the paper with non-spatial cluster assignment.
- 2 DLNM-Clust spatial assignment.R: Allows fitting the DLNM-Clust model proposed in the paper with spatial cluster assignment.
- 3 Model comparison.R: Allows performing model comparison, including the computation of area-level entropy values to assess the uncertainty in cluster assignment.

`dlnm` package


